import 'dart:math' as math;

import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/analytics/domain/period_summary.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/export/application/export_file.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:excel/excel.dart';

const _xlsxMimeType =
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

ExportFile buildFinancialXlsx({
  required PeriodSummary summary,
  required Iterable<Transaction> transactions,
  required Iterable<Transfer> transfers,
  required Iterable<Category> categories,
  required Iterable<Wallet> wallets,
}) {
  final workbook = Excel.createExcel();
  final defaultSheet = workbook.getDefaultSheet()!;
  workbook.rename(defaultSheet, 'Summary');

  final categoryValues = categories.toList(growable: false)
    ..sort((first, second) => first.name.compareTo(second.name));
  final walletValues = wallets.toList(growable: false)
    ..sort((first, second) => first.name.compareTo(second.name));
  final categoriesById = <CategoryId, Category>{
    for (final category in categoryValues) category.id: category,
  };
  final walletsById = <WalletId, Wallet>{
    for (final wallet in walletValues) wallet.id: wallet,
  };
  final transactionValues =
      transactions
          .where(
            (transaction) => _isInsidePeriod(
              transaction.occurredOn,
              summary.startDate,
              summary.endDate,
            ),
          )
          .toList(growable: false)
        ..sort(_compareTransactions);
  final transferValues =
      transfers
          .where(
            (transfer) => _isInsidePeriod(
              transfer.occurredOn,
              summary.startDate,
              summary.endDate,
            ),
          )
          .toList(growable: false)
        ..sort(_compareTransfers);

  _buildSummarySheet(workbook, summary);
  _buildTransactionSheet(
    workbook,
    transactionValues,
    walletsById,
    categoriesById,
  );
  _buildTransferSheet(workbook, transferValues, walletsById);
  _buildCategorySheet(workbook, categoryValues);
  _buildWalletSheet(workbook, walletValues);
  workbook.setDefaultSheet('Summary');

  final bytes = workbook.encode();

  if (bytes == null || bytes.isEmpty) {
    throw StateError('The XLSX workbook could not be encoded');
  }

  return ExportFile(
    fileName: 'chuspita-${summary.startDate}-to-${summary.endDate}.xlsx',
    mimeType: _xlsxMimeType,
    bytes: bytes,
  );
}

void _buildSummarySheet(Excel workbook, PeriodSummary summary) {
  final sheet = workbook['Summary'];
  sheet.appendRow([TextCellValue('Chuspita financial report')]);
  sheet.appendRow([
    TextCellValue('Period start'),
    TextCellValue(summary.startDate.toString()),
  ]);
  sheet.appendRow([
    TextCellValue('Period end'),
    TextCellValue(summary.endDate.toString()),
  ]);
  sheet.appendRow([TextCellValue('')]);
  _appendHeader(sheet, const [
    'Currency',
    'Income',
    'Expenses',
    'Net',
    'Expense count',
    'Average expense',
    'Largest expense',
  ]);

  final summaries = summary.byCurrency.values.toList(growable: false)
    ..sort(
      (first, second) => first.currency.code.compareTo(second.currency.code),
    );

  for (final currencySummary in summaries) {
    sheet.appendRow([
      TextCellValue(currencySummary.currency.code),
      _moneyCell(currencySummary.income),
      _moneyCell(currencySummary.expenses),
      _moneyCell(currencySummary.net),
      IntCellValue(currencySummary.expenseCount),
      _moneyCell(currencySummary.averageExpense),
      _moneyCell(currencySummary.largestExpense),
    ]);
  }

  _autoFit(sheet, 7);
}

void _buildTransactionSheet(
  Excel workbook,
  List<Transaction> transactions,
  Map<WalletId, Wallet> walletsById,
  Map<CategoryId, Category> categoriesById,
) {
  final sheet = workbook['Transactions'];
  _appendHeader(sheet, const [
    'ID',
    'Type',
    'Date',
    'Time',
    'Wallet',
    'Category',
    'Amount',
    'Currency',
    'Note',
  ]);

  for (final transaction in transactions) {
    sheet.appendRow([
      TextCellValue(transaction.id.value),
      TextCellValue(transaction.type.name),
      TextCellValue(transaction.occurredOn.toString()),
      TextCellValue(transaction.occurredAt.toString()),
      TextCellValue(
        walletsById[transaction.walletId]?.name ?? transaction.walletId.value,
      ),
      TextCellValue(
        categoriesById[transaction.categoryId]?.name ??
            transaction.categoryId.value,
      ),
      _moneyCell(transaction.amount),
      TextCellValue(transaction.amount.currency.code),
      TextCellValue(transaction.note ?? ''),
    ]);
  }

  _autoFit(sheet, 9);
}

void _buildTransferSheet(
  Excel workbook,
  List<Transfer> transfers,
  Map<WalletId, Wallet> walletsById,
) {
  final sheet = workbook['Transfers'];
  _appendHeader(sheet, const [
    'ID',
    'Date',
    'Time',
    'Source wallet',
    'Source amount',
    'Source currency',
    'Destination wallet',
    'Destination amount',
    'Destination currency',
    'Conversion factor',
    'Note',
  ]);

  for (final transfer in transfers) {
    sheet.appendRow([
      TextCellValue(transfer.id.value),
      TextCellValue(transfer.occurredOn.toString()),
      TextCellValue(transfer.occurredAt.toString()),
      TextCellValue(
        walletsById[transfer.sourceWalletId]?.name ??
            transfer.sourceWalletId.value,
      ),
      _moneyCell(transfer.sourceAmount),
      TextCellValue(transfer.sourceAmount.currency.code),
      TextCellValue(
        walletsById[transfer.destinationWalletId]?.name ??
            transfer.destinationWalletId.value,
      ),
      _moneyCell(transfer.destinationAmount),
      TextCellValue(transfer.destinationAmount.currency.code),
      DoubleCellValue(_conversionFactor(transfer)),
      TextCellValue(transfer.note ?? ''),
    ]);
  }

  _autoFit(sheet, 11);
}

void _buildCategorySheet(Excel workbook, List<Category> categories) {
  final sheet = workbook['Categories'];
  _appendHeader(sheet, const [
    'ID',
    'Name',
    'Applicability',
    'ARGB color',
    'Archived',
  ]);

  for (final category in categories) {
    sheet.appendRow([
      TextCellValue(category.id.value),
      TextCellValue(category.name),
      TextCellValue(category.applicability.name),
      TextCellValue(
        category.color.value.toRadixString(16).padLeft(8, '0').toUpperCase(),
      ),
      BoolCellValue(category.isArchived),
    ]);
  }

  _autoFit(sheet, 5);
}

void _buildWalletSheet(Excel workbook, List<Wallet> wallets) {
  final sheet = workbook['Wallets'];
  _appendHeader(sheet, const [
    'ID',
    'Name',
    'Currency',
    'Initial balance',
    'Archived',
  ]);

  for (final wallet in wallets) {
    sheet.appendRow([
      TextCellValue(wallet.id.value),
      TextCellValue(wallet.name),
      TextCellValue(wallet.currency.code),
      _moneyCell(wallet.initialBalance),
      BoolCellValue(wallet.isArchived),
    ]);
  }

  _autoFit(sheet, 5);
}

void _appendHeader(Sheet sheet, List<String> labels) {
  final rowIndex = sheet.maxRows;
  sheet.appendRow([for (final label in labels) TextCellValue(label)]);
  final style = CellStyle(
    bold: true,
    fontColorHex: ExcelColor.white,
    backgroundColorHex: ExcelColor.deepPurple,
  );

  for (var column = 0; column < labels.length; column++) {
    sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: column,
                rowIndex: rowIndex,
              ),
            )
            .cellStyle =
        style;
  }
}

void _autoFit(Sheet sheet, int columnCount) {
  for (var column = 0; column < columnCount; column++) {
    sheet.setColumnAutoFit(column);
  }
}

CellValue _moneyCell(Money money) {
  if (money.currency.minorUnitDigits == 0) {
    return IntCellValue(money.minorUnits);
  }

  final divisor = math.pow(10, money.currency.minorUnitDigits);
  return DoubleCellValue(money.minorUnits / divisor);
}

double _conversionFactor(Transfer transfer) {
  return _moneyAsDouble(transfer.destinationAmount) /
      _moneyAsDouble(transfer.sourceAmount);
}

double _moneyAsDouble(Money money) {
  return money.minorUnits / math.pow(10, money.currency.minorUnitDigits);
}

bool _isInsidePeriod(LocalDate date, LocalDate startDate, LocalDate endDate) {
  return date.compareTo(startDate) >= 0 && date.compareTo(endDate) <= 0;
}

int _compareTransactions(Transaction first, Transaction second) {
  final date = first.occurredOn.compareTo(second.occurredOn);
  final time = first.occurredAt.compareTo(second.occurredAt);

  return date != 0
      ? date
      : time != 0
      ? time
      : first.id.value.compareTo(second.id.value);
}

int _compareTransfers(Transfer first, Transfer second) {
  final date = first.occurredOn.compareTo(second.occurredOn);
  final time = first.occurredAt.compareTo(second.occurredAt);

  return date != 0
      ? date
      : time != 0
      ? time
      : first.id.value.compareTo(second.id.value);
}
