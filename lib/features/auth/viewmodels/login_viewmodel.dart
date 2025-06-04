import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:volticar_app/features/auth/models/user_model.dart';
import 'package:volticar_app/features/auth/repositories/login_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginRepository _loginRepository;
  final Logger _logger = Logger();
  User? _currentUser;

  // 登入相關狀態
  bool _isLoginLoading = false;
  String? _loginError;
  bool _isLoginSuccess = false;

  LoginViewModel({LoginRepository? loginRepository})
      : _loginRepository = loginRepository ?? LoginRepository();

  User? get currentUser => _currentUser;

  // 登入狀態 getter
  bool get isLoginLoading => _isLoginLoading;
  String? get loginError => _loginError;
  bool get isLoginSuccess => _isLoginSuccess;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // 驗證密碼
  bool isValidPassword(String password) {
    return password.length >= 8;
  }

  // 自動清除錯誤訊息(3秒後)
  void autoClearError() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_loginError != null) {
        _loginError = null;
        notifyListeners();
      }
    });
  }

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

      final user = await _loginRepository.login(username, password);
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

  // Google 登入方法
  Future<void> signInWithGoogle() async {
    try {
      _logger.i('AuthViewModel: 開始 Google 登入流程');
      _updateLoginState(isLoading: true, error: null);
      _logger.i('AuthViewModel: 已通知界面開始加載');

      _logger.i('AuthViewModel: 調用 AuthRepository.signInWithGoogle...');
      final user = await _loginRepository.signInWithGoogle();
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

  // 檢查登入狀態
  Future<bool> checkLoginStatus() async {
    return await _loginRepository.isLoggedIn();
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
      autoClearError(); // 自動在5秒後清除錯誤訊息
    }
    if (isSuccess != null) _isLoginSuccess = isSuccess;
    notifyListeners();
  }

  // 登出方法
  Future<void> logout() async {
    try {
      _logger.i('AuthViewModel: 開始登出流程');
      await _loginRepository.logout();
      _currentUser = null;
      // 重置登入成功狀態，避免在導航到登入頁面後自動重導向回車庫頁面
      _updateLoginState(isSuccess: false);
      _logger.i('AuthViewModel: 登出成功');
    } catch (e) {
      _logger.e('AuthViewModel: 登出過程中發生錯誤 - $e');
      _currentUser = null;
      // 即使發生錯誤也要重置登入和註冊成功狀態
      _updateLoginState(isSuccess: false);
    }
  }

  // 新增此方法：標記登入成功狀態已被處理
  void markLoginSuccessAsHandled() {
    if (_isLoginSuccess) {
      _isLoginSuccess = false;
      notifyListeners();
      _logger.i('LoginViewModel: Login success state has been reset.');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
