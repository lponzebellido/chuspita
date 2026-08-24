import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WalletId', () {
    test('normalizes its value', () {
      final id = WalletId(' wallet-1 ');

      expect(id.value, 'wallet-1');
    });

    test('rejects an empty value', () {
      expect(() => WalletId('   '), throwsArgumentError);
    });

    test('uses value equality', () {
      final first = WalletId('wallet-1');
      final second = WalletId('wallet-1');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });
  });
}
