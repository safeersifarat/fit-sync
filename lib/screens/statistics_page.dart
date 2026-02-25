import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:ui';

import '../state/onboarding_controller.dart';
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
                const _CaloriesBarChart(),
                const SizedBox(height: 20),
                const _QuickMetricsRow(),
                const SizedBox(height: 24),
                const _MacronutrientRingChart(),
                const SizedBox(height: 24),
                const _NetCalorieBalance(),
                const SizedBox(height: 24),
                const _WeightTrendChart(),
                const SizedBox(height: 24),
                const _GoalProgressCard(),
                const SizedBox(height: 24),
                const _StreakCalendarCard(),
                const SizedBox(height: 24),
                const _WorkoutMetricsCard(),
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
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your Statistics',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFFB3BA).withValues(alpha: 0.25),
                    const Color(0xFFFFB3BA).withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Weekly Average',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '102 CAL',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_upward,
                        size: 14,
                        color: Color(0xFFFFB3BA),
                      ),
                    ],
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

class _TimeToggle extends StatelessWidget {
  const _TimeToggle({required this.selected, required this.onChanged});

  final TimeView selected;
  final ValueChanged<TimeView> onChanged;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
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
        ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1)
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.7),
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
  const _CaloriesBarChart();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CalorieTrackerController>();
    final now = DateTime.now();
    final currentDayIndex = now.weekday - 1; // Monday = 0

    // Get weekly calorie data (mock for now, integrate with real data)
    final weeklyCalories = _getWeeklyCalories(ctrl);

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      blur: 15.0,
      opacity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calories',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${weeklyCalories[currentDayIndex].toInt()} cal',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 600,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Mon',
                          'Tues',
                          'Wed',
                          'Thurs',
                          'Fri',
                          'Sat',
                          'Sun',
                        ];
                        final index = value.toInt();
                        if (index < 0 || index >= days.length) {
                          return const SizedBox.shrink();
                        }
                        final isCurrentDay = index == currentDayIndex;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (isCurrentDay)
                              const Icon(
                                Icons.local_fire_department,
                                size: 14,
                                color: Color(0xFFFF6B35),
                              ),
                            if (isCurrentDay) const SizedBox(height: 2),
                            Text(
                              days[index],
                              style: TextStyle(
                                fontSize: 10,
                                color: isCurrentDay
                                    ? Colors.white
                                    : Colors.white70,
                                fontWeight: isCurrentDay
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
                  for (int i = 0; i < 7; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: weeklyCalories[i],
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
}

class _QuickMetricsRow extends StatelessWidget {
  const _QuickMetricsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickMetricCard(
            icon: Icons.directions_walk,
            title: 'Walk',
            value: '2 miles',
            progress: 0.5,
            progressLabel: '50%',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickMetricCard(
            icon: Icons.water_drop,
            title: 'Drink',
            value: '150 ml',
            progress: 0.6,
            progressLabel: null,
          ),
        ),
      ],
    );
  }
}

class _QuickMetricCard extends StatelessWidget {
  const _QuickMetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.progress,
    this.progressLabel,
  });

  final IconData icon;
  final String title;
  final String value;
  final double progress;
  final String? progressLabel;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white70),
              minHeight: 4,
            ),
          ),
          if (progressLabel != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                progressLabel!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MacronutrientRingChart extends StatelessWidget {
  const _MacronutrientRingChart();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CalorieTrackerController>();
    final macros = _calculateMacros(ctrl);

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      blur: 15.0,
      opacity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Macronutrients',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.white70, fontSize: 11),
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
    final caloriesOut = 350.0; // Mock - integrate with workout data
    final net = caloriesIn - caloriesOut;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      blur: 15.0,
      opacity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Net Calorie Balance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
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
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}

class _WeightTrendChart extends StatelessWidget {
  const _WeightTrendChart();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<OnboardingController>();
    final weightHistory = _getWeightHistory(ctrl);

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      blur: 15.0,
      opacity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weight & BMI Trend',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'BMI: ${ctrl.bmi.toStringAsFixed(1)}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (weightHistory.length - 1).toDouble(),
                minY: weightHistory.reduce((a, b) => a < b ? a : b) - 2,
                maxY: weightHistory.reduce((a, b) => a > b ? a : b) + 2,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= weightHistory.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'W${index + 1}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white54,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}kg',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white54,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < weightHistory.length; i++)
                        FlSpot(i.toDouble(), weightHistory[i]),
                    ],
                    isCurved: true,
                    color: const Color(0xFFCCFF00),
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFCCFF00).withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<double> _getWeightHistory(OnboardingController ctrl) {
    // Mock weight history - in production, store historical weight data
    final currentWeight = ctrl.weight;
    return [
      currentWeight + 2,
      currentWeight + 1.5,
      currentWeight + 1,
      currentWeight + 0.5,
      currentWeight,
    ];
  }
}

class _GoalProgressCard extends StatelessWidget {
  const _GoalProgressCard();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<OnboardingController>();
    final progress = _calculateGoalProgress(ctrl);

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      blur: 15.0,
      opacity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goal Progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            ctrl.goal ?? 'No goal set',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFCCFF00),
              ),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xFFCCFF00),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Target: ${_getTargetWeight(ctrl)} kg',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateGoalProgress(OnboardingController ctrl) {
    if (ctrl.goal == null) return 0.0;

    // Mock progress calculation - adjust based on actual goal logic
    final currentWeight = ctrl.weight;
    final targetWeight = _getTargetWeight(ctrl);
    final startWeight = currentWeight + 5; // Assume started 5kg heavier

    if (ctrl.goal!.toLowerCase().contains('lose')) {
      final totalToLose = startWeight - targetWeight;
      final lost = startWeight - currentWeight;
      return (lost / totalToLose).clamp(0.0, 1.0);
    } else if (ctrl.goal!.toLowerCase().contains('gain')) {
      final totalToGain = targetWeight - startWeight;
      final gained = currentWeight - startWeight;
      return (gained / totalToGain).clamp(0.0, 1.0);
    }

    return 0.5; // Default progress
  }

  double _getTargetWeight(OnboardingController ctrl) {
    // Calculate target BMI of 22 (healthy range)
    final targetBMI = 22.0;
    final heightMeters = ctrl.height / 100;
    return targetBMI * heightMeters * heightMeters;
  }
}

class _StreakCalendarCard extends StatelessWidget {
  const _StreakCalendarCard();

  @override
  Widget build(BuildContext context) {
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
              colors: [
                const Color(0xFFFFF9C4).withValues(alpha: 0.4),
                const Color(0xFFFFF9C4).withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'strick',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '50 cal',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black.withValues(alpha: 0.7),
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
          color: const Color(0xFFCCFF00),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: const Color(0xFF4CAF50),
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: const Color(0xFF4CAF50),
          shape: BoxShape.circle,
        ),
        defaultTextStyle: const TextStyle(color: Colors.black87),
        weekendTextStyle: const TextStyle(color: Colors.black54),
        todayTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        outsideDaysVisible: false,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: const TextStyle(color: Colors.black54, fontSize: 11),
        weekendStyle: const TextStyle(color: Colors.black54, fontSize: 11),
      ),
      eventLoader: (day) {
        // Mark days where all targets were met
        if (day.weekday == 5 || day.day % 3 == 0) {
          return [1]; // Return non-empty list to show marker
        }
        return [];
      },
    );
  }
}

class _WorkoutMetricsCard extends StatelessWidget {
  const _WorkoutMetricsCard();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      blur: 15.0,
      opacity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workout Performance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _WorkoutMetricRow(
            label: 'Total Distance',
            value: '14 km',
            icon: Icons.directions_run,
          ),
          const SizedBox(height: 16),
          _WorkoutMetricRow(
            label: 'Total Reps',
            value: '240',
            icon: Icons.fitness_center,
          ),
          const SizedBox(height: 16),
          _IntensityBreakdown(),
          const SizedBox(height: 20),
          _MuscleGroupRadar(),
        ],
      ),
    );
  }
}

class _WorkoutMetricRow extends StatelessWidget {
  const _WorkoutMetricRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _IntensityBreakdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Intensity',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _IntensityBar(
                label: 'WarmUp',
                percentage: 0.3,
                color: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _IntensityBar(
                label: 'Medium',
                percentage: 0.5,
                color: const Color(0xFFFFB74D),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _IntensityBar(
                label: 'High',
                percentage: 0.2,
                color: const Color(0xFFE91E63),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _IntensityBar extends StatelessWidget {
  const _IntensityBar({
    required this.label,
    required this.percentage,
    required this.color,
  });

  final String label;
  final double percentage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 60 * percentage,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        Text(
          '${(percentage * 100).toInt()}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _MuscleGroupRadar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Muscle Group Focus',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: RadarChart(
            RadarChartData(
              dataSets: [
                RadarDataSet(
                  fillColor: const Color(0xFFCCFF00).withValues(alpha: 0.3),
                  borderColor: const Color(0xFFCCFF00),
                  borderWidth: 2,
                  dataEntries: const [
                    RadarEntry(value: 0.7), // Core
                    RadarEntry(value: 0.9), // Legs
                    RadarEntry(value: 0.6), // Arms
                    RadarEntry(value: 0.5), // Back
                    RadarEntry(value: 0.4), // Shoulders
                  ],
                ),
              ],
              radarTouchData: RadarTouchData(enabled: false),
              radarBorderData: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
              titlePositionPercentageOffset: 0.2,
              getTitle: (index, angle) {
                const titles = ['Core', 'Legs', 'Arms', 'Back', 'Shoulders'];
                return RadarChartTitle(text: titles[index], angle: angle);
              },
              titleTextStyle: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
              tickCount: 3,
              ticksTextStyle: const TextStyle(
                color: Colors.white54,
                fontSize: 8,
              ),
              tickBorderData: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
