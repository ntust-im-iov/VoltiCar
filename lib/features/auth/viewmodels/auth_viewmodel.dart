import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:volticar_app/features/auth/repositories/auth_repository.dart';
import 'package:volticar_app/features/auth/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final Logger _logger = Logger();
  User? _currentUser;

  // 登入相關狀態
  bool _isLoginLoading = false;
  String? _loginError;
  bool _isLoginSuccess = false;

  // 註冊相關狀態
  bool _isRegisterLoading = false;
  String? _registerError;
  bool _isRegisterSuccess = false;

  // 郵件驗證相關狀態
  bool _isEmailVerificationLoading = false;
  String? _emailVerificationError;
  bool _isEmailVerificationSuccess = false;

  // 重設密碼相關狀態
  bool _isResetPasswordLoading = false;
  String? _resetPasswordError;
  bool _isResetPasswordSuccess = false;

  AuthViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  User? get currentUser => _currentUser;

  // 登入狀態 getter
  bool get isLoginLoading => _isLoginLoading;
  String? get loginError => _loginError;
  bool get isLoginSuccess => _isLoginSuccess;

  // 註冊狀態 getter
  bool get isRegisterLoading => _isRegisterLoading;
  String? get registerError => _registerError;
  bool get isRegisterSuccess => _isRegisterSuccess;

  // 郵件驗證狀態 getter
  bool get isEmailVerificationLoading => _isEmailVerificationLoading;
  String? get emailVerificationError => _emailVerificationError;
  bool get isEmailVerificationSuccess => _isEmailVerificationSuccess;

  // 重設密碼狀態 getter
  bool get isResetPasswordLoading => _isResetPasswordLoading;
  String? get resetPasswordError => _resetPasswordError;
  bool get isResetPasswordSuccess => _isResetPasswordSuccess;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 8;
  }

  // 自動清除登入錯誤訊息(5秒後)
  void autoClearLoginError() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_loginError != null) {
        _loginError = null;
        notifyListeners();
      }
    });
  }

  // 發送郵件驗證
  Future<void> sendEmailVerification(String email) async {
    try {
      _logger.i('AuthViewModel: 開始發送郵件驗證');
      _updateEmailVerificationState(isLoading: true, error: null);
      _logger.i('AuthViewModel: 已通知界面開始加載');

      _logger.i('AuthViewModel: 調用 AuthRepository.sendEmailVerification...');
      _logger.i('AuthViewModel: 參數 - email: $email');
      await _authRepository.sendEmailVerification(email);
      _logger.i('AuthViewModel: AuthRepository.sendEmailVerification 調用完成');

      _updateEmailVerificationState(isLoading: false, isSuccess: true);
      _logger.i('AuthViewModel: 郵件驗證發送成功');
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.split('Exception:').last.trim();
      }
      _updateEmailVerificationState(
        isLoading: false,
        error: errorMessage,
        isSuccess: false,
      );
      _logger.e('AuthViewModel: 郵件驗證發送錯誤 - $errorMessage');
    }
  }

  // 登入方法
  Future<void> login(String username, String password) async {
    // 登入狀態初始化
    _isLoginLoading = true;
    _isLoginSuccess = false;
    _loginError = null;
    notifyListeners();

    try {
      _logger.i('AuthViewModel: 開始登入流程');
      _updateLoginState(isLoading: true, error: null);
      _logger.i('AuthViewModel: 已通知界面開始加載');

      final user = await _authRepository.login(username, password);
      _logger.i('AuthViewModel: AuthRepository.login 調用完成');

      if (user != null) {
        _currentUser = user;
        _updateLoginState(isLoading: false, isSuccess: true);
        _logger.i('AuthViewModel: 登入成功');
      } else {
        _updateLoginState(
          isLoading: false,
          error: '登入失敗',
          isSuccess: false,
        );
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.split('Exception:').last.trim();
      }
      _updateLoginState(
        isLoading: false,
        error: errorMessage,
        isSuccess: false,
      );
      _logger.e('AuthViewModel: 登入錯誤 - $errorMessage');
    }
  }

  // 註冊方法
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      _logger.i('AuthViewModel: 開始註冊流程');
      _updateRegisterState(isLoading: true, error: null);
      _logger.i('AuthViewModel: 已通知界面開始加載');

      _logger.i('AuthViewModel: 調用 AuthRepository.register...');
      _logger.i('AuthViewModel: 參數 - username: $username, email: $email');
      final user = await _authRepository.register(
        username: username,
        email: email,
        password: password,
      );
      _logger.i('AuthViewModel: AuthRepository.register 調用完成');

      if (user != null) {
        _currentUser = user;
        _updateRegisterState(isLoading: false, isSuccess: true);
        _logger.i('AuthViewModel: 註冊成功');
      } else {
        _updateRegisterState(
          isLoading: false,
          error: '註冊失敗',
          isSuccess: false,
        );
        _logger.e('AuthViewModel: 註冊失敗');
      }
    } catch (e) {
      _updateRegisterState(
        isLoading: false,
        error: e.toString(),
        isSuccess: false,
      );
      _logger.e('AuthViewModel: 註冊錯誤 - ${e.toString()}');
    }
  }

  // 檢查登入狀態
  Future<bool> checkLoginStatus() async {
    return await _authRepository.isLoggedIn();
  }

  Future<bool> forgotPassword(String email) async {
    return await _authRepository.forgotPassword(email);
  }

  Future<bool> verifyResetOtp(String optCode) async {
    return await _authRepository.verifyResetOtp(optCode);
  }

  // 重設密碼方法
  Future<void> resetPassword(String newPassword) async {
    try {
      _updateResetPasswordState(isLoading: true, error: null);
      final result = await _authRepository.resetPassword(newPassword);

      if (result) {
        _updateResetPasswordState(isLoading: false, isSuccess: true);
      } else {
        _updateResetPasswordState(
          isLoading: false,
          error: '重設密碼失敗',
          isSuccess: false,
        );
      }
    } catch (e) {
      _updateResetPasswordState(
        isLoading: false,
        error: e.toString(),
        isSuccess: false,
      );
    }
  }

  // 重置重設密碼狀態
  void resetPasswordState() {
    _isResetPasswordLoading = false;
    _resetPasswordError = null;
    _isResetPasswordSuccess = false;
    notifyListeners();
    // 清除安全存儲中的數據
    _authRepository.clearResetPasswordData();
    _logger.i('重設密碼狀態和數據已重置');
  }

  // 登出方法
  Future<void> logout() async {
    try {
      _logger.i('AuthViewModel: 開始登出流程');
      await _authRepository.logout();
      _currentUser = null;
      // 重置登入成功狀態，避免在導航到登入頁面後自動重導向回車庫頁面
      _updateLoginState(isSuccess: false);
      _logger.i('AuthViewModel: 登出成功');
    } catch (e) {
      _logger.e('AuthViewModel: 登出過程中發生錯誤 - $e');
      _currentUser = null;
      // 即使發生錯誤也要重置登入成功狀態
      _updateLoginState(isSuccess: false);
    }
  }

  // Google 登入方法
  Future<void> signInWithGoogle() async {
    try {
      _logger.i('AuthViewModel: 開始 Google 登入流程');
      _updateLoginState(isLoading: true, error: null);
      _logger.i('AuthViewModel: 已通知界面開始加載');

      _logger.i('AuthViewModel: 調用 AuthRepository.signInWithGoogle...');
      final user = await _authRepository.signInWithGoogle();
      _logger.i('AuthViewModel: AuthRepository.signInWithGoogle 調用完成');

      if (user != null) {
        _currentUser = user;
        _updateLoginState(isLoading: false, isSuccess: true);
        _logger.i('AuthViewModel: Google 登入成功');
      } else {
        _updateLoginState(
          isLoading: false,
          error: 'Google 登入失敗',
          isSuccess: false,
        );
        _logger.e('AuthViewModel: Google 登入失敗');
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.split('Exception:').last.trim();
      }
      _updateLoginState(
        isLoading: false,
        error: 'Google 登入錯誤: $errorMessage',
        isSuccess: false,
      );
      _logger.e('AuthViewModel: Google 登入錯誤 - $errorMessage');
    }
  }

  // 更新登入狀態
  void _updateLoginState({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    if (isLoading != null) _isLoginLoading = isLoading;
    if (error != null) {
      _loginError = error;
      autoClearLoginError(); // 自動在5秒後清除錯誤訊息
    }
    if (isSuccess != null) _isLoginSuccess = isSuccess;
    notifyListeners();
  }

  // 更新註冊狀態
  void _updateRegisterState({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    if (isLoading != null) _isRegisterLoading = isLoading;
    if (error != null) _registerError = error;
    if (isSuccess != null) _isRegisterSuccess = isSuccess;
    notifyListeners();
  }

  // 更新郵件驗證狀態
  void _updateEmailVerificationState({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    if (isLoading != null) _isEmailVerificationLoading = isLoading;
    if (error != null) _emailVerificationError = error;
    if (isSuccess != null) _isEmailVerificationSuccess = isSuccess;
    notifyListeners();
  }

  // 更新重設密碼狀態
  void _updateResetPasswordState({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    if (isLoading != null) _isResetPasswordLoading = isLoading;
    if (error != null) _resetPasswordError = error;
    if (isSuccess != null) _isResetPasswordSuccess = isSuccess;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
