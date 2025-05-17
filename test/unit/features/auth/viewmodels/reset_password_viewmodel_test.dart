import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:volticar_app/features/auth/repositories/reset_password_repository.dart';
import 'package:volticar_app/features/auth/viewmodels/reset_password_viewmodel.dart';

@GenerateMocks([ResetPasswordRepository])
import 'reset_password_viewmodel_test.mocks.dart';

void main() {
  late MockResetPasswordRepository mockResetPasswordRepository;
  late ResetPasswordViewModel resetPasswordViewModel;

  setUp(() {
    mockResetPasswordRepository = MockResetPasswordRepository();
    resetPasswordViewModel = ResetPasswordViewModel(
        resetPasswordRepository: mockResetPasswordRepository);
  });

  group('ResetPasswordViewModel - 忘記密碼功能測試', () {
    test('成功發送忘記密碼請求時應返回 true', () async {
      // 安排
      const email = 'test@example.com';
      when(mockResetPasswordRepository.forgotPassword(email))
          .thenAnswer((_) async => true);

      // 執行
      final result = await resetPasswordViewModel.forgotPassword(email);

      // 驗證
      expect(result, isTrue);
      verify(mockResetPasswordRepository.forgotPassword(email)).called(1);
    });

    test('發送忘記密碼請求失敗時應返回 false', () async {
      // 安排
      const email = 'invalid@example.com';
      when(mockResetPasswordRepository.forgotPassword(email))
          .thenAnswer((_) async => false);

      // 執行
      final result = await resetPasswordViewModel.forgotPassword(email);

      // 驗證
      expect(result, isFalse);
      verify(mockResetPasswordRepository.forgotPassword(email)).called(1);
    });
  });

  group('ResetPasswordViewModel - 重設密碼功能測試', () {
    test('成功重設密碼時應更新狀態並通知監聽者', () async {
      // 安排
      const newPassword = 'newSecurePassword123';
      when(mockResetPasswordRepository.resetPassword(newPassword))
          .thenAnswer((_) async => true);

      bool notified = false;
      resetPasswordViewModel.addListener(() {
        notified = true;
      });

      // 執行
      await resetPasswordViewModel.resetPassword(newPassword);

      // 驗證
      expect(resetPasswordViewModel.isResetPasswordLoading, isFalse);
      expect(resetPasswordViewModel.isResetPasswordSuccess, isTrue);
      expect(resetPasswordViewModel.resetPasswordError, isNull);
      expect(notified, isTrue);
      verify(mockResetPasswordRepository.resetPassword(newPassword)).called(1);
    });

    test('重設密碼失敗時應更新狀態並通知監聽者', () async {
      // 安排
      const newPassword = 'newSecurePassword123';
      const errorMessage = '重設密碼失敗'; // 這是 ResetPasswordViewModel 內部設定的錯誤
      // Repository 拋出異常的情況
      // when(mockResetPasswordRepository.resetPassword(newPassword))
      //     .thenThrow(Exception(errorMessage));
      // Repository 返回 false 的情況
      when(mockResetPasswordRepository.resetPassword(newPassword))
          .thenAnswer((_) async => false);

      bool notified = false;
      resetPasswordViewModel.addListener(() {
        notified = true;
      });

      // 執行
      await resetPasswordViewModel.resetPassword(newPassword);

      // 驗證
      expect(resetPasswordViewModel.isResetPasswordLoading, isFalse);
      expect(resetPasswordViewModel.isResetPasswordSuccess, isFalse);
      expect(resetPasswordViewModel.resetPasswordError, errorMessage);
      expect(notified, isTrue);
      verify(mockResetPasswordRepository.resetPassword(newPassword)).called(1);
    });
  });

  // 你可以為 verifyResetOtp, resetPasswordState, markResetPasswordSuccessAsHandled 等方法添加更多測試
}
