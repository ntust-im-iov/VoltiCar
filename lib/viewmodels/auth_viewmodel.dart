import '../core/utils/observer.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';
import 'package:logger/logger.dart';

// 定義登入狀態事件
class LoginStateEvent extends ViewEvent {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const LoginStateEvent({
    this.isLoading = false, 
    this.error, 
    this.isSuccess = false
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
    this.isSuccess = false
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
    this.isSuccess = false
  });
}

class AuthViewModel extends EventViewModel {
  final AuthRepository _authRepository = AuthRepository();
  final Logger _logger = Logger();
  User? _currentUser;
  
  User? get currentUser => _currentUser;
  
  // 登入方法
  Future<void> login(String username, String password) async {
    try {
      // 通知界面開始加載
      notify(const LoginStateEvent(isLoading: true));
      
      // 調用存儲庫進行登入
      final user = await _authRepository.login(username, password);
      
      if (user != null) {
        _currentUser = user;
        // 通知界面登入成功
        notify(const LoginStateEvent(isSuccess: true));
      } else {
        // 通知界面登入失敗
        notify(const LoginStateEvent(error: '用戶名或密碼錯誤'));
      }
    } catch (e) {
      // 通知界面發生錯誤
      notify(LoginStateEvent(error: e.toString()));
    }
  }
  
  // 註冊方法
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String name,
  }) async {
    try {
      _logger.i('AuthViewModel: 開始註冊流程');
      // 通知界面開始加載
      notify(const RegisterStateEvent(isLoading: true));
      _logger.i('AuthViewModel: 已通知界面開始加載');
      
      _logger.i('AuthViewModel: 調用 AuthRepository.register...');
      _logger.i('AuthViewModel: 參數 - username: $username, email: $email, phone: $phone, name: $name');
      // 調用存儲庫進行註冊
      final user = await _authRepository.register(
        username: username,
        email: email,
        password: password,
        phone: phone,
        name: name,
      );
      _logger.i('AuthViewModel: AuthRepository.register 調用完成');
      
      if (user != null) {
        _currentUser = user;
        _logger.i('AuthViewModel: 註冊成功，用戶信息：${user.toJson()}');
        // 通知界面註冊成功
        notify(const RegisterStateEvent(isSuccess: true));
        _logger.i('AuthViewModel: 已通知界面註冊成功');
      } else {
        _logger.e('AuthViewModel: 註冊失敗，用戶對象為空');
        // 通知界面註冊失敗
        notify(const RegisterStateEvent(error: '註冊失敗'));
      }
    } catch (e) {
      _logger.e('AuthViewModel: 註冊過程中發生錯誤: $e');
      // 通知界面發生錯誤
      notify(RegisterStateEvent(error: e.toString()));
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
    await _authRepository.logout();
    _currentUser = null;
  }
} 