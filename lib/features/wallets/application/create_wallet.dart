import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:chuspita/features/wallets/domain/wallet_repository.dart';

final class CreateWallet {
  const CreateWallet({
    required this.walletRepository,
    required this.idGenerator,
  });

  final WalletRepository walletRepository;
  final String Function() idGenerator;

  Future<Wallet> call({
    required String name,
    required Money initialBalance,
  }) async {
    final wallet = Wallet(
      id: WalletId(idGenerator()),
      name: name,
      initialBalance: initialBalance,
    );

    await walletRepository.save(wallet);

    return wallet;
  }
}
