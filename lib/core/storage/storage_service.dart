//storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting and retrieving app data
class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // User Profile Data
  Future<void> saveUserProfile({
    String? displayName,
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? goal,
    String? avatarPath,
    bool? useMetricWeight,
    bool? useMetricHeight,
  }) async {
    if (displayName != null) {
      await _prefs!.setString('user_display_name', displayName);
    }
    if (age != null) {
      await _prefs!.setInt('user_age', age);
    }
    if (weight != null) {
      await _prefs!.setDouble('user_weight', weight);
    }
    if (height != null) {
      await _prefs!.setDouble('user_height', height);
    }
    if (gender != null) {
      await _prefs!.setString('user_gender', gender);
    }
    if (goal != null) {
      await _prefs!.setString('user_goal', goal);
    }
    if (avatarPath != null) {
      await _prefs!.setString('user_avatar_path', avatarPath);
    }
    if (useMetricWeight != null) {
      await _prefs!.setBool('user_use_metric_weight', useMetricWeight);
    }
    if (useMetricHeight != null) {
      await _prefs!.setBool('user_use_metric_height', useMetricHeight);
    }
  }

  String? getDisplayName() => _prefs!.getString('user_display_name');
  int? getAge() => _prefs!.getInt('user_age');
  double? getWeight() => _prefs!.getDouble('user_weight');
  double? getHeight() => _prefs!.getDouble('user_height');
  String? getGender() => _prefs!.getString('user_gender');
  String? getGoal() => _prefs!.getString('user_goal');
  String? getAvatarPath() => _prefs!.getString('user_avatar_path');
  bool? getUseMetricWeight() => _prefs!.getBool('user_use_metric_weight');
  bool? getUseMetricHeight() => _prefs!.getBool('user_use_metric_height');

  // App Settings
  Future<void> saveAppSettings({
    bool? appleHealthEnabled,
    bool? darkModeEnabled,
    String? languageCode,
  }) async {
    if (appleHealthEnabled != null) {
      await _prefs!.setBool('app_apple_health_enabled', appleHealthEnabled);
    }
    if (darkModeEnabled != null) {
      await _prefs!.setBool('app_dark_mode_enabled', darkModeEnabled);
    }
    if (languageCode != null) {
      await _prefs!.setString('app_language_code', languageCode);
    }
  }

  bool? getAppleHealthEnabled() => _prefs!.getBool('app_apple_health_enabled');
  bool? getDarkModeEnabled() => _prefs!.getBool('app_dark_mode_enabled');
  String? getLanguageCode() => _prefs!.getString('app_language_code');

  // Meal Entries
  Future<void> saveMealEntries(List<Map<String, dynamic>> entries) async {
    await _prefs!.setString('meal_entries', jsonEncode(entries));
  }

  List<Map<String, dynamic>> getMealEntries() {
    final jsonString = _prefs!.getString('meal_entries');
    if (jsonString == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // Weight History
  Future<void> saveWeightHistory(List<Map<String, dynamic>> history) async {
    await _prefs!.setString('weight_history', jsonEncode(history));
  }

  List<Map<String, dynamic>> getWeightHistory() {
    final jsonString = _prefs!.getString('weight_history');
    if (jsonString == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs!.clear();
  }

  // Clear specific data
  Future<void> clearUserData() async {
    await _prefs!.remove('user_display_name');
    await _prefs!.remove('user_age');
    await _prefs!.remove('user_weight');
    await _prefs!.remove('user_height');
    await _prefs!.remove('user_gender');
    await _prefs!.remove('user_goal');
    await _prefs!.remove('user_avatar_path');
    await _prefs!.remove('weight_history');
  }
}
