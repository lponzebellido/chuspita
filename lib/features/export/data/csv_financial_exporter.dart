import 'dart:convert';
import 'dart:math' as math;

import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/date/local_time.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/analytics/domain/period_summary.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/export/application/export_file.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';

const _csvMimeType = 'text/csv';
const _utf8ByteOrderMark = [0xEF, 0xBB, 0xBF];

ExportFile buildFinancialCsv({
  required PeriodSummary summary,
  required Iterable<Transaction> transactions,
  required Iterable<Transfer> transfers,
  required Iterable<Category> categories,
  required Iterable<Wallet> wallets,
}) {
  final categoriesById = <CategoryId, Category>{
    for (final category in categories) category.id: category,
  };
  final walletsById = <WalletId, Wallet>{
    for (final wallet in wallets) wallet.id: wallet,
  };
  final rows = <_CsvMovementRow>[
    for (final transaction in transactions)
      if (_isInsidePeriod(
        transaction.occurredOn,
        summary.startDate,
        summary.endDate,
      ))
        _transactionRow(transaction, walletsById, categoriesById),
    for (final transfer in transfers)
      if (_isInsidePeriod(
        transfer.occurredOn,
        summary.startDate,
        summary.endDate,
      ))
        _transferRow(transfer, walletsById),
  ]..sort(_compareRows);

  final csvRows = <List<String>>[
    const [
      'ID',
      'Type',
      'Date',
      'Time',
      'Wallet',
      'Destination wallet',
      'Category',
      'Amount',
      'Currency',
      'Destination amount',
      'Destination currency',
      'Conversion factor',
      'Note',
    ],
    for (final row in rows) row.values,
  ];
  final contents = csvRows
      .map((row) => row.map(_escapeCsvField).join(','))
      .join('\r\n');

  return ExportFile(
    fileName:
        'chuspita-movements-${summary.startDate}-to-${summary.endDate}.csv',
    mimeType: _csvMimeType,
    bytes: [..._utf8ByteOrderMark, ...utf8.encode('$contents\r\n')],
  );
}

_CsvMovementRow _transactionRow(
  Transaction transaction,
  Map<WalletId, Wallet> walletsById,
  Map<CategoryId, Category> categoriesById,
) {
  return _CsvMovementRow(
    id: transaction.id.value,
    date: transaction.occurredOn,
    time: transaction.occurredAt,
    values: [
      transaction.id.value,
      transaction.type.name,
      transaction.occurredOn.toString(),
      transaction.occurredAt.toString(),
      walletsById[transaction.walletId]?.name ?? transaction.walletId.value,
      '',
      categoriesById[transaction.categoryId]?.name ??
          transaction.categoryId.value,
      _formatMoneyAmount(transaction.amount),
      transaction.amount.currency.code,
      '',
      '',
      '',
      transaction.note ?? '',
    ],
  );
}

_CsvMovementRow _transferRow(
  Transfer transfer,
  Map<WalletId, Wallet> walletsById,
) {
  return _CsvMovementRow(
    id: transfer.id.value,
    date: transfer.occurredOn,
    time: transfer.occurredAt,
    values: [
      transfer.id.value,
      'transfer',
      transfer.occurredOn.toString(),
      transfer.occurredAt.toString(),
      walletsById[transfer.sourceWalletId]?.name ??
          transfer.sourceWalletId.value,
      walletsById[transfer.destinationWalletId]?.name ??
          transfer.destinationWalletId.value,
      '',
      _formatMoneyAmount(transfer.sourceAmount),
      transfer.sourceAmount.currency.code,
      _formatMoneyAmount(transfer.destinationAmount),
      transfer.destinationAmount.currency.code,
      _formatConversionFactor(transfer),
      transfer.note ?? '',
    ],
  );
}

String _formatMoneyAmount(Money money) {
  final digits = money.currency.minorUnitDigits;

  if (digits == 0) {
    return money.minorUnits.toString();
  }

  var divisor = 1;
  for (var index = 0; index < digits; index++) {
    divisor *= 10;
  }

  final absoluteMinorUnits = money.minorUnits.abs();
  final wholeUnits = absoluteMinorUnits ~/ divisor;
  final minorUnits = (absoluteMinorUnits % divisor).toString().padLeft(
    digits,
    '0',
  );
  final sign = money.minorUnits < 0 ? '-' : '';

  return '$sign$wholeUnits.$minorUnits';
}

String _formatConversionFactor(Transfer transfer) {
  final destinationAmount =
      transfer.destinationAmount.minorUnits /
      math.pow(10, transfer.destinationAmount.currency.minorUnitDigits);
  final sourceAmount =
      transfer.sourceAmount.minorUnits /
      math.pow(10, transfer.sourceAmount.currency.minorUnitDigits);
  final fixed = (destinationAmount / sourceAmount).toStringAsFixed(10);

  return fixed
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

String _escapeCsvField(String value) {
  if (!value.contains(RegExp('[,"\\r\\n]'))) {
    return value;
  }

  return '"${value.replaceAll('"', '""')}"';
}

bool _isInsidePeriod(LocalDate date, LocalDate startDate, LocalDate endDate) {
  return date.compareTo(startDate) >= 0 && date.compareTo(endDate) <= 0;
}

int _compareRows(_CsvMovementRow first, _CsvMovementRow second) {
  final date = first.date.compareTo(second.date);
  final time = first.time.compareTo(second.time);

  return date != 0
      ? date
      : time != 0
      ? time
      : first.id.compareTo(second.id);
}

final class _CsvMovementRow {
  const _CsvMovementRow({
    required this.id,
    required this.date,
    required this.time,
    required this.values,
  });

  final String id;
  final LocalDate date;
  final LocalTime time;
  final List<String> values;
}
