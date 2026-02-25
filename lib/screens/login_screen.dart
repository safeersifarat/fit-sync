import 'package:flutter/material.dart';

import '../widgets/auth_widgets.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'home_shell.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Welcome back!\nGlad to see you, again!',
      children: [
        const AuthTextField(
          hint: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        const AuthTextField(hint: 'Password', obscureText: true),
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
          onPressed: () {
            // After a real login API call succeeds, go to the workout home shell.
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeShell()),
            );
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
