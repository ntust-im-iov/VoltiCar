import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:volticar_app/features/auth/models/user_model.dart';
import 'package:volticar_app/features/auth/models/register_request.dart';
import 'package:volticar_app/core/constants/api_constants.dart';
import 'package:volticar_app/core/network/api_client.dart';

class RegisterService {
  static final RegisterService _instance = RegisterService._internal();
  final Logger _logger = Logger();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ApiClient _apiClient = ApiClient();

  factory RegisterService() {
    return _instance;
  }

  RegisterService._internal();

  // 發送郵件驗證
  Future<void> sendEmailVerification(String email) async {
    try {
      _logger.i('開始發送郵件驗證');
      _logger.i('發送郵件驗證到: $email');

      // 嘗試不同的請求格式
      // 格式1: 直接使用 email 作為鍵值
      final requestData = {
        'email': email,
      };

      _logger.i('發送請求數據: $requestData');

      final response = await _apiClient.post(
        ApiConstants.registerVerification,
        data: requestData,
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      _logger.i('收到郵件驗證響應');
      _logger.i('響應狀態碼: ${response.statusCode}');
      _logger.i('響應數據: ${response.data}');

      if (response.statusCode == 200) {
        _logger.i('郵件驗證已發送');
      } else {
        _logger.e('郵件驗證發送失敗: ${response.statusCode}');
        throw Exception('郵件驗證發送失敗: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('郵件驗證發送錯誤: ${e.type}');
      _logger.e('錯誤響應: ${e.response?.data}');
      _logger.e('錯誤消息: ${e.message}');
      _logger.e('請求數據: ${e.requestOptions.data}'); // 記錄發送了什麼數據
      _logger.e('請求 URL: ${e.requestOptions.uri}');
      _logger.e('請求方法: ${e.requestOptions.method}');
      _logger.e('請求標頭: ${e.requestOptions.headers}');

      // 檢查是否是缺少 email 字段的錯誤
      if (e.response?.statusCode == 422 &&
          e.response?.data != null &&
          e.response!.data.toString().contains('field required')) {
        throw Exception('請提供有效的電子郵件地址');
      }

      throw Exception(e.response?.data['detail'] ?? '郵件驗證發送失敗');
    } catch (e) {
      _logger.e('未預期的錯誤: $e');
      throw Exception('郵件驗證發送過程中發生錯誤');
    }
  }

  // 檢查用戶名稱是否存在
  Future<bool> checkUsername(String username) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.checkUsername}/$username',
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final exists = response.data['exists'] as bool?;
          if (exists == true) {
            // 使用者名稱已存在
            _logger.i('用戶名稱 "$username" 已被使用');
            return false; // 不可用
          } else if (exists == false) {
            // 使用者名稱不存在
            _logger.i('用戶名稱 "$username" 可用');
            return true; // 可用
          } else {
            _logger.w('檢查用戶名稱時收到未知的 exists 值: $exists');
            return false; // 或者拋出錯誤，視情況而定 (假設未知時為不可用)
          }
        } else {
          _logger.w('檢查用戶名稱時，後端回應格式不正確 (非 Map): ${response.data}');
          return false; // 或者拋出錯誤
        }
      } else {
        _logger.e('檢查用戶名稱請求失敗: 狀態碼 ${response.statusCode}, data: ${response.data}');
        throw Exception('檢查用戶名稱失敗: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('檢查用戶名稱時發生 Dio 錯誤: ${e.message}');
      _logger.e('Dio 錯誤回應: ${e.response?.data}');
      throw Exception(e.response?.data['detail'] ?? '檢查用戶名稱時發生網路錯誤');
    } catch (e) {
      _logger.e('檢查用戶名稱時發生未預期的錯誤: $e');
      throw Exception('檢查用戶名稱時發生未預期的錯誤');
    }
  }

  // 註冊新用戶
  Future<User> register(RegisterRequest request) async {
    try {
      _logger.i('開始註冊請求');
      _logger.i('請求數據: ${request.toJson()}');

      /* 先在 Firebase 創建用戶
      final firebase_auth.UserCredential firebaseCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: request.email,
        password: request.password,
      );

      // 發送郵件驗證(Firebase 驗證)
      await firebaseCredential.user?.sendEmailVerification();
      _logger.i('已發送驗證郵件到: ${request.email}');
      */

      final response = await _apiClient.post(
        ApiConstants.completeRegister,
        data: request.toJson(),
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      _logger.i('收到註冊響應');
      _logger.i('響應狀態碼: ${response.statusCode}');
      _logger.i('響應數據: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 創建用戶對象，使用請求數據和響應的 user_id(api回應的 response body)
        final accessToken = response.data['access_token'] as String? ?? '';
        final user = User(
          id: response.data['user_id'] as String? ?? '',
          username: request.username,
          email: request.email,
          password: request.password,
          name: request.username, // 使用 username 作為默認名稱
          userUuid: response.data['user_id'] as String?,
          token: accessToken,
          // isEmailVerified: true, // 新增郵件驗證狀態(棄用 後端會自動驗證)
        );

        _logger.i('用戶對象創建成功: ${user.toJson()}');

        // 如果 API 返回 token，保存它
        if (accessToken.isNotEmpty) {
          await _secureStorage.write(
            key: 'access_token',
            value: accessToken,
          );
          _logger.i('訪問令牌已保存');
        }

        // 保存登入狀態
        await _saveAuthState(user.userUuid ?? user.id);
        _logger.i('認證狀態已保存');

        return user;
      } else {
        _logger.e('註冊失敗: 狀態碼 ${response.statusCode}');
        throw Exception('註冊失敗: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('註冊錯誤: ${e.type}');
      _logger.e('錯誤響應: ${e.response?.data}');
      _logger.e('錯誤消息: ${e.message}');
      throw Exception(e.response?.data['detail'] ?? '註冊失敗');
    } catch (e) {
      _logger.e('未預期的錯誤: $e');
      throw Exception('註冊過程中發生錯誤');
    }
  }

  Future<void> _saveAuthState(String? userId) async {
    if (userId == null || userId.isEmpty) {
      _logger.w('保存認證狀態失敗：用戶ID為空');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_id', userId);
    _logger.i('認證狀態已保存，用戶ID: $userId');
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
