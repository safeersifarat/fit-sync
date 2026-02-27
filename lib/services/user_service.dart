//user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/storage/storage_service.dart';

class UserService {
  static const String baseUrl = "http://10.0.2.2:5000/api/users";

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
