import 'dart:async';

import 'package:chuspita/core/database/app_database.dart';
import 'package:chuspita/features/transactions/data/repositories/drift_transaction_repository.dart';
import 'package:chuspita/features/transactions/domain/transaction_repository.dart';
import 'package:chuspita/features/transfers/data/repositories/drift_transfer_repository.dart';
import 'package:chuspita/features/transfers/domain/transfer_repository.dart';
import 'package:chuspita/features/wallets/application/balance_summary.dart';
import 'package:chuspita/features/wallets/application/create_wallet.dart';
import 'package:chuspita/features/wallets/application/load_balance_summary.dart';
import 'package:chuspita/features/wallets/data/repositories/drift_wallet_repository.dart';
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

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return DriftTransactionRepository(ref.watch(appDatabaseProvider));
});

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return DriftTransferRepository(ref.watch(appDatabaseProvider));
});

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
