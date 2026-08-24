import 'dart:io';

import 'package:chuspita/core/color/argb_color.dart';
import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/database/app_database.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/categories/data/repositories/drift_category_repository.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/transactions/data/repositories/drift_transaction_repository.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction_id.dart';
import 'package:chuspita/features/transfers/data/repositories/drift_transfer_repository.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer_id.dart';
import 'package:chuspita/features/wallets/application/load_balance_summary.dart';
import 'package:chuspita/features/wallets/data/repositories/drift_wallet_repository.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('restores persisted movements and calculates balances', () async {
    final directory = await Directory.systemTemp.createTemp(
      'chuspita-core-finance-',
    );
    final databaseFile = File('${directory.path}/chuspita.sqlite');

    try {
      await seedDatabase(databaseFile);

      final database = AppDatabase(NativeDatabase(databaseFile));

      try {
        final summary = await LoadBalanceSummary(
          walletRepository: DriftWalletRepository(database),
          transactionRepository: DriftTransactionRepository(database),
          transferRepository: DriftTransferRepository(database),
        )();

        expect(summary.byWallet, {
          WalletId('cash-eur'): const Money(
            minorUnits: 10500,
            currency: Currency.eur,
          ),
          WalletId('savings-eur'): const Money(
            minorUnits: 4000,
            currency: Currency.eur,
          ),
          WalletId('cash-usd'): const Money(
            minorUnits: 4300,
            currency: Currency.usd,
          ),
        });
        expect(summary.byCurrency, {
          Currency.eur: const Money(minorUnits: 14500, currency: Currency.eur),
          Currency.usd: const Money(minorUnits: 4300, currency: Currency.usd),
        });
      } finally {
        await database.close();
      }
    } finally {
      await directory.delete(recursive: true);
    }
  });
}

Future<void> seedDatabase(File databaseFile) async {
  final database = AppDatabase(NativeDatabase(databaseFile));

  try {
    final walletRepository = DriftWalletRepository(database);
    final categoryRepository = DriftCategoryRepository(database);
    final transactionRepository = DriftTransactionRepository(database);
    final transferRepository = DriftTransferRepository(database);

    final cashEur = buildWallet('cash-eur', Currency.eur, 10000);
    final savingsEur = buildWallet('savings-eur', Currency.eur, 5000);
    final cashUsd = buildWallet('cash-usd', Currency.usd, 1000);

    await walletRepository.save(cashEur);
    await walletRepository.save(savingsEur);
    await walletRepository.save(cashUsd);
    await categoryRepository.save(
      Category(
        id: CategoryId('salary'),
        name: 'Salary',
        color: ArgbColor(0xFF4CAF50),
      ),
    );
    await categoryRepository.save(
      Category(
        id: CategoryId('food'),
        name: 'Food',
        color: ArgbColor(0xFFFF9800),
      ),
    );

    await transactionRepository.save(
      buildTransaction(
        id: 'income',
        walletId: cashEur.id,
        categoryId: CategoryId('salary'),
        type: TransactionType.income,
        amountMinor: 5000,
      ),
    );
    await transactionRepository.save(
      buildTransaction(
        id: 'expense',
        walletId: cashEur.id,
        categoryId: CategoryId('food'),
        type: TransactionType.expense,
        amountMinor: 2500,
      ),
    );
    await transferRepository.save(
      Transfer(
        id: TransferId('internal-transfer'),
        sourceWalletId: cashEur.id,
        destinationWalletId: savingsEur.id,
        sourceAmount: const Money(minorUnits: 2000, currency: Currency.eur),
        destinationAmount: const Money(
          minorUnits: 2000,
          currency: Currency.eur,
        ),
        occurredOn: LocalDate(year: 2026, month: 8, day: 23),
      ),
    );
    await transferRepository.save(
      Transfer(
        id: TransferId('currency-exchange'),
        sourceWalletId: savingsEur.id,
        destinationWalletId: cashUsd.id,
        sourceAmount: const Money(minorUnits: 3000, currency: Currency.eur),
        destinationAmount: const Money(
          minorUnits: 3300,
          currency: Currency.usd,
        ),
        occurredOn: LocalDate(year: 2026, month: 8, day: 23),
      ),
    );
  } finally {
    await database.close();
  }
}

Wallet buildWallet(String id, Currency currency, int initialBalanceMinor) {
  return Wallet(
    id: WalletId(id),
    name: id,
    initialBalance: Money(minorUnits: initialBalanceMinor, currency: currency),
  );
}

Transaction buildTransaction({
  required String id,
  required WalletId walletId,
  required CategoryId categoryId,
  required TransactionType type,
  required int amountMinor,
}) {
  return Transaction(
    id: TransactionId(id),
    type: type,
    amount: Money(minorUnits: amountMinor, currency: Currency.eur),
    walletId: walletId,
    categoryId: categoryId,
    occurredOn: LocalDate(year: 2026, month: 8, day: 23),
  );
}
