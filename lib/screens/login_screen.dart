// login_screen.dart
import 'package:flutter/material.dart';
import '../widgets/auth_widgets.dart';
import 'register_screen.dart';
import 'home_page.dart';
import 'forget_password.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = "Please enter email and password");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final auth = context.read<AuthController>();
    await auth.login(email, password);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (auth.isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    } else {
      setState(() => _error = auth.error ?? "Login failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const purple = Color(0xFF5B3FE8);
    return AuthScaffold(
      title: 'Welcome back!\nGlad to see you, again!',
      showBack: false,
      children: [
        AuthTextField(
          hint: 'Email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          hint: 'Password',
          controller: _passwordController,
          obscureText: true,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              );
            },
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.8)
                    : Colors.black54,
                decoration: TextDecoration.underline,
                fontSize: 13,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        PrimaryButton(
          label: _isLoading ? 'Logging in...' : 'Login',
          onPressed: _isLoading ? null : _handleLogin,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.black54,
                letterSpacing: -0.2,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: Text(
                'Register now',
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
}
