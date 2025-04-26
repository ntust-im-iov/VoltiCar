import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:volticar_app/core/utils/observer.dart';
import 'package:volticar_app/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:volticar_app/features/auth/repositories/auth_repository.dart';
import 'package:volticar_app/features/auth/models/user_model.dart';

// 生成 AuthRepository 的 Mock 類
@GenerateMocks([AuthRepository])
import 'auth_viewmodel_test.mocks.dart';

// 模擬觀察者
class MockObserver implements EventObserver {
  LoginStateEvent? lastLoginEvent;
  RegisterStateEvent? lastRegisterEvent;
  ResetPasswordStateEvent? lastResetPasswordEvent;

  @override
  void notify(ViewEvent event) {
    if (event is LoginStateEvent) {
      lastLoginEvent = event;
    } else if (event is RegisterStateEvent) {
      lastRegisterEvent = event;
    } else if (event is ResetPasswordStateEvent) {
      lastResetPasswordEvent = event;
    }
  }

  void reset() {
    lastLoginEvent = null;
    lastRegisterEvent = null;
    lastResetPasswordEvent = null;
  }
}

void main() {
  late AuthViewModel authViewModel;
  late MockAuthRepository mockAuthRepository;
  late MockObserver mockObserver;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    
    // 將 authViewModel 的 _authRepository 設置為 mockAuthRepository
    authViewModel = AuthViewModel(authRepository: mockAuthRepository);
    
    // 使用反射或暴露的方法設置 mock 存儲庫，這裡假設有方法可以設置
    // 如果 AuthViewModel 沒有提供設置存儲庫的方法，則需要修改 ViewModel 類以支持測試
    // authViewModel.setRepository(mockAuthRepository);
    
    mockObserver = MockObserver();
    authViewModel.subscribe(mockObserver);
  });

  group('登入功能測試', () {
    test('登入成功應通知觀察者成功狀態', () async {
      // 安排
      final testUser = User(
        id: 'test-id',
        username: 'testuser',
        email: 'test@example.com',
        password: '',
        name: 'Test User',
        userUuid: 'test-uuid',
        token: 'test-token',
        isEmailVerified: true,
      );
      
      when(mockAuthRepository.login('testuser', 'password123'))
          .thenAnswer((_) async => testUser);
      
      // 執行
      await authViewModel.login('testuser', 'password123');
      
      // 驗證
      verify(mockAuthRepository.login('testuser', 'password123')).called(1);
      expect(mockObserver.lastLoginEvent?.isLoading, isFalse);
      expect(mockObserver.lastLoginEvent?.isSuccess, isTrue);
      expect(mockObserver.lastLoginEvent?.error, isNull);
    });

    test('登入失敗應通知觀察者錯誤狀態', () async {
      // 安排
      when(mockAuthRepository.login('testuser', 'wrongpassword'))
          .thenAnswer((_) async => null);
      
      // 執行
      await authViewModel.login('testuser', 'wrongpassword');
      
      // 驗證
      verify(mockAuthRepository.login('testuser', 'wrongpassword')).called(1);
      expect(mockObserver.lastLoginEvent?.isLoading, isFalse);
      expect(mockObserver.lastLoginEvent?.isSuccess, isFalse);
      expect(mockObserver.lastLoginEvent?.error, isNotNull);
    });

    test('登入過程中應通知觀察者加載狀態', () async {
      // 安排
      when(mockAuthRepository.login(any, any))
          .thenAnswer((_) async {
            // 驗證加載狀態是否已通知
            expect(mockObserver.lastLoginEvent?.isLoading, isTrue);
            return null;
          });
      
      // 執行
      await authViewModel.login('testuser', 'password123');
      
      // 最終狀態應該是非加載狀態
      expect(mockObserver.lastLoginEvent?.isLoading, isFalse);
    });
  });

  group('註冊功能測試', () {
    test('註冊成功應通知觀察者成功狀態', () async {
      // 安排
      final testUser = User(
        id: 'test-id',
        username: 'newuser',
        email: 'new@example.com',
        password: '',
        name: 'New User',
        userUuid: 'new-uuid',
        token: 'new-token',
        isEmailVerified: false,
      );
      
      when(mockAuthRepository.register(
        username: 'newuser',
        email: 'new@example.com',
        password: 'password123',
      )).thenAnswer((_) async => testUser);
      
      // 執行
      await authViewModel.register(
        username: 'newuser',
        email: 'new@example.com',
        password: 'password123',
      );
      
      // 驗證
      verify(mockAuthRepository.register(
        username: 'newuser',
        email: 'new@example.com',
        password: 'password123',
      )).called(1);
      expect(mockObserver.lastRegisterEvent?.isLoading, isFalse);
      expect(mockObserver.lastRegisterEvent?.isSuccess, isTrue);
      expect(mockObserver.lastRegisterEvent?.error, isNull);
    });
  });

  group('重設密碼功能測試', () {
    test('重設密碼成功應通知觀察者成功狀態', () async {
      // 安排
      when(mockAuthRepository.resetPassword('reset-token', 'newpassword123'))
          .thenAnswer((_) async => true);
      
      // 執行
      await authViewModel.resetPassword('reset-token', 'newpassword123');
      
      // 驗證
      verify(mockAuthRepository.resetPassword('reset-token', 'newpassword123')).called(1);
      expect(mockObserver.lastResetPasswordEvent?.isLoading, isFalse);
      expect(mockObserver.lastResetPasswordEvent?.isSuccess, isTrue);
      expect(mockObserver.lastResetPasswordEvent?.error, isNull);
    });
  });
} 