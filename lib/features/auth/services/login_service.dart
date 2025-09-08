import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:volticar_app/features/auth/models/user_model.dart';
import 'package:volticar_app/core/constants/api_constants.dart';
import 'package:volticar_app/core/network/api_client.dart';

class LoginService {
  static final LoginService _instance = LoginService._internal();
  final Logger _logger = Logger();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ApiClient _apiClient = ApiClient();
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  factory LoginService() {
    return _instance;
  }

  LoginService._internal();

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
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      _logger.i('收到登入響應');
      _logger.i('響應狀態碼: ${response.statusCode}');
      _logger.i('響應數據: ${response.data}');

      if (response.statusCode == 200) {
        try {
          /* 使用電子郵件進行 Firebase 驗證
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
          */

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
            // isEmailVerified: true, // 已通過驗證才能登入(棄用 後端會自動驗證)
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
      // 重新添加：檢查是否為 Google 用戶嘗試密碼登入的特定錯誤
      if (e.response?.statusCode == 400 && // 或後端實際使用的狀態碼
          e.response?.data?['detail'] == 'google_auth_required') {
        // 或後端實際使用的錯誤 detail
        _logger.w('Google 用戶嘗試使用密碼登入');
        throw Exception('此帳號是透過 Google 註冊的，請點擊「使用 Google 登入」按鈕。');
      }
      // 其他登入錯誤
      throw Exception(e.response?.data['detail'] ?? '登入失敗');
    } catch (e) {
      _logger.e('未預期的錯誤: $e');
      throw Exception('登入過程中發生錯誤: $e');
    }
  }

  Future<void> logout() async {
    try {
      _logger.i('開始本地登出處理...');

      // 清除共享偏好設置中的登入狀態
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_logged_in');
      await prefs.remove('user_id');
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
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      return token != null && isLoggedIn;
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
      return prefs.getString('user_id');
    } catch (e) {
      _logger.e('獲取用戶ID時發生錯誤: $e');
      return null;
    }
  }

  //Firebase 錯誤訊息轉換
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

  // Google登入
  Future<User?> signInWithGoogle() async {
    try {
      _logger.i('開始 Google 登入流程');

      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      GoogleSignInAccount? googleUser;
      try {
        googleUser = await googleSignIn.signIn();
      } catch (e) {
        _logger.e('Google 登入過程中發生錯誤: $e');
        throw Exception('Google 登入過程中發生錯誤: $e');
      }

      if (googleUser == null) {
        _logger.w('使用者取消了 Google 登入');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final firebaseUser = userCredential.user!;
        _logger.i('Firebase Google 驗證成功，UID: ${firebaseUser.uid}');

        // 取 ID Token
        String? idToken = googleAuth.idToken;
        if (idToken == null) {
          throw Exception('Google 認證失敗：無法獲取 ID Token');
        }

        // ✅ 從 ID Token payload 抓取 sub 作為 google_id
        String? googleId;
        try {
          final parts = idToken.split('.');
          if (parts.length == 3) {
            String payload = parts[1];
            switch (payload.length % 4) {
              case 1:
                payload += '===';
                break;
              case 2:
                payload += '==';
                break;
              case 3:
                payload += '=';
                break;
            }
            final decoded = utf8.decode(base64Url.decode(payload));
            final Map<String, dynamic> tokenData = json.decode(decoded);
            googleId = tokenData['sub'] as String?;
            _logger.i('從 ID Token 解析出的 Google ID (sub): $googleId');
          }
        } catch (e) {
          _logger.w('解析 ID Token sub 失敗: $e，改用 Firebase UID');
        }
        googleId ??= firebaseUser.uid; // fallback

        // 組合送後端的資料
        final Map<String, dynamic> googleLoginData = {
          'google_id': googleId,
          'email': firebaseUser.email ?? '',
          'name': firebaseUser.displayName ??
              firebaseUser.email?.split('@')[0] ??
              'google_user',
          'id_token': idToken,
        };

        _logger.i('準備呼叫後端 Google 登入 API: ${ApiConstants.googleLogin}');
        _logger.i('傳送數據: $googleLoginData');

        // ... 後面呼叫 _apiClient.post 的部分不動，保留原本註冊 fallback 流程 ...
        try {
          // 呼叫後端 /users/google-login 端點
          final response = await _apiClient.post(
            ApiConstants.googleLogin, // 使用定義好的 googleLogin 常數
            data: googleLoginData,
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          );

          _logger.i('後端 Google 登入 API 響應狀態碼: ${response.statusCode}');
          _logger.i('後端 Google 登入 API 響應數據: ${response.data}');

          if (response.statusCode == 200) {
            // --- 處理後端 API 成功響應 ---
            _logger.i('後端 Google 登入成功');

            // 提取後端返回的 token 和用戶信息
            final backendData = response.data;
            final accessToken = backendData?['access_token'] as String?;
            final refreshToken = backendData?['refresh_token'] as String?;
            // 假設後端會返回一個 user_id 或類似的唯一標識符
            final backendUserId = backendData?['user_id'] as String? ??
                googleId; // 優先使用後端ID，否則用 googleId

            // 保存 token
            if (accessToken != null) {
              await _secureStorage.write(
                  key: 'access_token', value: accessToken);
              _logger.i('已保存訪問令牌');
            }
            if (refreshToken != null) {
              await _secureStorage.write(
                  key: 'refresh_token', value: refreshToken);
              _logger.i('已保存刷新令牌');
            }

            // 保存登入狀態
            await _saveAuthState(backendUserId);
            _logger.i('已更新認證狀態，用戶標識: $backendUserId');

            // 創建 User 對象返回給 UI 層
            // 注意：這裡的 User 對象主要用於前端顯示，token 來自後端
            final user = User(
              id: backendUserId, // 使用後端返回的 ID 或 googleId
              username: backendData?['username'] as String? ??
                  firebaseUser.displayName ??
                  firebaseUser.email?.split('@')[0] ??
                  'google_user', // 優先使用後端 username
              email: firebaseUser.email ?? '',
              name: backendData?['name'] as String? ??
                  firebaseUser.displayName ??
                  firebaseUser.email?.split('@')[0] ??
                  'google_user', // 優先使用後端 name
              userUuid: googleId, // 保留原始的 Firebase UID
              token: accessToken ?? '', // 使用後端返回的 token
              isGoogleUser: true, // 標記為 Google 用戶
              photoUrl: firebaseUser.photoURL, // 可以保留 Firebase 的頭像 URL
              // isEmailVerified 通常由 Firebase 管理，後端可能不直接返回
              isEmailVerified: firebaseUser.emailVerified,
            );
            _logger.i('創建最終 User 對象: ${user.toJson()}');
            return user;
          } else {
            // --- 處理後端 API 錯誤響應 ---
            _logger
                .e('後端 Google 登入失敗: ${response.statusCode}, ${response.data}');
            throw Exception(
                'Google 登入失敗: ${response.data?['detail'] ?? response.statusCode}');
          }
        } on DioException catch (e) {
          _logger.e('呼叫後端 Google 登入 API 時發生 DIO 錯誤: ${e.type}');
          _logger.e('錯誤響應: ${e.response?.data}');
          _logger.e('錯誤消息: ${e.message}');
          _logger.e('請求 URL: ${e.requestOptions.uri}');
          _logger.e('請求數據: ${e.requestOptions.data}');

          // 如果是 404 或用戶不存在的錯誤，或者是無效的Google ID錯誤，嘗試自動註冊
          if (e.response?.statusCode == 404 ||
              (e.response?.statusCode == 400 &&
                  e.response?.data != null &&
                  (e.response!.data
                          .toString()
                          .toLowerCase()
                          .contains('not found') ||
                      e.response!.data.toString().contains('無效的Google ID') ||
                      e.response!.data
                          .toString()
                          .toLowerCase()
                          .contains('invalid google id')))) {
            _logger.i('用戶不存在，嘗試自動註冊 Google 用戶...');

            try {
              // 嘗試自動註冊新的 Google 用戶
              return await _registerGoogleUser(googleLoginData, firebaseUser);
            } catch (registerError) {
              _logger.e('自動註冊 Google 用戶失敗: $registerError');
              throw Exception('Google 用戶註冊失敗: $registerError');
            }
          }

          // 提供更具體的錯誤訊息
          String errorMessage = 'Google 登入處理失敗';
          if (e.response?.data != null) {
            if (e.response!.data is Map) {
              errorMessage = e.response!.data['detail'] ??
                  e.response!.data['message'] ??
                  errorMessage;
            } else {
              errorMessage = e.response!.data.toString();
            }
          }
          throw Exception(errorMessage);
        } catch (e) {
          _logger.e('處理後端 Google 登入 API 響應時發生錯誤: $e');
          throw Exception('Google 登入處理失敗: $e');
        }
      } else {
        _logger.w('Firebase 認證失敗，無法獲取用戶信息');
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e('Google 登入過程中發生錯誤', error: e, stackTrace: stackTrace);
      // 可以根據錯誤類型提供更具體的錯誤信息
      if (e is firebase_auth.FirebaseAuthException) {
        throw Exception('Firebase 認證錯誤: ${_getFirebaseErrorMessage(e.code)}');
      }
      throw Exception('Google 登入失敗: $e');
    }
  }

  // 使用 /users/login/google API 進行 Google 用戶註冊
  Future<User> _registerGoogleUser(Map<String, dynamic> googleLoginData,
      firebase_auth.User firebaseUser) async {
    try {
      _logger.i('使用 /users/login/google API 註冊新的 Google 用戶...');

      // 準備發送到 /users/login/google 的註冊數據
      final registerData = {
        'google_id': googleLoginData['google_id'],
        'email': googleLoginData['email'],
        'name': googleLoginData['name'],
        'id_token': googleLoginData['id_token'],
        'username': googleLoginData['name']
            .toString()
            .replaceAll(' ', '_')
            .toLowerCase(),
        'photo_url': firebaseUser.photoURL,
        'is_email_verified': firebaseUser.emailVerified,
      };

      _logger.i('Google 註冊數據: $registerData');

      // 嘗試使用 form-urlencoded 格式，可能後端期望這種格式
      final response = await _apiClient.post(
        ApiConstants.googleLogin, // 使用 /users/login/google
        data: registerData,
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      _logger.i('Google 註冊 API 響應: ${response.statusCode}');
      _logger.i('響應數據: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 註冊成功，處理後端響應
        final backendData = response.data;
        final accessToken = backendData?['access_token'] as String?;
        final refreshToken = backendData?['refresh_token'] as String?;
        final backendUserId =
            backendData?['user_id'] as String? ?? googleLoginData['google_id'];

        // 保存 token
        if (accessToken != null) {
          await _secureStorage.write(key: 'access_token', value: accessToken);
          _logger.i('已保存後端返回的訪問令牌');
        }
        if (refreshToken != null) {
          await _secureStorage.write(key: 'refresh_token', value: refreshToken);
          _logger.i('已保存後端返回的刷新令牌');
        }

        // 保存登入狀態
        await _saveAuthState(backendUserId);
        _logger.i('已更新認證狀態，用戶標識: $backendUserId');

        // 創建並返回用戶對象
        final user = User(
          id: backendUserId,
          username:
              backendData?['username'] as String? ?? registerData['username'],
          email: googleLoginData['email'],
          name: googleLoginData['name'],
          userUuid: googleLoginData['google_id'],
          token: accessToken ?? '',
          isGoogleUser: true,
          photoUrl: firebaseUser.photoURL,
          isEmailVerified: firebaseUser.emailVerified,
        );

        _logger.i('Google 用戶註冊成功: ${user.toJson()}');
        return user;
      } else {
        throw Exception('Google 註冊失敗: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('Google 用戶註冊 API 錯誤: ${e.type}');
      _logger.e('錯誤響應: ${e.response?.data}');
      _logger.e('錯誤消息: ${e.message}');
      _logger.e('請求 URL: ${e.requestOptions.uri}');
      _logger.e('請求數據: ${e.requestOptions.data}');

      // 提供更具體的錯誤訊息
      String errorMessage = 'Google 註冊處理失敗';
      if (e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage = e.response!.data['detail'] ??
              e.response!.data['message'] ??
              errorMessage;
        } else {
          errorMessage = e.response!.data.toString();
        }
      }
      throw Exception('Google 用戶註冊失敗: $errorMessage');
    } catch (e) {
      _logger.e('Google 用戶註冊過程中發生錯誤: $e');
      throw Exception('Google 用戶註冊失敗: $e');
    }
  }
}
