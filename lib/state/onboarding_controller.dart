import 'package:flutter/material.dart';
import '../core/storage/storage_service.dart';
import '../core/error/app_exception.dart';
import '../core/error/error_handler.dart';

/// Central controller holding auth + onboarding data with persistence
class OnboardingController extends ChangeNotifier {
  StorageService? _storage;
  bool _isLoading = false;
  String? _errorMessage;

  // Auth
  String? email;
  String? password;
  String displayName = 'Youssef';

  // Profile
  /// Local file path to the selected avatar image.
  String? avatarPath;

  // Basic metrics
  int age = 25;
  double weight = 70; // kg
  double height = 170; // cm
  bool useMetricWeight = true; // true: kg, false: lb
  bool useMetricHeight = true; // true: cm, false: inches

  // Derived
  double get bmi {
    final hMeters = height / 100;
    if (hMeters == 0) return 0;
    return weight / (hMeters * hMeters);
  }

  // Step 3 details
  String? gender; // 'male', 'female', 'other'
  bool hasBackPain = false;
  bool hasKneePain = false;
  bool hasHeartIssue = false;

  String? goal; // e.g. 'Lose weight', 'Build muscle'

  // App-level settings
  bool appleHealthEnabled = true;
  bool darkModeEnabled = false;
  String languageCode = 'en'; // e.g. 'en', 'es'

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  /// Load data from storage
  Future<void> _loadFromStorage() async {
    if (_storage == null) return;

    displayName = _storage!.getDisplayName() ?? displayName;
    age = _storage!.getAge() ?? age;
    weight = _storage!.getWeight() ?? weight;
    height = _storage!.getHeight() ?? height;
    gender = _storage!.getGender();
    goal = _storage!.getGoal();
    avatarPath = _storage!.getAvatarPath();
    useMetricWeight = _storage!.getUseMetricWeight() ?? useMetricWeight;
    useMetricHeight = _storage!.getUseMetricHeight() ?? useMetricHeight;
    appleHealthEnabled =
        _storage!.getAppleHealthEnabled() ?? appleHealthEnabled;
    darkModeEnabled = _storage!.getDarkModeEnabled() ?? darkModeEnabled;
    languageCode = _storage!.getLanguageCode() ?? languageCode;
  }

  /// Save data to storage
  Future<void> _saveToStorage() async {
    if (_storage == null) return;

    try {
      await _storage!.saveUserProfile(
        displayName: displayName,
        age: age,
        weight: weight,
        height: height,
        gender: gender,
        goal: goal,
        avatarPath: avatarPath,
        useMetricWeight: useMetricWeight,
        useMetricHeight: useMetricHeight,
      );
      await _storage!.saveAppSettings(
        appleHealthEnabled: appleHealthEnabled,
        darkModeEnabled: darkModeEnabled,
        languageCode: languageCode,
      );
    } catch (e) {
      ErrorHandler.logError(e);
      throw StorageException(
        'Failed to save user data: ${ErrorHandler.getErrorMessage(e)}',
      );
    }
  }

  void setAuth(String email, String password) {
    this.email = email;
    this.password = password;
    notifyListeners();
  }

  Future<void> setDisplayName(String value) async {
    displayName = value;
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> setAvatarPath(String? path) async {
    avatarPath = path;
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> setAge(int value) async {
    age = value;
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> setWeight(double value) async {
    weight = value;
    notifyListeners();
    await _saveToStorage();
    await _saveWeightHistory();
  }

  Future<void> setHeight(double value) async {
    height = value;
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> toggleWeightUnit() async {
    useMetricWeight = !useMetricWeight;
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> toggleHeightUnit() async {
    useMetricHeight = !useMetricHeight;
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> setGender(String value) async {
    gender = value;
    notifyListeners();
    await _saveToStorage();
  }

  void setHealth({bool? backPain, bool? kneePain, bool? heartIssue}) {
    hasBackPain = backPain ?? hasBackPain;
    hasKneePain = kneePain ?? hasKneePain;
    hasHeartIssue = heartIssue ?? hasHeartIssue;
    notifyListeners();
  }

  Future<void> setGoal(String value) async {
    goal = value;
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> toggleAppleHealth() async {
    appleHealthEnabled = !appleHealthEnabled;
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> toggleDarkMode() async {
    darkModeEnabled = !darkModeEnabled;
    notifyListeners();
    await _saveToStorage();
    // Notify theme controller if available
    // This will be handled by the main app's Consumer2
  }

  Future<void> setLanguage(String code) async {
    languageCode = code;
    notifyListeners();
    await _saveToStorage();
  }

  /// Save weight history entry
  Future<void> _saveWeightHistory() async {
    if (_storage == null) return;

    try {
      final history = _storage!.getWeightHistory();
      history.add({
        'date': DateTime.now().toIso8601String(),
        'weight': weight,
        'bmi': bmi,
      });
      await _storage!.saveWeightHistory(history);
    } catch (e) {
      ErrorHandler.logError(e);
    }
  }

  /// Get weight history
  List<Map<String, dynamic>> getWeightHistory() {
    if (_storage == null) return [];
    return _storage!.getWeightHistory();
  }
}
