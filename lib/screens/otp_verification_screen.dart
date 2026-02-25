import 'package:flutter/material.dart';

import '../widgets/auth_widgets.dart';
import 'create_new_password_screen.dart';

class OTPVerificationScreen extends StatelessWidget {
  const OTPVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'OTP Verification',
      subtitle: 'Enter the 4-digit code we sent to your email.',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            4,
            (index) => SizedBox(
              width: 64,
              child: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 0,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          label: 'Verify',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateNewPasswordScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
          },
          child: const Text(
            'Didn\'t receive code? Resend',
            style: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
