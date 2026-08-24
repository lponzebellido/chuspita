import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/date/local_time.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/transactions/domain/transaction_id.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';

enum TransactionType { income, expense }

final class Transaction {
  factory Transaction({
    required TransactionId id,
    required TransactionType type,
    required Money amount,
    required WalletId walletId,
    required CategoryId categoryId,
    required LocalDate occurredOn,
    LocalTime occurredAt = LocalTime.midnight,
    String? note,
  }) {
    if (amount.minorUnits <= 0) {
      throw ArgumentError.value(
        amount.minorUnits,
        'amount',
        'Transaction amount must be greater than zero',
      );
    }

    final normalizedNote = note?.trim();

    return Transaction._(
      id: id,
      type: type,
      amount: amount,
      walletId: walletId,
      categoryId: categoryId,
      occurredOn: occurredOn,
      occurredAt: occurredAt,
      note: normalizedNote == null || normalizedNote.isEmpty
          ? null
          : normalizedNote,
    );
  }

  const Transaction._({
    required this.id,
    required this.type,
    required this.amount,
    required this.walletId,
    required this.categoryId,
    required this.occurredOn,
    required this.occurredAt,
    required this.note,
  });

  final TransactionId id;
  final TransactionType type;
  final Money amount;
  final WalletId walletId;
  final CategoryId categoryId;
  final LocalDate occurredOn;
  final LocalTime occurredAt;
  final String? note;

  Transaction updateDetails({
    required TransactionType type,
    required Money amount,
    required WalletId walletId,
    required CategoryId categoryId,
    required LocalDate occurredOn,
    LocalTime? occurredAt,
    String? note,
  }) {
    return Transaction(
      id: id,
      type: type,
      amount: amount,
      walletId: walletId,
      categoryId: categoryId,
      occurredOn: occurredOn,
      occurredAt: occurredAt ?? this.occurredAt,
      note: note,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Transaction && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
