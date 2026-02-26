import 'package:flutter/material.dart';
import '../core/storage/storage_service.dart';
import '../services/auth_service.dart';





class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _token;
  String? _userId;
  String? _error;
  String? get userId => _userId;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;

  Future<void> initialize() async {
    final storage = await StorageService.getInstance();
    _token = storage.getLanguageCode(); // TEMP reuse until we add token key
    if (_token != null) {
      _isAuthenticated = true;
    }
    notifyListeners();
  }

  Future<void> register(String email, String password, String name) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _authService.register(
        email: email,
        password: password,
        name: name,
      );

      _token = data["token"];
      _userId = data["userId"];

      final storage = await StorageService.getInstance();
      await storage.saveAppSettings(languageCode: _token); // TEMP

      _isAuthenticated = true;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _authService.login(
        email: email,
        password: password,
      );

      _token = data["token"];
      _userId = data["userId"];

      final storage = await StorageService.getInstance();
      await storage.saveAppSettings(languageCode: _token); // TEMP

      _isAuthenticated = true;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final storage = await StorageService.getInstance();
    await storage.clearAll();

    _isAuthenticated = false;
    _token = null;
    _userId = null;

    notifyListeners();
  }
}