import 'dart:io';

import 'package:chuspita/core/database/app_database.dart';
import 'package:chuspita/features/backup/application/invalid_database_backup.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

abstract interface class DatabaseBackupRestorer {
  Future<void> call(File selectedBackup);
}

final class RestoreDatabaseBackup implements DatabaseBackupRestorer {
  RestoreDatabaseBackup(
    this._database,
    this._reloadDatabase, {
    Future<File> Function()? activeDatabaseFile,
    Future<Directory> Function()? temporaryDirectory,
    DateTime Function()? now,
  }) : _activeDatabaseFile =
           activeDatabaseFile ?? AppDatabase.defaultDatabaseFile,
       _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory,
       _now = now ?? DateTime.now;

  static const _requiredTables = {
    'wallets',
    'categories',
    'transactions',
    'transfers',
  };

  final AppDatabase _database;
  final void Function() _reloadDatabase;
  final Future<File> Function() _activeDatabaseFile;
  final Future<Directory> Function() _temporaryDirectory;
  final DateTime Function() _now;

  @override
  Future<void> call(File selectedBackup) async {
    final temporaryRoot = await _temporaryDirectory();
    final workingDirectory = await temporaryRoot.createTemp(
      'chuspita-restore-',
    );
    final stagedBackup = File.fromUri(
      workingDirectory.uri.resolve('selected-backup.sqlite3'),
    );
    final emergencyBackup = File.fromUri(
      workingDirectory.uri.resolve('current-database.sqlite3'),
    );
    var databaseWasClosed = false;
    var restoreSucceeded = false;

    try {
      await selectedBackup.copy(stagedBackup.path);
      _validateBackup(stagedBackup, requireCurrentSchema: false);

      await _database.createBackup(emergencyBackup);
      await _database.close();
      databaseWasClosed = true;

      await _migrateToCurrentSchema(stagedBackup);
      _validateBackup(stagedBackup, requireCurrentSchema: true);

      await _installBackup(
        stagedBackup: stagedBackup,
        emergencyBackup: emergencyBackup,
      );
      restoreSucceeded = true;
    } finally {
      if (databaseWasClosed) {
        _reloadDatabase();
      }

      if (restoreSucceeded || !databaseWasClosed) {
        await workingDirectory.delete(recursive: true);
      }
    }
  }

  void _validateBackup(File file, {required bool requireCurrentSchema}) {
    Database? database;

    try {
      database = sqlite3.open(file.path, mode: OpenMode.readOnly);
      final version = database.userVersion;
      final validVersion = requireCurrentSchema
          ? version == AppDatabase.currentSchemaVersion
          : version >= 1 && version <= AppDatabase.currentSchemaVersion;

      if (!validVersion) {
        throw const InvalidDatabaseBackup();
      }

      final integrity = database.select('PRAGMA integrity_check');
      if (integrity.length != 1 || integrity.single.columnAt(0) != 'ok') {
        throw const InvalidDatabaseBackup();
      }

      final tables = database
          .select("SELECT name FROM sqlite_master WHERE type = 'table'")
          .map((row) => row.columnAt(0))
          .whereType<String>()
          .toSet();
      if (!tables.containsAll(_requiredTables)) {
        throw const InvalidDatabaseBackup();
      }

      if (database.select('PRAGMA foreign_key_check').isNotEmpty) {
        throw const InvalidDatabaseBackup();
      }

      if (requireCurrentSchema) {
        _verifyCurrentColumns(database);
      }
    } on InvalidDatabaseBackup {
      rethrow;
    } on Object {
      throw const InvalidDatabaseBackup();
    } finally {
      database?.close();
    }
  }

  void _verifyCurrentColumns(Database database) {
    database
      ..select(
        'SELECT id, name, currency_code, initial_balance_minor, '
        'is_archived, created_at_millis, updated_at_millis '
        'FROM wallets LIMIT 0',
      )
      ..select(
        'SELECT id, name, color_argb, applicability, is_archived, '
        'created_at_millis, updated_at_millis FROM categories LIMIT 0',
      )
      ..select(
        'SELECT id, type, amount_minor, wallet_id, category_id, occurred_on, '
        'occurred_at_minutes, note, created_at_millis, updated_at_millis '
        'FROM transactions LIMIT 0',
      )
      ..select(
        'SELECT id, source_wallet_id, destination_wallet_id, '
        'source_amount_minor, destination_amount_minor, occurred_on, '
        'occurred_at_minutes, note, created_at_millis, updated_at_millis '
        'FROM transfers LIMIT 0',
      );
  }

  Future<void> _migrateToCurrentSchema(File stagedBackup) async {
    final database = AppDatabase(NativeDatabase(stagedBackup));

    try {
      await database.customSelect('SELECT 1').getSingle();
    } finally {
      await database.close();
    }
  }

  Future<void> _installBackup({
    required File stagedBackup,
    required File emergencyBackup,
  }) async {
    final destination = await _activeDatabaseFile();
    await destination.parent.create(recursive: true);

    final suffix = _now().microsecondsSinceEpoch;
    final incoming = File('${destination.path}.restore-$suffix');
    final recovery = File('${destination.path}.recovery-$suffix');

    await stagedBackup.copy(incoming.path);
    await _deleteIfExists(File('${destination.path}-wal'));
    await _deleteIfExists(File('${destination.path}-shm'));

    try {
      await incoming.rename(destination.path);
      _validateBackup(destination, requireCurrentSchema: true);
    } on Object {
      await emergencyBackup.copy(recovery.path);
      await recovery.rename(destination.path);
      rethrow;
    } finally {
      await _deleteIfExists(incoming);
      await _deleteIfExists(recovery);
    }
  }

  Future<void> _deleteIfExists(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }
}
