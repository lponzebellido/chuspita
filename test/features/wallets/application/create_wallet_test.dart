import 'package:chuspita/core/color/argb_color.dart';
import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/wallets/application/create_wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:chuspita/features/wallets/domain/wallet_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates and saves a wallet with a generated id', () async {
    final repository = FakeWalletRepository();
    final createWallet = CreateWallet(
      walletRepository: repository,
      idGenerator: () => 'generated-wallet-id',
    );

    final wallet = await createWallet(
      name: ' Cash ',
      initialBalance: const Money(minorUnits: 1250, currency: Currency.eur),
      color: ArgbColor(0xFF5B5BD6),
    );

    expect(wallet.id, WalletId('generated-wallet-id'));
    expect(wallet.name, 'Cash');
    expect(repository.savedWallet, wallet);
  });
}

final class FakeWalletRepository implements WalletRepository {
  Wallet? savedWallet;

  @override
  Future<List<Wallet>> getAll() async => const [];

  @override
  Future<Wallet?> getById(WalletId id) async => null;

  @override
  Future<void> save(Wallet wallet) async {
    savedWallet = wallet;
  }
}
