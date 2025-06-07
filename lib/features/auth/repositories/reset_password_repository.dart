import 'package:volticar_app/features/auth/services/reset_password_service.dart';

class ResetPasswordRepository {
  final ResetPasswordService _resetPasswordService = ResetPasswordService();

  // 重設密碼
  Future<bool> forgotPassword(String email) async {
    return await _resetPasswordService.forgotPassword(email);
  }

  // 驗證重設密碼
  Future<bool> verifyResetOtp(String optCode) async {
    return await _resetPasswordService.verifyResetOtp(optCode);
  }

  // 重設密碼
  Future<bool> resetPassword(String newPassword) async {
    return await _resetPasswordService.resetPassword(newPassword);
  }

  // 清除重設密碼相關數據
  Future<void> clearResetPasswordData() async {
    await _resetPasswordService.clearResetPasswordData();
  }
}
