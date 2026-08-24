import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Wallet', () {
    test('creates an active wallet and derives its currency', () {
      final wallet = buildWallet();

      expect(wallet.name, 'Cash');
      expect(wallet.currency, Currency.eur);
      expect(
        wallet.initialBalance,
        const Money(minorUnits: 1000, currency: Currency.eur),
      );
      expect(wallet.colorValue, 0xFF3366CC);
      expect(wallet.isArchived, isFalse);
    });

    test('normalizes its name', () {
      final wallet = buildWallet(name: '  Main account  ');

      expect(wallet.name, 'Main account');
    });

    test('rejects an empty name', () {
      expect(() => buildWallet(name: '   '), throwsArgumentError);
    });

    test('rejects colors outside the 32-bit ARGB range', () {
      expect(() => buildWallet(colorValue: -1), throwsArgumentError);
      expect(() => buildWallet(colorValue: 0x100000000), throwsArgumentError);
    });

    test('archives immutably', () {
      final activeWallet = buildWallet();

      final archivedWallet = activeWallet.archive();

      expect(activeWallet.isArchived, isFalse);
      expect(archivedWallet.isArchived, isTrue);
      expect(archivedWallet.id, activeWallet.id);
    });

    test('uses entity equality based on its id', () {
      final id = WalletId('wallet-1');
      final first = buildWallet(id: id, name: 'Cash');
      final second = buildWallet(id: id, name: 'Bank account');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });
  });
}

Wallet buildWallet({
  WalletId? id,
  String name = 'Cash',
  Money initialBalance = const Money(minorUnits: 1000, currency: Currency.eur),
  int colorValue = 0xFF3366CC,
  bool isArchived = false,
}) {
  return Wallet(
    id: id ?? WalletId('wallet-1'),
    name: name,
    initialBalance: initialBalance,
    colorValue: colorValue,
    isArchived: isArchived,
  );
}
