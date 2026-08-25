import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/date/local_time.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer_id.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Transfer', () {
    test('creates a same-currency transfer', () {
      final transfer = buildTransfer();

      expect(transfer.sourceWalletId, WalletId('wallet-1'));
      expect(transfer.destinationWalletId, WalletId('wallet-2'));
      expect(transfer.sourceAmount.minorUnits, 10000);
      expect(transfer.destinationAmount.minorUnits, 10000);
      expect(transfer.isCurrencyExchange, isFalse);
      expect(transfer.note, 'Savings');
    });

    test('supports transfers between different currencies', () {
      final transfer = buildTransfer(
        destinationAmount: const Money(
          minorUnits: 11700,
          currency: Currency.usd,
        ),
      );

      expect(transfer.isCurrencyExchange, isTrue);
      expect(transfer.sourceAmount.currency, Currency.eur);
      expect(transfer.destinationAmount.currency, Currency.usd);
    });

    test('rejects transfers to the same wallet', () {
      final walletId = WalletId('wallet-1');

      expect(
        () => buildTransfer(
          sourceWalletId: walletId,
          destinationWalletId: walletId,
        ),
        throwsArgumentError,
      );
    });

    test('rejects zero and negative amounts', () {
      expect(
        () => buildTransfer(
          sourceAmount: const Money(minorUnits: 0, currency: Currency.eur),
        ),
        throwsArgumentError,
      );

      expect(
        () => buildTransfer(
          destinationAmount: const Money(
            minorUnits: -1,
            currency: Currency.eur,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('requires equal amounts for the same currency', () {
      expect(
        () => buildTransfer(
          destinationAmount: const Money(
            minorUnits: 9999,
            currency: Currency.eur,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('converts an empty note to null', () {
      final transfer = buildTransfer(note: '   ');

      expect(transfer.note, isNull);
    });

    test('updates details immutably while preserving identity', () {
      final transfer = buildTransfer();

      final updated = transfer.updateDetails(
        sourceWalletId: WalletId('wallet-3'),
        destinationWalletId: WalletId('wallet-4'),
        sourceAmount: const Money(minorUnits: 5000, currency: Currency.eur),
        destinationAmount: const Money(
          minorUnits: 5500,
          currency: Currency.usd,
        ),
        occurredOn: LocalDate(year: 2026, month: 8, day: 25),
        occurredAt: LocalTime(hour: 10, minute: 15),
        note: 'Updated',
      );

      expect(updated.id, transfer.id);
      expect(updated.sourceWalletId, WalletId('wallet-3'));
      expect(updated.destinationWalletId, WalletId('wallet-4'));
      expect(updated.sourceAmount.minorUnits, 5000);
      expect(updated.destinationAmount.minorUnits, 5500);
      expect(updated.occurredOn, LocalDate(year: 2026, month: 8, day: 25));
      expect(updated.occurredAt, LocalTime(hour: 10, minute: 15));
      expect(updated.note, 'Updated');
      expect(transfer.sourceWalletId, WalletId('wallet-1'));
    });

    test('uses entity equality based on its id', () {
      final id = TransferId('transfer-1');
      final first = buildTransfer(id: id);
      final second = buildTransfer(id: id, note: 'Different note');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });
  });
}

Transfer buildTransfer({
  TransferId? id,
  WalletId? sourceWalletId,
  WalletId? destinationWalletId,
  Money sourceAmount = const Money(minorUnits: 10000, currency: Currency.eur),
  Money destinationAmount = const Money(
    minorUnits: 10000,
    currency: Currency.eur,
  ),
  String? note = '  Savings  ',
}) {
  return Transfer(
    id: id ?? TransferId('transfer-1'),
    sourceWalletId: sourceWalletId ?? WalletId('wallet-1'),
    destinationWalletId: destinationWalletId ?? WalletId('wallet-2'),
    sourceAmount: sourceAmount,
    destinationAmount: destinationAmount,
    occurredOn: LocalDate(year: 2026, month: 8, day: 23),
    note: note,
  );
}
