import 'package:flutter/material.dart';
import '../services/workout_service.dart';

class WorkoutController extends ChangeNotifier {
  final WorkoutService _service = WorkoutService();

  bool _isLoading = false;
  String? _error;

  int totalDays = 90;
  int currentDay = 1;
  int streak = 0;
  List<int> completedDays = [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  Map<String, dynamic>? todayWorkout;

  Future<void> loadJourney() async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _service.getJourney();

      totalDays = data["totalDays"];
      currentDay = data["currentDay"];
      streak = data["streak"];
      completedDays = List<int>.from(data["completedDays"]);

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTodayWorkout() async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _service.getTodayWorkout();
      todayWorkout = data;

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
