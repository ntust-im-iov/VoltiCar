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

  // 檢查用戶名稱是否可用
  Future<bool> isUsernameAvailable(String username) async {
    try {
      _logger.i('Repository: 開始檢查用戶名稱 "$username" 是否可用');
      final bool isAvailable = await _registerService.checkUsername(username);
      _logger.i('Repository: 用戶名稱 "$username" 可用性: $isAvailable');
      return isAvailable;
    } catch (e) {
      _logger.e('Repository: 檢查用戶名稱 "$username" 時發生錯誤: $e');
      // 根據需求，這裡可以 rethrow 錯誤，或者回傳一個預設值 (例如 false)
      // 為了讓呼叫端能感知到錯誤，建議 rethrow
      rethrow;
    }
  }
}
