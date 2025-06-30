class ApiConfig {
  static const String baseUrl = 'https://travelbuddy.sdcmuj.com/api';

  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';
  static const String sendOtp = '$baseUrl/auth/forgot-password/send-otp';
  static const String verifyOtp = '$baseUrl/auth/forgot-password/verify-otp';
  static const String updatePassword =
      '$baseUrl/auth/forgot-password/update-password';
  static const String verifyEmail = '$baseUrl/auth/verify-email';

  // Ride endpoints
  static const String createRide = '$baseUrl/rides/create';
  static const String searchRides = '$baseUrl/rides/search';
  static const String getRideById = '$baseUrl/rides/get';
  static const String requestRide = '$baseUrl/rides/request';
  static const String cancelRequest = '$baseUrl/rides/cancel';
  static const String updateRideStatus = '$baseUrl/rides/update-status';
  static const String updateRideDetails = '$baseUrl/rides/update';
  static const String cancelRide = '$baseUrl/rides/cancel-ride';
  static const String userRideHistory = '$baseUrl/rides/user-ride-history';
  static const String userCreatedRides = '$baseUrl/rides/user-created';
  static const String userRideRequests = '$baseUrl/rides/user-requests';

  // User endpoints
  static const String userProfile = '$baseUrl/user/profile';

  // Interest endpoints
  static const String addInterest = '$baseUrl/interest/add-interest';


}
