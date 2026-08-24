import 'package:chuspita/app/settings/app_settings.dart';

abstract interface class SettingsRepository {
  Future<AppSettings> load();

  Future<void> saveLanguage(AppLanguage language);

  Future<void> saveTheme(AppThemePreference theme);
}
