import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Common background used for all auth screens, supports light and dark mode.
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final decoration = isDark
        ? AppTheme.getDarkBackgroundDecoration()
        : AppTheme.getLightBackgroundDecoration();

    if (isDark) {
      return Container(decoration: decoration, child: child);
    }

    // Light mode: add decorative purple orbs for depth
    return Container(
      decoration: decoration,
      child: Stack(
        children: [
          // Top-right large orb
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF5B3FE8).withValues(alpha: 0.12),
                    const Color(0xFF5B3FE8).withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Bottom-left orb
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7B5CF0).withValues(alpha: 0.10),
                    const Color(0xFF7B5CF0).withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Middle accent orb
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: MediaQuery.of(context).size.width * 0.6,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF9B7AF8).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Small top-left accent
          Positioned(
            top: 120,
            left: 30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF5B3FE8).withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          child,
        ],
      ),
    );
  }
}
