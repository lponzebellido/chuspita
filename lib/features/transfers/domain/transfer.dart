import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/date/local_time.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/transfers/domain/transfer_id.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';

final class Transfer {
  factory Transfer({
    required TransferId id,
    required WalletId sourceWalletId,
    required WalletId destinationWalletId,
    required Money sourceAmount,
    required Money destinationAmount,
    required LocalDate occurredOn,
    LocalTime occurredAt = LocalTime.midnight,
    String? note,
  }) {
    if (sourceWalletId == destinationWalletId) {
      throw ArgumentError('Source and destination wallets must be different');
    }

    if (sourceAmount.minorUnits <= 0) {
      throw ArgumentError.value(
        sourceAmount.minorUnits,
        'sourceAmount',
        'Source amount must be greater than zero',
      );
    }

    if (destinationAmount.minorUnits <= 0) {
      throw ArgumentError.value(
        destinationAmount.minorUnits,
        'destinationAmount',
        'Destination amount must be greater than zero',
      );
    }

    final usesSameCurrency =
        sourceAmount.currency == destinationAmount.currency;

    if (usesSameCurrency &&
        sourceAmount.minorUnits != destinationAmount.minorUnits) {
      throw ArgumentError('Same-currency transfers must use equal amounts');
    }

    final normalizedNote = note?.trim();

    return Transfer._(
      id: id,
      sourceWalletId: sourceWalletId,
      destinationWalletId: destinationWalletId,
      sourceAmount: sourceAmount,
      destinationAmount: destinationAmount,
      occurredOn: occurredOn,
      occurredAt: occurredAt,
      note: normalizedNote == null || normalizedNote.isEmpty
          ? null
          : normalizedNote,
    );
  }

  const Transfer._({
    required this.id,
    required this.sourceWalletId,
    required this.destinationWalletId,
    required this.sourceAmount,
    required this.destinationAmount,
    required this.occurredOn,
    required this.occurredAt,
    required this.note,
  });

  final TransferId id;
  final WalletId sourceWalletId;
  final WalletId destinationWalletId;
  final Money sourceAmount;
  final Money destinationAmount;
  final LocalDate occurredOn;
  final LocalTime occurredAt;
  final String? note;

  bool get isCurrencyExchange {
    return sourceAmount.currency != destinationAmount.currency;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Transfer && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
