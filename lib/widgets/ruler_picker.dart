import 'package:flutter/material.dart';

/// Simple horizontal ruler picker used for age/weight/height.
class RulerPicker extends StatelessWidget {
  const RulerPicker({
    super.key,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    required this.cardColor,
    this.unit,
  });

  final int min;
  final int max;
  final int value;
  final ValueChanged<int> onChanged;
  final Color cardColor;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final controller = FixedExtentScrollController(
      initialItem: (value - min).clamp(0, max - min),
    );

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      height: 180,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 120,
            child: ListWheelScrollView.useDelegate(
              controller: controller,
              physics: const FixedExtentScrollPhysics(),
              itemExtent: 40,
              onSelectedItemChanged: (index) => onChanged(min + index),
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  if (index < 0 || index > max - min) return null;
                  final v = min + index;
                  final isSelected = v == value;
                  return Center(
                    child: Text(
                      '$v',
                      style: TextStyle(
                        fontSize: isSelected ? 32 : 22,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (unit != null) ...[
            const SizedBox(height: 4),
            Text(
              unit!,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
