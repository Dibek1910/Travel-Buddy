import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_buddy/config/api_config.dart';

class AuthService {
  // Login user with email and password
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        final authToken = responseData['token'];
        final userName = responseData['user'];
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('authToken', authToken);
        await prefs.setString('authorization', 'Bearer $authToken');
        await prefs.setString('userEmail', email);
        await prefs.setString('userName', userName);

        return {
          'success': true,
          'message': responseData['message'],
          'token': authToken,
          'user': userName,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Network error: $error',
      };
    }
  }

  // Register user with firstName, email, and password
  static Future<Map<String, dynamic>> register(
    String firstName,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      return {
        'success': responseData['success'],
        'message': responseData['message'],
        'user': responseData['user'],
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Network error: $error',
      };
    }
  }

  // Send OTP for password reset
  static Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.sendOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );

      final responseData = jsonDecode(response.body);

      return {
        'success': responseData['success'],
        'message': responseData['message'],
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Network error: $error',
      };
    }
  }

  // Verify OTP
  static Future<Map<String, dynamic>> verifyOtp(
      String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.verifyOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      final responseData = jsonDecode(response.body);

      return {
        'success': responseData['success'],
        'message': responseData['message'],
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Network error: $error',
      };
    }
  }

  // Update password
  static Future<Map<String, dynamic>> updatePassword(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.updatePassword),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      return {
        'success': responseData['success'],
        'message': responseData['message'],
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Network error: $error',
      };
    }
  }

  // Logout user
  static Future<Map<String, dynamic>> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      if (authToken == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.get(
        Uri.parse(ApiConfig.logout),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);

      // Clear stored preferences regardless of server response
      await prefs.remove('authToken');
      await prefs.remove('authorization');
      await prefs.remove('userEmail');
      await prefs.remove('userName');

      return {
        'success': true,
        'message': responseData['message'] ?? 'Logged out successfully',
      };
    } catch (error) {
      // Clear preferences even if network call fails
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('authToken');
      await prefs.remove('authorization');
      await prefs.remove('userEmail');
      await prefs.remove('userName');

      return {
        'success': true,
        'message': 'Logged out successfully',
      };
    }
  }

  // Get authentication token
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null;
  }

  // Get user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }
}
