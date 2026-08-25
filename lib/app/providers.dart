import 'dart:async';

import 'package:chuspita/core/database/app_database.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/features/analytics/domain/calculate_period_summary.dart';
import 'package:chuspita/features/analytics/domain/period_summary.dart';
import 'package:chuspita/features/categories/application/create_category.dart';
import 'package:chuspita/features/categories/application/update_category.dart';
import 'package:chuspita/features/categories/data/repositories/drift_category_repository.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_repository.dart';
import 'package:chuspita/features/export/data/export_share_service.dart';
import 'package:chuspita/features/transactions/application/create_transaction.dart';
import 'package:chuspita/features/transactions/application/delete_transaction.dart';
import 'package:chuspita/features/transactions/application/update_transaction.dart';
import 'package:chuspita/features/transactions/data/repositories/drift_transaction_repository.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction_repository.dart';
import 'package:chuspita/features/transfers/application/create_transfer.dart';
import 'package:chuspita/features/transfers/data/repositories/drift_transfer_repository.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer_repository.dart';
import 'package:chuspita/features/wallets/application/balance_summary.dart';
import 'package:chuspita/features/wallets/application/create_wallet.dart';
import 'package:chuspita/features/wallets/application/load_balance_summary.dart';
import 'package:chuspita/features/wallets/application/update_wallet.dart';
import 'package:chuspita/features/wallets/data/repositories/drift_wallet_repository.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();

  ref.onDispose(() {
    unawaited(database.close());
  });

  return database;
});

final exportShareServiceProvider = Provider<ExportShareService>((ref) {
  return const NativeExportShareService();
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return DriftCategoryRepository(ref.watch(appDatabaseProvider));
});

final categoryIdGeneratorProvider = Provider<String Function()>((ref) {
  final uuid = Uuid();

  return () => uuid.v4();
});

final createCategoryProvider = Provider<CreateCategory>((ref) {
  return CreateCategory(
    categoryRepository: ref.watch(categoryRepositoryProvider),
    idGenerator: ref.watch(categoryIdGeneratorProvider),
  );
});

final updateCategoryProvider = Provider<UpdateCategory>((ref) {
  return UpdateCategory(
    categoryRepository: ref.watch(categoryRepositoryProvider),
  );
});

final categoriesProvider = FutureProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).getAll(),
  retry: (retryCount, error) => null,
);

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return DriftWalletRepository(ref.watch(appDatabaseProvider));
});

final walletIdGeneratorProvider = Provider<String Function()>((ref) {
  final uuid = Uuid();

  return () => uuid.v4();
});

final createWalletProvider = Provider<CreateWallet>((ref) {
  return CreateWallet(
    walletRepository: ref.watch(walletRepositoryProvider),
    idGenerator: ref.watch(walletIdGeneratorProvider),
  );
});

final updateWalletProvider = Provider<UpdateWallet>((ref) {
  return UpdateWallet(walletRepository: ref.watch(walletRepositoryProvider));
});

final walletsProvider = FutureProvider<List<Wallet>>(
  (ref) => ref.watch(walletRepositoryProvider).getAll(),
  retry: (retryCount, error) => null,
);

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return DriftTransactionRepository(ref.watch(appDatabaseProvider));
});

final transactionIdGeneratorProvider = Provider<String Function()>((ref) {
  final uuid = Uuid();

  return () => uuid.v4();
});

final createTransactionProvider = Provider<CreateTransaction>((ref) {
  return CreateTransaction(
    transactionRepository: ref.watch(transactionRepositoryProvider),
    idGenerator: ref.watch(transactionIdGeneratorProvider),
  );
});

final updateTransactionProvider = Provider<UpdateTransaction>((ref) {
  return UpdateTransaction(
    transactionRepository: ref.watch(transactionRepositoryProvider),
  );
});

final deleteTransactionProvider = Provider<DeleteTransaction>((ref) {
  return DeleteTransaction(
    transactionRepository: ref.watch(transactionRepositoryProvider),
  );
});

final transactionsProvider = FutureProvider<List<Transaction>>(
  (ref) => ref.watch(transactionRepositoryProvider).getAll(),
  retry: (retryCount, error) => null,
);

final currentDateProvider = Provider<LocalDate>((ref) {
  final now = DateTime.now();

  return LocalDate(year: now.year, month: now.month, day: now.day);
});

final currentMonthSummaryProvider = Provider<AsyncValue<PeriodSummary>>((ref) {
  final currentDate = ref.watch(currentDateProvider);
  final lastDay = DateTime(currentDate.year, currentDate.month + 1, 0).day;
  final startDate = LocalDate(
    year: currentDate.year,
    month: currentDate.month,
    day: 1,
  );
  final endDate = LocalDate(
    year: currentDate.year,
    month: currentDate.month,
    day: lastDay,
  );

  return ref
      .watch(transactionsProvider)
      .whenData(
        (transactions) => calculatePeriodSummary(
          transactions: transactions,
          startDate: startDate,
          endDate: endDate,
        ),
      );
});

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return DriftTransferRepository(ref.watch(appDatabaseProvider));
});

final transferIdGeneratorProvider = Provider<String Function()>((ref) {
  final uuid = Uuid();

  return () => uuid.v4();
});

final createTransferProvider = Provider<CreateTransfer>((ref) {
  return CreateTransfer(
    transferRepository: ref.watch(transferRepositoryProvider),
    idGenerator: ref.watch(transferIdGeneratorProvider),
  );
});

final transfersProvider = FutureProvider<List<Transfer>>(
  (ref) => ref.watch(transferRepositoryProvider).getAll(),
  retry: (retryCount, error) => null,
);

final loadBalanceSummaryProvider = Provider<LoadBalanceSummary>((ref) {
  return LoadBalanceSummary(
    walletRepository: ref.watch(walletRepositoryProvider),
    transactionRepository: ref.watch(transactionRepositoryProvider),
    transferRepository: ref.watch(transferRepositoryProvider),
  );
});

final balanceSummaryProvider = FutureProvider<BalanceSummary>(
  (ref) => ref.watch(loadBalanceSummaryProvider).call(),
  retry: (retryCount, error) => null,
);
