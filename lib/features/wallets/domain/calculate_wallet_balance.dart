import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';

Money calculateWalletBalance({
  required Wallet wallet,
  required Iterable<Transaction> transactions,
  required Iterable<Transfer> transfers,
}) {
  var balance = wallet.initialBalance;

  for (final transaction in transactions) {
    if (transaction.walletId != wallet.id) {
      continue;
    }

    _ensureWalletCurrency(
      wallet: wallet,
      money: transaction.amount,
      argumentName: 'transaction.amount',
    );

    balance = switch (transaction.type) {
      TransactionType.income => balance + transaction.amount,
      TransactionType.expense => balance - transaction.amount,
    };
  }

  for (final transfer in transfers) {
    if (transfer.sourceWalletId == wallet.id) {
      _ensureWalletCurrency(
        wallet: wallet,
        money: transfer.sourceAmount,
        argumentName: 'transfer.sourceAmount',
      );

      balance = balance - transfer.sourceAmount;
    } else if (transfer.destinationWalletId == wallet.id) {
      _ensureWalletCurrency(
        wallet: wallet,
        money: transfer.destinationAmount,
        argumentName: 'transfer.destinationAmount',
      );

      balance = balance + transfer.destinationAmount;
    }
  }

  return balance;
}

void _ensureWalletCurrency({
  required Wallet wallet,
  required Money money,
  required String argumentName,
}) {
  if (money.currency != wallet.currency) {
    throw ArgumentError.value(
      money.currency.code,
      argumentName,
      'Movement currency must match wallet currency '
      '${wallet.currency.code}',
    );
  }
}
