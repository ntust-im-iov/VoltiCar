import '../core/utils/observer.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';

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
  Future<void> register(String username, String email, String password) async {
    try {
      // 通知界面開始加載
      notify(const RegisterStateEvent(isLoading: true));
      
      // 調用存儲庫進行註冊
      final user = await _authRepository.register(username, email, password);
      
      if (user != null) {
        _currentUser = user;
        // 通知界面註冊成功
        notify(const RegisterStateEvent(isSuccess: true));
      } else {
        // 通知界面註冊失敗
        notify(const RegisterStateEvent(error: '註冊失敗'));
      }
    } catch (e) {
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