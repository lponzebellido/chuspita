import 'dart:convert';

import 'package:chuspita/core/color/argb_color.dart';
import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/date/local_time.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/analytics/domain/calculate_period_summary.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/export/data/csv_financial_exporter.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction_id.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer_id.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds a chronological RFC 4180 CSV for the selected period', () {
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
      name: 'Food, drinks',
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
        note: 'Lunch, "special"\nSecond line',
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

    final file = buildFinancialCsv(
      summary: summary,
      transactions: transactions,
      transfers: [transfer],
      categories: [food],
      wallets: [eurWallet, penWallet],
    );
    final csv = utf8.decode(file.bytes.sublist(3));

    expect(file.fileName, 'chuspita-movements-2026-08-01-to-2026-08-31.csv');
    expect(file.mimeType, 'text/csv');
    expect(file.bytes.take(3), orderedEquals([0xEF, 0xBB, 0xBF]));
    expect(
      csv,
      startsWith(
        'ID,Type,Date,Time,Wallet,Destination wallet,Category,Amount,'
        'Currency,Destination amount,Destination currency,Conversion factor,'
        'Note\r\n',
      ),
    );
    expect(csv, contains('income,income,2026-08-01,00:00'));
    expect(csv, contains('"Food, drinks"'));
    expect(csv, contains('100.00,EUR'));
    expect(csv, contains('"Lunch, ""special""\nSecond line"'));
    expect(
      csv,
      contains(
        'exchange,transfer,2026-08-15,09:30,Travel cash,Peru cash,,'
        '10.00,EUR,40.00,PEN,4,Exchange',
      ),
    );
    expect(csv, isNot(contains('outside')));
    expect(
      csv.indexOf('income,income'),
      lessThan(csv.indexOf('expense,expense')),
    );
    expect(
      csv.indexOf('expense,expense'),
      lessThan(csv.indexOf('exchange,transfer')),
    );
    expect(csv, endsWith('\r\n'));
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
