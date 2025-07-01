import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_buddy/config/api_config.dart';

class InterestService {
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  static Future<Map<String, dynamic>> addInterest(
    String from,
    String to,
  ) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
        return {'success': false, 'message': 'Authentication token not found'};
      }

      final response = await http.post(
        Uri.parse(ApiConfig.addInterest),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'from': from, 'to': to}),
      );

      final responseData = jsonDecode(response.body);
      return {
        'success': responseData['success'],
        'message': responseData['message'],
        'data': responseData['data'],
      };
    } catch (error) {
      return {'success': false, 'message': 'Network error: $error'};
    }
  }
}
