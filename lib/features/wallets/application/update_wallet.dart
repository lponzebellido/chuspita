import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_repository.dart';

final class UpdateWallet {
  const UpdateWallet({required this.walletRepository});

  final WalletRepository walletRepository;

  Future<Wallet> details({
    required Wallet wallet,
    required String name,
    required Money initialBalance,
  }) async {
    final updatedWallet = wallet.updateDetails(
      name: name,
      initialBalance: initialBalance,
    );

    await walletRepository.save(updatedWallet);

    return updatedWallet;
  }

  Future<Wallet> archive(Wallet wallet) async {
    final archivedWallet = wallet.archive();
    await walletRepository.save(archivedWallet);
    return archivedWallet;
  }

  Future<Wallet> restore(Wallet wallet) async {
    final restoredWallet = wallet.restore();
    await walletRepository.save(restoredWallet);
    return restoredWallet;
  }
}
