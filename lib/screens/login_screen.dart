// login_screen.dart
import 'package:flutter/material.dart';
import '../widgets/auth_widgets.dart';
import 'register_screen.dart';
import 'home_shell.dart';
import '../state/auth_controller.dart';
import 'package:provider/provider.dart';
import 'forget_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Welcome back!\nGlad to see you, again!',
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
                color: Colors.white.withValues(alpha: 0.8),
                decoration: TextDecoration.underline,
                fontSize: 13,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        PrimaryButton(
          label: 'Login',
          onPressed: () async {
            final email = _emailController.text.trim();
            final password = _passwordController.text;

            final auth = context.read<AuthController>();

            await auth.login(email, password);

            if (!mounted) return;

            final navigator = Navigator.of(context);

            if (auth.isAuthenticated) {
              navigator.pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeShell()),
              );
            }
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
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
              child: const Text(
                'Register now',
                style: TextStyle(
                  color: kLimeAccent,
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
