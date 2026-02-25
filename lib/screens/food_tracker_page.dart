import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../state/calorie_tracker_controller.dart';
import 'meal_mode_selection_page.dart';

class FoodTrackerPage extends StatelessWidget {
  const FoodTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CalorieTrackerController>();
    final selectedDay = controller.selectedDate;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _CalendarHeader(
              selectedDay: selectedDay,
              onDaySelected: controller.setSelectedDate,
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: _MealList(date: selectedDay),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.selectedDay,
    required this.onDaySelected,
  });

  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF004D40), Color(0xFF1B5E20)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            '${selectedDay.day}, ${_monthName(selectedDay.month)} ${selectedDay.year}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          TableCalendar(
            focusedDay: selectedDay,
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            calendarFormat: CalendarFormat.week,
            headerVisible: false,
            availableGestures: AvailableGestures.horizontalSwipe,
            selectedDayPredicate: (day) =>
                day.year == selectedDay.year &&
                day.month == selectedDay.month &&
                day.day == selectedDay.day,
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: Color(0xFFCCFF00),
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              defaultTextStyle: const TextStyle(color: Colors.white),
              weekendTextStyle: const TextStyle(color: Colors.white70),
              todayDecoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: (selected, focused) => onDaySelected(selected),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }
}

class _MealList extends StatelessWidget {
  const _MealList({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final items = [
      _MealCardData(
        type: MealType.breakfast,
        title: 'Breakfast',
        timeLabel: '08:00 AM',
        color: const Color(0xFFFFCDD2),
      ),
      _MealCardData(
        type: MealType.lunch,
        title: 'Lunch',
        timeLabel: '12:30 PM',
        color: const Color(0xFFFFF9C4),
      ),
      _MealCardData(
        type: MealType.dinner,
        title: 'Dinner',
        timeLabel: '07:00 PM',
        color: const Color(0xFFB3E5FC),
      ),
      _MealCardData(
        type: MealType.snack,
        title: 'Snacks',
        timeLabel: '04:30 PM',
        color: const Color(0xFFD1C4E9),
      ),
    ];

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MealModeSelectionPage(
                  mealType: item.type,
                  title: item.title,
                  timeLabel: item.timeLabel,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.timeLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MealModeSelectionPage(
                          mealType: item.type,
                          title: item.title,
                          timeLabel: item.timeLabel,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MealCardData {
  _MealCardData({
    required this.type,
    required this.title,
    required this.timeLabel,
    required this.color,
  });

  final MealType type;
  final String title;
  final String timeLabel;
  final Color color;
}
