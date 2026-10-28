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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          AppBranding.logoAsset,
          key: const ValueKey('chuspita-logo'),
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
