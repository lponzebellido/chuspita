import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/transactions/application/create_transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction_id.dart';
import 'package:chuspita/features/transactions/domain/transaction_repository.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates and saves a transaction with a generated id', () async {
    final repository = FakeTransactionRepository();
    final createTransaction = CreateTransaction(
      transactionRepository: repository,
      idGenerator: () => 'transaction-1',
    );

    final transaction = await createTransaction(
      type: TransactionType.expense,
      amount: const Money(minorUnits: 1250, currency: Currency.eur),
      walletId: WalletId('wallet-1'),
      categoryId: CategoryId('category-1'),
      occurredOn: LocalDate(year: 2026, month: 8, day: 24),
      note: ' Lunch ',
    );

    expect(transaction.id, TransactionId('transaction-1'));
    expect(transaction.type, TransactionType.expense);
    expect(transaction.note, 'Lunch');
    expect(repository.savedTransaction, transaction);
  });
}

final class FakeTransactionRepository implements TransactionRepository {
  Transaction? savedTransaction;

  @override
  Future<void> delete(TransactionId id) async {}

  @override
  Future<List<Transaction>> getAll() async => const [];

  @override
  Future<Transaction?> getById(TransactionId id) async => null;

  @override
  Future<void> save(Transaction transaction) async {
    savedTransaction = transaction;
  }
}
