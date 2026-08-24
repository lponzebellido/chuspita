import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/database/app_database.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/transactions/data/mappers/transaction_mapper.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction_id.dart';
import 'package:chuspita/features/transactions/domain/transaction_repository.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:drift/drift.dart';

final class DriftTransactionRepository implements TransactionRepository {
  DriftTransactionRepository(this._database, {int Function()? nowMillis})
    : _nowMillis = nowMillis ?? _currentTimeMillis;

  final AppDatabase _database;
  final int Function() _nowMillis;

  static int _currentTimeMillis() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  @override
  Future<List<Transaction>> getAll() async {
    final rows = await _database.select(_database.transactions).get();

    if (rows.isEmpty) {
      return const [];
    }

    final walletRows = await _database.select(_database.wallets).get();
    final currenciesByWalletId = {
      for (final wallet in walletRows)
        wallet.id: Currency.fromCode(wallet.currencyCode),
    };

    return rows
        .map((row) {
          final currency = currenciesByWalletId[row.walletId];

          if (currency == null) {
            throw StateError(
              'Transaction ${row.id} references missing wallet ${row.walletId}',
            );
          }

          return row.toDomain(currency: currency);
        })
        .toList(growable: false);
  }

  @override
  Future<Transaction?> getById(TransactionId id) async {
    final query = _database.select(_database.transactions)
      ..where((table) => table.id.equals(id.value));
    final row = await query.getSingleOrNull();

    if (row == null) {
      return null;
    }

    final wallet = await _requireWallet(WalletId(row.walletId));

    return row.toDomain(currency: Currency.fromCode(wallet.currencyCode));
  }

  @override
  Future<void> save(Transaction transaction) async {
    await _database.transaction(() async {
      final query = _database.select(_database.transactions)
        ..where((table) => table.id.equals(transaction.id.value));
      final existingRow = await query.getSingleOrNull();
      final wallet = await _requireWallet(transaction.walletId);
      final category = await _requireCategory(transaction.categoryId);
      final walletCurrency = Currency.fromCode(wallet.currencyCode);
      final keepsExistingAssociation =
          existingRow != null &&
          existingRow.type == transaction.type.name &&
          existingRow.categoryId == transaction.categoryId.value;

      if (category.applicability != 'both' &&
          category.applicability != transaction.type.name &&
          !keepsExistingAssociation) {
        throw StateError(
          'Category ${category.id} cannot be used for '
          '${transaction.type.name} transactions',
        );
      }

      if (transaction.amount.currency != walletCurrency) {
        throw StateError(
          'Transaction currency ${transaction.amount.currency.code} does not '
          'match wallet currency ${walletCurrency.code}',
        );
      }

      final now = _nowMillis();

      if (existingRow == null) {
        await _database
            .into(_database.transactions)
            .insert(
              TransactionsCompanion.insert(
                id: transaction.id.value,
                type: transaction.type.name,
                amountMinor: transaction.amount.minorUnits,
                walletId: transaction.walletId.value,
                categoryId: transaction.categoryId.value,
                occurredOn: transaction.occurredOn.toString(),
                occurredAtMinutes: Value(
                  transaction.occurredAt.minutesSinceMidnight,
                ),
                note: Value(transaction.note),
                createdAtMillis: now,
                updatedAtMillis: now,
              ),
            );

        return;
      }

      final updatedAtMillis = now < existingRow.createdAtMillis
          ? existingRow.createdAtMillis
          : now;

      await (_database.update(
        _database.transactions,
      )..where((table) => table.id.equals(transaction.id.value))).write(
        TransactionsCompanion(
          type: Value(transaction.type.name),
          amountMinor: Value(transaction.amount.minorUnits),
          walletId: Value(transaction.walletId.value),
          categoryId: Value(transaction.categoryId.value),
          occurredOn: Value(transaction.occurredOn.toString()),
          occurredAtMinutes: Value(transaction.occurredAt.minutesSinceMidnight),
          note: Value(transaction.note),
          updatedAtMillis: Value(updatedAtMillis),
        ),
      );
    });
  }

  @override
  Future<void> delete(TransactionId id) async {
    await (_database.delete(
      _database.transactions,
    )..where((table) => table.id.equals(id.value))).go();
  }

  Future<WalletRow> _requireWallet(WalletId id) async {
    final query = _database.select(_database.wallets)
      ..where((table) => table.id.equals(id.value));
    final wallet = await query.getSingleOrNull();

    if (wallet == null) {
      throw StateError('Wallet ${id.value} does not exist');
    }

    return wallet;
  }

  Future<CategoryRow> _requireCategory(CategoryId id) async {
    final query = _database.select(_database.categories)
      ..where((table) => table.id.equals(id.value));
    final category = await query.getSingleOrNull();

    if (category == null) {
      throw StateError('Category ${id.value} does not exist');
    }

    return category;
  }
}
