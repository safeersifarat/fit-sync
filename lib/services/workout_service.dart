import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/storage/storage_service.dart';

class WorkoutService {
  static const String baseUrl = "http://192.168.1.71:5000/api/workout";

  Future<Map<String, dynamic>> getJourney() async {
    final storage = await StorageService.getInstance();
    final token = storage.getAuthToken();

    if (token == null) {
      throw Exception("No auth token found");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/journey"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data["error"] ?? "Failed to load journey");
    }
  }

  Future<Map<String, dynamic>> getTodayWorkout() async {
    final storage = await StorageService.getInstance();
    final token = storage.getAuthToken();

    if (token == null) {
      throw Exception("No auth token found");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/today"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data["error"] ?? "Failed to load today's workout");
    }
  }
}
