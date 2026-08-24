import 'package:chuspita/app/settings/app_settings.dart';
import 'package:chuspita/app/settings/settings_providers.dart';
import 'package:chuspita/app/settings/settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads and persists language and theme preferences', () async {
    final repository = FakeSettingsRepository(
      const AppSettings(
        language: AppLanguage.spanish,
        theme: AppThemePreference.light,
      ),
    );
    final container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final initial = await container.read(appSettingsProvider.future);

    expect(initial.language, AppLanguage.spanish);
    expect(initial.theme, AppThemePreference.light);

    final controller = container.read(appSettingsProvider.notifier);
    await controller.setLanguage(AppLanguage.english);
    await controller.setTheme(AppThemePreference.dark);

    final updated = container.read(appSettingsProvider).requireValue;
    expect(updated.language, AppLanguage.english);
    expect(updated.theme, AppThemePreference.dark);
    expect(repository.settings, updated);
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
