import 'package:logger/logger.dart';
import 'package:volticar_app/core/utils/observer.dart';
import 'package:volticar_app/features/auth/repositories/auth_repository.dart';
import 'package:volticar_app/features/auth/models/user_model.dart';

// 定義登入狀態事件
class LoginStateEvent extends ViewEvent {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const LoginStateEvent({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });
}

// 定義註冊狀態事件
class RegisterStateEvent extends ViewEvent {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const RegisterStateEvent({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });
}

// 定義郵件驗證狀態事件
class EmailVerificationEvent extends ViewEvent {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const EmailVerificationEvent({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });
}

// 定義重設密碼狀態事件
class ResetPasswordStateEvent extends ViewEvent {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const ResetPasswordStateEvent({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });
}

// Inherit from EventViewModel to get observer pattern implementation
class AuthViewModel extends EventViewModel {
  final AuthRepository _authRepository;
  final Logger _logger = Logger();
  User? _currentUser;

  AuthViewModel({AuthRepository? authRepository}) 
    : _authRepository = authRepository ?? AuthRepository();

  User? get currentUser => _currentUser;

  // 發送郵件驗證
  Future<void> sendEmailVerification(String email) async {
    try {
      _logger.i('AuthViewModel: 開始發送郵件驗證');
      // 通知界面開始加載
      notify(const EmailVerificationEvent(isLoading: true));
      _logger.i('AuthViewModel: 已通知界面開始加載');

      _logger.i('AuthViewModel: 調用 AuthRepository.sendEmailVerification...');
      _logger.i('AuthViewModel: 參數 - email: $email');
      // 調用存儲庫進行郵件驗證
      await _authRepository.sendEmailVerification(email);
      _logger.i('AuthViewModel: AuthRepository.sendEmailVerification 調用完成');

      // 通知界面發送成功
      notify(const EmailVerificationEvent(isSuccess: true, isLoading: false));
      _logger.i('AuthViewModel: 郵件驗證發送成功');
    } catch (e) {
      // 通知界面發生錯誤
      String errorMessage = e.toString();
      // 處理可能的異常信息，使其更友好
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.split('Exception:').last.trim();
      }
      // 確保錯誤信息被正確傳遞到 UI
      notify(EmailVerificationEvent(
        isLoading: false,
        isSuccess: false,
        error: errorMessage,
      ));
      _logger.e('AuthViewModel: 郵件驗證發送錯誤 - $errorMessage');
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
        notify(const LoginStateEvent(isSuccess: true, isLoading: false));
        _logger.i('AuthViewModel: 登入成功');
      } else {
        // 通知界面登入失敗
        notify(const LoginStateEvent(error: '用戶名或密碼錯誤', isSuccess: false, isLoading: false));
        _logger.e('AuthViewModel: 登入失敗 - 用戶名或密碼錯誤');
      }
    } catch (e) {
      // 通知界面發生錯誤
      String errorMessage = e.toString();
      // 處理可能的異常信息，使其更友好
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.split('Exception:').last.trim();
      }
      // 確保錯誤信息被正確傳遞到 UI
      notify(LoginStateEvent(
        isLoading: false,
        isSuccess: false,
        error: errorMessage,
      ));
      _logger.e('AuthViewModel: 登入錯誤 - $errorMessage');
      return; // 提前返回，不執行 finally 塊中的重置
    }
    // 只有在成功或一般錯誤時才重置加載狀態
    //notify(const LoginStateEvent(isLoading: false, isSuccess: true));
  }

  // 註冊方法
  Future<void> register({
    required String username,
    required String email,
    required String password,
    // Removed required phone parameter as it's not used by the repository
  }) async {
    try {
      _logger.i('AuthViewModel: 開始註冊流程');
      // 通知界面開始加載
      notify(const RegisterStateEvent(isLoading: true));
      _logger.i('AuthViewModel: 已通知界面開始加載');

      _logger.i('AuthViewModel: 調用 AuthRepository.register...');
      _logger.i(
        'AuthViewModel: 參數 - username: $username, email: $email', // Removed phone from log
      );
      // 調用存儲庫進行註冊
      final user = await _authRepository.register(
        username: username,
        email: email,
        password: password,
        // Removed commented-out phone parameter
      );
      _logger.i('AuthViewModel: AuthRepository.register 調用完成');

      if (user != null) {
        _currentUser = user;
        notify(const RegisterStateEvent(isSuccess: true, isLoading: false));
        _logger.i('AuthViewModel: 註冊成功');
      } else {
        notify(const RegisterStateEvent(error: '註冊失敗', isSuccess: false, isLoading: false));
        _logger.e('AuthViewModel: 註冊失敗');
      }
    } catch (e) {
      notify(RegisterStateEvent(error: e.toString()));
      _logger.e('AuthViewModel: 註冊錯誤 - ${e.toString()}');
    }
  }

  // 檢查登入狀態
  Future<bool> checkLoginStatus() async {
    return await _authRepository.isLoggedIn();
  }

  // 重設密碼方法
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      // 通知界面開始加載
      notify(const ResetPasswordStateEvent(isLoading: true));

      // 調用存儲庫進行密碼重設
      final result = await _authRepository.resetPassword(token, newPassword);

      if (result) {
        // 通知界面重設成功
        notify(const ResetPasswordStateEvent(isSuccess: true, isLoading: false));
      } else {
        // 通知界面重設失敗
        notify(const ResetPasswordStateEvent(error: '重設密碼失敗', isSuccess: false, isLoading: false));
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

  // Google 登入方法
  Future<void> signInWithGoogle() async {
    try {
      _logger.i('AuthViewModel: 開始 Google 登入流程');
      // 通知界面開始加載 (可以使用 LoginStateEvent 或創建一個新的 GoogleLoginStateEvent)
      notify(const LoginStateEvent(isLoading: true));
      _logger.i('AuthViewModel: 已通知界面開始加載');

      _logger.i('AuthViewModel: 調用 AuthRepository.signInWithGoogle...');
      // 調用存儲庫進行 Google 登入
      final user = await _authRepository.signInWithGoogle();
      _logger.i('AuthViewModel: AuthRepository.signInWithGoogle 調用完成');

      if (user != null) {
        _currentUser = user;
        // 通知界面登入成功
        notify(const LoginStateEvent(isSuccess: true));
        _logger.i('AuthViewModel: Google 登入成功');
      } else {
        // 通知界面登入失敗
        notify(const LoginStateEvent(error: 'Google 登入失敗'));
        _logger.e('AuthViewModel: Google 登入失敗');
      }
    } catch (e) {
      // 通知界面發生錯誤
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.split('Exception:').last.trim();
      }
      notify(LoginStateEvent(
        isLoading: false,
        isSuccess: false,
        error: 'Google 登入錯誤: $errorMessage',
      ));
      _logger.e('AuthViewModel: Google 登入錯誤 - $errorMessage');
    } finally {
      // 確保加載狀態被重置
      notify(const LoginStateEvent(isLoading: false));
    }
  }

  // Removed redundant notify method implementation.
  // It's now inherited from EventViewModel.
}
