import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/transactions/domain/transaction_repository.dart';
import 'package:chuspita/features/transfers/domain/transfer_repository.dart';
import 'package:chuspita/features/wallets/application/balance_summary.dart';
import 'package:chuspita/features/wallets/domain/calculate_wallet_balance.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:chuspita/features/wallets/domain/wallet_repository.dart';

final class LoadBalanceSummary {
  const LoadBalanceSummary({
    required this.walletRepository,
    required this.transactionRepository,
    required this.transferRepository,
  });

  final WalletRepository walletRepository;
  final TransactionRepository transactionRepository;
  final TransferRepository transferRepository;

  Future<BalanceSummary> call() async {
    final wallets = await walletRepository.getAll();
    final transactions = await transactionRepository.getAll();
    final transfers = await transferRepository.getAll();
    final activeWallets = wallets
        .where((wallet) => !wallet.isArchived)
        .toList(growable: false);
    final byWallet = <WalletId, Money>{};
    final byCurrency = <Currency, Money>{};

    for (final wallet in activeWallets) {
      final balance = calculateWalletBalance(
        wallet: wallet,
        transactions: transactions,
        transfers: transfers,
      );

      byWallet[wallet.id] = balance;
      byCurrency.update(
        wallet.currency,
        (current) => current + balance,
        ifAbsent: () => balance,
      );
    }

    return BalanceSummary(
      byWallet: byWallet,
      byCurrency: byCurrency,
      walletNames: {for (final wallet in activeWallets) wallet.id: wallet.name},
      archivedWalletCount: wallets.length - activeWallets.length,
    );
  }
}
