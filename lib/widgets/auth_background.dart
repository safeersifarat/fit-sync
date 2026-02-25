import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Common background used for all auth screens, supports light and dark mode.
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final decoration = brightness == Brightness.dark
        ? AppTheme.getDarkBackgroundDecoration()
        : AppTheme.getLightBackgroundDecoration();

    return Container(decoration: decoration, child: child);
  }
}
