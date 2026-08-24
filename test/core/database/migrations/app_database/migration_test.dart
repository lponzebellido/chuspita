// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:chuspita/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test('migration from v1 to v2 does not corrupt data', () async {
    final oldWalletsData = <v1.WalletsData>[
      const v1.WalletsData(
        id: 'wallet-eur',
        name: 'Euros',
        currencyCode: 'EUR',
        initialBalanceMinor: 10000,
        colorArgb: 0xFF5B5BD6,
        isArchived: 0,
        createdAtMillis: 1000,
        updatedAtMillis: 1000,
      ),
      const v1.WalletsData(
        id: 'wallet-usd',
        name: 'Dollars',
        currencyCode: 'USD',
        initialBalanceMinor: 5000,
        colorArgb: 0xFF2E7D32,
        isArchived: 0,
        createdAtMillis: 1000,
        updatedAtMillis: 1000,
      ),
    ];
    final expectedNewWalletsData = <v2.WalletsData>[
      const v2.WalletsData(
        id: 'wallet-eur',
        name: 'Euros',
        currencyCode: 'EUR',
        initialBalanceMinor: 10000,
        isArchived: 0,
        createdAtMillis: 1000,
        updatedAtMillis: 1000,
      ),
      const v2.WalletsData(
        id: 'wallet-usd',
        name: 'Dollars',
        currencyCode: 'USD',
        initialBalanceMinor: 5000,
        isArchived: 0,
        createdAtMillis: 1000,
        updatedAtMillis: 1000,
      ),
    ];

    final oldCategoriesData = <v1.CategoriesData>[
      const v1.CategoriesData(
        id: 'category-food',
        name: 'Food',
        colorArgb: 0xFFFF9800,
        isArchived: 0,
        createdAtMillis: 1000,
        updatedAtMillis: 1000,
      ),
    ];
    final expectedNewCategoriesData = <v2.CategoriesData>[
      const v2.CategoriesData(
        id: 'category-food',
        name: 'Food',
        colorArgb: 0xFFFF9800,
        isArchived: 0,
        createdAtMillis: 1000,
        updatedAtMillis: 1000,
      ),
    ];

    final oldTransactionsData = <v1.TransactionsData>[
      const v1.TransactionsData(
        id: 'transaction-1',
        type: 'expense',
        amountMinor: 1000,
        walletId: 'wallet-eur',
        categoryId: 'category-food',
        occurredOn: '2026-08-23',
        createdAtMillis: 1000,
        updatedAtMillis: 1000,
      ),
    ];
    final expectedNewTransactionsData = <v2.TransactionsData>[
      const v2.TransactionsData(
        id: 'transaction-1',
        type: 'expense',
        amountMinor: 1000,
        walletId: 'wallet-eur',
        categoryId: 'category-food',
        occurredOn: '2026-08-23',
        createdAtMillis: 1000,
        updatedAtMillis: 1000,
      ),
    ];

    final oldTransfersData = <v1.TransfersData>[
      const v1.TransfersData(
        id: 'transfer-1',
        sourceWalletId: 'wallet-eur',
        destinationWalletId: 'wallet-usd',
        sourceAmountMinor: 2000,
        destinationAmountMinor: 2200,
        occurredOn: '2026-08-23',
        createdAtMillis: 1000,
        updatedAtMillis: 1000,
      ),
    ];
    final expectedNewTransfersData = <v2.TransfersData>[
      const v2.TransfersData(
        id: 'transfer-1',
        sourceWalletId: 'wallet-eur',
        destinationWalletId: 'wallet-usd',
        sourceAmountMinor: 2000,
        destinationAmountMinor: 2200,
        occurredOn: '2026-08-23',
        createdAtMillis: 1000,
        updatedAtMillis: 1000,
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.wallets, oldWalletsData);
        batch.insertAll(oldDb.categories, oldCategoriesData);
        batch.insertAll(oldDb.transactions, oldTransactionsData);
        batch.insertAll(oldDb.transfers, oldTransfersData);
      },
      validateItems: (newDb) async {
        expect(expectedNewWalletsData, await newDb.select(newDb.wallets).get());
        expect(
          expectedNewCategoriesData,
          await newDb.select(newDb.categories).get(),
        );
        expect(
          expectedNewTransactionsData,
          await newDb.select(newDb.transactions).get(),
        );
        expect(
          expectedNewTransfersData,
          await newDb.select(newDb.transfers).get(),
        );
      },
    );
  });

  test('migration from v2 to v3 keeps existing categories usable', () async {
    final oldWalletsData = <v2.WalletsData>[
      const v2.WalletsData(
        id: 'wallet-eur',
        name: 'Euros',
        currencyCode: 'EUR',
        initialBalanceMinor: 10000,
        isArchived: 0,
        createdAtMillis: 1000,
        updatedAtMillis: 1000,
      ),
    ];
    final expectedNewWalletsData = <v3.WalletsData>[
      const v3.WalletsData(
        id: 'wallet-eur',
        name: 'Euros',
        currencyCode: 'EUR',
        initialBalanceMinor: 10000,
        isArchived: 0,
        createdAtMillis: 1000,
        updatedAtMillis: 1000,
      ),
    ];
    final oldCategoriesData = <v2.CategoriesData>[
      const v2.CategoriesData(
        id: 'category-food',
        name: 'Food',
        colorArgb: 0xFFFF9800,
        isArchived: 0,
        createdAtMillis: 1000,
        updatedAtMillis: 1000,
      ),
    ];
    final expectedNewCategoriesData = <v3.CategoriesData>[
      const v3.CategoriesData(
        id: 'category-food',
        name: 'Food',
        colorArgb: 0xFFFF9800,
        applicability: 'both',
        isArchived: 0,
        createdAtMillis: 1000,
        updatedAtMillis: 1000,
      ),
    ];
    final oldTransactionsData = <v2.TransactionsData>[
      const v2.TransactionsData(
        id: 'transaction-1',
        type: 'expense',
        amountMinor: 1000,
        walletId: 'wallet-eur',
        categoryId: 'category-food',
        occurredOn: '2026-08-23',
        createdAtMillis: 1000,
        updatedAtMillis: 1000,
      ),
    ];
    final expectedNewTransactionsData = <v3.TransactionsData>[
      const v3.TransactionsData(
        id: 'transaction-1',
        type: 'expense',
        amountMinor: 1000,
        walletId: 'wallet-eur',
        categoryId: 'category-food',
        occurredOn: '2026-08-23',
        createdAtMillis: 1000,
        updatedAtMillis: 1000,
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.wallets, oldWalletsData);
        batch.insertAll(oldDb.categories, oldCategoriesData);
        batch.insertAll(oldDb.transactions, oldTransactionsData);
      },
      validateItems: (newDb) async {
        expect(expectedNewWalletsData, await newDb.select(newDb.wallets).get());
        expect(
          expectedNewCategoriesData,
          await newDb.select(newDb.categories).get(),
        );
        expect(
          expectedNewTransactionsData,
          await newDb.select(newDb.transactions).get(),
        );
      },
    );
  });
}
