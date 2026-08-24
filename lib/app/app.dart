import 'package:chuspita/app/settings/app_settings.dart';
import 'package:chuspita/app/settings/settings_providers.dart';
import 'package:chuspita/app/theme/app_theme.dart';
import 'package:chuspita/features/wallets/presentation/home_screen.dart';
import 'package:chuspita/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class ChuspitaApp extends ConsumerWidget {
  const ChuspitaApp({super.key, this.locale, this.themeMode});

  final Locale? locale;
  final ThemeMode? themeMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(appSettingsProvider).asData?.value ?? const AppSettings();

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode ?? settings.theme.themeMode,
      locale: locale ?? settings.language.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(),
    );
  }
}
