import 'package:logger/logger.dart';
import 'package:volticar_app/features/auth/models/user_model.dart';
import 'package:volticar_app/features/auth/services/login_service.dart';

class LoginRepository {
  final LoginService _loginService = LoginService();
  final Logger _logger = Logger();

  // 登錄
  Future<User?> login(String account, String password) async {
    try {
      _logger.i('準備登入，用戶帳號: $account');
      final user = await _loginService.login(account, password);

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

  // Google登入
  Future<User?> signInWithGoogle() async {
    try {
      _logger.i('Repository: 開始Google登入流程');

      // 調用 AuthService 進行 Google 登入
      final user = await _loginService.signInWithGoogle();

      if (user != null) {
        _logger.i('Google登入成功，用戶ID: ${user.id}');
        _logger.i('Google登入完成，返回用戶信息');
        return user;
      } else {
        _logger.w('Google登入失敗，用戶為空');
        return null;
      }
    } catch (e) {
      _logger.e('Google登入過程中發生錯誤: $e');
      rethrow;
    }
  }

  // 檢查是否已登錄
  Future<bool> isLoggedIn() async {
    return await _loginService.isLoggedIn();
  }

  // 登出
  Future<void> logout() async {
    try {
      _logger.i('Repository: 開始登出處理');
      await _loginService.logout();
      _logger.i('Repository: 登出成功完成');
    } catch (e) {
      _logger.e('Repository: 登出過程中發生錯誤: $e');
      rethrow;
    }
  }
}
