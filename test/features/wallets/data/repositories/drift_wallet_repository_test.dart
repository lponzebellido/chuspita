import 'dart:io';

import 'package:chuspita/core/color/argb_color.dart';
import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/database/app_database.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/wallets/data/repositories/drift_wallet_repository.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriftWalletRepository', () {
    late AppDatabase database;
    late DriftWalletRepository repository;
    late int currentTime;

    setUp(() {
      currentTime = 1000;
      database = AppDatabase(NativeDatabase.memory());
      repository = DriftWalletRepository(
        database,
        nowMillis: () => currentTime,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('saves and restores a wallet', () async {
      final wallet = buildWallet();

      await repository.save(wallet);
      final restored = await repository.getById(wallet.id);

      expect(restored, isNotNull);
      expect(restored!.id, wallet.id);
      expect(restored.name, wallet.name);
      expect(restored.currency, Currency.eur);
      expect(restored.initialBalance, wallet.initialBalance);
      expect(restored.color, wallet.color);
      expect(restored.isArchived, isFalse);
    });

    test('updates a wallet while preserving its creation timestamp', () async {
      final wallet = buildWallet();

      await repository.save(wallet);

      currentTime = 2000;
      await repository.save(wallet.archive());

      final row = await (_databaseWalletQuery(database, wallet.id)).getSingle();

      expect(row.createdAtMillis, 1000);
      expect(row.updatedAtMillis, 2000);
      expect(row.isArchived, isTrue);

      final restored = await repository.getById(wallet.id);
      expect(restored!.isArchived, isTrue);
    });

    test('returns all wallets', () async {
      await repository.save(buildWallet(id: 'wallet-1'));
      await repository.save(buildWallet(id: 'wallet-2'));

      final wallets = await repository.getAll();

      expect(wallets.map((wallet) => wallet.id).toSet(), {
        WalletId('wallet-1'),
        WalletId('wallet-2'),
      });
    });
  });

  test('persists a wallet after closing and reopening SQLite', () async {
    final directory = await Directory.systemTemp.createTemp(
      'chuspita-wallet-repository-',
    );
    final file = File('${directory.path}/chuspita.sqlite');
    final wallet = buildWallet();

    try {
      final firstDatabase = AppDatabase(NativeDatabase(file));

      try {
        final repository = DriftWalletRepository(firstDatabase);
        await repository.save(wallet);
      } finally {
        await firstDatabase.close();
      }

      final secondDatabase = AppDatabase(NativeDatabase(file));

      try {
        final repository = DriftWalletRepository(secondDatabase);
        final restored = await repository.getById(wallet.id);

        expect(restored, isNotNull);
        expect(restored!.name, 'Cash');
        expect(restored.initialBalance, wallet.initialBalance);
        expect(restored.currency, Currency.eur);
      } finally {
        await secondDatabase.close();
      }
    } finally {
      await directory.delete(recursive: true);
    }
  });
}

Selectable<WalletRow> _databaseWalletQuery(AppDatabase database, WalletId id) {
  return database.select(database.wallets)
    ..where((table) => table.id.equals(id.value));
}

Wallet buildWallet({String id = 'wallet-1'}) {
  return Wallet(
    id: WalletId(id),
    name: 'Cash',
    initialBalance: const Money(minorUnits: 12500, currency: Currency.eur),
    color: ArgbColor(0xFF3366CC),
  );
}
