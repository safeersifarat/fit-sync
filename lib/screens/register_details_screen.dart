import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../state/onboarding_controller.dart';
import '../widgets/auth_widgets.dart';
import 'home_shell.dart';

class RegisterDetailsScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String password;
  final int age;
  final double weight;
  final double height;
  final bool useMetricWeight;
  final bool useMetricHeight;
  final String gender;
  final String? avatarPath;

  const RegisterDetailsScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.age,
    required this.weight,
    required this.height,
    required this.useMetricWeight,
    required this.useMetricHeight,
    required this.gender,
    this.avatarPath,
  });

  @override
  State<RegisterDetailsScreen> createState() => _RegisterDetailsScreenState();
}

class _RegisterDetailsScreenState extends State<RegisterDetailsScreen> {
  String? _error;

  String? _goal;
  bool? _hasBackPain;
  bool? _hasKneePain;
  int? _planDuration;
  bool? _dumbbellOption;
  String? _levelOfPhysique;

  final List<String> _goals = [
    'Lose weight',
    'Build muscle',
    'Improve endurance',
    'Stay healthy',
  ];

  Future<void> _onCreateAccount() async {
    if (_goal == null) {
      setState(() => _error = 'Please select your fitness goal.');
      return;
    }
    if (_hasBackPain == null) {
      setState(() => _error = 'Please indicate if you have back pain.');
      return;
    }
    if (_hasKneePain == null) {
      setState(() => _error = 'Please indicate if you have knee pain.');
      return;
    }
    if (_planDuration == null) {
      setState(() => _error = 'Please select a plan duration.');
      return;
    }
    if (_dumbbellOption == null) {
      setState(() => _error = 'Please indicate if you have dumbbells.');
      return;
    }
    if (_levelOfPhysique == null) {
      setState(() => _error = 'Please select your level of physique.');
      return;
    }

    setState(() => _error = null);

    final ctrl = context.read<OnboardingController>();
    ctrl.setAuth(widget.email, widget.password);
    await ctrl.setDisplayName(widget.name);
    await ctrl.setPhoneNumber(widget.phone);
    await ctrl.setAge(widget.age);
    await ctrl.setWeight(widget.weight);
    await ctrl.setHeight(widget.height);

    // Convert logic from previous use cases
    if (ctrl.useMetricWeight != widget.useMetricWeight) {
      await ctrl.toggleWeightUnit();
    }
    if (ctrl.useMetricHeight != widget.useMetricHeight) {
      await ctrl.toggleHeightUnit();
    }

    await ctrl.setGoal(_goal!);
    ctrl.setHealth(backPain: _hasBackPain, kneePain: _hasKneePain);
    await ctrl.setPlanDuration(_planDuration!);
    await ctrl.setDumbbellOption(_dumbbellOption!);
    await ctrl.setLevelOfPhysique(_levelOfPhysique!);
    await ctrl.setGender(widget.gender);
    if (widget.avatarPath != null) {
      await ctrl.setAvatarPath(widget.avatarPath);
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'More\nDetails',
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal Selection
            _buildSectionTitle('Fitness Goal'),
            const SizedBox(height: 12),
            _buildGoalSelector(),
            const SizedBox(height: 24),

            // Back Pain
            _buildSectionTitle('Do you have Back Pain?'),
            const SizedBox(height: 12),
            _buildYesNoSelector(
              value: _hasBackPain,
              onChanged: (val) => setState(() => _hasBackPain = val),
            ),
            const SizedBox(height: 24),

            // Knee Pain
            _buildSectionTitle('Do you have Knee Pain?'),
            const SizedBox(height: 12),
            _buildYesNoSelector(
              value: _hasKneePain,
              onChanged: (val) => setState(() => _hasKneePain = val),
            ),
            const SizedBox(height: 24),

            // Dumbbell Option
            _buildSectionTitle('Do you have dumbbells?'),
            const SizedBox(height: 12),
            _buildYesNoSelector(
              value: _dumbbellOption,
              onChanged: (val) => setState(() => _dumbbellOption = val),
            ),
            const SizedBox(height: 24),

            // Plan Duration
            _buildSectionTitle('Plan Duration'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildChoiceChip(
                  label: '3 Months',
                  selected: _planDuration == 3,
                  onTap: () => setState(() => _planDuration = 3),
                ),
                _buildChoiceChip(
                  label: '6 Months',
                  selected: _planDuration == 6,
                  onTap: () => setState(() => _planDuration = 6),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Level of Physique
            _buildSectionTitle('Level of Physique'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildChoiceChip(
                  label: 'Easy',
                  selected: _levelOfPhysique == 'easy',
                  onTap: () => setState(() => _levelOfPhysique = 'easy'),
                ),
                _buildChoiceChip(
                  label: 'Medium',
                  selected: _levelOfPhysique == 'medium',
                  onTap: () => setState(() => _levelOfPhysique = 'medium'),
                ),
                _buildChoiceChip(
                  label: 'Hard',
                  selected: _levelOfPhysique == 'hard',
                  onTap: () => setState(() => _levelOfPhysique = 'hard'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Error Message
            if (_error != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.redAccent.withValues(alpha: 0.2),
                          Colors.redAccent.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Colors.redAccent.withValues(alpha: 0.9),
                        fontSize: 13,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Create Account Button
            PrimaryButton(label: 'Create Account', onPressed: _onCreateAccount),
            const SizedBox(height: 30),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.9),
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildGoalSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _goals.map((goal) {
        return _buildChoiceChip(
          label: goal,
          selected: _goal == goal,
          onTap: () => setState(() => _goal = goal),
        );
      }).toList(),
    );
  }

  Widget _buildYesNoSelector({
    required bool? value,
    required ValueChanged<bool> onChanged,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildChoiceChip(
          label: 'Yes',
          selected: value == true,
          onTap: () => onChanged(true),
        ),
        _buildChoiceChip(
          label: 'No',
          selected: value == false,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(
                      0xFFC6FF00,
                    ).withValues(alpha: 0.3), // kLimeAccent
                    const Color(0xFFC6FF00).withValues(alpha: 0.2),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFFC6FF00).withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.2),
            width: selected ? 2 : 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFFC6FF00).withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? const Color(0xFFC6FF00)
                : Colors.white.withValues(alpha: 0.8),
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}
