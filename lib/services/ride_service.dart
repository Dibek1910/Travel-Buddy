import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:travel_buddy/config/api_config.dart';
import 'package:travel_buddy/services/auth_service.dart';

class RideService {
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

      Map<String, dynamic> requestBody = {};
      if (from != null && from.isNotEmpty) requestBody['from'] = from;
      if (to != null && to.isNotEmpty) requestBody['to'] = to;
      if (date != null && date.isNotEmpty) requestBody['date'] = date;

      final response = await http.post(
        Uri.parse(ApiConfig.searchRides),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestBody),
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

  static Future<Map<String, dynamic>> getRideById(String rideId) async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.getRideById}/$rideId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
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

      final response = await http.post(
        Uri.parse(ApiConfig.updateRideStatus),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
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

  static Future<Map<String, dynamic>> cancelRideRequest(
      String requestId) async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.post(
        Uri.parse(ApiConfig.cancelRequest),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'requestId': requestId}),
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

  static Future<Map<String, dynamic>> updateRideDetails(
      String rideId, Map<String, dynamic> rideData) async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final requestBody = Map<String, dynamic>.from(rideData);
      requestBody['rideId'] = rideId;

      final response = await http.patch(
        Uri.parse(ApiConfig.updateRideDetails),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestBody),
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

  static Future<Map<String, dynamic>> cancelRide(String rideId) async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.post(
        Uri.parse(ApiConfig.cancelRide),
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
}
