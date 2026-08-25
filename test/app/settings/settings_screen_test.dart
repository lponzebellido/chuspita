import 'dart:io';

import 'package:chuspita/app/app.dart';
import 'package:chuspita/app/providers.dart';
import 'package:chuspita/app/settings/app_settings.dart';
import 'package:chuspita/app/settings/settings_providers.dart';
import 'package:chuspita/app/settings/settings_repository.dart';
import 'package:chuspita/features/backup/application/create_database_backup.dart';
import 'package:chuspita/features/backup/data/backup_share_service.dart';
import 'package:chuspita/features/wallets/application/balance_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('changes language and appearance from settings', (tester) async {
    final repository = FakeSettingsRepository(
      const AppSettings(language: AppLanguage.spanish),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repository),
          balanceSummaryProvider.overrideWithValue(
            AsyncData(BalanceSummary(byWallet: const {}, byCurrency: const {})),
          ),
          transactionsProvider.overrideWithValue(const AsyncData([])),
        ],
        child: const ChuspitaApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Configuración'));
    await tester.pumpAndSettle();

    expect(find.text('Idioma'), findsOneWidget);
    expect(find.text('Apariencia'), findsOneWidget);

    await tester.tap(find.text('Inglés'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(repository.settings.language, AppLanguage.english);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(repository.settings.theme, AppThemePreference.dark);
  });

  testWidgets('creates and shares a database backup from settings', (
    tester,
  ) async {
    final repository = FakeSettingsRepository(
      const AppSettings(language: AppLanguage.spanish),
    );
    final backupFile = File('/tmp/chuspita-backup.sqlite3');
    final backupCreator = FakeDatabaseBackupCreator(backupFile);
    final backupShareService = FakeBackupShareService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repository),
          databaseBackupCreatorProvider.overrideWithValue(backupCreator),
          backupShareServiceProvider.overrideWithValue(backupShareService),
          balanceSummaryProvider.overrideWithValue(
            AsyncData(BalanceSummary(byWallet: const {}, byCurrency: const {})),
          ),
          transactionsProvider.overrideWithValue(const AsyncData([])),
        ],
        child: const ChuspitaApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Configuración'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Crear copia de seguridad'), 200);

    await tester.tap(find.text('Crear copia de seguridad'));
    await tester.pumpAndSettle();

    expect(backupCreator.callCount, 1);
    expect(backupShareService.sharedFile, backupFile);
    expect(backupShareService.sharePositionOrigin, isNotNull);
  });
}

final class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository(this.settings);

  AppSettings settings;

  @override
  Future<AppSettings> load() async => settings;

  @override
  Future<void> saveLanguage(AppLanguage language) async {
    settings = settings.copyWith(language: language);
  }

  @override
  Future<void> saveTheme(AppThemePreference theme) async {
    settings = settings.copyWith(theme: theme);
  }
}

final class FakeDatabaseBackupCreator implements DatabaseBackupCreator {
  FakeDatabaseBackupCreator(this.file);

  final File file;
  var callCount = 0;

  @override
  Future<File> call() async {
    callCount++;
    return file;
  }
}

final class FakeBackupShareService implements BackupShareService {
  File? sharedFile;
  Rect? sharePositionOrigin;

  @override
  Future<void> share(File file, {Rect? sharePositionOrigin}) async {
    sharedFile = file;
    this.sharePositionOrigin = sharePositionOrigin;
  }
}
