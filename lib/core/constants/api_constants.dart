class ApiConstants {
  static const String baseUrl = 'https://volticar.dynns.com:22000/';
  // Auth endpoints
  static const String login = '/users/login';
  static const String register = '/users/register';
  static const String resetPassword = '/users/reset-password';
  static const String googleLogin = '/users/google-login';

  // API version
  static const String apiVersion = '/api/v1';

  // Request timeouts
  static const int connectionTimeout = 5000; // 5 seconds
  static const int receiveTimeout = 3000; // 3 seconds

  // Header keys
  static const String authHeader = 'Authorization';
  static const String contentTypeHeader = 'Content-Type';
  static const String acceptHeader = 'Accept';

  // Header values
  static const String contentType = 'application/json';
  static const String bearerPrefix = 'Bearer ';
}
