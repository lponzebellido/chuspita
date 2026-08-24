import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/features/transfers/domain/exchange_rate.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';

ExchangeRate? findLatestExchangeRate({
  required Iterable<Transfer> transfers,
  required Currency sourceCurrency,
  required Currency destinationCurrency,
}) {
  Transfer? latestTransfer;
  var latestIsReversed = false;

  for (final transfer in transfers) {
    final isDirect =
        transfer.sourceAmount.currency == sourceCurrency &&
        transfer.destinationAmount.currency == destinationCurrency;
    final isReversed =
        transfer.sourceAmount.currency == destinationCurrency &&
        transfer.destinationAmount.currency == sourceCurrency;

    if (!isDirect && !isReversed) {
      continue;
    }

    final dateComparison = latestTransfer == null
        ? 1
        : transfer.occurredOn.compareTo(latestTransfer.occurredOn);
    final timeComparison = latestTransfer == null
        ? 1
        : transfer.occurredAt.compareTo(latestTransfer.occurredAt);

    if (latestTransfer == null ||
        dateComparison > 0 ||
        (dateComparison == 0 && timeComparison >= 0)) {
      latestTransfer = transfer;
      latestIsReversed = isReversed;
    }
  }

  if (latestTransfer == null) {
    return null;
  }

  return latestIsReversed
      ? ExchangeRate.fromAmounts(
          sourceAmount: latestTransfer.destinationAmount,
          destinationAmount: latestTransfer.sourceAmount,
        )
      : ExchangeRate.fromAmounts(
          sourceAmount: latestTransfer.sourceAmount,
          destinationAmount: latestTransfer.destinationAmount,
        );
}
