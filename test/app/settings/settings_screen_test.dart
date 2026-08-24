import 'package:chuspita/app/app.dart';
import 'package:chuspita/app/providers.dart';
import 'package:chuspita/app/settings/app_settings.dart';
import 'package:chuspita/app/settings/settings_providers.dart';
import 'package:chuspita/app/settings/settings_repository.dart';
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
