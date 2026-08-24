import 'package:chuspita/core/color/argb_color.dart';
import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/database/app_database.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/categories/data/repositories/drift_category_repository.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_applicability.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/transactions/data/repositories/drift_transaction_repository.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction_id.dart';
import 'package:chuspita/features/wallets/data/repositories/drift_wallet_repository.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriftTransactionRepository', () {
    late AppDatabase database;
    late DriftTransactionRepository repository;
    late int currentTime;

    setUp(() async {
      currentTime = 1000;
      database = AppDatabase(NativeDatabase.memory());

      await DriftWalletRepository(
        database,
        nowMillis: () => currentTime,
      ).save(buildWallet());
      await DriftCategoryRepository(
        database,
        nowMillis: () => currentTime,
      ).save(buildCategory());

      repository = DriftTransactionRepository(
        database,
        nowMillis: () => currentTime,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('saves and restores a transaction', () async {
      final transaction = buildTransaction();

      await repository.save(transaction);
      final restored = await repository.getById(transaction.id);

      expect(restored, isNotNull);
      expect(restored!.type, TransactionType.expense);
      expect(restored.amount, transaction.amount);
      expect(restored.walletId, transaction.walletId);
      expect(restored.categoryId, transaction.categoryId);
      expect(restored.occurredOn, transaction.occurredOn);
      expect(restored.note, 'Lunch');
    });

    test('updates a transaction and clears its nullable note', () async {
      final transaction = buildTransaction();
      await repository.save(transaction);

      currentTime = 2000;
      final updated = buildTransaction(
        type: TransactionType.income,
        amountMinor: 3500,
        note: null,
      );
      await repository.save(updated);

      final query = database.select(database.transactions)
        ..where((table) => table.id.equals(transaction.id.value));
      final row = await query.getSingle();
      final restored = await repository.getById(transaction.id);

      expect(row.createdAtMillis, 1000);
      expect(row.updatedAtMillis, 2000);
      expect(restored!.type, TransactionType.income);
      expect(restored.amount.minorUnits, 3500);
      expect(restored.note, isNull);
    });

    test('returns all transactions', () async {
      await repository.save(buildTransaction(id: 'transaction-1'));
      await repository.save(buildTransaction(id: 'transaction-2'));

      final transactions = await repository.getAll();

      expect(transactions.map((transaction) => transaction.id).toSet(), {
        TransactionId('transaction-1'),
        TransactionId('transaction-2'),
      });
    });

    test('rejects a currency that differs from the wallet', () async {
      final transaction = buildTransaction(currency: Currency.usd);

      expect(() => repository.save(transaction), throwsA(isA<StateError>()));
    });

    test('rejects a missing category', () async {
      final transaction = buildTransaction(categoryId: 'missing-category');

      expect(() => repository.save(transaction), throwsA(isA<StateError>()));
    });

    test('rejects a category incompatible with the transaction type', () async {
      await DriftCategoryRepository(
        database,
        nowMillis: () => currentTime,
      ).save(buildCategory(applicability: CategoryApplicability.expense));
      final transaction = buildTransaction(type: TransactionType.income);

      expect(() => repository.save(transaction), throwsA(isA<StateError>()));
    });

    test(
      'keeps an existing association after category applicability changes',
      () async {
        final transaction = buildTransaction(type: TransactionType.income);
        await repository.save(transaction);
        await DriftCategoryRepository(
          database,
          nowMillis: () => currentTime,
        ).save(buildCategory(applicability: CategoryApplicability.expense));

        await repository.save(buildTransaction(type: TransactionType.income));

        expect(await repository.getById(transaction.id), isNotNull);
      },
    );

    test('deletes a transaction', () async {
      final transaction = buildTransaction();
      await repository.save(transaction);

      await repository.delete(transaction.id);

      expect(await repository.getById(transaction.id), isNull);
    });
  });
}

Wallet buildWallet() {
  return Wallet(
    id: WalletId('wallet-1'),
    name: 'Cash',
    initialBalance: const Money(minorUnits: 0, currency: Currency.eur),
  );
}

Category buildCategory({
  CategoryApplicability applicability = CategoryApplicability.both,
}) {
  return Category(
    id: CategoryId('category-1'),
    name: 'Food',
    color: ArgbColor(0xFFFF9800),
    applicability: applicability,
  );
}

Transaction buildTransaction({
  String id = 'transaction-1',
  TransactionType type = TransactionType.expense,
  int amountMinor = 2500,
  Currency currency = Currency.eur,
  String categoryId = 'category-1',
  String? note = 'Lunch',
}) {
  return Transaction(
    id: TransactionId(id),
    type: type,
    amount: Money(minorUnits: amountMinor, currency: currency),
    walletId: WalletId('wallet-1'),
    categoryId: CategoryId(categoryId),
    occurredOn: LocalDate(year: 2026, month: 8, day: 23),
    note: note,
  );
}
