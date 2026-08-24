import 'package:flutter/material.dart';

enum AppLanguage { system, spanish, english }

extension AppLanguageLocale on AppLanguage {
  Locale? get locale {
    return switch (this) {
      AppLanguage.system => null,
      AppLanguage.spanish => const Locale('es'),
      AppLanguage.english => const Locale('en'),
    };
  }
}

enum AppThemePreference { system, light, dark }

extension AppThemePreferenceMode on AppThemePreference {
  ThemeMode get themeMode {
    return switch (this) {
      AppThemePreference.system => ThemeMode.system,
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
    };
  }
}

final class AppSettings {
  const AppSettings({
    this.language = AppLanguage.system,
    this.theme = AppThemePreference.system,
  });

  final AppLanguage language;
  final AppThemePreference theme;

  AppSettings copyWith({AppLanguage? language, AppThemePreference? theme}) {
    return AppSettings(
      language: language ?? this.language,
      theme: theme ?? this.theme,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppSettings &&
            language == other.language &&
            theme == other.theme;
  }

  @override
  int get hashCode => Object.hash(language, theme);
}
