import 'package:flutter/material.dart';
import '../core/storage/storage_service.dart';
import '../core/error/app_exception.dart';
import '../core/error/error_handler.dart';

enum MealType { breakfast, lunch, dinner, snack }

class MealEntry {
  MealEntry({
    required this.id,
    required this.type,
    required this.date,
    required this.timeOfDay,
    required this.name,
    required this.carbs,
    required this.fats,
    required this.protein,
    this.estimatedCalories,
  });

  final String id;
  final MealType type;
  final DateTime date;
  final TimeOfDay timeOfDay;
  final String name;
  final double carbs;
  final double fats;
  final double protein;
  final double? estimatedCalories;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'date': date.toIso8601String(),
      'timeOfDay': '${timeOfDay.hour}:${timeOfDay.minute}',
      'name': name,
      'carbs': carbs,
      'fats': fats,
      'protein': protein,
      'estimatedCalories': estimatedCalories,
    };
  }

  factory MealEntry.fromJson(Map<String, dynamic> json) {
    final timeParts = (json['timeOfDay'] as String).split(':');
    return MealEntry(
      id: json['id'] as String,
      type: MealType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MealType.snack,
      ),
      date: DateTime.parse(json['date'] as String),
      timeOfDay: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      name: json['name'] as String,
      carbs: (json['carbs'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      estimatedCalories: json['estimatedCalories'] != null
          ? (json['estimatedCalories'] as num).toDouble()
          : null,
    );
  }
}

class CalorieTrackerController extends ChangeNotifier {
  StorageService? _storage;
  bool _isLoading = false;
  String? _errorMessage;

  DateTime selectedDate = DateTime.now();
  final List<MealEntry> _entries = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MealEntry> get allEntries => List.unmodifiable(_entries);

  /// Initialize controller and load saved data
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _storage = await StorageService.getInstance();
      await _loadFromStorage();
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e);
      ErrorHandler.logError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load meal entries from storage
  Future<void> _loadFromStorage() async {
    if (_storage == null) return;

    try {
      final savedEntries = _storage!.getMealEntries();
      _entries.clear();
      _entries.addAll(savedEntries.map((json) => MealEntry.fromJson(json)));
    } catch (e) {
      ErrorHandler.logError(e);
      _errorMessage = 'Failed to load meal entries';
    }
  }

  /// Save meal entries to storage
  Future<void> _saveToStorage() async {
    if (_storage == null) return;

    try {
      final entriesJson = _entries.map((e) => e.toJson()).toList();
      await _storage!.saveMealEntries(entriesJson);
    } catch (e) {
      ErrorHandler.logError(e);
      throw StorageException(
        'Failed to save meal entries: ${ErrorHandler.getErrorMessage(e)}',
      );
    }
  }

  List<MealEntry> mealsForSelectedDate(MealType type) {
    return _entries
        .where(
          (e) =>
              e.type == type &&
              e.date.year == selectedDate.year &&
              e.date.month == selectedDate.month &&
              e.date.day == selectedDate.day,
        )
        .toList();
  }

  double get totalCaloriesForSelectedDate {
    return _entries
        .where(
          (e) =>
              e.date.year == selectedDate.year &&
              e.date.month == selectedDate.month &&
              e.date.day == selectedDate.day,
        )
        .fold(0.0, (sum, e) => sum + (e.estimatedCalories ?? 0));
  }

  Future<void> setSelectedDate(DateTime date) async {
    selectedDate = date;
    notifyListeners();
  }

  Future<void> addEntry(MealEntry entry) async {
    try {
      _entries.add(entry);
      notifyListeners();
      await _saveToStorage();
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e);
      ErrorHandler.logError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeEntry(String id) async {
    try {
      _entries.removeWhere((e) => e.id == id);
      notifyListeners();
      await _saveToStorage();
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e);
      ErrorHandler.logError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateEntry(MealEntry updatedEntry) async {
    try {
      final index = _entries.indexWhere((e) => e.id == updatedEntry.id);
      if (index != -1) {
        _entries[index] = updatedEntry;
        notifyListeners();
        await _saveToStorage();
      }
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e);
      ErrorHandler.logError(e);
      notifyListeners();
      rethrow;
    }
  }
}
