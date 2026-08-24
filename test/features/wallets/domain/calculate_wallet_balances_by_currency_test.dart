import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction_id.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer_id.dart';
import 'package:chuspita/features/wallets/domain/calculate_balances_by_currency.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculateBalancesByCurrency', () {
    test('groups multiple wallets without mixing currencies', () {
      final balances = calculateBalancesByCurrency(
        wallets: [
          buildWallet('cash-eur', Currency.eur, 10000),
          buildWallet('bank-eur', Currency.eur, 25000),
          buildWallet('cash-pen', Currency.pen, 50000),
        ],
        transactions: const [],
        transfers: const [],
      );

      expect(balances, {
        Currency.eur: const Money(minorUnits: 35000, currency: Currency.eur),
        Currency.pen: const Money(minorUnits: 50000, currency: Currency.pen),
      });
    });

    test(
      'includes transactions while internal transfers preserve the total',
      () {
        final cash = buildWallet('cash', Currency.eur, 10000);
        final bank = buildWallet('bank', Currency.eur, 20000);

        final balances = calculateBalancesByCurrency(
          wallets: [cash, bank],
          transactions: [
            buildTransaction(
              id: 'income',
              walletId: cash.id,
              type: TransactionType.income,
              minorUnits: 5000,
            ),
            buildTransaction(
              id: 'expense',
              walletId: bank.id,
              type: TransactionType.expense,
              minorUnits: 3000,
            ),
          ],
          transfers: [
            buildTransfer(
              sourceWalletId: cash.id,
              destinationWalletId: bank.id,
              sourceAmount: const Money(
                minorUnits: 2000,
                currency: Currency.eur,
              ),
              destinationAmount: const Money(
                minorUnits: 2000,
                currency: Currency.eur,
              ),
            ),
          ],
        );

        expect(
          balances[Currency.eur],
          const Money(minorUnits: 32000, currency: Currency.eur),
        );
      },
    );

    test('keeps both sides of a currency exchange separate', () {
      final euroWallet = buildWallet('eur', Currency.eur, 10000);
      final dollarWallet = buildWallet('usd', Currency.usd, 0);

      final balances = calculateBalancesByCurrency(
        wallets: [euroWallet, dollarWallet],
        transactions: const [],
        transfers: [
          buildTransfer(
            sourceWalletId: euroWallet.id,
            destinationWalletId: dollarWallet.id,
            sourceAmount: const Money(
              minorUnits: 10000,
              currency: Currency.eur,
            ),
            destinationAmount: const Money(
              minorUnits: 11700,
              currency: Currency.usd,
            ),
          ),
        ],
      );

      expect(
        balances[Currency.eur],
        const Money(minorUnits: 0, currency: Currency.eur),
      );
      expect(
        balances[Currency.usd],
        const Money(minorUnits: 11700, currency: Currency.usd),
      );
    });

    test('returns an unmodifiable result', () {
      final balances = calculateBalancesByCurrency(
        wallets: [buildWallet('wallet', Currency.eur, 10000)],
        transactions: const [],
        transfers: const [],
      );

      expect(balances.clear, throwsUnsupportedError);
    });
  });
}

Wallet buildWallet(String id, Currency currency, int initialMinorUnits) {
  return Wallet(
    id: WalletId(id),
    name: id,
    initialBalance: Money(minorUnits: initialMinorUnits, currency: currency),
  );
}

Transaction buildTransaction({
  required String id,
  required WalletId walletId,
  required TransactionType type,
  required int minorUnits,
}) {
  return Transaction(
    id: TransactionId(id),
    type: type,
    amount: Money(minorUnits: minorUnits, currency: Currency.eur),
    walletId: walletId,
    categoryId: CategoryId('category-1'),
    occurredOn: LocalDate(year: 2026, month: 8, day: 23),
  );
}

Transfer buildTransfer({
  required WalletId sourceWalletId,
  required WalletId destinationWalletId,
  required Money sourceAmount,
  required Money destinationAmount,
}) {
  return Transfer(
    id: TransferId('transfer-1'),
    sourceWalletId: sourceWalletId,
    destinationWalletId: destinationWalletId,
    sourceAmount: sourceAmount,
    destinationAmount: destinationAmount,
    occurredOn: LocalDate(year: 2026, month: 8, day: 23),
  );
}
