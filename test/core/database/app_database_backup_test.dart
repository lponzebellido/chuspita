import 'dart:io';

import 'package:chuspita/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates a restorable snapshot of the financial database', () async {
    final directory = await Directory.systemTemp.createTemp(
      'chuspita-database-backup-',
    );
    final sourceFile = File('${directory.path}/source.sqlite');
    final backupFile = File('${directory.path}/backup/chuspita.sqlite3');

    try {
      final source = AppDatabase(NativeDatabase(sourceFile));

      try {
        await _seedFinancialData(source);

        await source.createBackup(backupFile);
      } finally {
        await source.close();
      }

      expect(await backupFile.exists(), isTrue);

      final restored = AppDatabase(NativeDatabase(backupFile));

      try {
        final wallet = await restored.select(restored.wallets).getSingle();
        final category = await restored.select(restored.categories).getSingle();
        final transaction = await restored
            .select(restored.transactions)
            .getSingle();

        expect(wallet.name, 'Travel cash');
        expect(wallet.currencyCode, 'EUR');
        expect(category.name, 'Food');
        expect(transaction.amountMinor, 1299);
        expect(transaction.note, 'Dinner');
      } finally {
        await restored.close();
      }
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('does not overwrite an existing destination', () async {
    final directory = await Directory.systemTemp.createTemp(
      'chuspita-database-backup-existing-',
    );
    final source = AppDatabase(
      NativeDatabase(File('${directory.path}/source.sqlite')),
    );
    final destination = File('${directory.path}/existing.sqlite3');

    try {
      await destination.writeAsString('keep me');

      await expectLater(
        source.createBackup(destination),
        throwsA(isA<StateError>()),
      );
      expect(await destination.readAsString(), 'keep me');
    } finally {
      await source.close();
      await directory.delete(recursive: true);
    }
  });
}

Future<void> _seedFinancialData(AppDatabase database) async {
  await database
      .into(database.wallets)
      .insert(
        WalletsCompanion.insert(
          id: 'wallet-1',
          name: 'Travel cash',
          currencyCode: 'EUR',
          initialBalanceMinor: 50000,
          createdAtMillis: 1000,
          updatedAtMillis: 1000,
        ),
      );
  await database
      .into(database.categories)
      .insert(
        CategoriesCompanion.insert(
          id: 'category-1',
          name: 'Food',
          colorArgb: 0xFFFF9800,
          createdAtMillis: 1000,
          updatedAtMillis: 1000,
        ),
      );
  await database
      .into(database.transactions)
      .insert(
        TransactionsCompanion.insert(
          id: 'transaction-1',
          type: 'expense',
          amountMinor: 1299,
          walletId: 'wallet-1',
          categoryId: 'category-1',
          occurredOn: '2026-08-25',
          note: const Value('Dinner'),
          createdAtMillis: 1000,
          updatedAtMillis: 1000,
        ),
      );
}
