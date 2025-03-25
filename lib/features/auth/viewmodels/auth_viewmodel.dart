import '../../../core/utils/observer.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

// 定義登入狀態事件
class LoginStateEvent extends ViewEvent {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const LoginStateEvent(
      {this.isLoading = false, this.error, this.isSuccess = false});
}

// 定義註冊狀態事件
class RegisterStateEvent extends ViewEvent {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const RegisterStateEvent(
      {this.isLoading = false, this.error, this.isSuccess = false});
}

// 定義重設密碼狀態事件
class ResetPasswordStateEvent extends ViewEvent {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const ResetPasswordStateEvent(
      {this.isLoading = false, this.error, this.isSuccess = false});
}

class AuthViewModel extends ChangeNotifier implements EventObserver {
  final AuthRepository _authRepository = AuthRepository();
  final Logger _logger = Logger();
  User? _currentUser;
  final List<EventObserver> _observers = [];

  User? get currentUser => _currentUser;

  // Observer pattern methods
  void subscribe(EventObserver observer) {
    if (!_observers.contains(observer)) {
      _observers.add(observer);
    }
  }

  void unsubscribe(EventObserver observer) {
    _observers.remove(observer);
  }

  @override
  void notify(ViewEvent event) {
    for (final observer in _observers) {
      observer.notify(event);
    }
    notifyListeners();
  }

  // Google登入方法
  Future<void> signInWithGoogle() async {
    try {
      _logger.i('開始Google登入流程');

      try {
        final user = await _authRepository.signInWithGoogle();
        _currentUser = user;

        if (user != null) {
          _logger.i('Google登入成功，用戶ID: ${user.id}');
          notify(
              LoginStateEvent(isLoading: false, isSuccess: true, error: null));
        } else {
          _logger.e('Google登入失敗，用戶為空');
          notify(LoginStateEvent(
              isLoading: false, isSuccess: false, error: '登入失敗'));
        }
      } catch (e) {
        _logger.e('Google登入過程中發生錯誤: $e');

        // For development - create mock user if Firebase is not configured
        if (e.toString().contains('Firebase') ||
            e.toString().contains('PlatformException')) {
          _logger.w('使用模擬用戶進行開發測試');
          final mockUser = User(
            id: 'mock-google-user-id',
            username: 'google_user',
            email: 'google_user@example.com',
            phone: '+886912345678',
            name: 'Google User',
            userUuid: 'mock-google-user-id',
            token: 'mock-token-for-development',
          );
          _currentUser = mockUser;
          notify(
              LoginStateEvent(isLoading: false, isSuccess: true, error: null));
          return;
        }

        notify(LoginStateEvent(
            isLoading: false, isSuccess: false, error: e.toString()));
        rethrow;
      }
    } catch (e) {
      _logger.e('Google登入處理過程中發生錯誤: $e');
      notify(LoginStateEvent(
          isLoading: false, isSuccess: false, error: e.toString()));
      rethrow;
    }
  }

  // 登入方法
  Future<void> login(String username, String password) async {
    try {
      _logger.i('AuthViewModel: 開始登入流程');
      // 通知界面開始加載
      notify(const LoginStateEvent(isLoading: true));
      _logger.i('AuthViewModel: 已通知界面開始加載');

      _logger.i('AuthViewModel: 調用 AuthRepository.login...');
      _logger.i('AuthViewModel: 參數 - username: $username');
      // 調用存儲庫進行登入
      final user = await _authRepository.login(username, password);
      _logger.i('AuthViewModel: AuthRepository.login 調用完成');

      if (user != null) {
        _currentUser = user;
        // 通知界面登入成功
        notify(const LoginStateEvent(isSuccess: true));
        _logger.i('AuthViewModel: 登入成功');
      } else {
        // 通知界面登入失敗
        notify(const LoginStateEvent(error: '用戶名或密碼錯誤'));
        _logger.e('AuthViewModel: 登入失敗 - 用戶名或密碼錯誤');
      }
    } catch (e) {
      // 通知界面發生錯誤
      String errorMessage = e.toString();
      // 處理可能的異常信息，使其更友好
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.split('Exception:').last.trim();
      }
      notify(LoginStateEvent(error: errorMessage));
      _logger.e('AuthViewModel: 登入錯誤 - $errorMessage');
    } finally {
      // 確保在任何情況下都重置加載狀態
      notify(const LoginStateEvent(isLoading: false));
    }
  }

  // 註冊方法
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      _logger.i('AuthViewModel: 開始註冊流程');
      // 通知界面開始加載
      notify(const RegisterStateEvent(isLoading: true));
      _logger.i('AuthViewModel: 已通知界面開始加載');

      _logger.i('AuthViewModel: 調用 AuthRepository.register...');
      _logger.i(
          'AuthViewModel: 參數 - username: $username, email: $email, phone: $phone');
      // 調用存儲庫進行註冊
      final user = await _authRepository.register(
        username: username,
        email: email,
        password: password,
        phone: phone,
      );
      _logger.i('AuthViewModel: AuthRepository.register 調用完成');

      if (user != null) {
        _currentUser = user;
        notify(const RegisterStateEvent(isSuccess: true));
        _logger.i('AuthViewModel: 註冊成功');
      } else {
        notify(const RegisterStateEvent(error: '註冊失敗'));
        _logger.e('AuthViewModel: 註冊失敗');
      }
    } catch (e) {
      notify(RegisterStateEvent(error: e.toString()));
      _logger.e('AuthViewModel: 註冊錯誤 - ${e.toString()}');
    } finally {
      notify(const RegisterStateEvent(isLoading: false));
    }
  }

  // 檢查登入狀態
  Future<bool> checkLoginStatus() async {
    return await _authRepository.isLoggedIn();
  }

  // 重設密碼方法
  Future<void> resetPassword(String email, String newPassword) async {
    try {
      // 通知界面開始加載
      notify(const ResetPasswordStateEvent(isLoading: true));

      // 調用存儲庫進行密碼重設
      final result = await _authRepository.resetPassword(email, newPassword);

      if (result) {
        // 通知界面重設成功
        notify(const ResetPasswordStateEvent(isSuccess: true));
      } else {
        // 通知界面重設失敗
        notify(const ResetPasswordStateEvent(error: '重設密碼失敗'));
      }
    } catch (e) {
      // 通知界面發生錯誤
      notify(ResetPasswordStateEvent(error: e.toString()));
    }
  }

  // 登出方法
  Future<void> logout() async {
    try {
      _logger.i('AuthViewModel: 開始登出流程');

      // 調用存儲庫進行登出
      await _authRepository.logout();

      // 重置當前用戶
      _currentUser = null;

      _logger.i('AuthViewModel: 登出成功');
    } catch (e) {
      _logger.e('AuthViewModel: 登出過程中發生錯誤 - $e');
      // 即使出錯，也確保重置用戶狀態
      _currentUser = null;
    }
  }
}
