import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction_id.dart';

abstract interface class TransactionRepository {
  Future<List<Transaction>> getAll();

  Future<Transaction?> getById(TransactionId id);

  Future<void> save(Transaction transaction);

  Future<void> delete(TransactionId id);
}
