import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/onboarding_controller.dart';
import '../widgets/ruler_picker.dart';
import 'onboarding_step_weight_screen.dart';

class OnboardingStepAgeScreen extends StatelessWidget {
  const OnboardingStepAgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<OnboardingController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StepHeader(current: 1, total: 3),
              const SizedBox(height: 24),
              const Text(
                'What is your age?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              RulerPicker(
                min: 10,
                max: 90,
                value: ctrl.age,
                onChanged: (v) => ctrl.setAge(v),
                cardColor: const Color(0xFFFFCDD2), // soft pink
                unit: 'years',
              ),
              const Spacer(),
              _NextButton(
                onNext: () {
                  if (ctrl.age < 10) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OnboardingStepWeightScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        total,
        (index) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 4,
            decoration: BoxDecoration(
              color: index < current ? Colors.black : Colors.black12,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: onNext,
        child: const Text('Next'),
      ),
    );
  }
}
