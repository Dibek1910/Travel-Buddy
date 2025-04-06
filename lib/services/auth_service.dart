import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_buddy/config/api_config.dart';

class AuthService {
  // Login user
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', authToken);
        await prefs.setString('authorization', 'Bearer $authToken');

        // Save user data if available
        if (responseData['user'] != null) {
          await prefs.setString('userId', responseData['user']['id']);
          await prefs.setString('userEmail', responseData['user']['email']);
          await prefs.setString(
              'userFirstName', responseData['user']['firstName']);
          await prefs.setString(
              'userLastName', responseData['user']['lastName']);
        }

        return {
          'success': true,
          'message': responseData['message'],
          'token': authToken,
          'user': responseData['user'],
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

  // Register user
  static Future<Map<String, dynamic>> register(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
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
      await prefs.remove('userId');
      await prefs.remove('userEmail');
      await prefs.remove('userFirstName');
      await prefs.remove('userLastName');

      return {
        'success': true,
        'message': responseData['message'] ?? 'Logged out successfully',
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Network error: $error',
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
}
