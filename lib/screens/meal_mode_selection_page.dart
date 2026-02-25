import 'package:flutter/material.dart';

import '../state/calorie_tracker_controller.dart';
import 'meal_manual_entry_page.dart';
import 'meal_ai_scan_page.dart';

class MealModeSelectionPage extends StatelessWidget {
  const MealModeSelectionPage({
    super.key,
    required this.mealType,
    required this.title,
    required this.timeLabel,
  });

  final MealType mealType;
  final String title;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('$title - $timeLabel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How would you like to log this meal?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            _ModeTile(
              icon: Icons.edit_note_rounded,
              title: 'Manual Mode',
              subtitle: 'Enter meal details manually.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MealManualEntryPage(
                      mealType: mealType,
                      title: title,
                      timeLabel: timeLabel,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _ModeTile(
              icon: Icons.camera_alt_rounded,
              title: 'AI Scan',
              subtitle: 'Use camera to estimate calories.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MealAiScanPage(
                      mealType: mealType,
                      title: title,
                      timeLabel: timeLabel,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white12,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
