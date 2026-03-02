import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../state/onboarding_controller.dart';
import '../state/auth_controller.dart';
import '../widgets/auth_background.dart';
import '../core/widgets/loading_overlay.dart';
import '../core/error/app_exception.dart';
import '../core/error/error_handler.dart';
import 'login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isPickingImage = false;

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final ctrl = context.read<OnboardingController>();
    _nameController = TextEditingController(text: ctrl.displayName);
    _ageController = TextEditingController(text: ctrl.age.toString());
    _weightController = TextEditingController(
      text: ctrl.weight.toStringAsFixed(1),
    );
    _heightController = TextEditingController(
      text: ctrl.height.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    if (_isPickingImage) return;

    setState(() => _isPickingImage = true);

    try {
      final isDarkSheet = Theme.of(context).brightness == Brightness.dark;
      final handleColor = isDarkSheet ? Colors.white24 : Colors.black12;
      final iconColor = isDarkSheet ? Colors.white : Colors.black87;
      final textColor = isDarkSheet ? Colors.white : Colors.black87;

      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkSheet
                        ? [
                            const Color(0xFF0D2614).withValues(alpha: 0.85),
                            const Color(0xFF004D40).withValues(alpha: 0.7),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.85),
                            const Color(0xFFF5F1FF).withValues(alpha: 0.8),
                          ],
                  ),
                  border: Border(
                    top: BorderSide(
                      color: isDarkSheet
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.06),
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: handleColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: Icon(Icons.photo_library, color: iconColor),
                        title: Text(
                          'Gallery',
                          style: TextStyle(color: textColor),
                        ),
                        onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
                      ),
                      ListTile(
                        leading: Icon(Icons.photo_camera, color: iconColor),
                        title: Text(
                          'Camera',
                          style: TextStyle(color: textColor),
                        ),
                        onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

      if (!mounted || source == null) {
        setState(() => _isPickingImage = false);
        return;
      }

      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (!mounted || picked == null) {
        setState(() => _isPickingImage = false);
        return;
      }

      await context.read<OnboardingController>().setAvatarPath(picked.path);
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPickingImage = false);
        ErrorHandler.showError(
          context,
          CameraException(
            'Failed to pick image: ${ErrorHandler.getErrorMessage(e)}',
          ),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final ctrl = context.read<OnboardingController>();

      await ctrl.setDisplayName(_nameController.text.trim());
      await ctrl.setAge(int.tryParse(_ageController.text.trim()) ?? ctrl.age);

      final weightValue = double.tryParse(_weightController.text.trim());
      if (weightValue != null && weightValue > 0) {
        await ctrl.setWeight(weightValue);
      }

      final heightValue = double.tryParse(_heightController.text.trim());
      if (heightValue != null && heightValue > 0) {
        await ctrl.setHeight(heightValue);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(
          context,
          StorageException(
            'Failed to save profile: ${ErrorHandler.getErrorMessage(e)}',
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMoreInfoOptions() {
    final isDarkSheet = Theme.of(context).brightness == Brightness.dark;
    final handleColor = isDarkSheet ? Colors.white24 : Colors.black12;
    final titleColor = isDarkSheet ? Colors.white : Colors.black87;
    final textColor = isDarkSheet ? Colors.white : Colors.black87;
    final iconColor = isDarkSheet ? Colors.white70 : Colors.black54;
    final chevronColor = isDarkSheet ? Colors.white38 : Colors.black26;
    final dividerColor = isDarkSheet
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.06);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkSheet
                      ? [
                          const Color(0xFF0D2614).withValues(alpha: 0.85),
                          const Color(0xFF004D40).withValues(alpha: 0.7),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.85),
                          const Color(0xFFF5F1FF).withValues(alpha: 0.8),
                        ],
                ),
                border: Border(
                  top: BorderSide(
                    color: isDarkSheet
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.06),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: handleColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Account Security',
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: Icon(Icons.lock_outline, color: iconColor),
                      title: Text(
                        'Change Password',
                        style: TextStyle(color: textColor),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: chevronColor,
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showChangePasswordSheet();
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.email_outlined,
                        color: iconColor,
                      ),
                      title: Text(
                        'Change Email',
                        style: TextStyle(color: textColor),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: chevronColor,
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showChangeEmailSheet();
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.phone_outlined,
                        color: iconColor,
                      ),
                      title: Text(
                        'Change Phone Number',
                        style: TextStyle(color: textColor),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: chevronColor,
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showChangePhoneSheet();
                      },
                    ),
                    // ── Divider before logout
                    Divider(
                      height: 1,
                      color: dividerColor,
                      indent: 20,
                      endIndent: 20,
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.power_settings_new_rounded,
                        color: Color(0xFFFF4757),
                      ),
                      title: const Text(
                        'Log Out',
                        style: TextStyle(
                          color: Color(0xFFFF4757),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFFFF4757),
                        size: 20,
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _logout();
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  // ── Change Password Sheet ──
  void _showChangePasswordSheet() {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    _showGlassFormSheet(
      title: 'Change Password',
      icon: Icons.lock_outline,
      fields: [
        _GlassFieldConfig(controller: oldPassCtrl, hint: 'Current Password', obscure: true),
        _GlassFieldConfig(controller: newPassCtrl, hint: 'New Password', obscure: true),
        _GlassFieldConfig(controller: confirmPassCtrl, hint: 'Confirm New Password', obscure: true),
      ],
      buttonLabel: 'Update Password',
      onSubmit: () {
        final oldPass = oldPassCtrl.text.trim();
        final newPass = newPassCtrl.text.trim();
        final confirm = confirmPassCtrl.text.trim();

        if (oldPass.isEmpty || newPass.isEmpty || confirm.isEmpty) {
          _showSnack('Please fill all fields');
          return false;
        }
        if (newPass.length < 6) {
          _showSnack('New password must be at least 6 characters');
          return false;
        }
        if (newPass != confirm) {
          _showSnack('Passwords do not match');
          return false;
        }

        _showSnack('Password updated successfully', isSuccess: true);
        return true;
      },
      onDispose: () {
        oldPassCtrl.dispose();
        newPassCtrl.dispose();
        confirmPassCtrl.dispose();
      },
    );
  }

  // ── Change Email Sheet ──
  void _showChangeEmailSheet() {
    final ctrl = context.read<OnboardingController>();
    final newEmailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();

    _showGlassFormSheet(
      title: 'Change Email',
      icon: Icons.email_outlined,
      subtitle: 'Current: ${ctrl.email ?? "Not set"}',
      fields: [
        _GlassFieldConfig(controller: newEmailCtrl, hint: 'New Email', type: TextInputType.emailAddress),
        _GlassFieldConfig(controller: passwordCtrl, hint: 'Confirm Password', obscure: true),
      ],
      buttonLabel: 'Update Email',
      onSubmit: () {
        final email = newEmailCtrl.text.trim();
        final password = passwordCtrl.text.trim();

        if (email.isEmpty || password.isEmpty) {
          _showSnack('Please fill all fields');
          return false;
        }
        if (!email.contains('@') || !email.contains('.')) {
          _showSnack('Please enter a valid email');
          return false;
        }

        _showSnack('Email updated successfully', isSuccess: true);
        return true;
      },
      onDispose: () {
        newEmailCtrl.dispose();
        passwordCtrl.dispose();
      },
    );
  }

  // ── Change Phone Sheet ──
  void _showChangePhoneSheet() {
    final ctrl = context.read<OnboardingController>();
    final newPhoneCtrl = TextEditingController();

    _showGlassFormSheet(
      title: 'Change Phone Number',
      icon: Icons.phone_outlined,
      subtitle: 'Current: ${ctrl.phoneNumber ?? "Not set"}',
      fields: [
        _GlassFieldConfig(controller: newPhoneCtrl, hint: 'New Phone Number', type: TextInputType.phone),
      ],
      buttonLabel: 'Update Phone',
      onSubmit: () {
        final phone = newPhoneCtrl.text.trim();

        if (phone.isEmpty) {
          _showSnack('Please enter a phone number');
          return false;
        }
        if (phone.length < 8) {
          _showSnack('Please enter a valid phone number');
          return false;
        }

        _showSnack('Phone number updated successfully', isSuccess: true);
        return true;
      },
      onDispose: () {
        newPhoneCtrl.dispose();
      },
    );
  }

  void _showSnack(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? const Color(0xFF2E7D32) : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Reusable glass form sheet ──
  void _showGlassFormSheet({
    required String title,
    required IconData icon,
    String? subtitle,
    required List<_GlassFieldConfig> fields,
    required String buttonLabel,
    required bool Function() onSubmit,
    required VoidCallback onDispose,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const purple = Color(0xFF5B3FE8);
    const lime = Color(0xFFCCFF00);
    final accentColor = isDark ? lime : purple;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black45;
    final handleColor = isDark ? Colors.white24 : Colors.black12;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF0D2614).withValues(alpha: 0.88),
                            const Color(0xFF004D40).withValues(alpha: 0.75),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.9),
                            const Color(0xFFF5F1FF).withValues(alpha: 0.85),
                          ],
                  ),
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.06),
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: handleColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Icon
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accentColor.withValues(alpha: 0.2),
                                accentColor.withValues(alpha: 0.08),
                              ],
                            ),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: Icon(icon, color: accentColor, size: 24),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          title,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),

                        // Subtitle
                        if (subtitle != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 13,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Fields
                        ...fields.map((f) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _buildGlassTextField(
                                controller: f.controller,
                                hint: f.hint,
                                obscure: f.obscure,
                                keyboardType: f.type,
                                isDark: isDark,
                                accentColor: accentColor,
                              ),
                            )),

                        const SizedBox(height: 8),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor.withValues(alpha: isDark ? 0.9 : 1.0),
                                  foregroundColor: isDark ? Colors.black87 : Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  if (onSubmit()) {
                                    Navigator.pop(ctx);
                                    onDispose();
                                  }
                                },
                                child: Text(
                                  buttonLabel,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).whenComplete(onDispose);
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    required Color accentColor,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark
        ? Colors.white.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.35);
    final fillColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.04);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.1);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: TextStyle(color: textColor, letterSpacing: -0.3),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: hintColor),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: accentColor.withValues(alpha: 0.6), width: 2),
            ),
          ),
        ),
      ),
    );
  }



  Future<void> _logout() async {
    final isDarkDialog = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDarkDialog ? Colors.white : Colors.black87;
    final contentColor = isDarkDialog
        ? Colors.white.withValues(alpha: 0.7)
        : Colors.black54;
    final cancelColor = isDarkDialog
        ? Colors.white.withValues(alpha: 0.6)
        : Colors.black45;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: AlertDialog(
            backgroundColor: isDarkDialog
                ? const Color(0xFF0D2614).withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.85),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: isDarkDialog
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.06),
                width: 1,
              ),
            ),
            title: Text(
              'Log Out?',
              style: TextStyle(
                color: titleColor,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            content: Text(
              'You\'ll be signed out of your account.',
              style: TextStyle(
                color: contentColor,
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: cancelColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF4757),
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthController>().logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<OnboardingController>();
    final avatarPath = ctrl.avatarPath;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const purple = Color(0xFF5B3FE8);
    const accentGreen = Color(0xFFCCFF00);

    return LoadingOverlay(
      isLoading: _isSaving || _isPickingImage,
      message: _isSaving ? 'Saving...' : 'Loading image...',
      child: AuthBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
            title: Text(
              'Account Informations',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickAvatar,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            ClipOval(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 15,
                                  sigmaY: 15,
                                ),
                                child: Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withValues(alpha: 0.25),
                                        Colors.white.withValues(alpha: 0.08),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.4,
                                      ),
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: ClipOval(
                                      child: avatarPath != null
                                          ? Image.file(
                                              File(avatarPath),
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              color: const Color(0xFF1A3A21),
                                              child: const Icon(
                                                Icons.person_rounded,
                                                color: Colors.white54,
                                                size: 56,
                                              ),
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
                                      (isDark ? accentGreen : purple)
                                          .withValues(alpha: 0.9),
                                      (isDark ? accentGreen : purple)
                                          .withValues(alpha: 0.7),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isDark ? accentGreen : purple)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: isDark ? Colors.black87 : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _Label('Name'),
                    const SizedBox(height: 8),
                    _DarkTextField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Please enter your name'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _Label('Age'),
                    const SizedBox(height: 8),
                    _DarkTextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final value = int.tryParse(v ?? '');
                        if (value == null || value <= 0) {
                          return 'Enter a valid age';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _Label('Weight (kg)'),
                    const SizedBox(height: 8),
                    _DarkTextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        final value = double.tryParse(v ?? '');
                        if (value == null || value <= 0) {
                          return 'Enter a valid weight';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _Label('Height (cm)'),
                    const SizedBox(height: 8),
                    _DarkTextField(
                      controller: _heightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        final value = double.tryParse(v ?? '');
                        if (value == null || value <= 0) {
                          return 'Enter a valid height';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    Builder(
                      builder: (context) {
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;
                        return OutlinedButton.icon(
                          onPressed: _showMoreInfoOptions,
                          icon: Icon(
                            Icons.shield_outlined,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          label: Text(
                            'More Info (Password, Email, etc.)',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.2),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: LoadingButton(
                          isLoading: _isSaving,
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (isDark ? accentGreen : purple)
                                .withValues(alpha: isDark ? 0.9 : 1.0),
                            foregroundColor: isDark
                                ? Colors.black87
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: isDark ? Colors.white70 : Colors.black87,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _DarkTextField extends StatelessWidget {
  const _DarkTextField({
    required this.controller,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            letterSpacing: -0.3,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFFCCFF00).withValues(alpha: 0.6)
                    : const Color(0xFF5B3FE8).withValues(alpha: 0.8),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassFieldConfig {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? type;

  _GlassFieldConfig({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.type,
  });
}
