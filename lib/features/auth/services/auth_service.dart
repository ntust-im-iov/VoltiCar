import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import '../models/register_request.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

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
          id: response.data['user_id'] as String? ?? '',
          username: request.username,
          email: request.email,
          password: request.password,
          name: request.username, // 使用 username 作為默認名稱
          userUuid: response.data['user_id'] as String?,
          token: response.data['token'] as String? ?? '',
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

  Future<User?> login(String username, String password) async {
    try {
      _logger.i('開始登入請求');
      _logger.i('用戶名: $username');

      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'username': username,
          'password': password,
        },
      );

      _logger.i('收到登入響應');
      _logger.i('響應狀態碼: ${response.statusCode}');
      _logger.i('響應數據: ${response.data}');

      if (response.statusCode == 200) {
        try {
          // 使用響應數據創建用戶對象
          final user = User(
            id: response.data['user_id'] ?? response.data['user_uuid'] ?? '',
            username: response.data['username'] ?? username,
            email: response.data['email'] ?? '',
            password: '', // 不存儲密碼
            phone: response.data['phone'] ?? '',
            name:
                response.data['name'] ?? response.data['username'] ?? username,
            userUuid:
                response.data['user_uuid'] ?? response.data['user_id'] ?? '',
            token:
                response.data['access_token'] ?? response.data['token'] ?? '',
          );

          _logger.i('用戶對象創建成功: ${user.toJson()}');

          // 保存訪問令牌
          if (response.data['access_token'] != null) {
            await _secureStorage.write(
              key: 'access_token',
              value: response.data['access_token'],
            );
            _logger.i('訪問令牌已保存');
          } else if (response.data['token'] != null) {
            await _secureStorage.write(
              key: 'access_token',
              value: response.data['token'],
            );
            _logger.i('訪問令牌已保存(token鍵)');
          } else {
            _logger.w('響應中未找到訪問令牌');
          }

          // 保存刷新令牌(如果有)
          if (response.data['refresh_token'] != null) {
            await _secureStorage.write(
              key: 'refresh_token',
              value: response.data['refresh_token'],
            );
            _logger.i('刷新令牌已保存');
          }

          // 保存登入狀態
          await _saveAuthState(user.userUuid);
          _logger.i('認證狀態已保存');

          return user;
        } catch (e) {
          _logger.e('解析用戶數據時發生錯誤: $e');
          throw Exception('登入成功但處理用戶數據時發生錯誤');
        }
      } else {
        _logger.e('登入失敗: 狀態碼 ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      _logger.e('登入DIO錯誤: ${e.type}');
      _logger.e('錯誤響應: ${e.response?.data}');
      _logger.e('錯誤消息: ${e.message}');

      String errorMessage = '登入失敗';

      if (e.response?.statusCode == 401) {
        errorMessage = '用戶名或密碼錯誤';
      } else if (e.response?.data != null &&
          e.response?.data['detail'] != null) {
        errorMessage = e.response?.data['detail'];
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
      return prefs.getString('userId');
    } catch (e) {
      _logger.e('獲取用戶ID時發生錯誤: $e');
      return null;
    }
  }

  // Google登入
  Future<User?> signInWithGoogle() async {
    try {
      _logger.i('開始Google登入流程');

      // 初始化GoogleSignIn，設置為每次都提示選擇帳號
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        forceCodeForRefreshToken: true,
      );

      // 確保先登出，以便每次都會顯示帳號選擇界面
      await googleSignIn.signOut();

      // 顯示Google登入界面
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        _logger.w('用戶取消了Google登入');
        return null;
      }

      _logger.i('獲取Google認證');
      // 獲取認證
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 創建Firebase憑證
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 使用Firebase進行身份驗證
      final userCredential = await firebase_auth.FirebaseAuth.instance
          .signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        _logger.i('Firebase認證成功，用戶ID: ${firebaseUser.uid}');

        // 創建用戶對象
        final user = User(
          id: firebaseUser.uid,
          username: firebaseUser.displayName ??
              firebaseUser.email?.split('@')[0] ??
              'user',
          email: firebaseUser.email ?? '',
          phone: firebaseUser.phoneNumber ?? '',
          name: firebaseUser.displayName,
          userUuid: firebaseUser.uid,
          token: await firebaseUser.getIdToken() ?? '',
          photoUrl: firebaseUser.photoURL,
        );

        // 保存token到安全存儲
        await _secureStorage.write(key: 'access_token', value: user.token);

        // 將Google用戶數據保存到MongoDB
        await _saveGoogleUserToMongoDB(user);

        _logger.i('Google登入成功，返回用戶對象');
        return user;
      } else {
        _logger.e('Firebase認證失敗');
        return null;
      }
    } catch (e) {
      _logger.e('Google登入過程中發生錯誤: $e');
      rethrow;
    }
  }

  // 將Google用戶數據保存到MongoDB
  Future<bool> _saveGoogleUserToMongoDB(User user) async {
    try {
      _logger.i('開始將Google用戶數據保存到MongoDB');
      _logger.i('用戶數據: ${user.toJson()}');

      // 準備要發送到後端的數據 - 使用註冊端點的格式
      final Map<String, dynamic> userData = {
        'username': user.username,
        'email': user.email,
        'password': '${user.id}_google_auth', // 使用Firebase UID作為密碼的一部分，確保唯一性
        'phone': user.phone,
        'name': user.name ?? user.username,
        'user_uuid': user.id, // 使用Firebase UID作為用戶UUID
        'auth_provider': 'google',
        'profile_image': user.photoUrl ?? '',
      };

      _logger.i('準備發送數據到MongoDB: $userData');
      _logger.i('API端點: ${ApiConstants.register}');

      // 發送請求到後端API，使用註冊端點
      final response = await _apiClient.post(
        ApiConstants.register,
        data: userData,
      );

      _logger.i('MongoDB響應狀態碼: ${response.statusCode}');
      _logger.i('MongoDB響應數據: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.i('Google用戶數據成功保存到MongoDB Users集合');

        // 如果後端返回了新的令牌，則更新本地存儲
        if (response.data != null && response.data['access_token'] != null) {
          await _secureStorage.write(
            key: 'access_token',
            value: response.data['access_token'],
          );
          _logger.i('已更新來自MongoDB的訪問令牌');

          // 保存刷新令牌（如果有）
          if (response.data['refresh_token'] != null) {
            await _secureStorage.write(
              key: 'refresh_token',
              value: response.data['refresh_token'],
            );
            _logger.i('已保存刷新令牌');
          }
        }

        // 如果後端返回了用戶ID，則更新本地存儲
        if (response.data != null && response.data['user_id'] != null) {
          await _saveAuthState(response.data['user_id']);
          _logger.i('已更新來自MongoDB的用戶ID');
        }

        return true;
      } else if (response.statusCode == 409) {
        _logger.w('用戶已存在於MongoDB，嘗試使用登入端點');
        return await _loginGoogleUserToMongoDB(user);
      } else {
        _logger.e('保存Google用戶數據到MongoDB失敗: ${response.statusCode}');
        _logger.e('響應數據: ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        _logger.w('用戶已存在於MongoDB，嘗試使用登入端點');
        return await _loginGoogleUserToMongoDB(user);
      }

      _logger.e('保存Google用戶數據到MongoDB時發生DIO錯誤: ${e.type}');
      _logger.e('錯誤響應: ${e.response?.data}');
      _logger.e('錯誤消息: ${e.message}');
      _logger.e('錯誤URL: ${e.requestOptions.path}');
      _logger.e('錯誤數據: ${e.requestOptions.data}');
      return false;
    } catch (e) {
      _logger.e('保存Google用戶數據到MongoDB時發生未預期的錯誤: $e');
      return false;
    }
  }

  // 如果用戶已存在，則使用登入端點
  Future<bool> _loginGoogleUserToMongoDB(User user) async {
    try {
      _logger.i('嘗試使用登入端點將Google用戶連接到MongoDB');

      // 準備登入數據
      final Map<String, dynamic> loginData = {
        'username': user.email, // 使用email作為用戶名
        'password': '${user.id}_google_auth', // 使用相同的密碼格式
      };

      _logger.i('準備發送登入數據到MongoDB: $loginData');
      _logger.i('API端點: ${ApiConstants.login}');

      // 發送請求到登入端點
      final response = await _apiClient.post(
        ApiConstants.login,
        data: loginData,
      );

      _logger.i('MongoDB登入響應狀態碼: ${response.statusCode}');
      _logger.i('MongoDB登入響應數據: ${response.data}');

      if (response.statusCode == 200) {
        _logger.i('Google用戶成功登入到MongoDB');

        // 更新令牌和用戶ID
        if (response.data != null && response.data['access_token'] != null) {
          await _secureStorage.write(
            key: 'access_token',
            value: response.data['access_token'],
          );
          _logger.i('已更新來自MongoDB的訪問令牌');
        }

        if (response.data != null && response.data['user_id'] != null) {
          await _saveAuthState(response.data['user_id']);
          _logger.i('已更新來自MongoDB的用戶ID');
        }

        return true;
      } else {
        _logger.e('Google用戶登入到MongoDB失敗: ${response.statusCode}');
        _logger.e('響應數據: ${response.data}');
        return false;
      }
    } catch (e) {
      _logger.e('Google用戶登入到MongoDB時發生錯誤: $e');
      return false;
    }
  }
}
