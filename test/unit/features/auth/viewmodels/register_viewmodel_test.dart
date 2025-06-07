import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:volticar_app/features/auth/models/user_model.dart';
import 'package:volticar_app/features/auth/repositories/register_repository.dart';
import 'package:volticar_app/features/auth/viewmodels/register_viewmodel.dart';

@GenerateMocks([RegisterRepository])
import 'register_viewmodel_test.mocks.dart';

void main() {
  late MockRegisterRepository mockRegisterRepository;
  late RegisterViewModel registerViewModel;

  setUp(() {
    mockRegisterRepository = MockRegisterRepository();
    registerViewModel =
        RegisterViewModel(registerRepository: mockRegisterRepository);
  });

  group('RegisterViewModel - 註冊功能測試', () {
    final testUser = User(
      id: '1',
      username: 'new_user',
      email: 'new@example.com',
      token: 'test-token',
    );

    test('註冊成功時應更新狀態並通知監聽者', () async {
      // 安排
      when(mockRegisterRepository.register(
        username: 'new_user',
        email: 'new@example.com',
        password: 'password123',
      )).thenAnswer((_) async => testUser);

      // 執行
      bool notified = false;
      registerViewModel.addListener(() {
        notified = true;
      });

      await registerViewModel.register(
        username: 'new_user',
        email: 'new@example.com',
        password: 'password123',
      );

      // 驗證
      expect(registerViewModel.currentUser, equals(testUser));
      expect(registerViewModel.isRegisterLoading, isFalse);
      expect(registerViewModel.isRegisterSuccess, isTrue);
      expect(registerViewModel.registerError, isNull);
      expect(notified, isTrue);
    });

    test('註冊失敗時應設置錯誤並通知監聽者', () async {
      // 安排
      when(mockRegisterRepository.register(
        username: 'existing_user',
        email: 'existing@example.com',
        password: 'password123',
      )).thenThrow(Exception('註冊失敗的錯誤訊息'));

      // 執行
      bool notified = false;
      registerViewModel.addListener(() {
        notified = true;
      });

      await registerViewModel.register(
        username: 'existing_user',
        email: 'existing@example.com',
        password: 'password123',
      );

      // 驗證
      expect(registerViewModel.currentUser, isNull);
      expect(registerViewModel.isRegisterLoading, isFalse);
      expect(registerViewModel.isRegisterSuccess, isFalse);
      expect(registerViewModel.registerError, '註冊失敗的錯誤訊息');
      expect(notified, isTrue);
    });
  });

  // 你可以為 sendEmailVerification, markEmailVerificationSuccessAsHandled, markRegisterSuccessAsHandled 等方法添加更多測試
}
