import 'package:chuspita/core/color/argb_color.dart';
import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/date/local_time.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/analytics/domain/calculate_period_summary.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/export/data/xlsx_financial_exporter.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction_id.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer_id.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds a readable workbook for the selected period', () {
    final startDate = LocalDate(year: 2026, month: 8, day: 1);
    final endDate = LocalDate(year: 2026, month: 8, day: 31);
    final eurWallet = Wallet(
      id: WalletId('wallet-eur'),
      name: 'Travel cash',
      initialBalance: const Money(minorUnits: 10000, currency: Currency.eur),
    );
    final penWallet = Wallet(
      id: WalletId('wallet-pen'),
      name: 'Peru cash',
      initialBalance: const Money(minorUnits: 0, currency: Currency.pen),
    );
    final food = Category(
      id: CategoryId('food'),
      name: 'Food',
      color: ArgbColor(0xFFF28C28),
    );
    final transactions = [
      _transaction(
        id: 'income',
        type: TransactionType.income,
        amount: 10000,
        date: LocalDate(year: 2026, month: 8, day: 1),
      ),
      _transaction(
        id: 'expense',
        type: TransactionType.expense,
        amount: 2550,
        date: LocalDate(year: 2026, month: 8, day: 10),
        time: LocalTime(hour: 13, minute: 45),
        note: 'Lunch',
      ),
      _transaction(
        id: 'outside',
        type: TransactionType.expense,
        amount: 9999,
        date: LocalDate(year: 2026, month: 7, day: 31),
      ),
    ];
    final transfer = Transfer(
      id: TransferId('exchange'),
      sourceWalletId: eurWallet.id,
      destinationWalletId: penWallet.id,
      sourceAmount: const Money(minorUnits: 1000, currency: Currency.eur),
      destinationAmount: const Money(minorUnits: 4000, currency: Currency.pen),
      occurredOn: LocalDate(year: 2026, month: 8, day: 15),
      occurredAt: LocalTime(hour: 9, minute: 30),
      note: 'Exchange',
    );
    final summary = calculatePeriodSummary(
      transactions: transactions,
      startDate: startDate,
      endDate: endDate,
    );

    final file = buildFinancialXlsx(
      summary: summary,
      transactions: transactions,
      transfers: [transfer],
      categories: [food],
      wallets: [eurWallet, penWallet],
    );
    final workbook = Excel.decodeBytes(file.bytes);

    expect(file.fileName, 'chuspita-2026-08-01-to-2026-08-31.xlsx');
    expect(
      file.mimeType,
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
    expect(file.bytes.take(2), [0x50, 0x4B]);
    expect(
      workbook.tables.keys,
      unorderedEquals([
        'Summary',
        'Transactions',
        'Transfers',
        'Categories',
        'Wallets',
      ]),
    );

    final summarySheet = workbook.tables['Summary']!;
    expect(_text(summarySheet, 'A1'), 'Chuspita financial report');
    expect(_text(summarySheet, 'B2'), '2026-08-01');
    expect(_text(summarySheet, 'B3'), '2026-08-31');
    expect(_text(summarySheet, 'A6'), 'EUR');
    expect(_number(summarySheet, 'B6'), 100.0);
    expect(_number(summarySheet, 'C6'), 25.5);
    expect(_number(summarySheet, 'D6'), 74.5);

    final transactionSheet = workbook.tables['Transactions']!;
    expect(transactionSheet.maxRows, 3);
    expect(_text(transactionSheet, 'A2'), 'income');
    expect(_text(transactionSheet, 'A3'), 'expense');
    expect(_text(transactionSheet, 'C3'), '2026-08-10');
    expect(_text(transactionSheet, 'D3'), '13:45');
    expect(_text(transactionSheet, 'E3'), 'Travel cash');
    expect(_text(transactionSheet, 'F3'), 'Food');
    expect(_number(transactionSheet, 'G3'), 25.5);
    expect(_text(transactionSheet, 'I3'), 'Lunch');

    final transferSheet = workbook.tables['Transfers']!;
    expect(transferSheet.maxRows, 2);
    expect(_text(transferSheet, 'A2'), 'exchange');
    expect(_number(transferSheet, 'E2'), 10.0);
    expect(_number(transferSheet, 'H2'), 40.0);
    expect(_number(transferSheet, 'J2'), 4.0);

    final categorySheet = workbook.tables['Categories']!;
    expect(_text(categorySheet, 'B2'), 'Food');
    expect(_text(categorySheet, 'D2'), 'FFF28C28');

    final walletSheet = workbook.tables['Wallets']!;
    expect(walletSheet.maxRows, 3);
    expect(_text(walletSheet, 'B2'), 'Peru cash');
    expect(_text(walletSheet, 'B3'), 'Travel cash');
  });
}

Transaction _transaction({
  required String id,
  required TransactionType type,
  required int amount,
  required LocalDate date,
  LocalTime time = LocalTime.midnight,
  String? note,
}) {
  return Transaction(
    id: TransactionId(id),
    type: type,
    amount: Money(minorUnits: amount, currency: Currency.eur),
    walletId: WalletId('wallet-eur'),
    categoryId: CategoryId('food'),
    occurredOn: date,
    occurredAt: time,
    note: note,
  );
}

String _text(Sheet sheet, String cell) {
  return (sheet.cell(CellIndex.indexByString(cell)).value! as TextCellValue)
      .value
      .toString();
}

num _number(Sheet sheet, String cell) {
  return switch (sheet.cell(CellIndex.indexByString(cell)).value!) {
    IntCellValue(:final value) => value,
    DoubleCellValue(:final value) => value,
    final value => throw StateError('Expected a numeric value, got $value'),
  };
}
