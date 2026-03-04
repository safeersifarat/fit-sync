import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../controllers/stats_controller.dart';
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
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<StatsController>().loadAllStats();
    });
  }

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
                _NetCalorieBalance(view: _selectedView),
                const SizedBox(height: 24),
                _MacronutrientRingChart(view: _selectedView),
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
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER',
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }
}

// ──────────────────────────────────────────────
//  Header
// ──────────────────────────────────────────────
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

// ──────────────────────────────────────────────
//  Time toggle
// ──────────────────────────────────────────────
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
          Expanded(child: _ToggleButton(label: 'Day', isSelected: selected == TimeView.day, onTap: () => onChanged(TimeView.day))),
          Expanded(child: _ToggleButton(label: 'Week', isSelected: selected == TimeView.week, onTap: () => onChanged(TimeView.week))),
          Expanded(child: _ToggleButton(label: 'Month', isSelected: selected == TimeView.month, onTap: () => onChanged(TimeView.month))),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({required this.label, required this.isSelected, required this.onTap});
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
                      ? [Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.1)]
                      : [purple.withValues(alpha: 0.85), purple.withValues(alpha: 0.7)],
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.3) : purple.withValues(alpha: 0.5),
                  width: 1,
                )
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black54),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Calories Bar Chart (Problem 1, 2, 3)
// ──────────────────────────────────────────────
class _CaloriesBarChart extends StatefulWidget {
  const _CaloriesBarChart({required this.view});
  final TimeView view;

  @override
  State<_CaloriesBarChart> createState() => _CaloriesBarChartState();
}

class _CaloriesBarChartState extends State<_CaloriesBarChart> {
  int _selectedBarIndex = -1; // -1 = none → shows total

  @override
  void didUpdateWidget(_CaloriesBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.view != widget.view) {
      setState(() => _selectedBarIndex = -1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const purple = Color(0xFF5B3FE8);
    final ctrl = context.watch<StatsController>();

    if (ctrl.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<double> chartData = [];
    List<String> labels = [];
    int highlightIndex = -1;
    String displaySubTitle = '';

    if (widget.view == TimeView.day) {
      // Breakfast / Lunch / Dinner bars
      final breakfast = (ctrl.dailyStats?['breakfastCalories'] ?? 0 as num).toDouble();
      final lunch = (ctrl.dailyStats?['lunchCalories'] ?? 0 as num).toDouble();
      final dinner = (ctrl.dailyStats?['dinnerCalories'] ?? 0 as num).toDouble();
      chartData = [breakfast, lunch, dinner];
      labels = ['Breakfast', 'Lunch', 'Dinner'];
      highlightIndex = _selectedBarIndex >= 0 ? _selectedBarIndex : -1;

      if (_selectedBarIndex >= 0 && _selectedBarIndex < chartData.length) {
        displaySubTitle = '${chartData[_selectedBarIndex].toInt()} cal — ${labels[_selectedBarIndex]}';
      } else {
        final total = breakfast + lunch + dinner;
        displaySubTitle = '${total.toInt()} cal total';
      }
    } else if (widget.view == TimeView.week) {
      // Last 7 days daily intake
      final weekStats = ctrl.weeklyStats;
      chartData = List.filled(7, 0.0);
      labels = List.filled(7, '');

      const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      for (int i = 0; i < weekStats.length && i < 7; i++) {
        chartData[i] = (weekStats[i]['intake'] ?? 0 as num).toDouble();
        try {
          final d = DateTime.parse(weekStats[i]['date'] as String);
          labels[i] = dayNames[d.weekday - 1];
        } catch (_) {
          labels[i] = 'D${i + 1}';
        }
      }
      highlightIndex = _selectedBarIndex >= 0 ? _selectedBarIndex : 6;

      if (_selectedBarIndex >= 0 && _selectedBarIndex < chartData.length) {
        displaySubTitle = '${chartData[_selectedBarIndex].toInt()} cal — ${labels[_selectedBarIndex]}';
      } else {
        displaySubTitle = '${ctrl.weeklyTotalIntake.toInt()} cal this week';
      }
    } else {
      // Last 4 weeks weekly intake
      final monthStats = ctrl.monthlyStats;
      chartData = List.filled(4, 0.0);
      labels = ['W1', 'W2', 'W3', 'W4'];
      for (int i = 0; i < monthStats.length && i < 4; i++) {
        chartData[i] = (monthStats[i]['intake'] ?? 0 as num).toDouble();
      }
      highlightIndex = _selectedBarIndex >= 0 ? _selectedBarIndex : 3;

      if (_selectedBarIndex >= 0 && _selectedBarIndex < chartData.length) {
        displaySubTitle = '${chartData[_selectedBarIndex].toInt()} cal — ${labels[_selectedBarIndex]}';
      } else {
        displaySubTitle = '${ctrl.monthlyTotalIntake.toInt()} cal this month';
      }
    }

    final maxVal = chartData.isNotEmpty ? chartData.reduce((a, b) => a > b ? a : b) : 0.0;

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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              displaySubTitle,
              key: ValueKey(displaySubTitle),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxVal > 0 ? maxVal : 600) * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchCallback: (event, response) {
                    if (!event.isInterestedForInteractions) return;
                    if (response?.spot != null) {
                      final idx = response!.spot!.touchedBarGroupIndex;
                      setState(() {
                        _selectedBarIndex = (_selectedBarIndex == idx) ? -1 : idx;
                      });
                    }
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) return const SizedBox.shrink();
                        final isHighlighted = index == highlightIndex;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isHighlighted)
                              const Icon(Icons.local_fire_department, size: 14, color: Color(0xFFFF6B35)),
                            if (isHighlighted) const SizedBox(height: 2),
                            Text(
                              labels[index],
                              style: TextStyle(
                                fontSize: 10,
                                color: isHighlighted ? (isDark ? Colors.white : Colors.black87) : (isDark ? Colors.white70 : Colors.black54),
                                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  for (int i = 0; i < chartData.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: chartData[i] > 0 ? chartData[i] : 0.1,
                          color: (_selectedBarIndex == i)
                              ? (isDark ? const Color(0xFFCCFF00) : purple)
                              : const Color(0xFFFFF9C4).withValues(alpha: isDark ? 1 : 0.85),
                          width: widget.view == TimeView.day ? 40 : 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          if (widget.view == TimeView.day)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Tap a bar to see meal details',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Net Calorie Balance (Problem 4)
// ──────────────────────────────────────────────
class _NetCalorieBalance extends StatelessWidget {
  const _NetCalorieBalance({required this.view});
  final TimeView view;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<StatsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const purple = Color(0xFF5B3FE8);

    double caloriesIn = 0;
    double caloriesOut = 0;
    double net = 0;

    if (view == TimeView.day) {
      caloriesIn = (ctrl.dailyStats?['intakeCalories'] ?? 0 as num).toDouble();
      caloriesOut = (ctrl.dailyStats?['energySpent'] ?? ctrl.dailyStats?['burnedCalories'] ?? 0 as num).toDouble();
      net = (ctrl.dailyStats?['balance'] ?? (caloriesIn - caloriesOut) as num).toDouble();
    } else if (view == TimeView.week) {
      caloriesIn = ctrl.weeklyTotalIntake;
      caloriesOut = ctrl.weeklyTotalBurned;
      net = ctrl.weeklyTotalBalance;
    } else {
      caloriesIn = ctrl.monthlyTotalIntake;
      caloriesOut = ctrl.monthlyTotalBurned;
      net = ctrl.monthlyTotalBalance;
    }

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
          if (view != TimeView.day)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                view == TimeView.week ? 'Last 7 days' : 'Last 4 weeks',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BalanceItem(label: 'Calories In', value: '${caloriesIn.toInt()}', color: const Color(0xFF4CAF50)),
              _BalanceItem(
                label: 'Calories Out',
                value: caloriesOut > 0 ? '${caloriesOut.toInt()}' : '—',
                color: const Color(0xFFE91E63),
              ),
              _BalanceItem(
                label: 'Net',
                value: '${net.toInt()}',
                color: net >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFE91E63),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  const _BalanceItem({required this.label, required this.value, required this.color});
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
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

// ──────────────────────────────────────────────
//  Macronutrients (Problem 5)
// ──────────────────────────────────────────────
class _MacronutrientRingChart extends StatelessWidget {
  const _MacronutrientRingChart({required this.view});
  final TimeView view;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<StatsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const purple = Color(0xFF5B3FE8);

    final double proteinG;
    final double carbsG;
    final double fatsG;

    if (view == TimeView.week) {
      proteinG = ctrl.weeklyTotalProtein;
      carbsG = ctrl.weeklyTotalCarbs;
      fatsG = ctrl.weeklyTotalFats;
    } else if (view == TimeView.month) {
      proteinG = ctrl.monthlyTotalProtein;
      carbsG = ctrl.monthlyTotalCarbs;
      fatsG = ctrl.monthlyTotalFats;
    } else {
      proteinG = (ctrl.dailyStats?['protein'] ?? 0 as num).toDouble();
      carbsG = (ctrl.dailyStats?['carbs'] ?? 0 as num).toDouble();
      fatsG = (ctrl.dailyStats?['fats'] ?? 0 as num).toDouble();
    }
    final totalG = proteinG + carbsG + fatsG;

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
          if (view != TimeView.day)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Macros are based on today\'s food log',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white54 : Colors.black45,
                  fontSize: 11,
                ),
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MacroRing(
                  label: 'Protein',
                  valueG: proteinG,
                  percent: totalG > 0 ? proteinG / totalG : 0,
                  color: const Color(0xFF4CAF50),
                ),
              ),
              Expanded(
                child: _MacroRing(
                  label: 'Carbs',
                  valueG: carbsG,
                  percent: totalG > 0 ? carbsG / totalG : 0,
                  color: const Color(0xFFFFB74D),
                ),
              ),
              Expanded(
                child: _MacroRing(
                  label: 'Fats',
                  valueG: fatsG,
                  percent: totalG > 0 ? fatsG / totalG : 0,
                  color: const Color(0xFFE91E63),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroRing extends StatelessWidget {
  const _MacroRing({required this.label, required this.valueG, required this.percent, required this.color});
  final String label;
  final double valueG;
  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 40,
          lineWidth: 8,
          percent: percent.clamp(0.0, 1.0),
          progressColor: color,
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          circularStrokeCap: CircularStrokeCap.round,
          center: Text(
            '${valueG.toInt()}g',
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

// ──────────────────────────────────────────────
//  Streak Calendar (Problem 6)
// ──────────────────────────────────────────────
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
                  ? [const Color(0xFFFFF9C4).withValues(alpha: 0.4), const Color(0xFFFFF9C4).withValues(alpha: 0.2)]
                  : [purple.withValues(alpha: 0.08), purple.withValues(alpha: 0.04)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.3) : purple.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Workout Calendar',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Completed workout days',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),
              const _StreakCalendar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakCalendar extends StatelessWidget {
  const _StreakCalendar();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const purple = Color(0xFF5B3FE8);
    final accentColor = isDark ? const Color(0xFF4CAF50) : purple;
    final todayColor = isDark ? const Color(0xFFCCFF00) : purple;

    final ctrl = context.watch<StatsController>();
    final completedDates = ctrl.completedWorkoutDates;

    final today = DateTime.now();
    final firstDay = DateTime(today.year, today.month - 1, 1);
    final lastDay = DateTime(today.year, today.month + 1, 0);

    return TableCalendar(
      firstDay: firstDay,
      lastDay: lastDay,
      focusedDay: today,
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        leftChevronIcon: Icon(Icons.chevron_left, color: isDark ? Colors.white70 : Colors.black54),
        rightChevronIcon: Icon(Icons.chevron_right, color: isDark ? Colors.white70 : Colors.black54),
      ),
      daysOfWeekVisible: true,
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(color: todayColor, shape: BoxShape.circle),
        markerDecoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
        defaultTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black87),
        weekendTextStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        todayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        outsideDaysVisible: false,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 11),
        weekendStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 11),
      ),
      eventLoader: (day) {
        // Mark days where a workout was completed
        final normalized = DateTime(day.year, day.month, day.day);
        final hasWorkout = completedDates.any((d) =>
          d.year == normalized.year && d.month == normalized.month && d.day == normalized.day);
        return hasWorkout ? [true] : [];
      },
    );
  }
}