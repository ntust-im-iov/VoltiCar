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

      _logger.i('註冊成功，返回用戶信息');
      return response;

      _logger.e('註冊失敗，返回 null');
      return null;
    } catch (e) {
      _logger.e('註冊過程中發生錯誤: $e');
      rethrow;
    }
  }

  // 登錄
  Future<User?> login(String account, String password) async {
    try {
      _logger.i('準備登入，用戶帳號: $account');
      final user = await _authService.login(account, password);

      if (user != null) {
        _logger.i('登入成功，返回用戶信息');
        return user;
      }

      _logger.w('登入失敗，返回 null');
      return null;
    } catch (e) {
      _logger.e('登入過程中發生錯誤: $e');
      rethrow;
    }
  }

  // 登出
  Future<void> logout() async {
    try {
      _logger.i('Repository: 開始登出處理');
      await _authService.logout();
      _logger.i('Repository: 登出成功完成');
    } catch (e) {
      _logger.e('Repository: 登出過程中發生錯誤: $e');
      rethrow;
    }
  }

  // 檢查是否已登錄
  Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }

  // 重設密碼
  Future<bool> resetPassword(String token, String newPassword) async {
    return await _authService.resetPassword(token, newPassword);
  }

  // 取得用戶ID
  Future<String?> getUserId() async {
    return await _authService.getUserId();
  }
}
