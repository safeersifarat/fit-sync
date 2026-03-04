import 'package:flutter/material.dart';
import '../services/stats_service.dart';
import '../services/workout_service.dart';

class StatsController extends ChangeNotifier {
  final StatsService _service = StatsService();
  final WorkoutService _workoutService = WorkoutService();

  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? dailyStats;
  List<dynamic> weeklyStats = [];
  List<dynamic> monthlyStats = [];
  Map<String, dynamic>? lifetimeStats;
  List<DateTime> completedWorkoutDates = [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAllStats() async {
    try {
      _isLoading = true;
      notifyListeners();

      final results = await Future.wait([
        _service.getDailyStats(),
        _service.getWeeklyStats(),
        _service.getMonthlyStats(),
        _service.getLifetimeStats(),
        _workoutService.getJourney(),
      ]);

      dailyStats = results[0] as Map<String, dynamic>;
      weeklyStats = results[1] as List<dynamic>;
      monthlyStats = results[2] as List<dynamic>;
      lifetimeStats = results[3] as Map<String, dynamic>;

      // Parse completed dates from journey response for the calendar
      final journey = results[4] as Map<String, dynamic>;
      final rawDates = journey['completedDates'] as List<dynamic>? ?? [];
      completedWorkoutDates = rawDates.map((d) {
        try {
          return DateTime.parse(d as String);
        } catch (_) {
          return null;
        }
      }).whereType<DateTime>().toList();

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Aggregated helpers for week/month views
  double _sumWeek(String key) => weeklyStats.fold(
      0.0, (sum, day) => sum + ((day[key] ?? 0) as num).toDouble());

  double _sumMonth(String key) => monthlyStats.fold(
      0.0, (sum, week) => sum + ((week[key] ?? 0) as num).toDouble());

  double get weeklyTotalIntake => _sumWeek('intake');
  double get weeklyTotalBurned => _sumWeek('burned');
  double get weeklyTotalBalance => _sumWeek('balance');
  double get weeklyTotalProtein => _sumWeek('protein');
  double get weeklyTotalCarbs => _sumWeek('carbs');
  double get weeklyTotalFats => _sumWeek('fats');

  double get monthlyTotalIntake => _sumMonth('intake');
  double get monthlyTotalBurned => _sumMonth('burned');
  double get monthlyTotalBalance => _sumMonth('balance');
  double get monthlyTotalProtein => _sumMonth('protein');
  double get monthlyTotalCarbs => _sumMonth('carbs');
  double get monthlyTotalFats => _sumMonth('fats');
}
