import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_buddy/config/api_config.dart';

class UserService {
  // Get auth token from shared preferences
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'Authentication token not found',
        };
      }

      final response = await http.get(
        Uri.parse(ApiConfig.userProfile),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return {
        'success': responseData['success'],
        'message': responseData['message'],
        'userProfile': responseData['userProfile'],
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Network error: $error',
      };
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateUserProfile(
    String firstName,
    String lastName,
    String phoneNumber, // Added phone number parameter
  ) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'Authentication token not found',
        };
      }

      final response = await http.patch(
        Uri.parse(ApiConfig.updateUserProfile),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber, // Include phone number in request
        }),
      );

      final responseData = jsonDecode(response.body);
      return {
        'success': responseData['success'],
        'message': responseData['message'],
        'userProfile': responseData['userProfile'],
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Network error: $error',
      };
    }
  }
}
