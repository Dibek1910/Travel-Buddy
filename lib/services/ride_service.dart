import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:travel_buddy/config/api_config.dart';
import 'package:travel_buddy/services/auth_service.dart';

class RideService {
  static const Duration _timeoutDuration = Duration(seconds: 30);

  static Future<Map<String, dynamic>> createRide(
    Map<String, dynamic> rideData,
  ) async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final response = await http
          .post(
            Uri.parse(ApiConfig.createRide),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode(rideData),
          )
          .timeout(_timeoutDuration);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 401) {
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': responseData['message'] ?? 'Ride created successfully',
        'ride': responseData['ride'],
      };
    } catch (error) {
      return {'success': false, 'message': _getErrorMessage(error)};
    }
  }

  static Future<Map<String, dynamic>> searchRides(
    String? from,
    String? to,
    String? date,
  ) async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      Map<String, dynamic> requestBody = {};
      if (from != null && from.isNotEmpty) requestBody['from'] = from;
      if (to != null && to.isNotEmpty) requestBody['to'] = to;
      if (date != null && date.isNotEmpty) requestBody['date'] = date;

      final response = await http
          .post(
            Uri.parse(ApiConfig.searchRides),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 401) {
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }

      final responseData = jsonDecode(response.body);

      List<dynamic> rides = responseData['rides'] ?? [];
      List<dynamic> availableRides =
          rides.where((ride) {
            if (ride is Map<String, dynamic>) {
              final int capacity = ride['capacity'] ?? 0;
              final List requests = ride['requests'] ?? [];
              final int approvedRequests =
                  requests.where((req) {
                    if (req is Map<String, dynamic> &&
                        req['status'] is String) {
                      return req['status'] == 'approved';
                    }
                    return false;
                  }).length;

              final int availableSeats = capacity - approvedRequests;
              return availableSeats > 0;
            }
            return false;
          }).toList();

      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? 'Search completed',
        'rides': availableRides,
      };
    } catch (error) {
      return {'success': false, 'message': _getErrorMessage(error)};
    }
  }

  static Future<Map<String, dynamic>> requestRide(String rideId) async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final response = await http
          .post(
            Uri.parse(ApiConfig.requestRide),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode({'rideId': rideId}),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 401) {
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }

      final responseData = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? 'Request sent successfully',
      };
    } catch (error) {
      return {'success': false, 'message': _getErrorMessage(error)};
    }
  }

  static Future<Map<String, dynamic>> getUserCreatedRides() async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final response = await http
          .get(
            Uri.parse(ApiConfig.userCreatedRides),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 401) {
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }

      final responseData = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? 'Rides loaded successfully',
        'rides': responseData['rides'] ?? [],
      };
    } catch (error) {
      return {'success': false, 'message': _getErrorMessage(error)};
    }
  }

  static Future<Map<String, dynamic>> getUserRideRequests() async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final response = await http
          .get(
            Uri.parse(ApiConfig.userRideRequests),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 401) {
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }

      final responseData = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? 'Requests loaded successfully',
        'requests': responseData['requests'] ?? [],
      };
    } catch (error) {
      return {'success': false, 'message': _getErrorMessage(error)};
    }
  }

  static Future<Map<String, dynamic>> getRideById(String rideId) async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final response = await http
          .get(
            Uri.parse('${ApiConfig.getRideById}/$rideId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 401) {
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }

      final responseData = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? 'Ride details loaded',
        'rideDetails': responseData['rideDetails'],
      };
    } catch (error) {
      return {'success': false, 'message': _getErrorMessage(error)};
    }
  }

  static Future<Map<String, dynamic>> updateRideRequestStatus(
    String rideId,
    String requestId,
    String status,
  ) async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final response = await http
          .post(
            Uri.parse(ApiConfig.updateRideStatus),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode({'requestId': requestId, 'status': status}),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 401) {
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }

      final responseData = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? 'Request status updated',
      };
    } catch (error) {
      return {'success': false, 'message': _getErrorMessage(error)};
    }
  }

  static Future<Map<String, dynamic>> cancelRideRequest(
    String requestId,
  ) async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final response = await http
          .post(
            Uri.parse(ApiConfig.cancelRequest),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode({'requestId': requestId}),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 401) {
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }

      final responseData = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? 'Request cancelled successfully',
      };
    } catch (error) {
      return {'success': false, 'message': _getErrorMessage(error)};
    }
  }

  static Future<Map<String, dynamic>> updateRideDetails(
    String rideId,
    Map<String, dynamic> rideData,
  ) async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final requestBody = Map<String, dynamic>.from(rideData);
      requestBody['rideId'] = rideId;

      final response = await http
          .patch(
            Uri.parse(ApiConfig.updateRideDetails),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 401) {
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }

      final responseData = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? 'Ride updated successfully',
        'ride': responseData['ride'],
      };
    } catch (error) {
      return {'success': false, 'message': _getErrorMessage(error)};
    }
  }

  static Future<Map<String, dynamic>> cancelRide(String rideId) async {
    try {
      final authToken = await AuthService.getAuthToken();
      if (authToken == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final response = await http
          .post(
            Uri.parse(ApiConfig.cancelRide),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode({'rideId': rideId}),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 401) {
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }

      final responseData = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? 'Ride cancelled successfully',
      };
    } catch (error) {
      return {'success': false, 'message': _getErrorMessage(error)};
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
