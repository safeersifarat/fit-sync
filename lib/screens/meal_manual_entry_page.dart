import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/calorie_tracker_controller.dart';

class MealManualEntryPage extends StatefulWidget {
  const MealManualEntryPage({
    super.key,
    required this.mealType,
    required this.title,
    required this.timeLabel,
  });

  final MealType mealType;
  final String title;
  final String timeLabel;

  @override
  State<MealManualEntryPage> createState() => _MealManualEntryPageState();
}

class _MealManualEntryPageState extends State<MealManualEntryPage> {
  final _nameController = TextEditingController();
  double _carbs = 30;
  double _fats = 15;
  double _protein = 20;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Manual - ${widget.title}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meal Name',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter your meal name...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _MacroSlider(
              label: 'Total Carbs',
              color: Colors.greenAccent,
              value: _carbs,
              onChanged: (v) => setState(() => _carbs = v),
            ),
            const SizedBox(height: 12),
            _MacroSlider(
              label: 'Total Fats',
              color: Colors.blueAccent,
              value: _fats,
              onChanged: (v) => setState(() => _fats = v),
            ),
            const SizedBox(height: 12),
            _MacroSlider(
              label: 'Total Protein',
              color: Colors.purpleAccent,
              value: _protein,
              onChanged: (v) => setState(() => _protein = v),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  final ctrl = context.read<CalorieTrackerController>();
                  final date = ctrl.selectedDate;
                  final timeOfDay = TimeOfDay.now();
                  final entry = MealEntry(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    type: widget.mealType,
                    date: date,
                    timeOfDay: timeOfDay,
                    name: _nameController.text.isEmpty
                        ? widget.title
                        : _nameController.text,
                    carbs: _carbs,
                    fats: _fats,
                    protein: _protein,
                    estimatedCalories:
                        (_carbs * 4) + (_protein * 4) + (_fats * 9),
                  );
                  ctrl.addEntry(entry);
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroSlider extends StatelessWidget {
  const _MacroSlider({
    required this.label,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final Color color;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            Text(
              '${value.toInt()} g',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: Colors.white24,
          ),
          child: Slider(min: 0, max: 100, value: value, onChanged: onChanged),
        ),
      ],
    );
  }
}
