import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction_repository.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';

final class UpdateTransaction {
  const UpdateTransaction({required this.transactionRepository});

  final TransactionRepository transactionRepository;

  Future<Transaction> call({
    required Transaction transaction,
    required TransactionType type,
    required Money amount,
    required WalletId walletId,
    required CategoryId categoryId,
    required LocalDate occurredOn,
    String? note,
  }) async {
    final updatedTransaction = transaction.updateDetails(
      type: type,
      amount: amount,
      walletId: walletId,
      categoryId: categoryId,
      occurredOn: occurredOn,
      note: note,
    );

    await transactionRepository.save(updatedTransaction);

    return updatedTransaction;
  }
}
