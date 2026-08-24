import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';

abstract interface class WalletRepository {
  Future<List<Wallet>> getAll();

  Future<Wallet?> getById(WalletId id);

  Future<void> save(Wallet wallet);
}
