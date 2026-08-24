import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/movements/presentation/movement_item.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';

enum MovementSortOrder { newestFirst, oldestFirst }

final class MovementFilters {
  MovementFilters({
    this.type,
    this.walletId,
    this.categoryId,
    this.startDate,
    this.endDate,
    this.sortOrder = MovementSortOrder.newestFirst,
  }) {
    if ((startDate == null) != (endDate == null)) {
      throw ArgumentError('A date filter requires both start and end dates');
    }

    if (startDate != null && startDate!.compareTo(endDate!) > 0) {
      throw ArgumentError('The start date cannot be after the end date');
    }

    if (type == MovementType.transfer && categoryId != null) {
      throw ArgumentError('Transfers cannot be filtered by category');
    }
  }

  final MovementType? type;
  final WalletId? walletId;
  final CategoryId? categoryId;
  final LocalDate? startDate;
  final LocalDate? endDate;
  final MovementSortOrder sortOrder;

  bool get isEmpty => activeCount == 0;

  int get activeCount {
    var count = 0;

    if (type != null) count++;
    if (walletId != null) count++;
    if (categoryId != null) count++;
    if (startDate != null) count++;
    if (sortOrder != MovementSortOrder.newestFirst) count++;

    return count;
  }

  bool matches(MovementItem movement) {
    if (type != null && movement.type != type) {
      return false;
    }

    if (!_matchesWallet(movement) || !_matchesCategory(movement)) {
      return false;
    }

    if (startDate != null &&
        (movement.occurredOn.compareTo(startDate!) < 0 ||
            movement.occurredOn.compareTo(endDate!) > 0)) {
      return false;
    }

    return true;
  }

  List<MovementItem> apply(Iterable<MovementItem> movements) {
    final result = movements.where(matches).toList();
    result.sort(_compare);
    return result;
  }

  int _compare(MovementItem first, MovementItem second) {
    final dateComparison = first.occurredOn.compareTo(second.occurredOn);
    final timeComparison = first.occurredAt.compareTo(second.occurredAt);
    final idComparison = first.id.compareTo(second.id);
    final ascendingComparison = dateComparison != 0
        ? dateComparison
        : timeComparison != 0
        ? timeComparison
        : idComparison;

    return sortOrder == MovementSortOrder.oldestFirst
        ? ascendingComparison
        : -ascendingComparison;
  }

  bool _matchesWallet(MovementItem movement) {
    if (walletId == null) {
      return true;
    }

    return switch (movement) {
      TransactionMovementItem(:final transaction) =>
        transaction.walletId == walletId,
      TransferMovementItem(:final transfer) =>
        transfer.sourceWalletId == walletId ||
            transfer.destinationWalletId == walletId,
    };
  }

  bool _matchesCategory(MovementItem movement) {
    if (categoryId == null) {
      return true;
    }

    return switch (movement) {
      TransactionMovementItem(:final transaction) =>
        transaction.categoryId == categoryId,
      TransferMovementItem() => false,
    };
  }
}
