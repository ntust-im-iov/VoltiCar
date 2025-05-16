import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:volticar_app/features/auth/repositories/register_repository.dart';
import 'package:volticar_app/features/auth/models/user_model.dart';

class RegisterViewModel extends ChangeNotifier {
  final RegisterRepository _registerRepository;
  final Logger _logger = Logger();
  User? _currentUser;

  // 註冊相關狀態
  bool _isRegisterLoading = false;
  String? _registerError;
  bool _isRegisterSuccess = false;

  // 郵件驗證相關狀態
  bool _isEmailVerificationLoading = false;
  String? _emailVerificationError;
  bool _isEmailVerificationSuccess = false;

  RegisterViewModel({RegisterRepository? registerRepository})
      : _registerRepository = registerRepository ?? RegisterRepository();

  User? get currentUser => _currentUser;

  // 註冊狀態 getter
  bool get isRegisterLoading => _isRegisterLoading;
  String? get registerError => _registerError;
  bool get isRegisterSuccess => _isRegisterSuccess;

  // 郵件驗證狀態 getter
  bool get isEmailVerificationLoading => _isEmailVerificationLoading;
  String? get emailVerificationError => _emailVerificationError;
  bool get isEmailVerificationSuccess => _isEmailVerificationSuccess;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 8;
  }

  // 自動清除錯誤訊息(3秒後)
  void autoClearError() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_registerError != null || _emailVerificationError != null) {
        _registerError = null;
        _emailVerificationError = null;
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
      await _registerRepository.sendEmailVerification(email);
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
      final user = await _registerRepository.register(
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
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.split('Exception:').last.trim();
      }
      _updateRegisterState(
        isLoading: false,
        error: errorMessage,
        isSuccess: false,
      );
      _logger.e('AuthViewModel: 註冊錯誤 - $errorMessage');
    }
  }

  // 更新註冊狀態
  void _updateRegisterState({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    if (isLoading != null) _isRegisterLoading = isLoading;
    if (error != null) {
      _registerError = error;
      autoClearError(); // 自動在5秒後清除錯誤訊息
    }

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
    if (error != null) {
      _emailVerificationError = error;
      autoClearError(); // 自動清除錯誤訊息
    }
    if (isSuccess != null) _isEmailVerificationSuccess = isSuccess;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
