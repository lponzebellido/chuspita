import 'package:chuspita/app/settings/app_settings.dart';
import 'package:chuspita/app/settings/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class SharedPreferencesSettingsRepository implements SettingsRepository {
  const SharedPreferencesSettingsRepository(this._preferences);

  static const _languageKey = 'settings.language';
  static const _themeKey = 'settings.theme';

  final SharedPreferencesAsync _preferences;

  @override
  Future<AppSettings> load() async {
    final storedLanguage = await _preferences.getString(_languageKey);
    final storedTheme = await _preferences.getString(_themeKey);

    return AppSettings(
      language: _languageFromStorage(storedLanguage),
      theme: _themeFromStorage(storedTheme),
    );
  }

  @override
  Future<void> saveLanguage(AppLanguage language) {
    if (language == AppLanguage.system) {
      return _preferences.remove(_languageKey);
    }

    return _preferences.setString(_languageKey, language.name);
  }

  @override
  Future<void> saveTheme(AppThemePreference theme) {
    if (theme == AppThemePreference.system) {
      return _preferences.remove(_themeKey);
    }

    return _preferences.setString(_themeKey, theme.name);
  }

  AppLanguage _languageFromStorage(String? value) {
    return switch (value) {
      'spanish' => AppLanguage.spanish,
      'english' => AppLanguage.english,
      _ => AppLanguage.system,
    };
  }

  AppThemePreference _themeFromStorage(String? value) {
    return switch (value) {
      'light' => AppThemePreference.light,
      'dark' => AppThemePreference.dark,
      _ => AppThemePreference.system,
    };
  }
}
