import 'package:flutter/material.dart';
import '../storage/storage_service.dart';
import '../error/error_handler.dart';
import 'app_theme.dart';

class ThemeController extends ChangeNotifier {
  StorageService? _storage;
  bool _isDarkMode = false;
  bool _isLoading = false;

  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;

  ThemeData get currentTheme =>
      _isDarkMode ? AppTheme.getDarkTheme() : AppTheme.getLightTheme();

  /// Initialize and load theme preference
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _storage = await StorageService.getInstance();
      _isDarkMode = _storage?.getDarkModeEnabled() ?? false;
    } catch (e) {
      ErrorHandler.logError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    try {
      await _storage?.saveAppSettings(
        appleHealthEnabled: true, // Keep existing value
        darkModeEnabled: _isDarkMode,
        languageCode: 'en', // Keep existing value
      );
    } catch (e) {
      ErrorHandler.logError(e);
    }
  }

  /// Set theme mode explicitly
  Future<void> setDarkMode(bool enabled) async {
    if (_isDarkMode == enabled) return;
    _isDarkMode = enabled;
    notifyListeners();

    try {
      await _storage?.saveAppSettings(
        appleHealthEnabled: true, // Keep existing value
        darkModeEnabled: _isDarkMode,
        languageCode: 'en', // Keep existing value
      );
    } catch (e) {
      ErrorHandler.logError(e);
    }
  }

  /// Sync with OnboardingController's darkModeEnabled
  void syncWithOnboarding(bool darkModeEnabled) {
    if (_isDarkMode != darkModeEnabled) {
      _isDarkMode = darkModeEnabled;
      notifyListeners();
    }
  }
}
