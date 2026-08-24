import 'package:chuspita/core/color/argb_color.dart';
import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction_id.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer_id.dart';
import 'package:chuspita/features/wallets/domain/calculate_wallet_balance.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculateWalletBalance', () {
    test('returns the initial balance without movements', () {
      final wallet = buildWallet();

      final balance = calculateWalletBalance(
        wallet: wallet,
        transactions: const [],
        transfers: const [],
      );

      expect(balance, const Money(minorUnits: 10000, currency: Currency.eur));
    });

    test('adds income and subtracts expenses', () {
      final wallet = buildWallet();

      final balance = calculateWalletBalance(
        wallet: wallet,
        transactions: [
          buildTransaction(
            id: 'income-1',
            type: TransactionType.income,
            minorUnits: 5000,
          ),
          buildTransaction(
            id: 'expense-1',
            type: TransactionType.expense,
            minorUnits: 2500,
          ),
        ],
        transfers: const [],
      );

      expect(balance, const Money(minorUnits: 12500, currency: Currency.eur));
    });

    test('applies both sides of a multi-currency transfer', () {
      final euroWallet = buildWallet(
        id: 'wallet-eur',
        currency: Currency.eur,
        initialMinorUnits: 20000,
      );
      final dollarWallet = buildWallet(
        id: 'wallet-usd',
        currency: Currency.usd,
        initialMinorUnits: 5000,
      );
      final transfer = buildTransfer(
        sourceWalletId: euroWallet.id,
        destinationWalletId: dollarWallet.id,
        sourceAmount: const Money(minorUnits: 10000, currency: Currency.eur),
        destinationAmount: const Money(
          minorUnits: 11700,
          currency: Currency.usd,
        ),
      );

      final euroBalance = calculateWalletBalance(
        wallet: euroWallet,
        transactions: const [],
        transfers: [transfer],
      );
      final dollarBalance = calculateWalletBalance(
        wallet: dollarWallet,
        transactions: const [],
        transfers: [transfer],
      );

      expect(
        euroBalance,
        const Money(minorUnits: 10000, currency: Currency.eur),
      );
      expect(
        dollarBalance,
        const Money(minorUnits: 16700, currency: Currency.usd),
      );
    });

    test('ignores movements from unrelated wallets', () {
      final wallet = buildWallet();

      final balance = calculateWalletBalance(
        wallet: wallet,
        transactions: [
          buildTransaction(
            id: 'unrelated',
            walletId: WalletId('other-wallet'),
            currency: Currency.usd,
          ),
        ],
        transfers: [
          buildTransfer(
            sourceWalletId: WalletId('other-source'),
            destinationWalletId: WalletId('other-destination'),
            sourceAmount: const Money(minorUnits: 100, currency: Currency.usd),
            destinationAmount: const Money(
              minorUnits: 100,
              currency: Currency.usd,
            ),
          ),
        ],
      );

      expect(balance, wallet.initialBalance);
    });

    test('rejects a transaction whose currency differs from its wallet', () {
      final wallet = buildWallet();

      expect(
        () => calculateWalletBalance(
          wallet: wallet,
          transactions: [
            buildTransaction(id: 'invalid', currency: Currency.usd),
          ],
          transfers: const [],
        ),
        throwsArgumentError,
      );
    });

    test('rejects a transfer side whose currency differs from its wallet', () {
      final wallet = buildWallet();

      expect(
        () => calculateWalletBalance(
          wallet: wallet,
          transactions: const [],
          transfers: [
            buildTransfer(
              sourceWalletId: wallet.id,
              destinationWalletId: WalletId('wallet-usd'),
              sourceAmount: const Money(
                minorUnits: 100,
                currency: Currency.usd,
              ),
              destinationAmount: const Money(
                minorUnits: 100,
                currency: Currency.eur,
              ),
            ),
          ],
        ),
        throwsArgumentError,
      );
    });
  });
}

Wallet buildWallet({
  String id = 'wallet-1',
  Currency currency = Currency.eur,
  int initialMinorUnits = 10000,
}) {
  return Wallet(
    id: WalletId(id),
    name: 'Wallet',
    initialBalance: Money(minorUnits: initialMinorUnits, currency: currency),
    color: ArgbColor(0xFF3366CC),
  );
}

Transaction buildTransaction({
  required String id,
  TransactionType type = TransactionType.expense,
  WalletId? walletId,
  Currency currency = Currency.eur,
  int minorUnits = 1000,
}) {
  return Transaction(
    id: TransactionId(id),
    type: type,
    amount: Money(minorUnits: minorUnits, currency: currency),
    walletId: walletId ?? WalletId('wallet-1'),
    categoryId: CategoryId('category-1'),
    occurredOn: LocalDate(year: 2026, month: 8, day: 23),
  );
}

Transfer buildTransfer({
  WalletId? sourceWalletId,
  WalletId? destinationWalletId,
  Money sourceAmount = const Money(minorUnits: 1000, currency: Currency.eur),
  Money destinationAmount = const Money(
    minorUnits: 1000,
    currency: Currency.eur,
  ),
}) {
  return Transfer(
    id: TransferId('transfer-1'),
    sourceWalletId: sourceWalletId ?? WalletId('wallet-1'),
    destinationWalletId: destinationWalletId ?? WalletId('wallet-2'),
    sourceAmount: sourceAmount,
    destinationAmount: destinationAmount,
    occurredOn: LocalDate(year: 2026, month: 8, day: 23),
  );
}
