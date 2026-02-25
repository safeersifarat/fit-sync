import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/onboarding_controller.dart';
import '../widgets/ruler_picker.dart';
import 'onboarding_step_height_screen.dart';

class OnboardingStepWeightScreen extends StatelessWidget {
  const OnboardingStepWeightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<OnboardingController>();
    final isKg = ctrl.useMetricWeight;
    final displayValue = isKg
        ? ctrl.weight.round()
        : (ctrl.weight * 2.205).round();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _StepHeader(current: 1, total: 3),
              const SizedBox(height: 24),
              const Text(
                'What is your weight?',
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
                    label: const Text('kg'),
                    selected: isKg,
                    onSelected: (v) {
                      if (!isKg) ctrl.toggleWeightUnit();
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('lb'),
                    selected: !isKg,
                    onSelected: (v) {
                      if (isKg) ctrl.toggleWeightUnit();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              RulerPicker(
                min: isKg ? 30 : 70,
                max: isKg ? 200 : 400,
                value: displayValue,
                onChanged: (v) {
                  final newKg = isKg ? v.toDouble() : v / 2.205;
                  ctrl.setWeight(newKg);
                },
                cardColor: const Color(0xFFFFF9C4), // soft yellow
                unit: isKg ? 'kg' : 'lb',
              ),
              const Spacer(),
              _NextButton(
                onNext: () {
                  if (ctrl.weight <= 0) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OnboardingStepHeightScreen(),
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
