import 'package:chuspita/app/settings/app_settings.dart';
import 'package:chuspita/app/settings/settings_repository.dart';
import 'package:chuspita/app/settings/shared_preferences_settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SharedPreferencesSettingsRepository(SharedPreferencesAsync());
});

final appSettingsProvider =
    AsyncNotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
      retry: (retryCount, error) => null,
    );

final class AppSettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() {
    return ref.watch(settingsRepositoryProvider).load();
  }

  Future<void> setLanguage(AppLanguage language) async {
    final previous = state.asData?.value ?? const AppSettings();
    state = AsyncData(previous.copyWith(language: language));

    try {
      await ref.read(settingsRepositoryProvider).saveLanguage(language);
    } on Object catch (error, stackTrace) {
      state = AsyncData(previous);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> setTheme(AppThemePreference theme) async {
    final previous = state.asData?.value ?? const AppSettings();
    state = AsyncData(previous.copyWith(theme: theme));

    try {
      await ref.read(settingsRepositoryProvider).saveTheme(theme);
    } on Object catch (error, stackTrace) {
      state = AsyncData(previous);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
