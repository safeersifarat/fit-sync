import 'package:flutter/material.dart';

import '../widgets/auth_background.dart';
import '../core/widgets/glass_container.dart';

enum AppSettingsFocus { none, notifications }

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key, this.initialFocus = AppSettingsFocus.none});

  final AppSettingsFocus initialFocus;

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  bool _notificationsEnabled = true;
  bool _breakfastReminder = true;
  bool _lunchReminder = true;
  bool _dinnerReminder = true;
  bool _workoutReminder = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AuthBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
          title: Text(
            'Notifications',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              _SettingsTile(
                title: 'Enable Notifications',
                subtitle: 'Turn on daily workout reminders',
                trailing: Switch(
                  value: _notificationsEnabled,
                  activeThumbColor: isDark ? Colors.black : Colors.white,
                  activeTrackColor: isDark
                      ? const Color(0xFFCCFF00)
                      : const Color(0xFF5B3FE8),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.white24,
                  onChanged: (val) {
                    setState(() {
                      _notificationsEnabled = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _notificationsEnabled ? 1.0 : 0.5,
                child: IgnorePointer(
                  ignoring: !_notificationsEnabled,
                  child: Column(
                    children: [
                      _SettingsTile(
                        title: 'Breakfast Reminder',
                        subtitle: 'Remind me to log breakfast',
                        trailing: Switch(
                          value: _breakfastReminder,
                          activeThumbColor: isDark
                              ? Colors.black
                              : Colors.white,
                          activeTrackColor: isDark
                              ? const Color(0xFFCCFF00)
                              : const Color(0xFF5B3FE8),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.white24,
                          onChanged: (val) {
                            setState(() {
                              _breakfastReminder = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SettingsTile(
                        title: 'Lunch Reminder',
                        subtitle: 'Remind me to log lunch',
                        trailing: Switch(
                          value: _lunchReminder,
                          activeThumbColor: isDark
                              ? Colors.black
                              : Colors.white,
                          activeTrackColor: isDark
                              ? const Color(0xFFCCFF00)
                              : const Color(0xFF5B3FE8),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.white24,
                          onChanged: (val) {
                            setState(() {
                              _lunchReminder = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SettingsTile(
                        title: 'Dinner Reminder',
                        subtitle: 'Remind me to log dinner',
                        trailing: Switch(
                          value: _dinnerReminder,
                          activeThumbColor: isDark
                              ? Colors.black
                              : Colors.white,
                          activeTrackColor: isDark
                              ? const Color(0xFFCCFF00)
                              : const Color(0xFF5B3FE8),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.white24,
                          onChanged: (val) {
                            setState(() {
                              _dinnerReminder = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SettingsTile(
                        title: 'Workout Reminder',
                        subtitle: 'Remind me to exercise',
                        trailing: Switch(
                          value: _workoutReminder,
                          activeThumbColor: isDark
                              ? Colors.black
                              : Colors.white,
                          activeTrackColor: isDark
                              ? const Color(0xFFCCFF00)
                              : const Color(0xFF5B3FE8),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.white24,
                          onChanged: (val) {
                            setState(() {
                              _workoutReminder = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.title, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : const Color(0xFF1A1A1A).withValues(alpha: 0.6);

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
