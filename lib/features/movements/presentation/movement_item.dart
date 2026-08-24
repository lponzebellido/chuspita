import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';

enum MovementType { expense, income, transfer }

sealed class MovementItem {
  const MovementItem();

  LocalDate get occurredOn;

  MovementType get type;

  String get id;
}

final class TransactionMovementItem extends MovementItem {
  const TransactionMovementItem(this.transaction);

  final Transaction transaction;

  @override
  String get id => transaction.id.value;

  @override
  LocalDate get occurredOn => transaction.occurredOn;

  @override
  MovementType get type => switch (transaction.type) {
    TransactionType.expense => MovementType.expense,
    TransactionType.income => MovementType.income,
  };
}

final class TransferMovementItem extends MovementItem {
  const TransferMovementItem(this.transfer);

  final Transfer transfer;

  @override
  String get id => transfer.id.value;

  @override
  LocalDate get occurredOn => transfer.occurredOn;

  @override
  MovementType get type => MovementType.transfer;
}

List<MovementItem> combineMovements({
  required Iterable<Transaction> transactions,
  required Iterable<Transfer> transfers,
}) {
  return [
    for (final transaction in transactions)
      TransactionMovementItem(transaction),
    for (final transfer in transfers) TransferMovementItem(transfer),
  ];
}
