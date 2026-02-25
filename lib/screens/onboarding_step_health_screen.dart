import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/onboarding_controller.dart';
import 'onboarding_step_goal_screen.dart';

class OnboardingStepHealthScreen extends StatelessWidget {
  const OnboardingStepHealthScreen({super.key});

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
              const _StepHeader(current: 3, total: 3),
              const SizedBox(height: 24),
              const Text(
                'Health & Limitations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              _YesNoRow(
                label: 'Do you have back pain?',
                value: ctrl.hasBackPain,
                onChanged: (v) => ctrl.setHealth(backPain: v),
              ),
              const SizedBox(height: 12),
              _YesNoRow(
                label: 'Do you have knee pain?',
                value: ctrl.hasKneePain,
                onChanged: (v) => ctrl.setHealth(kneePain: v),
              ),
              const SizedBox(height: 12),
              _YesNoRow(
                label: 'Any heart issues?',
                value: ctrl.hasHeartIssue,
                onChanged: (v) => ctrl.setHealth(heartIssue: v),
              ),
              const Spacer(),
              _NextButton(
                onNext: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OnboardingStepGoalScreen(),
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

class _YesNoRow extends StatelessWidget {
  const _YesNoRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.black87)),
        ),
        const SizedBox(width: 16),
        ToggleButtons(
          isSelected: [!value, value],
          borderRadius: BorderRadius.circular(16),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 32),
          onPressed: (index) => onChanged(index == 1),
          children: const [Text('No'), Text('Yes')],
        ),
      ],
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
