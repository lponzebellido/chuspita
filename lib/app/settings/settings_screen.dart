import 'dart:async';

import 'package:chuspita/app/providers.dart';
import 'package:chuspita/app/settings/app_settings.dart';
import 'package:chuspita/app/settings/settings_providers.dart';
import 'package:chuspita/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

final class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  var _isCreatingBackup = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsTitle)),
      body: settings.when(
        data: (value) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            _SectionTitle(
              icon: Icons.language_outlined,
              title: context.l10n.languageSettingsTitle,
            ),
            const SizedBox(height: 8),
            Card(
              child: RadioGroup<AppLanguage>(
                groupValue: value.language,
                onChanged: (language) {
                  if (language != null) {
                    unawaited(_setLanguage(context, language));
                  }
                },
                child: Column(
                  children: [
                    RadioListTile(
                      value: AppLanguage.system,
                      title: Text(context.l10n.systemOption),
                    ),
                    RadioListTile(
                      value: AppLanguage.spanish,
                      title: Text(context.l10n.spanishLanguage),
                    ),
                    RadioListTile(
                      value: AppLanguage.english,
                      title: Text(context.l10n.englishLanguage),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            _SectionTitle(
              icon: Icons.brightness_6_outlined,
              title: context.l10n.appearanceSettingsTitle,
            ),
            const SizedBox(height: 8),
            Card(
              child: RadioGroup<AppThemePreference>(
                groupValue: value.theme,
                onChanged: (theme) {
                  if (theme != null) {
                    unawaited(_setTheme(context, theme));
                  }
                },
                child: Column(
                  children: [
                    RadioListTile(
                      value: AppThemePreference.system,
                      title: Text(context.l10n.systemOption),
                    ),
                    RadioListTile(
                      value: AppThemePreference.light,
                      title: Text(context.l10n.lightTheme),
                    ),
                    RadioListTile(
                      value: AppThemePreference.dark,
                      title: Text(context.l10n.darkTheme),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            _SectionTitle(
              icon: Icons.shield_outlined,
              title: context.l10n.backupSettingsTitle,
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (shareAnchorContext) => Card(
                child: ListTile(
                  leading: const Icon(Icons.save_alt_outlined),
                  title: Text(context.l10n.createBackup),
                  subtitle: Text(context.l10n.backupDescription),
                  trailing: _isCreatingBackup
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _isCreatingBackup
                      ? null
                      : () => unawaited(_createBackup(shareAnchorContext)),
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 56),
                const SizedBox(height: 16),
                Text(
                  context.l10n.loadSettingsError,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(appSettingsProvider),
                  child: Text(context.l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _setLanguage(BuildContext context, AppLanguage language) async {
    try {
      await ref.read(appSettingsProvider.notifier).setLanguage(language);
    } on Object {
      if (context.mounted) {
        _showSaveError(context);
      }
    }
  }

  Future<void> _setTheme(BuildContext context, AppThemePreference theme) async {
    try {
      await ref.read(appSettingsProvider.notifier).setTheme(theme);
    } on Object {
      if (context.mounted) {
        _showSaveError(context);
      }
    }
  }

  void _showSaveError(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.saveSettingsError)));
  }

  Future<void> _createBackup(BuildContext shareAnchorContext) async {
    final renderObject = shareAnchorContext.findRenderObject();
    final sharePositionOrigin = renderObject is RenderBox
        ? renderObject.localToGlobal(Offset.zero) & renderObject.size
        : null;

    setState(() => _isCreatingBackup = true);

    try {
      final file = await ref.read(databaseBackupCreatorProvider)();
      await ref
          .read(backupShareServiceProvider)
          .share(file, sharePositionOrigin: sharePositionOrigin);
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.createBackupError)));
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingBackup = false);
      }
    }
  }
}

final class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}
