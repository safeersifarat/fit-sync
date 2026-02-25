import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/onboarding_controller.dart';
import '../widgets/auth_background.dart';
import '../widgets/calorie_line_chart.dart';
import '../widgets/schedule_timeline.dart';
import '../widgets/workout_notification.dart';
import 'dumbbell_workout_screen.dart';

class WorkoutHomePage extends StatefulWidget {
  const WorkoutHomePage({
    super.key,
    required this.onSettingsTap,
    required this.onProfileTap,
  });

  final VoidCallback onSettingsTap;
  final VoidCallback onProfileTap;

  @override
  State<WorkoutHomePage> createState() => _WorkoutHomePageState();
}

class _WorkoutHomePageState extends State<WorkoutHomePage> {
  final List<Map<String, String>> _upcomingWorkouts = [
    {
      'title': 'Pushups session',
      'details': '25 rep, 3 sets with 20 sec rest',
      'time': '04:00 PM',
    },
    {'title': 'WarmUp', 'details': 'Run 02 km', 'time': '02:00 PM'},
  ];

  @override
  void initState() {
    super.initState();
    // Show notification after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _upcomingWorkouts.isNotEmpty) {
        _showWorkoutNotification();
      }
    });
  }

  void _showWorkoutNotification() {
    if (_upcomingWorkouts.isEmpty) return;

    final workout = _upcomingWorkouts.first;
    showWorkoutNotification(
      context,
      workoutTitle: workout['title']!,
      workoutDetails: workout['details']!,
      scheduledTime: workout['time']!,
      onTap: () {
        // Navigate to workout start page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DumbbellWorkoutScreen(
              title: workout['title']!,
              targetReps: workout['title']!.contains('rep') ? 25 : null,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = context.watch<OnboardingController>().displayName;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AuthBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(
                      name: name,
                      onSettingsTap: widget.onSettingsTap,
                      onProfileTap: widget.onProfileTap,
                    ),
                    const SizedBox(height: 24),
                    const CalorieLineChart(),
                    const SizedBox(height: 24),
                    _ScheduleSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.onSettingsTap,
    required this.onProfileTap,
  });

  final String name;
  final VoidCallback onSettingsTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<OnboardingController>();
    final avatarPath = ctrl.avatarPath;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hi!,', style: Theme.of(context).textTheme.headlineMedium),
            Text(name, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onSettingsTap,
                    child: Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onProfileTap,
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.2),
                                Colors.white.withValues(alpha: 0.1),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: ClipOval(
                              child: avatarPath != null
                                  ? Image.file(
                                      File(avatarPath),
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/avatar_placeholder.png',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      ScheduleItem(title: 'WarmUp', subtitle: 'Run 02 km', isFirst: true),
      ScheduleItem(
        title: 'Muscle Up',
        subtitle: '10 reps, 3 sets with 20 sec rest',
      ),
      ScheduleItem(
        title: 'Cool Down',
        subtitle: 'Stretching 10 minutes',
        isLast: true,
      ),
    ];

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your\nSchedule',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: const Icon(
                      Icons.filter_list,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Today's Activity",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ScheduleTimeline(
              items: items,
              onStartTap: (item) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DumbbellWorkoutScreen(
                      title: item.title,
                      targetReps: item.title == 'Muscle Up' ? 10 : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
