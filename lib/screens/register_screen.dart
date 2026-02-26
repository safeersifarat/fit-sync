// register_screen.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../widgets/auth_widgets.dart';
import 'login_screen.dart';
import 'register_details_screen.dart';
import '../state/onboarding_controller.dart';
import '../widgets/auth_widgets.dart';
import 'login_screen.dart';
import 'onboarding_splash_screen.dart';
import '../state/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();

  String? _error;
  int _age = 25;
  double _weight = 70;
  double _height = 170;
  bool _useMetricWeight = true;
  bool _useMetricHeight = true;
  String? _gender;
  String? _avatarPath;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarPath = pickedFile.path;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      setState(() => _error = 'Please enter your name.');
      return;
    }
    if (phone.isEmpty) {
      setState(() => _error = 'Please enter your phone number.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Please enter a valid email.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    if (_gender == null) {
      setState(() => _error = 'Please select your gender.');
      return;
    }

    setState(() => _error = null);
    final ctrl = context.read<OnboardingController>();
    final auth = context.read<AuthController>();
    await auth.register(email, password, name);

    if (auth.isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingSplashScreen()),
      );
    }
    await ctrl.setDisplayName(name);
    await ctrl.setAge(_age);
    await ctrl.setWeight(_weight);
    await ctrl.setHeight(_height);
    await ctrl.setGender(_gender!);
    await ctrl.setGoal(_goal!);
    if (!_useMetricWeight) await ctrl.toggleWeightUnit();
    if (!_useMetricHeight) await ctrl.toggleHeightUnit();

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterDetailsScreen(
          name: name,
          email: email,
          phone: phone,
          password: password,
          age: _age,
          weight: _weight,
          height: _height,
          useMetricWeight: _useMetricWeight,
          useMetricHeight: _useMetricHeight,
          gender: _gender!,
          avatarPath: _avatarPath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create your\naccount',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    backgroundImage: _avatarPath != null
                        ? FileImage(File(_avatarPath!))
                        : null,
                    child: _avatarPath == null
                        ? const Icon(Icons.add_a_photo, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Name Field
              _buildSectionTitle('Full Name'),
              const SizedBox(height: 8),
              AuthTextField(
                hint: 'Enter your name',
                controller: _nameController,
                focusNode: _nameFocus,
                nextFocus: _emailFocus,
              ),
              // Phone Field
              _buildSectionTitle('Phone Number'),
              const SizedBox(height: 8),
              AuthTextField(
                hint: 'Phone Number',
                keyboardType: TextInputType.phone,
                controller: _phoneController,
                focusNode: _phoneFocus,
                nextFocus: _emailFocus,
              ),
              const SizedBox(height: 20),

              // Email Field
              _buildSectionTitle('Email'),
              const SizedBox(height: 8),
              AuthTextField(
                hint: 'Email',
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                focusNode: _emailFocus,
                nextFocus: _passwordFocus,
              ),
              const SizedBox(height: 20),

              // Password Fields
              _buildSectionTitle('Password'),
              const SizedBox(height: 8),
              AuthTextField(
                hint: 'Password',
                obscureText: true,
                controller: _passwordController,
                focusNode: _passwordFocus,
                nextFocus: _confirmFocus,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                hint: 'Confirm Password',
                obscureText: true,
                controller: _confirmController,
                focusNode: _confirmFocus,
              ),
              const SizedBox(height: 24),

              // Age Field
              _buildSectionTitle('Age'),
              const SizedBox(height: 12),
              _buildAgeSelector(),
              const SizedBox(height: 24),

              // Weight Field
              _buildSectionTitle('Weight'),
              const SizedBox(height: 12),
              _buildWeightSelector(),
              const SizedBox(height: 24),

              // Height Field
              _buildSectionTitle('Height'),
              const SizedBox(height: 12),
              _buildHeightSelector(),
              const SizedBox(height: 24),

              // Gender Selection
              _buildSectionTitle('Gender'),
              const SizedBox(height: 12),
              _buildGenderSelector(),
              const SizedBox(height: 24),

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

              // Next Button
              PrimaryButton(label: 'Next', onPressed: _onNext),
              const SizedBox(height: 16),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: -0.2,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Login now',
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
          ),
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

  Widget _buildAgeSelector() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_age',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'years',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: kLimeAccent,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                  thumbColor: kLimeAccent,
                  overlayColor: kLimeAccent.withValues(alpha: 0.2),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _age.toDouble(),
                  min: 10,
                  max: 90,
                  divisions: 80,
                  label: '$_age years',
                  onChanged: (value) {
                    setState(() => _age = value.round());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeightSelector() {
    final displayValue = _useMetricWeight
        ? _weight.round()
        : (_weight * 2.205).round();
    final unit = _useMetricWeight ? 'kg' : 'lb';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$displayValue',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  _buildUnitToggle(
                    unit1: 'kg',
                    unit2: 'lb',
                    isUnit1: _useMetricWeight,
                    onToggle: () {
                      setState(() {
                        _useMetricWeight = !_useMetricWeight;
                        if (!_useMetricWeight) {
                          _weight = _weight * 2.205;
                        } else {
                          _weight = _weight / 2.205;
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: kLimeAccent,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                  thumbColor: kLimeAccent,
                  overlayColor: kLimeAccent.withValues(alpha: 0.2),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: displayValue.toDouble(),
                  min: _useMetricWeight ? 30 : 70,
                  max: _useMetricWeight ? 200 : 400,
                  divisions: (_useMetricWeight ? 170 : 330),
                  label: '$displayValue $unit',
                  onChanged: (value) {
                    setState(() {
                      if (_useMetricWeight) {
                        _weight = value;
                      } else {
                        _weight = value / 2.205;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeightSelector() {
    final displayValue = _useMetricHeight
        ? _height.round()
        : (_height / 2.54).round();
    final unit = _useMetricHeight ? 'cm' : 'in';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$displayValue',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  _buildUnitToggle(
                    unit1: 'cm',
                    unit2: 'in',
                    isUnit1: _useMetricHeight,
                    onToggle: () {
                      setState(() {
                        _useMetricHeight = !_useMetricHeight;
                        if (!_useMetricHeight) {
                          _height = _height / 2.54;
                        } else {
                          _height = _height * 2.54;
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: kLimeAccent,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                  thumbColor: kLimeAccent,
                  overlayColor: kLimeAccent.withValues(alpha: 0.2),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: displayValue.toDouble(),
                  min: _useMetricHeight ? 120 : 48,
                  max: _useMetricHeight ? 220 : 85,
                  divisions: (_useMetricHeight ? 100 : 37),
                  label: '$displayValue $unit',
                  onChanged: (value) {
                    setState(() {
                      if (_useMetricHeight) {
                        _height = value;
                      } else {
                        _height = value * 2.54;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitToggle({
    required String unit1,
    required String unit2,
    required bool isUnit1,
    required VoidCallback onToggle,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUnitChip(
                label: unit1,
                selected: isUnit1,
                onTap: isUnit1 ? null : onToggle,
              ),
              _buildUnitChip(
                label: unit2,
                selected: !isUnit1,
                onTap: !isUnit1 ? null : onToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitChip({
    required String label,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    kLimeAccent.withValues(alpha: 0.3),
                    kLimeAccent.withValues(alpha: 0.2),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? kLimeAccent : Colors.white.withValues(alpha: 0.6),
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildChoiceChip(
          label: 'Male',
          selected: _gender == 'male',
          onTap: () => setState(() => _gender = 'male'),
        ),
        _buildChoiceChip(
          label: 'Female',
          selected: _gender == 'female',
          onTap: () => setState(() => _gender = 'female'),
        ),
        _buildChoiceChip(
          label: 'Other',
          selected: _gender == 'other',
          onTap: () => setState(() => _gender = 'other'),
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
