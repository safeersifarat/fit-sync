import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/storage/storage_service.dart';

class AiService {
  static const String baseUrl = "http://192.168.1.71:5000/api/ai";

  Future<Map<String, String>> _headers() async {
    final storage = await StorageService.getInstance();
    final token = storage.getAuthToken();
    if (token == null) throw Exception("No auth token found");
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<String> sendMessage(String message) async {
    final response = await http.post(
      Uri.parse("$baseUrl/chat"),
      headers: await _headers(),
      body: jsonEncode({"message": message}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data["reply"] ?? "No response";
    } else {
      throw Exception(data["error"] ?? "Failed to send message");
    }
  }

  /// Sends a food image (File) to the backend for recognition.
  /// Returns a map with "reply" (String) and "detectedFood" (Map).
  Future<Map<String, dynamic>> sendFoodImage(File imageFile) async {
    // Convert to base64 data URL
    final bytes = await imageFile.readAsBytes();
    final base64Str = base64Encode(bytes);
    final ext = imageFile.path.split('.').last.toLowerCase();
    final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
    final dataUrl = 'data:$mime;base64,$base64Str';

    final response = await http.post(
      Uri.parse("$baseUrl/food-image"),
      headers: await _headers(),
      body: jsonEncode({"image": dataUrl}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {
        'reply': data['reply'] ?? 'Food logged!',
        'detectedFood': data['detectedFood'],
      };
    } else {
      throw Exception(data["error"] ?? "Failed to process image");
    }
  }
}
