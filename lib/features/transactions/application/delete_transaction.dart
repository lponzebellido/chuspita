import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction_repository.dart';

final class DeleteTransaction {
  const DeleteTransaction({required this.transactionRepository});

  final TransactionRepository transactionRepository;

  Future<void> call(Transaction transaction) {
    return transactionRepository.delete(transaction.id);
  }
}
