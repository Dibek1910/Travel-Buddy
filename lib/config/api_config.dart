class ApiConfig {
  static const String baseUrl = 'http://localhost:8080/api';

  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';

  // Ride endpoints
  static const String createRide = '$baseUrl/rides/create';
  static const String searchRides = '$baseUrl/rides/search';
  static const String getRideById = '$baseUrl/rides/get';
  static const String requestRide = '$baseUrl/rides/request';
  static const String cancelRequest = '$baseUrl/rides/cancel';
  static const String updateRideStatus = '$baseUrl/rides/update-status';
  static const String updateRideDetails = '$baseUrl/rides/update';
  static const String userRideHistory = '$baseUrl/rides/user-ride-history';
  static const String userCreatedRides = '$baseUrl/rides/user-created';
  static const String userRideRequests = '$baseUrl/rides/user-requests';

  // User endpoints
  static const String userProfile = '$baseUrl/user/profile';
  static const String updateUserProfile = '$baseUrl/user/profile';
}
