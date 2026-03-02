import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/auth_widgets.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _emailSent = false;
  String? _error;

  late AnimationController _checkAnimController;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkScale = CurvedAnimation(
      parent: _checkAnimController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _checkAnimController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address.');
      return;
    }

    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(email)) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _authService.forgotPassword(email: email);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
      _checkAnimController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const purple = Color(0xFF5B3FE8);

    if (_emailSent) {
      return _buildSuccessView(isDark, purple);
    }

    return AuthScaffold(
      title: 'Forgot\nPassword?',
      subtitle: "Don't worry! Enter your email and we'll send you a reset link.",
      children: [
        const SizedBox(height: 8),

        // Email field
        AuthTextField(
          hint: 'Enter your email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          onSubmitted: _resetPassword,
        ),

        const SizedBox(height: 24),

        // Error message
        if (_error != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.redAccent.withValues(alpha: 0.2),
                      Colors.redAccent.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent.withValues(alpha: 0.9),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Colors.redAccent.withValues(alpha: 0.9),
                          fontSize: 13,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Send reset link button
        _isLoading
            ? Center(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? kLimeAccent : purple,
                    ),
                  ),
                ),
              )
            : PrimaryButton(
                label: 'Send Reset Link',
                onPressed: _resetPassword,
              ),

        const SizedBox(height: 24),

        // Back to login
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Remember your password? ',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.black54,
                letterSpacing: -0.2,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Text(
                'Login',
                style: TextStyle(
                  color: isDark ? kLimeAccent : purple,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Success view after the email has been sent
  Widget _buildSuccessView(bool isDark, Color purple) {
    final accentColor = isDark ? kLimeAccent : purple;
    return AuthScaffold(
      title: 'Check your\nemail',
      subtitle: 'We sent a password reset link to\n${_emailController.text.trim()}',
      showBack: false,
      children: [
        const SizedBox(height: 24),

        // Animated check icon
        Center(
          child: ScaleTransition(
            scale: _checkScale,
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withValues(alpha: 0.25),
                        accentColor.withValues(alpha: 0.1),
                      ],
                    ),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.5),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.mark_email_read_rounded,
                    color: accentColor,
                    size: 44,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),

        // Info card
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.05),
                        ]
                      : [
                          Colors.black.withValues(alpha: 0.04),
                          Colors.black.withValues(alpha: 0.02),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.08),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    isDark,
                    Icons.schedule_rounded,
                    'The link will expire in 1 hour',
                  ),
                  const SizedBox(height: 14),
                  _buildInfoRow(
                    isDark,
                    Icons.all_inbox_rounded,
                    'Check your spam folder if not found',
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Resend button
        SecondaryButton(
          label: 'Resend Email',
          onPressed: () {
            setState(() => _emailSent = false);
            _checkAnimController.reset();
          },
        ),

        const SizedBox(height: 12),

        // Back to login
        PrimaryButton(
          label: 'Back to Login',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }

  Widget _buildInfoRow(bool isDark, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark
              ? Colors.white.withValues(alpha: 0.6)
              : Colors.black45,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black54,
              fontSize: 13,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}