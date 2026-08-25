import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:chuspita/core/database/tables.dart';
import 'package:path_provider/path_provider.dart';

import 'app_database.steps.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Wallets, Categories, Transactions, Transfers])
final class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  static const currentSchemaVersion = 4;

  var _isClosed = false;

  Future<void> createBackup(File destination) async {
    if (await destination.exists()) {
      throw StateError('The backup destination already exists.');
    }

    await destination.parent.create(recursive: true);
    await customStatement('VACUUM INTO ?', [destination.path]);
  }

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  Future<void> close() {
    if (_isClosed) {
      return Future.value();
    }

    _isClosed = true;
    return super.close();
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
      },
      onUpgrade: stepByStep(
        from1To2: (migrator, schema) async {
          await migrator.alterTable(TableMigration(schema.wallets));
        },
        from2To3: (migrator, schema) async {
          await migrator.alterTable(
            TableMigration(
              schema.categories,
              columnTransformer: {
                schema.categories.applicability: const Constant('both'),
              },
            ),
          );
        },
        from3To4: (migrator, schema) async {
          await migrator.alterTable(
            TableMigration(
              schema.transactions,
              columnTransformer: {
                schema.transactions.occurredAtMinutes: const Constant(0),
              },
            ),
          );
          await migrator.alterTable(
            TableMigration(
              schema.transfers,
              columnTransformer: {
                schema.transfers.occurredAtMinutes: const Constant(0),
              },
            ),
          );
        },
      ),
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'chuspita',
      native: DriftNativeOptions(
        databasePath: () async => (await defaultDatabaseFile()).path,
      ),
    );
  }

  static Future<File> defaultDatabaseFile() async {
    final directory = await getApplicationSupportDirectory();
    return File.fromUri(directory.uri.resolve('chuspita.sqlite'));
  }
}
