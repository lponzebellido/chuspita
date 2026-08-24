import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/wallets/domain/calculate_wallet_balance.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';

Map<Currency, Money> calculateBalancesByCurrency({
  required Iterable<Wallet> wallets,
  required Iterable<Transaction> transactions,
  required Iterable<Transfer> transfers,
}) {
  final transactionList = transactions.toList(growable: false);
  final transferList = transfers.toList(growable: false);
  final balances = <Currency, Money>{};

  for (final wallet in wallets) {
    final walletBalance = calculateWalletBalance(
      wallet: wallet,
      transactions: transactionList,
      transfers: transferList,
    );

    final currentBalance = balances[wallet.currency];

    balances[wallet.currency] = currentBalance == null
        ? walletBalance
        : currentBalance + walletBalance;
  }

  return Map.unmodifiable(balances);
}
