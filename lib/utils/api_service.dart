import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = "http://180.235.121.245:40734";

  static Future<String> sendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/send-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      final data = jsonDecode(response.body);
      return data['message'] ?? "Failed to send OTP";
    } catch (e) {
      return "Error: $e";
    }
  }

  static Future<String> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );
      final data = jsonDecode(response.body);
      return data['message'] ?? "Failed to verify OTP";
    } catch (e) {
      return "Error: $e";
    }
  }
}
