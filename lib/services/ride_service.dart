import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:travel_buddy/config/api_config.dart';
import 'package:travel_buddy/services/auth_service.dart';

class RideService {
  // Create a new ride - Fixed: Accept Map<String, dynamic> parameter
  static Future<Map<String, dynamic>> createRide(
      Map<String, dynamic> rideData) async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.post(
        Uri.parse(ApiConfig.createRide),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(rideData),
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
      String? from, String? to, String? date) async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      // Build query parameters
      Map<String, String> queryParams = {};
      if (from != null && from.isNotEmpty) queryParams['from'] = from;
      if (to != null && to.isNotEmpty) queryParams['to'] = to;
      if (date != null && date.isNotEmpty) queryParams['date'] = date;

      final uri = Uri.parse(ApiConfig.searchRides).replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
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

  // Request to join a ride
  static Future<Map<String, dynamic>> requestRide(String rideId) async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.post(
        Uri.parse(ApiConfig.requestRide),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'rideId': rideId}),
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

  // Get user's created rides
  static Future<Map<String, dynamic>> getUserCreatedRides() async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.get(
        Uri.parse(ApiConfig.userCreatedRides),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
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

  // Get user's ride requests
  static Future<Map<String, dynamic>> getUserRideRequests() async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.get(
        Uri.parse(ApiConfig.userRideRequests),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      final responseData = jsonDecode(response.body);
      return {
        'success': responseData['success'],
        'message': responseData['message'],
        'requests': responseData['requests'],
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Network error: $error',
      };
    }
  }

  // Update ride request status (approve/reject)
  static Future<Map<String, dynamic>> updateRideRequestStatus(
      String rideId, String requestId, String status) async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.put(
        Uri.parse(ApiConfig.updateRideStatus),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'rideId': rideId,
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

  // Cancel ride request - Fixed: Renamed from cancelRequest to cancelRideRequest
  static Future<Map<String, dynamic>> cancelRideRequest(String rideId) async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.delete(
        Uri.parse(ApiConfig.cancelRequest),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'rideId': rideId}),
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
  static Future<Map<String, dynamic>> updateRide(
      String rideId, Map<String, dynamic> rideData) async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.updateRideDetails}/$rideId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(rideData),
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

  // Cancel ride
  static Future<Map<String, dynamic>> cancelRide(String rideId) async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.cancelRide}/$rideId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
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

  static updateRideDetails(rideDetail, Map<String, dynamic> updatedDetails) {}
}
