import 'package:logger/logger.dart';
import 'package:volticar_app/features/auth/models/user_model.dart';
import 'package:volticar_app/features/auth/models/register_request.dart';
import 'package:volticar_app/features/auth/services/register_service.dart';

class RegisterRepository {
  final RegisterService _registerService = RegisterService();
  final Logger _logger = Logger();

  // 發送郵件驗證
  Future<void> sendEmailVerification(String email) async {
    try {
      _logger.i('Repository: 開始發送郵件驗證請求');
      _logger.i('郵件地址: $email');

      await _registerService.sendEmailVerification(email);

      _logger.i('Repository: 郵件驗證發送成功');
    } catch (e) {
      _logger.e('Repository: 發送郵件驗證失敗: $e');
      rethrow;
    }
  }

  // 註冊
  Future<User?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      _logger.i('開始創建註冊請求...');

      final request = RegisterRequest(
        username: username,
        email: email,
        password: password,
      );

      _logger.i('註冊請求創建完成: ${request.toJson()}');

      final response = await _registerService.register(request);
      _logger.i('註冊響應: $response');

      _logger.i('註冊成功，返回用戶信息');
      return response;
    } catch (e) {
      _logger.e('註冊過程中發生錯誤: $e');
      rethrow;
    }
  }
}
