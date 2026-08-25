import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/wallets/application/delete_wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:chuspita/features/wallets/domain/wallet_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deletes the requested wallet', () async {
    final repository = FakeWalletRepository();
    final deleteWallet = DeleteWallet(walletRepository: repository);
    final wallet = Wallet(
      id: WalletId('wallet-1'),
      name: 'Cash',
      initialBalance: const Money(minorUnits: 1000, currency: Currency.eur),
    );

    await deleteWallet(wallet);

    expect(repository.deletedId, wallet.id);
  });
}

final class FakeWalletRepository implements WalletRepository {
  WalletId? deletedId;

  @override
  Future<void> delete(WalletId id) async {
    deletedId = id;
  }

  @override
  Future<List<Wallet>> getAll() async => const [];

  @override
  Future<Wallet?> getById(WalletId id) async => null;

  @override
  Future<void> save(Wallet wallet) async {}
}
