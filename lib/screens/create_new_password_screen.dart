import 'package:flutter/material.dart';

import '../widgets/auth_widgets.dart';
import 'success_screen.dart';

class CreateNewPasswordScreen extends StatelessWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create new\npassword',
      subtitle:
          'Your new password must be different from previously used passwords.',
      children: [
        const AuthTextField(hint: 'New Password', obscureText: true),
        const SizedBox(height: 16),
        const AuthTextField(hint: 'Confirm Password', obscureText: true),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Reset Password',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SuccessScreen()),
            );
          },
        ),
      ],
    );
  }
}
