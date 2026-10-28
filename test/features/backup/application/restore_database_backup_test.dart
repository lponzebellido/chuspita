import 'dart:io';

import 'package:chuspita/core/database/app_database.dart';
import 'package:chuspita/features/backup/application/invalid_database_backup.dart';
import 'package:chuspita/features/backup/application/restore_database_backup.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('replaces the active database with a valid Chuspita backup', () async {
    final directory = await Directory.systemTemp.createTemp(
      'chuspita-restore-valid-',
    );

    try {
      final selectedBackup = await _createBackup(
        directory: directory,
        prefix: 'selected',
        walletName: 'Restored wallet',
      );
      final activeFile = File('${directory.path}/active.sqlite');
      final activeDatabase = AppDatabase(NativeDatabase(activeFile));
      await _insertWallet(activeDatabase, name: 'Current wallet');
      var reloadCount = 0;
      final restore = RestoreDatabaseBackup(
        activeDatabase,
        () => reloadCount++,
        activeDatabaseFile: () async => activeFile,
        temporaryDirectory: () async => directory,
        now: () => DateTime(2026, 8, 25, 12),
      );

      await restore(selectedBackup);

      expect(reloadCount, 1);

      final restoredDatabase = AppDatabase(NativeDatabase(activeFile));
      try {
        final wallets = await restoredDatabase
            .select(restoredDatabase.wallets)
            .get();
        expect(wallets, hasLength(1));
        expect(wallets.single.name, 'Restored wallet');
      } finally {
        await restoredDatabase.close();
      }
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('rejects an invalid file without closing the active database', () async {
    final directory = await Directory.systemTemp.createTemp(
      'chuspita-restore-invalid-',
    );
    final activeFile = File('${directory.path}/active.sqlite');
    final activeDatabase = AppDatabase(NativeDatabase(activeFile));

    try {
      await _insertWallet(activeDatabase, name: 'Current wallet');
      final invalidBackup = File('${directory.path}/invalid.sqlite3');
      await invalidBackup.writeAsString('not a SQLite database');
      var reloadCount = 0;
      final restore = RestoreDatabaseBackup(
        activeDatabase,
        () => reloadCount++,
        activeDatabaseFile: () async => activeFile,
        temporaryDirectory: () async => directory,
      );

      await expectLater(
        restore(invalidBackup),
        throwsA(isA<InvalidDatabaseBackup>()),
      );

      expect(reloadCount, 0);
      final wallets = await activeDatabase.select(activeDatabase.wallets).get();
      expect(wallets.single.name, 'Current wallet');
    } finally {
      await activeDatabase.close();
      await directory.delete(recursive: true);
    }
  });
}

Future<File> _createBackup({
  required Directory directory,
  required String prefix,
  required String walletName,
}) async {
  final sourceFile = File('${directory.path}/$prefix-source.sqlite');
  final backupFile = File('${directory.path}/$prefix-backup.sqlite3');
  final database = AppDatabase(NativeDatabase(sourceFile));

  try {
    await _insertWallet(database, name: walletName);
    await database.createBackup(backupFile);
  } finally {
    await database.close();
  }

  return backupFile;
}

Future<void> _insertWallet(AppDatabase database, {required String name}) async {
  await database
      .into(database.wallets)
      .insert(
        WalletsCompanion.insert(
          id: 'wallet-1',
          name: name,
          currencyCode: 'EUR',
          initialBalanceMinor: 10000,
          createdAtMillis: 1000,
          updatedAtMillis: 1000,
        ),
      );
}
