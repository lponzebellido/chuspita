import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/transactions/application/delete_transaction.dart';
import 'package:chuspita/features/transactions/application/update_transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction_id.dart';
import 'package:chuspita/features/transactions/domain/transaction_repository.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('updates and saves a transaction', () async {
    final repository = FakeTransactionRepository();
    final transaction = buildTransaction();
    final updateTransaction = UpdateTransaction(
      transactionRepository: repository,
    );

    final updated = await updateTransaction(
      transaction: transaction,
      type: TransactionType.income,
      amount: const Money(minorUnits: 5000, currency: Currency.eur),
      walletId: transaction.walletId,
      categoryId: transaction.categoryId,
      occurredOn: transaction.occurredOn,
      note: 'Salary',
    );

    expect(updated.id, transaction.id);
    expect(updated.type, TransactionType.income);
    expect(updated.note, 'Salary');
    expect(repository.savedTransaction, updated);
  });

  test('deletes a transaction by id', () async {
    final repository = FakeTransactionRepository();
    final transaction = buildTransaction();
    final deleteTransaction = DeleteTransaction(
      transactionRepository: repository,
    );

    await deleteTransaction(transaction);

    expect(repository.deletedId, transaction.id);
  });
}

Transaction buildTransaction() {
  return Transaction(
    id: TransactionId('transaction-1'),
    type: TransactionType.expense,
    amount: const Money(minorUnits: 1250, currency: Currency.eur),
    walletId: WalletId('wallet-1'),
    categoryId: CategoryId('category-1'),
    occurredOn: LocalDate(year: 2026, month: 8, day: 24),
  );
}

final class FakeTransactionRepository implements TransactionRepository {
  Transaction? savedTransaction;
  TransactionId? deletedId;

  @override
  Future<void> delete(TransactionId id) async {
    deletedId = id;
  }

  @override
  Future<List<Transaction>> getAll() async => const [];

  @override
  Future<Transaction?> getById(TransactionId id) async => null;

  @override
  Future<void> save(Transaction transaction) async {
    savedTransaction = transaction;
  }
}
