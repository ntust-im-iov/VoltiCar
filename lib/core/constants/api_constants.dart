class ApiConstants {
  static const String baseUrl = 'https://volticar.dynns.com:22000/';

  // Auth endpoints
  static const String login = '/users/login';
  static const String register = '/users/register';
  static const String resetPassword = '/users/reset-password';
  static const String forgotPassword = '/users/forgot-password';
  static const String refreshToken = '/users/token/refresh';

  // 用戶相關端點
  static const String userProfile = '/users/profile';
  static const String updateFcmToken = '/users/update-fcm-token';
  static const String checkPhone = '/users/check-phone/';
  static const String leaderboard = '/users/leaderboard';
  static const String manageFriends = '/users/friends';
  static const String userTasks = '/users/tasks';
  static const String userAchievements = '/users/achievements';
  static const String redeemReward = '/users/redeem-reward';
  static const String userInventory = '/users/inventory';
  static const String chargingStations = '/users/charging-stations';

  // API version
  static const String apiVersion = '/api/v1';

  // Request timeouts
  static const int connectionTimeout = 15000; // 15 seconds
  static const int receiveTimeout = 10000; // 10 seconds

  // Header keys
  static const String authHeader = 'Authorization';
  static const String contentTypeHeader = 'Content-Type';
  static const String acceptHeader = 'Accept';

  // Header values
  static const String contentType = 'application/json';
  static const String bearerPrefix = 'Bearer ';
}
