import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:chuspita/core/database/tables.dart';
import 'package:path_provider/path_provider.dart';

import 'app_database.steps.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Wallets, Categories, Transactions, Transfers])
final class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

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
      ),
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'chuspita',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
