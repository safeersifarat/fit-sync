import 'package:flutter/material.dart';

import '../widgets/auth_widgets.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Forgot Password?',
      subtitle:
          'Enter your email address and we\'ll send you a\nverification code.',
      children: [
        const AuthTextField(
          hint: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Send Code',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OTPVerificationScreen()),
            );
          },
        ),
      ],
    );
  }
}
