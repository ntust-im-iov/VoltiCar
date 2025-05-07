import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:volticar_app/features/auth/models/user_model.dart';
import 'package:volticar_app/features/auth/models/register_request.dart';
import 'package:volticar_app/core/constants/api_constants.dart';
import 'package:volticar_app/core/network/api_client.dart';

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

  //檢查郵件是否已驗證(Firebase 驗證)
  Future<bool> isEmailVerified() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      await currentUser.reload();
      return currentUser.emailVerified;
    }
    return false;
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

  // Google登入
  Future<User?> signInWithGoogle() async {
    try {
      _logger.i('開始 Google 登入流程');

      // 初始化 GoogleSignIn
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      _logger.i('嘗試 Google 登入...');
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

      _logger.i('取得 Google 認證...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      _logger.i('創建 Firebase 憑證...');
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      _logger.i('使用 Firebase 進行身份驗證...');
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user != null) {
        _logger.i('Firebase 認證成功，用戶 ID: ${userCredential.user!.uid}');
        final firebaseUser = userCredential.user!;
        _logger.i('Firebase Google 驗證成功，UID: ${firebaseUser.uid}');

        // 準備發送到後端 /users/google-login 的數據
        String emailPrefix = firebaseUser.email?.split('@')[0] ?? 'google_user';
        String displayName = firebaseUser.displayName ?? '';
        String name = displayName.isNotEmpty ? displayName : emailPrefix;
        String email = firebaseUser.email ?? '';
        String googleId = firebaseUser.uid; // 使用 Firebase UID 作為 google_id

        final Map<String, dynamic> googleLoginData = {
          'google_id': googleId,
          'email': email,
          'name': name,
          // 如果後端需要其他來自 Google 的資訊 (如 photoUrl)，可以在這裡添加
          // 'photo_url': firebaseUser.photoURL,
        };

        _logger.i('準備呼叫後端 Google 登入 API: ${ApiConstants.googleLogin}');
        _logger.i('傳送數據: $googleLoginData');

        try {
          // 呼叫後端 /users/google-login 端點
          final response = await _apiClient.post(
            ApiConstants.googleLogin, // 使用定義好的 googleLogin 常數
            data: googleLoginData,
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
                  name, // 優先使用後端 username
              email: email,
              name: backendData?['name'] as String? ?? name, // 優先使用後端 name
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
          throw Exception(e.response?.data['detail'] ?? 'Google 登入處理失敗');
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
} // End of AuthService class
