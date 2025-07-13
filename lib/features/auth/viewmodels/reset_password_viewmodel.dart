import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:volticar_app/features/auth/repositories/reset_password_repository.dart';
import 'package:volticar_app/features/auth/models/user_model.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  final ResetPasswordRepository _resetPasswordRepository;
  final Logger _logger = Logger();
  User? _currentUser;

  // 重設密碼相關狀態
  bool _isResetPasswordLoading = false;
  String? _resetPasswordError;
  bool _isResetPasswordSuccess = false;

  ResetPasswordViewModel({ResetPasswordRepository? resetPasswordRepository})
      : _resetPasswordRepository =
            resetPasswordRepository ?? ResetPasswordRepository();

  User? get currentUser => _currentUser;

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

  Future<bool> forgotPassword(String email) async {
    return await _resetPasswordRepository.forgotPassword(email);
  }

  Future<bool> verifyResetOtp(String optCode) async {
    return await _resetPasswordRepository.verifyResetOtp(optCode);
  }

  // 重設密碼方法
  Future<void> resetPassword(String newPassword) async {
    try {
      _updateResetPasswordState(isLoading: true, error: null);
      final result = await _resetPasswordRepository.resetPassword(newPassword);

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
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.split('Exception:').last.trim();
      }
      _updateResetPasswordState(
        isLoading: false,
        error: errorMessage,
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
    _resetPasswordRepository.clearResetPasswordData();
    _logger.i('重設密碼狀態和數據已重置');
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

  // 新增此方法：標記重設密碼成功狀態已被處理
  void markResetPasswordSuccessAsHandled() {
    if (_isResetPasswordSuccess) {
      _isResetPasswordSuccess = false;
      _resetPasswordError = null;
      _isResetPasswordLoading = false;
      notifyListeners();
      // 清除安全存儲中的數據
      _resetPasswordRepository.clearResetPasswordData();
      _logger.i(
          'ResetPasswordViewModel: Reset password success state has been reset.');
      _logger.i('重設密碼狀態和數據已重置');
    }
  }

}
