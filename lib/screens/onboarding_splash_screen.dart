import 'package:flutter/material.dart';

import '../widgets/auth_background.dart';
import '../widgets/auth_widgets.dart';
import 'onboarding_step_age_screen.dart';

class OnboardingSplashScreen extends StatelessWidget {
  const OnboardingSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.35),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
                const Spacer(),
                // Placeholder athlete image area – replace with actual asset later.
                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(20),
                  child: const Text(
                    'Start your\nFitness Journey',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: "Let's start",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OnboardingStepAgeScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
