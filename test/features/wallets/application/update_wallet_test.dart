import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/wallets/application/update_wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:chuspita/features/wallets/domain/wallet_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateWallet', () {
    test('updates and saves wallet details', () async {
      final repository = FakeWalletRepository();
      final updateWallet = UpdateWallet(walletRepository: repository);
      final wallet = buildWallet();

      final updated = await updateWallet.details(
        wallet: wallet,
        name: 'Bank',
        initialBalance: const Money(minorUnits: 2000, currency: Currency.usd),
      );

      expect(updated.name, 'Bank');
      expect(updated.currency, Currency.usd);
      expect(repository.savedWallet, updated);
    });

    test('archives and restores a wallet', () async {
      final repository = FakeWalletRepository();
      final updateWallet = UpdateWallet(walletRepository: repository);
      final wallet = buildWallet();

      final archived = await updateWallet.archive(wallet);
      final restored = await updateWallet.restore(archived);

      expect(archived.isArchived, isTrue);
      expect(restored.isArchived, isFalse);
      expect(repository.savedWallet, restored);
    });
  });
}

Wallet buildWallet() {
  return Wallet(
    id: WalletId('wallet-1'),
    name: 'Cash',
    initialBalance: const Money(minorUnits: 1000, currency: Currency.eur),
  );
}

final class FakeWalletRepository implements WalletRepository {
  Wallet? savedWallet;

  @override
  Future<void> delete(WalletId id) async {}

  @override
  Future<List<Wallet>> getAll() async => const [];

  @override
  Future<Wallet?> getById(WalletId id) async => null;

  @override
  Future<void> save(Wallet wallet) async {
    savedWallet = wallet;
  }
}
