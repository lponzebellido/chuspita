import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction_id.dart';
import 'package:chuspita/features/transactions/domain/transaction_repository.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';

final class CreateTransaction {
  const CreateTransaction({
    required this.transactionRepository,
    required this.idGenerator,
  });

  final TransactionRepository transactionRepository;
  final String Function() idGenerator;

  Future<Transaction> call({
    required TransactionType type,
    required Money amount,
    required WalletId walletId,
    required CategoryId categoryId,
    required LocalDate occurredOn,
    String? note,
  }) async {
    final transaction = Transaction(
      id: TransactionId(idGenerator()),
      type: type,
      amount: amount,
      walletId: walletId,
      categoryId: categoryId,
      occurredOn: occurredOn,
      note: note,
    );

    await transactionRepository.save(transaction);

    return transaction;
  }
}
