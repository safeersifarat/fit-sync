import 'package:flutter/foundation.dart';
import '../services/profile_service.dart';

class ProfileController extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? get profileData => _profileData;

  Future<void> loadProfile() async {
    _setLoading(true);
    try {
      _profileData = await _profileService.getProfile();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final updatedData = await _profileService.updateProfile(data);
      if (_profileData != null) {
        _profileData!.addAll(updatedData);
      } else {
        _profileData = updatedData;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    _setLoading(true);
    try {
      await _profileService.updatePassword(oldPassword, newPassword);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changeEmail(String newEmail, String password) async {
    _setLoading(true);
    try {
      await _profileService.updateEmail(newEmail, password);
      if (_profileData != null) {
        _profileData!['email'] = newEmail;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePhone(String newPhone) async {
    _setLoading(true);
    try {
      await _profileService.updatePhone(newPhone);
      if (_profileData != null) {
        _profileData!['phone'] = newPhone;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
