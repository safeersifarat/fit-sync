import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/storage/storage_service.dart';

class ProfileService {
  static const String baseUrl = 'http://192.168.1.71:5000/api';

  Future<Map<String, String>> _getHeaders() async {
    final storage = await StorageService.getInstance();
    final token = storage.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/profile'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Failed to get profile',
      );
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/profile'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] ?? {};
    } else {
      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Failed to update profile',
      );
    }
  }

  Future<void> updatePassword(String oldPassword, String newPassword) async {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/password'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Failed to update password',
      );
    }
  }

  Future<void> updateEmail(String newEmail, String password) async {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/email'),
      headers: await _getHeaders(),
      body: jsonEncode({'newEmail': newEmail, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Failed to update email',
      );
    }
  }

  Future<void> updatePhone(String newPhone) async {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/phone'),
      headers: await _getHeaders(),
      body: jsonEncode({'newPhone': newPhone}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Failed to update phone',
      );
    }
  }
}
