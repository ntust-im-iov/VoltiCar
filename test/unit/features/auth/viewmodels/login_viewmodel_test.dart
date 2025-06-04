import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:volticar_app/features/auth/models/user_model.dart'; // 假設 User Model 仍然存在且路徑正確
import 'package:volticar_app/features/auth/repositories/login_repository.dart';
import 'package:volticar_app/features/auth/viewmodels/login_viewmodel.dart';

// 生成 MockLoginRepository
@GenerateMocks([LoginRepository])
import 'login_viewmodel_test.mocks.dart'; // 這個檔案將由 build_runner 生成

void main() {
  late MockLoginRepository mockLoginRepository;
  late LoginViewModel loginViewModel;

  setUp(() {
    mockLoginRepository = MockLoginRepository();
    loginViewModel = LoginViewModel(loginRepository: mockLoginRepository);
  });

  group('LoginViewModel - 登入功能測試', () {
    final testUser = User(
      id: '1',
      username: 'test_user',
      email: 'test@example.com',
      token: 'test-token', // 假設 User model 包含 token
    );

    test('登入成功時應更新狀態並通知監聽者', () async {
      // 安排
      when(mockLoginRepository.login('test_user', 'password123'))
          .thenAnswer((_) async => testUser);

      // 執行
      bool notified = false;
      loginViewModel.addListener(() {
        notified = true;
      });

      await loginViewModel.login('test_user', 'password123');

      // 驗證
      expect(loginViewModel.currentUser, equals(testUser));
      expect(loginViewModel.isLoginLoading, isFalse);
      expect(loginViewModel.isLoginSuccess, isTrue);
      expect(loginViewModel.loginError, isNull);
      expect(notified, isTrue);

      // 考慮驗證 markLoginSuccessAsHandled 的相關行為（如果需要）
      // 例如，可以模擬呼叫 markLoginSuccessAsHandled 並檢查 isLoginSuccess 是否變回 false
    });

    test('登入失敗時應設置錯誤並通知監聽者', () async {
      // 安排
      // 假設登入失敗時 LoginRepository 會拋出一個 Exception
      when(mockLoginRepository.login('wrong_user@test.com', 'wrong_password'))
          .thenThrow(Exception('登入失敗的錯誤訊息'));

      // 執行
      bool notified = false;
      loginViewModel.addListener(() {
        notified = true;
      });

      await loginViewModel.login('wrong_user@test.com', 'wrong_password');

      // 驗證
      expect(loginViewModel.currentUser, isNull);
      expect(loginViewModel.isLoginLoading, isFalse);
      expect(loginViewModel.isLoginSuccess, isFalse);
      expect(loginViewModel.loginError,
          '登入失敗的錯誤訊息'); // 驗證 LoginViewModel 是否捕獲並設置了錯誤訊息
      expect(notified, isTrue);
    });
  });

  group('LoginViewModel - 登出功能測試', () {
    final testUser = User(
      id: '1',
      username: 'test_user',
      email: 'test@example.com',
      token: 'test-token',
    );

    test('登出應清除當前用戶並重置登入狀態', () async {
      // 安排: 先模擬登入成功
      when(mockLoginRepository.login('test_user', 'password123'))
          .thenAnswer((_) async => testUser);
      await loginViewModel.login('test_user', 'password123');

      expect(loginViewModel.currentUser, isNotNull);
      expect(loginViewModel.isLoginSuccess, isTrue);

      // 安排: 模擬登出
      when(mockLoginRepository.logout())
          .thenAnswer((_) async {}); // 假設 logout 返回 Future<void>

      // 執行
      bool notified = false;
      loginViewModel.addListener(() {
        notified = true;
      });

      await loginViewModel.logout();

      // 驗證
      expect(loginViewModel.currentUser, isNull);
      expect(loginViewModel.isLoginSuccess, isFalse); // 假設登出會重置 isLoginSuccess
      expect(notified, isTrue);
    });
  });

  // 你可以為 checkLoginStatus, signInWithGoogle, autoClearError, markLoginSuccessAsHandled 等方法添加更多測試
}
