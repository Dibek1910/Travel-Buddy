import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_buddy/config/api_config.dart';

class RideService {
  // Get auth token from shared preferences
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Create a new ride
  static Future<Map<String, dynamic>> createRide(
    String from,
    String to,
    String date,
    int capacity,
    dynamic price,
    String description,
  ) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'Authentication token not found',
        };
      }

      final response = await http.post(
        Uri.parse(ApiConfig.createRide),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': from,
          'to': to,
          'date': date,
          'capacity': capacity,
          'price': price,
          'description': description,
        }),
      );

      final responseData = jsonDecode(response.body);
      return {
        'success': responseData['success'],
        'message': responseData['message'],
        'ride': responseData['ride'],
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Network error: $error',
      };
    }
  }

  // Search for rides
  static Future<Map<String, dynamic>> searchRides(
    String from,
    String to,
    String date,
  ) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'Authentication token not found',
        };
      }

      final response = await http.post(
        Uri.parse(ApiConfig.searchRides),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': from,
          'to': to,
          'date': date,
        }),
      );

      final responseData = jsonDecode(response.body);
      return {
        'success': responseData['success'],
        'message': responseData['message'],
        'rides': responseData['rides'],
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Network error: $error',
      };
    }
  }

  // Get ride by ID
  static Future<Map<String, dynamic>> getRideById(String rideId) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'Authentication token not found',
        };
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.getRideById}/$rideId'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return {
        'success': responseData['success'],
        'message': responseData['message'],
        'rideDetails': responseData['rideDetails'],
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Network error: $error',
      };
    }
  }

  // Request to join a ride
  static Future<Map<String, dynamic>> requestRide(String rideId) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'Authentication token not found',
        };
      }

      final response = await http.post(
        Uri.parse(ApiConfig.requestRide),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'rideId': rideId,
        }),
      );

      final responseData = jsonDecode(response.body);
      return {
        'success': responseData['success'],
        'message': responseData['message'],
        'requestTicket': responseData['requestTicket'],
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Network error: $error',
      };
    }
  }

  // Cancel a ride request
  static Future<Map<String, dynamic>> cancelRequest(String requestId) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'Authentication token not found',
        };
      }

      final response = await http.post(
        Uri.parse(ApiConfig.cancelRequest),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'requestId': requestId,
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

  // Update ride request status
  static Future<Map<String, dynamic>> updateRequestStatus(
    String requestId,
    String status,
  ) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'Authentication token not found',
        };
      }

      final response = await http.post(
        Uri.parse(ApiConfig.updateRideStatus),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'requestId': requestId,
          'status': status,
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

  // Update ride details
  static Future<Map<String, dynamic>> updateRideDetails(
    String rideId,
    Map<String, dynamic> updatedDetails,
  ) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'Authentication token not found',
        };
      }

      // Add rideId to the updated details
      updatedDetails['rideId'] = rideId;

      final response = await http.patch(
        Uri.parse(ApiConfig.updateRideDetails),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedDetails),
      );

      final responseData = jsonDecode(response.body);
      return {
        'success': responseData['success'],
        'message': responseData['message'],
        'ride': responseData['ride'],
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Network error: $error',
      };
    }
  }

  // Get user ride history
  static Future<Map<String, dynamic>> getUserRideHistory() async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'Authentication token not found',
        };
      }

      final response = await http.get(
        Uri.parse(ApiConfig.userRideHistory),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return {
        'success': responseData['success'],
        'message': responseData['message'],
        'rides': responseData['rides'],
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Network error: $error',
      };
    }
  }

  // Get rides created by user
  static Future<Map<String, dynamic>> getUserCreatedRides() async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'Authentication token not found',
        };
      }

      final response = await http.get(
        Uri.parse(ApiConfig.userCreatedRides),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return {
        'success': responseData['success'],
        'message': responseData['message'],
        'rides': responseData['rides'],
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Network error: $error',
      };
    }
  }

  // Get user ride requests
  static Future<Map<String, dynamic>> getUserRideRequests() async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'Authentication token not found',
        };
      }

      final response = await http.get(
        Uri.parse(ApiConfig.userRideRequests),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      return {
        'success': responseData['success'],
        'message': responseData['message'],
        'requests': responseData['requests'],
        'user': responseData['user'],
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Network error: $error',
      };
    }
  }
}
