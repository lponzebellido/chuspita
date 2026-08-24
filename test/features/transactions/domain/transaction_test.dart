import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction_id.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Transaction', () {
    test('creates an expense and normalizes its note', () {
      final transaction = buildTransaction();

      expect(transaction.type, TransactionType.expense);
      expect(transaction.amount.minorUnits, 1250);
      expect(transaction.walletId, WalletId('wallet-1'));
      expect(transaction.categoryId, CategoryId('category-1'));
      expect(transaction.occurredOn, LocalDate(year: 2026, month: 8, day: 23));
      expect(transaction.note, 'Lunch');
    });

    test('supports income transactions', () {
      final transaction = buildTransaction(type: TransactionType.income);

      expect(transaction.type, TransactionType.income);
    });

    test('rejects zero and negative amounts', () {
      expect(
        () => buildTransaction(
          amount: const Money(minorUnits: 0, currency: Currency.eur),
        ),
        throwsArgumentError,
      );

      expect(
        () => buildTransaction(
          amount: const Money(minorUnits: -1, currency: Currency.eur),
        ),
        throwsArgumentError,
      );
    });

    test('converts an empty note to null', () {
      final transaction = buildTransaction(note: '   ');

      expect(transaction.note, isNull);
    });

    test('updates details while preserving its identity', () {
      final transaction = buildTransaction();

      final updated = transaction.updateDetails(
        type: TransactionType.income,
        amount: const Money(minorUnits: 5000, currency: Currency.usd),
        walletId: WalletId('wallet-2'),
        categoryId: CategoryId('category-2'),
        occurredOn: LocalDate(year: 2026, month: 9, day: 1),
        note: ' Salary ',
      );

      expect(updated.id, transaction.id);
      expect(updated.type, TransactionType.income);
      expect(
        updated.amount,
        const Money(minorUnits: 5000, currency: Currency.usd),
      );
      expect(updated.walletId, WalletId('wallet-2'));
      expect(updated.categoryId, CategoryId('category-2'));
      expect(updated.occurredOn, LocalDate(year: 2026, month: 9, day: 1));
      expect(updated.note, 'Salary');
    });

    test('uses entity equality based on its id', () {
      final id = TransactionId('transaction-1');
      final first = buildTransaction(id: id);
      final second = buildTransaction(id: id, type: TransactionType.income);

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });
  });
}

Transaction buildTransaction({
  TransactionId? id,
  TransactionType type = TransactionType.expense,
  Money amount = const Money(minorUnits: 1250, currency: Currency.eur),
  String? note = '  Lunch  ',
}) {
  return Transaction(
    id: id ?? TransactionId('transaction-1'),
    type: type,
    amount: amount,
    walletId: WalletId('wallet-1'),
    categoryId: CategoryId('category-1'),
    occurredOn: LocalDate(year: 2026, month: 8, day: 23),
    note: note,
  );
}
