import 'dart:async';

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

  // 使用者名稱檢查相關狀態
  Timer? _debounce;
  bool _isCheckingUsername = false;
  String? _usernameAvailabilityMessage;
  bool _isUsernameAvailable = false;
  String? _usernameFormatError;

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

  // 使用者名稱檢查狀態 getter
  bool get isCheckingUsername => _isCheckingUsername;
  String? get usernameAvailabilityMessage => _usernameAvailabilityMessage;
  bool get isUsernameAvailable => _isUsernameAvailable;
  String? get usernameFormatError => _usernameFormatError;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 8;
  }

  // 驗證使用者名稱格式
  bool isValidUserName(String username) {
    if (username.isEmpty) {
      return false;
    }
    // 規則：
    // 1. 長度 4-20 字元。
    // 2. 只能包含英文大小寫字母 (a-z, A-Z), 數字 (0-9), 底線 (_)。
    // 3. 必須以字母或數字開頭。
    // 4. 必須以字母或數字結尾。
    // 5. 不允許連續的底線 (__)。
    final RegExp usernameRegExp =
        RegExp(r"^(?=[a-zA-Z0-9_]{4,20}$)(?!.*__)[a-zA-Z0-9][a-zA-Z0-9_]*[a-zA-Z0-9]$");

    // 處理一個特殊情況：如果使用者名稱長度剛好是1，且上述正規表示式可能不匹配（因為它期望首尾之間至少有0個字符給中間的 `[a-zA-Z0-9_]*`）
    // 但我們的長度預查 `(?=[a-zA-Z0-9_]{4,20}$)` 已經確保長度至少為4。
    // 因此，上述正規表達式應該能正確處理。
    // 例如 "ab_c" (長度4) -> true
    // "abc" (長度3) -> false (因長度不足)
    // "a__b" (長度4) -> false (因連續底線)
    // "_abc" (長度4) -> false (非字母數字開頭)
    // "abc_" (長度4) -> false (非字母數字結尾)

    return usernameRegExp.hasMatch(username);
  }

  // 自動清除錯誤訊息(3秒後)
  void autoClearError() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_registerError != null ||
          _emailVerificationError != null ||
          _usernameAvailabilityMessage != null) {
        _registerError = null;
        _emailVerificationError = null;
        _usernameAvailabilityMessage = null;
        notifyListeners();
      }
    });
  }

  // 檢查使用者名稱是否可用 (帶 Debounce)
  Future<void> checkUsernameAvailability(String username) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // 首先，立即檢查格式
    if (username.isNotEmpty && !isValidUserName(username)) {
      _usernameFormatError = '使用者名稱格式不符。'; // ViewModel 只設定簡單錯誤訊息
      _isCheckingUsername = false;
      _usernameAvailabilityMessage = null;
      _isUsernameAvailable = false;
      notifyListeners();
      _debounce?.cancel();
      return;
    } else {
      _usernameFormatError = null; // 格式正確，清除格式錯誤訊息
      // (如果 username 為空，也會清除 format error)
    }

    if (username.isEmpty) {
      _isCheckingUsername = false;
      _usernameAvailabilityMessage = null;
      _isUsernameAvailable = false;
      _usernameFormatError = null; // Username is empty, so no format error
      notifyListeners();
      return;
    }

    // 格式正確，準備檢查可用性
    _isCheckingUsername = true;
    _usernameAvailabilityMessage = null;
    _isUsernameAvailable = false;
    // _usernameFormatError 應該已經被設為 null 或在上面處理了
    notifyListeners();

    _debounce = Timer(const Duration(milliseconds: 700), () async {
      try {
        // 再次確認格式，以防萬一 (理論上不會到這一步如果格式初次就錯誤)
        if (!isValidUserName(username)) {
          _usernameFormatError = '使用者名稱格式不符。'; // 簡短訊息
          _isCheckingUsername = false;
          _usernameAvailabilityMessage = null;
          notifyListeners();
          return;
        }
        _usernameFormatError = null; // 確保清除

        final isAvailable = await _registerRepository.isUsernameAvailable(username);
        _isUsernameAvailable = isAvailable;
        if (isAvailable) {
          _usernameAvailabilityMessage = '使用者名稱 "$username" 可用';
        } else {
          _usernameAvailabilityMessage = '使用者名稱 "$username" 已被使用';
        }
      } catch (e) {
        _isUsernameAvailable = false;
        String errorMessage = e.toString();
        if (errorMessage.contains('Exception:')) {
          errorMessage = errorMessage.split('Exception:').last.trim();
        }
        _usernameAvailabilityMessage = '檢查使用者名稱失敗: $errorMessage';
        _logger.e('檢查使用者名稱 "$username" 時發生錯誤: $e');
      } finally {
        _isCheckingUsername = false;
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

  // 新增此方法：標記郵件驗證成功狀態已被處理
  void markEmailVerificationSuccessAsHandled() {
    if (_isEmailVerificationSuccess) {
      _isEmailVerificationSuccess = false;
      notifyListeners();
      _logger.i('RegisterViewModel: Email verification success state has been reset.');
    }
  }

  // 新增此方法：標記註冊成功狀態已被處理
  void markRegisterSuccessAsHandled() {
    if (_isRegisterSuccess) {
      _isRegisterSuccess = false;
      notifyListeners();
      _logger.i('RegisterViewModel: Register success state has been reset.');
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
