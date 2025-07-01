class ApiConfig {
  static const String baseUrl = 'https://travelbuddy.sdcmuj.com';
  static const String login = '$baseUrl/api/auth/login';
  static const String register = '$baseUrl/api/auth/register';
  static const String logout = '$baseUrl/api/auth/logout';
  static const String sendOtp = '$baseUrl/api/auth/forgot-password/send-otp';
  static const String verifyOtp =
      '$baseUrl/api/auth/forgot-password/verify-otp';
  static const String updatePassword =
      '$baseUrl/api/auth/forgot-password/update-password';
  static const String userProfile = '$baseUrl/api/user/profile';
  static const String createRide = '$baseUrl/api/rides/create';
  static const String searchRides = '$baseUrl/api/rides/search';
  static const String getRideById = '$baseUrl/api/rides/get';
  static const String requestRide = '$baseUrl/api/rides/request';
  static const String cancelRequest = '$baseUrl/api/rides/cancel';
  static const String updateRideStatus = '$baseUrl/api/rides/update-status';
  static const String updateRideDetails = '$baseUrl/api/rides/update';
  static const String cancelRide = '$baseUrl/api/rides/cancel-ride';
  static const String userCreatedRides = '$baseUrl/api/rides/user-created';
  static const String userRideRequests = '$baseUrl/api/rides/user-requests';
  static const String addInterest = '$baseUrl/api/interest/add-interest';

}
