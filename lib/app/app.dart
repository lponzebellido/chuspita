import 'package:chuspita/app/theme/app_theme.dart';
import 'package:chuspita/features/wallets/presentation/home_screen.dart';
import 'package:chuspita/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

final class ChuspitaApp extends StatelessWidget {
  const ChuspitaApp({super.key, this.locale});

  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(),
    );
  }
}
