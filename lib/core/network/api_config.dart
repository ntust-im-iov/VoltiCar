class ApiConfig {
  static const String baseUrl = 'http://59.126.6.46:22000';
  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration receiveTimeout = Duration(seconds: 3);
  
  // API 端點
  static const String register = '/users/register';
  static const String login = '/api/auth/login';
  static const String logout = '/api/auth/logout';
  static const String refreshToken = '/api/auth/refresh';
} 