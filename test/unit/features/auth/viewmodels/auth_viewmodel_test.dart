import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:volticar_app/features/auth/models/user_model.dart';
import 'package:volticar_app/features/auth/repositories/auth_repository.dart';
import 'package:volticar_app/features/auth/viewmodels/auth_viewmodel.dart';

@GenerateMocks([AuthRepository])
import 'auth_viewmodel_test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthViewModel authViewModel;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authViewModel = AuthViewModel(authRepository: mockAuthRepository);
  });

  group('登入功能測試', () {
    test('登入成功時應更新狀態並通知監聽者', () async {
      // 安排
      final testUser = User(
        id: '1',
        username: 'test_user',
        email: 'test@example.com',
        token: 'test-token',
      );
      when(mockAuthRepository.login('test_user', 'password123'))
          .thenAnswer((_) async => testUser);

      // 執行
      bool notified = false;
      authViewModel.addListener(() {
        notified = true;
      });

      await authViewModel.login('test_user', 'password123');

      // 驗證
      expect(authViewModel.currentUser, equals(testUser));
      expect(authViewModel.isLoginLoading, isFalse);
      expect(authViewModel.isLoginSuccess, isTrue);
      expect(authViewModel.loginError, isNull);
      expect(notified, isTrue);
    });

    test('登入失敗時應設置錯誤並通知監聽者', () async {
      // 安排
      when(mockAuthRepository.login('wrong_user@test.com', 'wrong_password'))
          .thenAnswer((_) async => null);

      // 執行
      bool notified = false;
      authViewModel.addListener(() {
        notified = true;
      });

      await authViewModel.login('wrong_user@test.com', 'wrong_password');

      // 驗證
      expect(authViewModel.currentUser, isNull);
      expect(authViewModel.isLoginLoading, isFalse);
      expect(authViewModel.isLoginSuccess, isFalse);
      expect(authViewModel.loginError, isNotNull);
      expect(notified, isTrue);
    });
  });

  group('註冊功能測試', () {
    test('註冊成功時應更新狀態並通知監聽者', () async {
      // 安排
      final testUser = User(
        id: '1',
        username: 'new_user',
        email: 'new@example.com',
        token: 'test-token',
      );
      when(mockAuthRepository.register(
        username: 'new_user',
        email: 'new@example.com',
        password: 'password123',
      )).thenAnswer((_) async => testUser);

      // 執行
      bool notified = false;
      authViewModel.addListener(() {
        notified = true;
      });

      await authViewModel.register(
        username: 'new_user',
        email: 'new@example.com',
        password: 'password123',
      );

      // 驗證
      expect(authViewModel.currentUser, equals(testUser));
      expect(authViewModel.isRegisterLoading, isFalse);
      expect(authViewModel.isRegisterSuccess, isTrue);
      expect(authViewModel.registerError, isNull);
      expect(notified, isTrue);
    });
  });

  group('登出功能測試', () {
    test('登出應清除當前用戶並重置登入狀態', () async {
      // 安排
      final testUser = User(
        id: '1',
        username: 'test_user',
        email: 'test@example.com',
        token: 'test-token',
      );
      when(mockAuthRepository.login('test_user', 'password123'))
          .thenAnswer((_) async => testUser);
      when(mockAuthRepository.logout()).thenAnswer((_) async => null);

      await authViewModel.login('test_user', 'password123');
      expect(authViewModel.currentUser, isNotNull);
      expect(authViewModel.isLoginSuccess, isTrue);

      // 執行
      bool notified = false;
      authViewModel.addListener(() {
        notified = true;
      });

      await authViewModel.logout();

      // 驗證
      expect(authViewModel.currentUser, isNull);
      expect(authViewModel.isLoginSuccess, isFalse);
      expect(notified, isTrue);
    });
  });
}
