import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/date/local_time.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/transfers/application/find_latest_exchange_rate.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer_id.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the latest matching transfer', () {
    final rate = findLatestExchangeRate(
      transfers: [
        buildTransfer(id: 'older', destinationMinor: 4000, day: 1),
        buildTransfer(id: 'latest', destinationMinor: 4200, day: 2),
      ],
      sourceCurrency: Currency.eur,
      destinationCurrency: Currency.pen,
    );

    expect(rate!.toInputValue(), '4.2');
  });

  test('can derive the inverse of the latest matching transfer', () {
    final rate = findLatestExchangeRate(
      transfers: [buildTransfer(id: 'transfer-1', destinationMinor: 4000)],
      sourceCurrency: Currency.pen,
      destinationCurrency: Currency.eur,
    );

    expect(rate!.toInputValue(), '0.25');
  });

  test('uses the time when matching transfers share a date', () {
    final rate = findLatestExchangeRate(
      transfers: [
        buildTransfer(id: 'evening', destinationMinor: 4300, hour: 18),
        buildTransfer(id: 'morning', destinationMinor: 4100, hour: 8),
      ],
      sourceCurrency: Currency.eur,
      destinationCurrency: Currency.pen,
    );

    expect(rate!.toInputValue(), '4.3');
  });

  test('returns null when the currency pair has no history', () {
    final rate = findLatestExchangeRate(
      transfers: const [],
      sourceCurrency: Currency.eur,
      destinationCurrency: Currency.pen,
    );

    expect(rate, isNull);
  });
}

Transfer buildTransfer({
  required String id,
  required int destinationMinor,
  int day = 1,
  int hour = 0,
}) {
  return Transfer(
    id: TransferId(id),
    sourceWalletId: WalletId('wallet-eur'),
    destinationWalletId: WalletId('wallet-pen'),
    sourceAmount: const Money(minorUnits: 1000, currency: Currency.eur),
    destinationAmount: Money(
      minorUnits: destinationMinor,
      currency: Currency.pen,
    ),
    occurredOn: LocalDate(year: 2026, month: 8, day: day),
    occurredAt: LocalTime(hour: hour, minute: 0),
  );
}
