import '../models/user_model.dart';
import '../models/register_request.dart';
import '../services/auth_service.dart';
import 'package:logger/logger.dart';

class AuthRepository {
  final AuthService _authService = AuthService();
  final Logger _logger = Logger();
  
  // 註冊
  Future<User?> register({
    required String username,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      _logger.i('開始創建註冊請求...');
      
      final request = RegisterRequest(
        username: username,
        email: email,
        password: password,
        phone: phone,
      );
      
      _logger.i('註冊請求創建完成: ${request.toJson()}');
      
      final response = await _authService.register(request);
      _logger.i('註冊響應: $response');
      
      if (response != null) {
        _logger.i('註冊成功，返回用戶信息');
        return response;
      }
      
      _logger.e('註冊失敗，返回 null');
      return null;
    } catch (e) {
      _logger.e('註冊過程中發生錯誤: $e');
      rethrow;
    }
  }
  
  // 登錄
  Future<User?> login(String account, String password) async {
    return await _authService.login(account, password);
  }
  
  // 登出
  Future<void> logout() async {
    await _authService.logout();
  }
  
  // 檢查是否已登錄
  Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }
  
  // 重設密碼
  Future<bool> resetPassword(String email, String newPassword) async {
    return await _authService.resetPassword(email, newPassword);
  }
  
  // 取得用戶ID
  Future<String?> getUserId() async {
    return await _authService.getUserId();
  }
} 