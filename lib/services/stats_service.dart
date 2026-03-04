import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/storage/storage_service.dart';

class StatsService {
  static const String baseUrl = "http://192.168.1.71:5000/api/stats";

  Future<Map<String, String>> _headers() async {
    final storage = await StorageService.getInstance();
    final token = storage.getAuthToken();
    if (token == null) throw Exception("No auth token found");

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<Map<String, dynamic>> getDailyStats() async {
    final response = await http.get(
      Uri.parse("$baseUrl/daily"),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load daily stats");
    }
  }

  Future<List<dynamic>> getWeeklyStats() async {
    final response = await http.get(
      Uri.parse("$baseUrl/weekly"),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load weekly stats");
    }
  }

  Future<List<dynamic>> getMonthlyStats() async {
    final response = await http.get(
      Uri.parse("$baseUrl/monthly"),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load monthly stats");
    }
  }

  Future<Map<String, dynamic>> getLifetimeStats() async {
    final response = await http.get(
      Uri.parse("$baseUrl/lifetime"),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load lifetime stats");
    }
  }
}
