import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_repository.dart';

final class DeleteWallet {
  const DeleteWallet({required this.walletRepository});

  final WalletRepository walletRepository;

  Future<void> call(Wallet wallet) {
    return walletRepository.delete(wallet.id);
  }
}
