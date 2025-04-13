import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import '../models/register_request.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final Logger _logger = Logger();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ApiClient _apiClient = ApiClient();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // 註冊新用戶
  Future<User> register(RegisterRequest request) async {
    try {
      _logger.i('開始註冊請求');
      _logger.i('請求數據: ${request.toJson()}');

      // 確保 login_type 欄位設置為 "normal"
      final Map<String, dynamic> requestData = request.toJson();
      requestData['login_type'] = 'normal';

      final response = await _apiClient.post(
        ApiConstants.register,
        data: requestData,
      );

      _logger.i('收到註冊響應');
      _logger.i('響應狀態碼: ${response.statusCode}');
      _logger.i('響應數據: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 創建用戶對象，使用請求數據和響應的 user_id
        final user = User(
          username: request.username,
          email: request.email,
          password: request.password,
          phone: request.phone,
          name: request.username, // 使用 username 作為默認名稱
          userUuid: response.data['user_id'] as String,
        );

        _logger.i('用戶對象創建成功: ${user.toJson()}');

        // 如果 API 返回 token，保存它
        if (response.data['access_token'] != null) {
          await _secureStorage.write(
            key: 'access_token',
            value: response.data['access_token'],
          );
          _logger.i('訪問令牌已保存');
        }

        // 保存登入狀態
        await _saveAuthState(user.userUuid);
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

  Future<User?> login(String identifier, String password) async {
    try {
      _logger.i('開始登入請求');
      _logger.i('識別符: $identifier');
      _logger.i('API URL: ${ApiConstants.baseUrl}${ApiConstants.login}');

      // 判斷傳入的是用戶名還是郵箱
      final Map<String, dynamic> loginData = {};
      if (identifier.contains('@')) {
        loginData['email'] = identifier;
      } else {
        loginData['username'] = identifier;
      }
      loginData['password'] = password;

      _logger.i('登入請求數據: $loginData');

      final response = await _apiClient.post(
        ApiConstants.login,
        data: loginData,
      );

      _logger.i('收到登入響應');
      _logger.i('響應狀態碼: ${response.statusCode}');
      _logger.i('響應數據: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          // 確保響應中有user_id
          final userId = response.data['user_id'];
          if (userId == null) {
            _logger.e('響應中未找到用戶ID');
            _logger.e('完整響應內容: ${response.data}');
            throw Exception('響應中未找到用戶ID');
          }

          // 使用響應數據創建用戶對象
          final user = User(
            username: identifier, // 使用傳入的識別符作為臨時用戶名
            email: identifier.contains('@') ? identifier : '', // 如果是郵箱則使用它
            password: '', // 不存儲密碼
            phone: '', // API可能沒有返回電話
            name: '', // API可能沒有返回姓名
            userUuid: userId,
          );

          _logger.i('用戶對象創建成功: ${user.toJson()}');

          // 保存訪問令牌
          if (response.data['access_token'] != null) {
            await _secureStorage.write(
              key: 'access_token',
              value: response.data['access_token'],
            );
            _logger.i('訪問令牌已保存');
          } else {
            _logger.w('響應中未找到訪問令牌，這可能會導致後續請求失敗');
            _logger.w('完整響應內容: ${response.data}');
          }

          // 保存登入狀態
          await _saveAuthState(userId);
          _logger.i('認證狀態已保存，用戶ID: $userId');

          return user;
        } catch (e) {
          _logger.e('解析用戶數據時發生錯誤: $e');
          _logger.e('響應數據: ${response.data}');
          throw Exception('登入成功但處理用戶數據時發生錯誤: $e');
        }
      } else {
        _logger.e('登入失敗: 狀態碼 ${response.statusCode}');
        _logger.e('響應內容: ${response.data}');
        return null;
      }
    } on DioException catch (e) {
      _logger.e('登入DIO錯誤: ${e.type}');
      _logger.e('錯誤響應狀態碼: ${e.response?.statusCode}');
      _logger.e('錯誤響應數據: ${e.response?.data}');
      _logger.e('錯誤消息: ${e.message}');

      String errorMessage = '登入失敗';

      if (e.response?.statusCode == 401) {
        errorMessage = '用戶名或密碼錯誤';
      } else if (e.response?.data != null &&
          e.response?.data['detail'] != null) {
        errorMessage = e.response?.data['detail'];
      } else if (e.response?.data != null && e.response?.data['msg'] != null) {
        errorMessage = e.response?.data['msg'];
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = '連接超時，請檢查網絡';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = '接收數據超時，請稍後再試';
      }

      throw Exception(errorMessage);
    } catch (e) {
      _logger.e('登入過程中發生未預期的錯誤: $e');
      throw Exception('登入過程中發生錯誤: $e');
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.resetPassword,
        data: {'token': token, 'new_password': newPassword},
      );

      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Reset password error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      _logger.i('開始本地登出處理...');

      // 清除共享偏好設置中的登入狀態
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('userId');
      _logger.i('已清除SharedPreferences中的登入狀態');

      // 清除安全存儲中的所有令牌
      await _secureStorage.delete(key: 'access_token');
      await _secureStorage.delete(key: 'refresh_token');
      _logger.i('已清除安全存儲中的所有令牌');

      _logger.i('本地登出完成');
    } catch (e) {
      _logger.e('登出過程中發生錯誤: $e');
      throw Exception('登出過程中發生錯誤');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final token = await _secureStorage.read(key: 'access_token');
      return token != null;
    } catch (e) {
      _logger.e('Check login status error: $e');
      return false;
    }
  }

  Future<void> _saveAuthState(String userId) async {
    try {
      _logger.i('保存認證狀態...');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', userId);
      _logger.i('認證狀態保存成功: userId = $userId');
    } catch (e) {
      _logger.e('保存認證狀態時發生錯誤: $e');
      throw Exception('保存認證狀態失敗');
    }
  }

  Future<String?> getUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('userId');
    } catch (e) {
      _logger.e('獲取用戶ID時發生錯誤: $e');
      return null;
    }
  }
}
