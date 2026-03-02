//user_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/storage/storage_service.dart';

class UserService {
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return "http://10.0.2.2:5001/api/users";
    }
    return "http://127.0.0.1:5001/api/users";
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final storage = await StorageService.getInstance();
    final token = storage.getAuthToken();
    if (token == null) {
      throw Exception("No auth token found");
    }
    final response = await http.put(
      Uri.parse("$baseUrl/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }
}
