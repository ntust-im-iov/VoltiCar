class ApiConstants {
  static const String baseUrl = 'https://volticar.dynns.com:22000/';
  // Auth endpoints
  static const String login = '/users/login'; // 登入
  static const String registerVerification =
      '/users/request-verification'; // 註冊信箱驗證請求
  static const String completeRegister =
      '/users/complete-registration'; // 驗證信箱後完成註冊
  static const String forgotPassword = '/users/forgot-password'; // 驗證信箱
  static const String verifyResetOtp = '/users/verify-reset-otp'; // 驗證重置密碼驗證碼
  static const String resetPassword = '/users/reset-password'; // 重置密碼
  static const String googleLogin = '/users/login/google'; // 再次修正為正確的路徑
  static const String checkUsername = '/users/check-username'; // 檢查用戶名稱是否存在

  // Station endpoints
  static const String stationsOverview = '/stations/overview'; // 充電站概覽
  static const String stations = '/stations'; // 充電站
  static const String stationsByCity = '/stations/city'; // 按城市搜尋充電站
  static const String stationDetail = '/stations/id'; // 充電站詳細信息

  // Parking endpoints
  static const String parkingOverview = '/parkings/overview'; // 停車場概覽
  static const String parkingDetail = '/parkings/id'; // 停車場詳細信息

  // Task
  static const String taskDefinitions = '/api/v1/tasks/'; //任務清單

  // API version
  static const String apiVersion = '/api/v1';

  // Request timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Header keys
  static const String authHeader = 'Authorization';
  static const String contentTypeHeader = 'Content-Type';
  static const String acceptHeader = 'Accept';

  // Header values
  static const String contentType = 'application/json';
  static const String bearerPrefix = 'Bearer ';
}
