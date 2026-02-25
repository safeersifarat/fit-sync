import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/onboarding_controller.dart';
import '../widgets/ruler_picker.dart';
import 'onboarding_step_bmi_screen.dart';

class OnboardingStepHeightScreen extends StatelessWidget {
  const OnboardingStepHeightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<OnboardingController>();
    final isCm = ctrl.useMetricHeight;
    final displayValue = isCm
        ? ctrl.height.round()
        : (ctrl.height / 2.54).round();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _StepHeader(current: 2, total: 3),
              const SizedBox(height: 24),
              const Text(
                'What is your height?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('cm'),
                    selected: isCm,
                    onSelected: (v) {
                      if (!isCm) ctrl.toggleHeightUnit();
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('in'),
                    selected: !isCm,
                    onSelected: (v) {
                      if (isCm) ctrl.toggleHeightUnit();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              RulerPicker(
                min: isCm ? 120 : 48,
                max: isCm ? 220 : 85,
                value: displayValue,
                onChanged: (v) {
                  final newCm = isCm ? v.toDouble() : v * 2.54;
                  ctrl.setHeight(newCm);
                },
                cardColor: const Color(0xFFB3E5FC), // soft blue
                unit: isCm ? 'cm' : 'in',
              ),
              const Spacer(),
              _NextButton(
                onNext: () {
                  if (ctrl.height <= 0) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OnboardingStepBmiScreen(),
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
