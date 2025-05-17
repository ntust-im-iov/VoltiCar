import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:volticar_app/core/constants/api_constants.dart';
import 'package:volticar_app/core/network/api_client.dart';

class ResetPasswordService {
  static final ResetPasswordService _instance =
      ResetPasswordService._internal();
  final Logger _logger = Logger();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ApiClient _apiClient = ApiClient();

  factory ResetPasswordService() {
    return _instance;
  }

  ResetPasswordService._internal();

  Future<bool> forgotPassword(String email) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.forgotPassword,
        data: {'identifier': email},
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // 保存email到安全存儲，供後續步驟使用
        await _secureStorage.write(key: 'reset_email', value: email);
        _logger.i('已保存重設密碼使用的電子郵件: $email');
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('忘記密碼錯誤: $e');
      rethrow;
    }
  }

  Future<bool> verifyResetOtp(String optCode) async {
    try {
      // 從安全存儲中獲取之前保存的電子郵件
      final email = await _secureStorage.read(key: 'reset_email');
      if (email == null || email.isEmpty) {
        _logger.e('找不到電子郵件，無法驗證重設密碼');
        throw Exception('找不到電子郵件，請重新開始密碼重設流程');
      }

      final response = await _apiClient.post(
        ApiConstants.verifyResetOtp,
        data: {'identifier': email, 'otp_code': optCode},
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // 儲存確認令牌到安全存儲
        String confirmationToken = response.data['confirmation_token'] ?? '';
        if (confirmationToken.isNotEmpty) {
          _logger.i('收到確認令牌，正在儲存...');
          await _secureStorage.write(
            key: 'confirmation_token',
            value: confirmationToken,
          );
          _logger.i('確認令牌已儲存');
        } else {
          _logger.w('未收到確認令牌或令牌為空');
        }
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('驗證重置密碼錯誤: $e');
      rethrow;
    }
  }

  Future<bool> resetPassword(String newPassword,
      {String? confirmationToken}) async {
    try {
      // 如果沒有提供令牌，則從安全存儲中獲取
      String token = confirmationToken ?? '';
      if (token.isEmpty) {
        _logger.i('從安全存儲中讀取確認令牌...');
        token = await _secureStorage.read(key: 'confirmation_token') ?? '';
        if (token.isEmpty) {
          _logger.e('找不到確認令牌');
          throw Exception('重置密碼失敗: 找不到確認令牌');
        }
      }

      final response = await _apiClient.post(
        ApiConstants.resetPassword,
        data: {
          'confirmation_token': token,
          'new_password': newPassword,
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // 密碼重置成功後，清除所有重設密碼相關的數據
        await clearResetPasswordData();
        _logger.i('密碼重置成功，已清除相關數據');
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('重置密碼錯誤: $e');
      rethrow;
    }
  }

  // 清除所有與重設密碼相關的存儲數據
  Future<void> clearResetPasswordData() async {
    try {
      await _secureStorage.delete(key: 'confirmation_token');
      await _secureStorage.delete(key: 'reset_email');
      _logger.i('已清除所有重設密碼相關數據');
    } catch (e) {
      _logger.e('清除重設密碼數據時發生錯誤: $e');
    }
  }

  Future<String?> getUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_id');
    } catch (e) {
      _logger.e('獲取用戶ID時發生錯誤: $e');
      return null;
    }
  }
}
