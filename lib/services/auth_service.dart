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
      
      final response = await _apiClient.post(
        ApiConstants.register,
        data: request.toJson(),
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
          name: request.username,  // 使用 username 作為默認名稱
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

  Future<User?> login(String username, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data);
        
        if (response.data['access_token'] != null) {
          await _secureStorage.write(
            key: 'access_token',
            value: response.data['access_token'],
          );
        }
        
        await _saveAuthState(user.userUuid);
        return user;
      }
      
      return null;
    } catch (e) {
      _logger.e('Login error: $e');
      rethrow;
    }
  }
  
  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final response = await _apiClient.post(
        '/auth/reset-password',
        data: {
          'email': email,
          'new_password': newPassword,
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Reset password error: $e');
      rethrow;
    }
  }
  
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await _secureStorage.deleteAll();
    } catch (e) {
      _logger.e('Logout error: $e');
      rethrow;
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
      return await _secureStorage.read(key: 'user_id');
    } catch (e) {
      _logger.e('Get user ID error: $e');
      return null;
    }
  }
} 