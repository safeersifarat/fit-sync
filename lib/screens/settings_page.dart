import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/onboarding_controller.dart';
import '../widgets/auth_background.dart';
import '../core/widgets/glass_container.dart';
import '../core/theme/app_theme.dart';
import 'app_settings_page.dart';
import 'profile_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<OnboardingController>();
    final avatarPath = ctrl.avatarPath;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProfileHeader(
                  name: ctrl.displayName,
                  height: ctrl.height,
                  weight: ctrl.weight,
                  useMetricHeight: ctrl.useMetricHeight,
                  useMetricWeight: ctrl.useMetricWeight,
                  avatarPath: avatarPath,
                  onEditAvatar: () => _onEditAvatar(context),
                ),
                const SizedBox(height: 32),
                const _SectionTitle('App Settings'),
                const SizedBox(height: 12),
                _SettingsCard(
                  children: [
                    _SettingsRow(
                      title: 'Account Informations',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ProfilePage(),
                          ),
                        );
                      },
                    ),
                    Divider(
                      height: 1,
                      color: AppTheme.getTextColor(context, opacity: 0.1),
                    ),
                    _SettingsRow(
                      title: 'Notifications',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AppSettingsPage(
                              initialFocus: AppSettingsFocus.notifications,
                            ),
                          ),
                        );
                      },
                    ),
                    Divider(
                      height: 1,
                      color: AppTheme.getTextColor(context, opacity: 0.1),
                    ),
                    _SettingsRow(
                      title: 'Text Size',
                      trailingText: 'Medium',
                      onTap: () {
                        // Placeholder for text size dialog.
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: isDark
                              ? const Color(0xFF101018)
                              : Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          builder: (ctx) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                16,
                                24,
                                24,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Text Size',
                                    style: Theme.of(ctx).textTheme.titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Coming soon. Your text size is currently set to Medium.',
                                    style: TextStyle(
                                      color: AppTheme.getTextColor(
                                        ctx,
                                        opacity: 0.7,
                                      ),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFFCCFF00,
                                        ),
                                      ),
                                      child: const Text('Close'),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _SectionTitle('Support'),
                const SizedBox(height: 12),
                const _SupportCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onEditAvatar(BuildContext context) async {
    // The actual implementation is provided in ProfilePage to keep this
    // widget lightweight. Here we just delegate to the same flow by
    // navigating to the profile editor.
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.height,
    required this.weight,
    required this.useMetricHeight,
    required this.useMetricWeight,
    required this.avatarPath,
    required this.onEditAvatar,
  });

  final String name;
  final double height;
  final double weight;
  final bool useMetricHeight;
  final bool useMetricWeight;
  final String? avatarPath;
  final VoidCallback onEditAvatar;

  @override
  Widget build(BuildContext context) {
    final heightLabel = useMetricHeight
        ? '${height.round()} cm'
        : '${(height / 2.54).round()} in';
    final weightLabel = useMetricWeight
        ? '${weight.round()} KG'
        : '${(weight * 2.205).round()} lb';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onEditAvatar,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: ClipOval(
                        child: avatarPath != null
                            ? Image.file(File(avatarPath!), fit: BoxFit.cover)
                            : Image.asset(
                                'assets/avatar_placeholder.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFCCFF00).withValues(alpha: 0.9),
                        const Color(0xFFCCFF00).withValues(alpha: 0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFCCFF00).withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '$heightLabel   •   $weightLabel',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.getTextColor(context, opacity: 0.7),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.getTextColor(context, opacity: 0.7),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(24),
      blur: 15.0,
      opacity: 0.12,
      borderWidth: 1.0,
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.title, this.trailingText, this.onTap});

  final String title;
  final String? trailingText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.getTextColor(context),
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              if (trailingText != null) ...[
                Text(
                  trailingText!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.getTextColor(context, opacity: 0.6),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.getTextColor(context, opacity: 0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      children: const [
        _SettingsRow(title: 'Terms Of Service'),
        Divider(height: 1, color: Color(0x33FFFFFF)),
        _SettingsRow(title: 'Privacy Policy'),
      ],
    );
  }
}
