import 'package:chuspita/app/branding/app_branding.dart';
import 'package:chuspita/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';

final class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.appName,
      image: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppBranding.logoSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Image.asset(
            AppBranding.logoAsset,
            key: const ValueKey('chuspita-logo'),
            width: 150,
            height: 38,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
