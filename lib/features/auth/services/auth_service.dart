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
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // 註冊新用戶
  Future<User> register(RegisterRequest request) async {
    try {
      _logger.i('開始註冊請求');
      _logger.i('請求數據: ${request.toJson()}');

      // 先在 Firebase 創建用戶
      final firebase_auth.UserCredential firebaseCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: request.email,
        password: request.password,
      );

      // 發送郵件驗證
      await firebaseCredential.user?.sendEmailVerification();
      _logger.i('已發送驗證郵件到: ${request.email}');

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
          isEmailVerified: false, // 新增郵件驗證狀態
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
    } on firebase_auth.FirebaseAuthException catch (e) {
      _logger.e('Firebase 註冊錯誤: ${e.code}');
      throw Exception(_getFirebaseErrorMessage(e.code));
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

  // 檢查郵件是否已驗證
  Future<bool> isEmailVerified() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      await currentUser.reload();
      return currentUser.emailVerified;
    }
    return false;
  }

  // Firebase 錯誤訊息轉換
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return '此電子郵件已被使用';
      case 'invalid-email':
        return '無效的電子郵件格式';
      case 'operation-not-allowed':
        return '電子郵件/密碼註冊未啟用';
      case 'weak-password':
        return '密碼強度不足';
      case 'user-disabled':
        return '此帳號已被停用';
      case 'user-not-found':
        return '找不到此電子郵件對應的帳號';
      case 'wrong-password':
        return '密碼錯誤';
      case 'invalid-credential':
        return '登入憑證無效';
      case 'too-many-requests':
        return '電子郵件尚未驗證';
      default:
        return '操作失敗：$code';
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      _logger.i('開始登入請求');
      _logger.i('電子郵件: $email');

      // 先向 MongoDB 發送請求獲取用戶資料
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'email': email, // 改用 email 參數
          'password': password,
        },
      );

      _logger.i('收到登入響應');
      _logger.i('響應狀態碼: ${response.statusCode}');
      _logger.i('響應數據: ${response.data}');

      if (response.statusCode == 200) {
        try {
          // 使用電子郵件進行 Firebase 驗證
          try {
            final firebaseCredential =
                await _firebaseAuth.signInWithEmailAndPassword(
              email: email,
              password: password,
            );

            // 檢查郵件是否已驗證
            if (!firebaseCredential.user!.emailVerified) {
              _logger.w('用戶郵件尚未驗證');
              // 重新發送驗證郵件
              await firebaseCredential.user!.sendEmailVerification();
              throw Exception('電子郵件尚未驗證');
            }
          } on firebase_auth.FirebaseAuthException catch (e) {
            _logger.e('Firebase 登入錯誤: ${e.code}');
            throw Exception(_getFirebaseErrorMessage(e.code));
          }

          // 創建用戶對象
          final user = User(
            id: response.data['user_id'] ?? '',
            username: response.data['username'] ??
                email.split('@')[0], // 如果沒有用戶名，使用郵件前綴
            email: email,
            password: '', // 不存儲密碼
            name: response.data['name'] ??
                response.data['username'] ??
                email.split('@')[0],
            userUuid: response.data['user_id'] ?? '',
            token: response.data['access_token'] ?? '',
            isEmailVerified: true, // 已通過驗證才能登入
          );

          _logger.i('用戶對象創建成功: ${user.toJson()}');

          // 保存訪問令牌
          if (response.data['access_token'] != null) {
            await _secureStorage.write(
              key: 'access_token',
              value: response.data['access_token'],
            );
            _logger.i('訪問令牌已保存');
          }

          // 保存登入狀態
          await _saveAuthState(user.id);
          _logger.i('認證狀態已保存');

          return user;
        } catch (e) {
          _logger.e('處理登入響應時發生錯誤: $e');
          throw Exception('登入過程中發生錯誤: $e');
        }
      } else {
        _logger.e('登入失敗: ${response.statusCode}');
        throw Exception('登入失敗: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('登入錯誤: ${e.type}');
      _logger.e('錯誤響應: ${e.response?.data}');
      _logger.e('錯誤消息: ${e.message}');
      throw Exception(e.response?.data['detail'] ?? '登入失敗');
    } catch (e) {
      _logger.e('未預期的錯誤: $e');
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
      _logger.i('開始 Google 登入流程');

      // 初始化 GoogleSignIn
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      _logger.i('嘗試 Google 登入...');
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        _logger.w('使用者取消了 Google 登入');
        return null;
      }

      _logger.i('取得 Google 認證...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      _logger.i('創建 Firebase 憑證...');
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      _logger.i('使用 Firebase 進行身份驗證...');
      final userCredential = await firebase_auth.FirebaseAuth.instance
          .signInWithCredential(credential);

      if (userCredential.user != null) {
        _logger.i('Firebase 認證成功，用戶 ID: ${userCredential.user!.uid}');

        // 創建用戶對象
        final user = User(
          id: userCredential.user!.uid,
          username: userCredential.user!.displayName ?? '',
          email: userCredential.user!.email ?? '',
          name: userCredential.user!.displayName ?? '',
          userUuid: userCredential.user!.uid,
          token: await userCredential.user!.getIdToken() ?? '',
          isGoogleUser: true,
        );

        // 保存用戶數據到 MongoDB
        await _saveGoogleUserToMongoDB(user);

        return user;
      }

      _logger.w('Firebase 認證失敗');
      return null;
    } catch (e, stackTrace) {
      _logger.e('Google 登入過程中發生錯誤', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // 將 Google 用戶數據保存到 MongoDB
  Future<bool> _saveGoogleUserToMongoDB(User user) async {
    try {
      _logger.i('開始將 Google 用戶數據保存到 MongoDB');
      _logger.i('用戶數據: ${user.toJson()}');

      // 準備要發送到後端的數據 - 使用註冊端點的格式
      final Map<String, dynamic> userData = {
        'username': user.username,
        'email': user.email,
        'password': '${user.id}_google_auth', // 使用 Firebase UID 作為密碼的一部分，確保唯一性
        'isGoogleUser': true,
        'name': user.name,
        'userUuid': user.userUuid,
      };

      _logger.i('準備發送數據到 MongoDB: $userData');
      _logger.i('API 端點: ${ApiConstants.register}');

      // 發送請求到後端 API，使用註冊端點
      final response = await _apiClient.post(
        ApiConstants.register,
        data: userData,
      );

      _logger.i('MongoDB 響應狀態碼: ${response.statusCode}');
      _logger.i('MongoDB 響應數據: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.i('Google 用戶數據成功保存到 MongoDB Users 集合');

        // 如果後端返回了新的令牌，則更新本地存儲
        if (response.data != null && response.data['access_token'] != null) {
          await _secureStorage.write(
            key: 'access_token',
            value: response.data['access_token'],
          );
          _logger.i('已更新來自 MongoDB 的訪問令牌');

          // 保存刷新令牌（如果有）
          if (response.data['refresh_token'] != null) {
            await _secureStorage.write(
              key: 'refresh_token',
              value: response.data['refresh_token'],
            );
            _logger.i('已保存刷新令牌');
          }
        }

        // 如果後端返回了用戶 ID，則更新本地存儲
        if (response.data != null && response.data['user_id'] != null) {
          await _saveAuthState(response.data['user_id']);
          _logger.i('已更新來自 MongoDB 的用戶 ID');
        }

        return true;
      } else if (response.statusCode == 409) {
        _logger.w('用戶已存在於 MongoDB，嘗試使用登入端點');
        return await _loginGoogleUserToMongoDB(user);
      } else {
        _logger.e('保存 Google 用戶數據到 MongoDB 失敗: ${response.statusCode}');
        _logger.e('響應數據: ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        _logger.w('用戶已存在於 MongoDB，嘗試使用登入端點');
        return await _loginGoogleUserToMongoDB(user);
      }

      _logger.e('保存 Google 用戶數據到 MongoDB 時發生 DIO 錯誤: ${e.type}');
      _logger.e('錯誤響應: ${e.response?.data}');
      _logger.e('錯誤消息: ${e.message}');
      _logger.e('錯誤 URL: ${e.requestOptions.path}');
      _logger.e('錯誤數據: ${e.requestOptions.data}');
      return false;
    } catch (e) {
      _logger.e('保存 Google 用戶數據到 MongoDB 時發生未預期的錯誤: $e');
      return false;
    }
  }

  // 如果用戶已存在，則使用登入端點
  Future<bool> _loginGoogleUserToMongoDB(User user) async {
    try {
      _logger.i('嘗試使用登入端點將 Google 用戶連接到 MongoDB');

      // 準備登入數據
      final Map<String, dynamic> loginData = {
        'username': user.email, // 使用 email 作為用戶名
        'password': '${user.id}_google_auth', // 使用相同的密碼格式
      };

      _logger.i('準備發送登入數據到 MongoDB: $loginData');
      _logger.i('API 端點: ${ApiConstants.login}');

      // 發送請求到登入端點
      final response = await _apiClient.post(
        ApiConstants.login,
        data: loginData,
      );

      _logger.i('MongoDB 登入響應狀態碼: ${response.statusCode}');
      _logger.i('MongoDB 登入響應數據: ${response.data}');

      if (response.statusCode == 200) {
        _logger.i('Google 用戶成功登入到 MongoDB');

        // 更新令牌和用戶 ID
        if (response.data != null && response.data['access_token'] != null) {
          await _secureStorage.write(
            key: 'access_token',
            value: response.data['access_token'],
          );
          _logger.i('已更新來自 MongoDB 的訪問令牌');
        }

        if (response.data != null && response.data['user_id'] != null) {
          await _saveAuthState(response.data['user_id']);
          _logger.i('已更新來自 MongoDB 的用戶 ID');
        }

        return true;
      } else {
        _logger.e('Google 用戶登入到 MongoDB 失敗: ${response.statusCode}');
        _logger.e('響應數據: ${response.data}');
        return false;
      }
    } catch (e) {
      _logger.e('Google 用戶登入到 MongoDB 時發生錯誤: $e');
      return false;
    }
  }
}
