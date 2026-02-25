import 'package:flutter/material.dart';
import 'dart:ui';

/// Reusable liquid glass container widget
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 20.0,
    this.opacity,
    this.borderWidth = 1.5,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blur;
  final double? opacity;
  final double borderWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final baseOpacity = opacity ?? (isDark ? 0.15 : 0.25);
    final glassColor = isDark ? Colors.white : Colors.black;
    final borderColor = isDark ? Colors.white : Colors.black;
    final shadowColor = isDark ? Colors.black : Colors.white;

    final container = ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          margin: margin,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                glassColor.withValues(alpha: baseOpacity),
                glassColor.withValues(alpha: baseOpacity * 0.3),
              ],
            ),
            borderRadius: borderRadius ?? BorderRadius.circular(24),
            border: Border.all(
              color: borderColor.withValues(alpha: isDark ? 0.2 : 0.15),
              width: borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withValues(alpha: isDark ? 0.1 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: container);
    }

    return container;
  }
}

/// Minimal glass card for lists
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: margin,
      borderRadius: BorderRadius.circular(20),
      blur: 15.0,
      opacity: 0.12,
      borderWidth: 1.0,
      onTap: onTap,
      child: child,
    );
  }
}

/// Glass button
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      borderRadius: BorderRadius.circular(28),
      blur: 15.0,
      opacity: 0.2,
      borderWidth: 1.5,
      onTap: onPressed,
      child: child,
    );
  }
}
