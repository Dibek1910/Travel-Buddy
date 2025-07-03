import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_buddy/config/api_config.dart';

class AuthService {
  static const String _authTokenKey = 'authToken';
  static const String _userDataKey = 'userData';
  static const String _userIdKey = 'userId';
  static const String _userNameKey = 'userName';

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.login),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_authTokenKey, responseData['token']);

        if (responseData['user'] != null) {
          final userData = responseData['user'];

          String userName = '';
          if (userData is String) {
            userName = userData;
            await prefs.setString(_userNameKey, userName);
          } else if (userData is Map<String, dynamic>) {
            userName = userData['firstName'] ?? userData['name'] ?? 'User';
            await prefs.setString(_userNameKey, userName);
            await prefs.setString(_userDataKey, jsonEncode(userData));

            if (userData['phoneNo'] != null) {
              await prefs.setString(
                'userPhoneNumber',
                userData['phoneNo'].toString(),
              );
            }
          }
        }

        return {
          'success': true,
          'message': responseData['message'] ?? 'Login successful',
          'user': responseData['user'],
          'token': responseData['token'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
        };
      }
    } catch (error) {
      print('Login error: $error');
      return {'success': false, 'message': _getErrorMessage(error)};
    }
  }

  static Future<Map<String, dynamic>> register(
    String firstName,
    String email,
    String password,
    String phoneNo,
  ) async {
    try {
      print('Attempting registration for: $email');

      final response = await http
          .post(
            Uri.parse(ApiConfig.register),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'firstName': firstName,
              'email': email,
              'password': password,
              'phoneNo': phoneNo,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseData['success'] != false) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userPhoneNumber', phoneNo);
        } catch (e) {
          print('Error storing phone number: $e');
        }
      }

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': responseData['message'] ?? 'Registration completed',
        'user': responseData['user'],
      };
    } catch (error) {
      print('Registration error: $error');
      return {'success': false, 'message': _getErrorMessage(error)};
    }
  }

  static Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.sendOtp),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? 'OTP sent successfully',
      };
    } catch (error) {
      return {'success': false, 'message': _getErrorMessage(error)};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(
    String email,
    String otp,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.verifyOtp),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'otp': otp}),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? 'OTP verified successfully',
      };
    } catch (error) {
      return {'success': false, 'message': _getErrorMessage(error)};
    }
  }

  static Future<Map<String, dynamic>> updatePassword(
    String email,
    String newPassword,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.updatePassword),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': newPassword}),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? 'Password updated successfully',
      };
    } catch (error) {
      return {'success': false, 'message': _getErrorMessage(error)};
    }
  }

  static Future<bool> validateToken() async {
    try {
      final authToken = await getAuthToken();
      if (authToken == null) return false;

      final response = await http
          .get(
            Uri.parse(ApiConfig.userProfile),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
          )
          .timeout(const Duration(seconds: 15));

      return response.statusCode == 200;
    } catch (error) {
      print('Token validation error: $error');
      return false;
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await Future.wait([
        prefs.remove(_authTokenKey),
        prefs.remove(_userDataKey),
        prefs.remove(_userIdKey),
        prefs.remove(_userNameKey),
        prefs.remove('userPhoneNumber'),
      ]);

      return {'success': true, 'message': 'Logged out successfully'};
    } catch (error) {
      return {
        'success': false,
        'message': 'Error during logout: ${error.toString()}',
      };
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_authTokenKey);
      return token != null && token.isNotEmpty;
    } catch (error) {
      return false;
    }
  }

  static Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_authTokenKey);
    } catch (error) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userDataKey);
      if (userDataString != null) {
        return jsonDecode(userDataString);
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  static Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (error) {
      return null;
    }
  }

  static Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey);
    } catch (error) {
      return null;
    }
  }

  static Future<String?> getUserPhoneNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('userPhoneNumber');
    } catch (error) {
      return null;
    }
  }

  static String _getErrorMessage(dynamic error) {
    if (error.toString().contains('TimeoutException')) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error.toString().contains('SocketException')) {
      return 'No internet connection. Please check your network.';
    } else if (error.toString().contains('FormatException')) {
      return 'Invalid server response. Please try again.';
    } else {
      return 'Network error occurred. Please try again.';
    }
  }
}
