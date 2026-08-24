import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';

final class TransactionFilters {
  TransactionFilters({
    this.type,
    this.walletId,
    this.categoryId,
    this.startDate,
    this.endDate,
  }) {
    if ((startDate == null) != (endDate == null)) {
      throw ArgumentError('A date filter requires both start and end dates');
    }

    if (startDate != null && startDate!.compareTo(endDate!) > 0) {
      throw ArgumentError('The start date cannot be after the end date');
    }
  }

  final TransactionType? type;
  final WalletId? walletId;
  final CategoryId? categoryId;
  final LocalDate? startDate;
  final LocalDate? endDate;

  bool get isEmpty => activeCount == 0;

  int get activeCount {
    var count = 0;

    if (type != null) count++;
    if (walletId != null) count++;
    if (categoryId != null) count++;
    if (startDate != null) count++;

    return count;
  }

  bool matches(Transaction transaction) {
    if (type != null && transaction.type != type) {
      return false;
    }

    if (walletId != null && transaction.walletId != walletId) {
      return false;
    }

    if (categoryId != null && transaction.categoryId != categoryId) {
      return false;
    }

    if (startDate != null &&
        (transaction.occurredOn.compareTo(startDate!) < 0 ||
            transaction.occurredOn.compareTo(endDate!) > 0)) {
      return false;
    }

    return true;
  }

  List<Transaction> apply(Iterable<Transaction> transactions) {
    return transactions.where(matches).toList(growable: false);
  }
}
