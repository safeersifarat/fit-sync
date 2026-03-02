import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:ui';

import '../state/calorie_tracker_controller.dart';
import '../widgets/auth_background.dart';
import '../core/widgets/glass_container.dart';

enum TimeView { day, week, month }

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  TimeView _selectedView = TimeView.day;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = _formatDate(now);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(dateStr: dateStr),
                const SizedBox(height: 24),
                _TimeToggle(
                  selected: _selectedView,
                  onChanged: (view) => setState(() => _selectedView = view),
                ),
                const SizedBox(height: 24),
                _CaloriesBarChart(view: _selectedView),
                const SizedBox(height: 24),
                const _NetCalorieBalance(),
                if (_selectedView == TimeView.day) ...[
                  const SizedBox(height: 24),
                  const _MacronutrientRingChart(),
                ],
                const SizedBox(height: 24),
                const _StreakCalendarCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.dateStr});

  final String dateStr;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateStr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white54 : Colors.black45,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your Statistics',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeToggle extends StatelessWidget {
  const _TimeToggle({required this.selected, required this.onChanged});

  final TimeView selected;
  final ValueChanged<TimeView> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(4),
      borderRadius: BorderRadius.circular(16),
      blur: 15.0,
      opacity: 0.12,
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'Day',
              isSelected: selected == TimeView.day,
              onTap: () => onChanged(TimeView.day),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: 'Week',
              isSelected: selected == TimeView.week,
              onTap: () => onChanged(TimeView.week),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: 'Month',
              isSelected: selected == TimeView.month,
              onTap: () => onChanged(TimeView.month),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const purple = Color(0xFF5B3FE8);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.white.withValues(alpha: 0.1),
                        ]
                      : [
                          purple.withValues(alpha: 0.85),
                          purple.withValues(alpha: 0.7),
                        ],
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : purple.withValues(alpha: 0.5),
                  width: 1,
                )
              : null,
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: purple.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.black54),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}

class _CaloriesBarChart extends StatelessWidget {
  const _CaloriesBarChart({required this.view});

  final TimeView view;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const purple = Color(0xFF5B3FE8);

    final ctrl = context.watch<CalorieTrackerController>();
    final now = DateTime.now();

    List<double> chartData = [];
    List<String> labels = [];
    int highlightIndex = -1;

    if (view == TimeView.day) {
      final breakfast = ctrl
          .mealsForSelectedDate(MealType.breakfast)
          .fold(0.0, (sum, e) => sum + (e.estimatedCalories ?? 0));
      final lunch = ctrl
          .mealsForSelectedDate(MealType.lunch)
          .fold(0.0, (sum, e) => sum + (e.estimatedCalories ?? 0));
      final dinner = ctrl
          .mealsForSelectedDate(MealType.dinner)
          .fold(0.0, (sum, e) => sum + (e.estimatedCalories ?? 0));
      chartData = [breakfast, lunch, dinner];
      labels = ['Breakfast', 'Lunch', 'Dinner'];
      highlightIndex = -1;
    } else if (view == TimeView.week) {
      chartData = _getWeeklyCalories(ctrl);
      labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      highlightIndex = now.weekday - 1;
    } else {
      chartData = _getMonthlyCalories(ctrl);
      labels = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
      highlightIndex = (now.day - 1) ~/ 7;
      if (highlightIndex > 3) highlightIndex = 3;
    }

    final totalValue = chartData.fold(0.0, (sum, val) => sum + val);

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      blur: 15.0,
      opacity: 0.12,
      borderColor: isDark ? null : purple.withValues(alpha: 0.35),
      borderWidth: isDark ? 1.0 : 1.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calories',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${totalValue.toInt()} cal total',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY:
                    (chartData.isNotEmpty
                        ? chartData.reduce((a, b) => a > b ? a : b)
                        : 600) *
                    1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        final isHighlighted = index == highlightIndex;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (isHighlighted)
                              const Icon(
                                Icons.local_fire_department,
                                size: 14,
                                color: Color(0xFFFF6B35),
                              ),
                            if (isHighlighted) const SizedBox(height: 2),
                            Text(
                              labels[index],
                              style: TextStyle(
                                fontSize: 10,
                                color: isHighlighted
                                    ? (isDark ? Colors.white : Colors.black87)
                                    : (isDark
                                          ? Colors.white70
                                          : Colors.black54),
                                fontWeight: isHighlighted
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  for (int i = 0; i < chartData.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: chartData[i],
                          color: const Color(0xFFFFF9C4),
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<double> _getWeeklyCalories(CalorieTrackerController ctrl) {
    // Mock data - replace with real weekly aggregation from controller
    return [220.0, 340, 410, 460, 505, 380, 360];
  }

  List<double> _getMonthlyCalories(CalorieTrackerController ctrl) {
    // Mock data - replace with real monthly aggregation
    return [2400.0, 2600.0, 2100.0, 2800.0];
  }
}

class _MacronutrientRingChart extends StatelessWidget {
  const _MacronutrientRingChart();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CalorieTrackerController>();
    final macros = _calculateMacros(ctrl);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const purple = Color(0xFF5B3FE8);

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      blur: 15.0,
      opacity: 0.12,
      borderColor: isDark ? null : purple.withValues(alpha: 0.35),
      borderWidth: isDark ? 1.0 : 1.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Macronutrients',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MacroRing(
                  label: 'Protein',
                  value: macros['protein'] ?? 0.0,
                  target: 0.3,
                  color: const Color(0xFF4CAF50),
                ),
              ),
              Expanded(
                child: _MacroRing(
                  label: 'Carbs',
                  value: macros['carbs'] ?? 0.0,
                  target: 0.5,
                  color: const Color(0xFFFFB74D),
                ),
              ),
              Expanded(
                child: _MacroRing(
                  label: 'Fats',
                  value: macros['fats'] ?? 0.0,
                  target: 0.2,
                  color: const Color(0xFFE91E63),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateMacros(CalorieTrackerController ctrl) {
    // Calculate totals from meal entries
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    final today = DateTime.now();
    final entries =
        ctrl.mealsForSelectedDate(MealType.breakfast) +
        ctrl.mealsForSelectedDate(MealType.lunch) +
        ctrl.mealsForSelectedDate(MealType.dinner) +
        ctrl.mealsForSelectedDate(MealType.snack);

    for (final entry in entries) {
      if (entry.date.year == today.year &&
          entry.date.month == today.month &&
          entry.date.day == today.day) {
        totalProtein += entry.protein;
        totalCarbs += entry.carbs;
        totalFats += entry.fats;
      }
    }

    final total = totalProtein + totalCarbs + totalFats;
    if (total == 0) {
      return {'protein': 0.0, 'carbs': 0.0, 'fats': 0.0};
    }

    return {
      'protein': totalProtein / total,
      'carbs': totalCarbs / total,
      'fats': totalFats / total,
    };
  }
}

class _MacroRing extends StatelessWidget {
  const _MacroRing({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  });

  final String label;
  final double value;
  final double target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = (value / target).clamp(0.0, 1.0);

    return Column(
      children: [
        CircularPercentIndicator(
          radius: 40,
          lineWidth: 8,
          percent: percentage,
          progressColor: color,
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          circularStrokeCap: CircularStrokeCap.round,
          center: Text(
            '${(value * 100).toInt()}%',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _NetCalorieBalance extends StatelessWidget {
  const _NetCalorieBalance();

  @override
  Widget build(BuildContext context) {
    final calorieCtrl = context.watch<CalorieTrackerController>();
    final caloriesIn = calorieCtrl.totalCaloriesForSelectedDate;
    final caloriesOut = 350.0;
    final net = caloriesIn - caloriesOut;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const purple = Color(0xFF5B3FE8);

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      blur: 15.0,
      opacity: 0.12,
      borderColor: isDark ? null : purple.withValues(alpha: 0.35),
      borderWidth: isDark ? 1.0 : 1.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Net Calorie Balance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BalanceItem(
                label: 'Calories In',
                value: '${caloriesIn.toInt()}',
                color: const Color(0xFF4CAF50),
              ),
              _BalanceItem(
                label: 'Calories Out',
                value: '${caloriesOut.toInt()}',
                color: const Color(0xFFE91E63),
              ),
              _BalanceItem(
                label: 'Net',
                value: '${net.toInt()}',
                color: net >= 0
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFE91E63),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  const _BalanceItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _StreakCalendarCard extends StatelessWidget {
  const _StreakCalendarCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const purple = Color(0xFF5B3FE8);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFFFFF9C4).withValues(alpha: 0.4),
                      const Color(0xFFFFF9C4).withValues(alpha: 0.2),
                    ]
                  : [
                      purple.withValues(alpha: 0.08),
                      purple.withValues(alpha: 0.04),
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : purple.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: purple.withValues(alpha: 0.12),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'strick',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '50 cal',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.black.withValues(alpha: 0.7),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),
              _StreakCalendar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakCalendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const purple = Color(0xFF5B3FE8);
    final accentColor = isDark ? const Color(0xFF4CAF50) : purple;
    final todayColor = isDark ? const Color(0xFFCCFF00) : purple;

    final today = DateTime.now();
    final firstDay = DateTime(today.year, today.month, 1);
    final lastDay = DateTime(today.year, today.month + 1, 0);

    return TableCalendar(
      firstDay: firstDay,
      lastDay: lastDay,
      focusedDay: today,
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerVisible: false,
      daysOfWeekVisible: true,
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: todayColor,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: accentColor,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: accentColor,
          shape: BoxShape.circle,
        ),
        defaultTextStyle: TextStyle(
          color: isDark ? Colors.black87 : Colors.black87,
        ),
        weekendTextStyle: TextStyle(
          color: isDark ? Colors.black54 : Colors.black54,
        ),
        todayTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        outsideDaysVisible: false,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: isDark ? Colors.black54 : Colors.black54,
          fontSize: 11,
        ),
        weekendStyle: TextStyle(
          color: isDark ? Colors.black54 : Colors.black54,
          fontSize: 11,
        ),
      ),
      eventLoader: (day) {
        if (day.weekday == 5 || day.day % 3 == 0) {
          return [1];
        }
        return [];
      },
    );
  }
}
