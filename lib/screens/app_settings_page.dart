import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/onboarding_controller.dart';
import '../widgets/auth_background.dart';
import '../core/widgets/glass_container.dart';
import '../core/theme/theme_controller.dart';

enum AppSettingsFocus { none, notifications }

class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({super.key, this.initialFocus = AppSettingsFocus.none});

  final AppSettingsFocus initialFocus;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<OnboardingController>();
    final themeController = context.watch<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        ),
        title: Text(
          'App Setting',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: AuthBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              _SettingsTile(
                title: 'Reminder',
                subtitle: 'Daily workout reminders',
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white70,
                ),
                onTap: () {
                  // Placeholder for reminder preferences.
                },
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                title: 'Change Password',
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white70,
                ),
                onTap: () {
                  // Placeholder for change password flow.
                },
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                title: 'Apple Health',
                trailing: Switch(
                  value: ctrl.appleHealthEnabled,
                  activeThumbColor: Colors.black,
                  activeTrackColor: const Color(0xFFCCFF00),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.white24,
                  onChanged: (_) => ctrl.toggleAppleHealth(),
                ),
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                title: 'Dark Mode',
                trailing: Switch(
                  value: ctrl.darkModeEnabled,
                  activeThumbColor: Colors.black,
                  activeTrackColor: const Color(0xFFCCFF00),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.white24,
                  onChanged: (_) async {
                    await ctrl.toggleDarkMode();
                    themeController.syncWithOnboarding(ctrl.darkModeEnabled);
                  },
                ),
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                title: 'Language',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _languageLabel(ctrl.languageCode),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white70,
                    ),
                  ],
                ),
                onTap: () => _showLanguageSheet(context, ctrl),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _languageLabel(String code) {
    switch (code) {
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'en':
      default:
        return 'English';
    }
  }

  void _showLanguageSheet(BuildContext context, OnboardingController ctrl) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF101018) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final dividerColor = isDark ? Colors.white24 : Colors.black12;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('English', style: TextStyle(color: textColor)),
                trailing: ctrl.languageCode == 'en'
                    ? const Icon(Icons.check, color: Color(0xFFCCFF00))
                    : null,
                onTap: () {
                  ctrl.setLanguage('en');
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                title: Text('Spanish', style: TextStyle(color: textColor)),
                trailing: ctrl.languageCode == 'es'
                    ? const Icon(Icons.check, color: Color(0xFFCCFF00))
                    : null,
                onTap: () {
                  ctrl.setLanguage('es');
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                title: Text('French', style: TextStyle(color: textColor)),
                trailing: ctrl.languageCode == 'fr'
                    ? const Icon(Icons.check, color: Color(0xFFCCFF00))
                    : null,
                onTap: () {
                  ctrl.setLanguage('fr');
                  Navigator.of(ctx).pop();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : const Color(0xFF6A6A6A);

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: subtitleColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
