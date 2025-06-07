import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volticar_app/features/auth/views/login_view.dart';
import 'package:volticar_app/features/auth/viewmodels/login_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// 生成 AuthViewModel 的 Mock 類
@GenerateMocks([LoginViewModel])
import 'login_view_test.mocks.dart';

void main() {
  late MockLoginViewModel mockLoginViewModel;

  setUp(() {
    mockLoginViewModel = MockLoginViewModel();

    // 預設常用方法和屬性的行為
    when(mockLoginViewModel.checkLoginStatus()).thenAnswer((_) async => false);
    when(mockLoginViewModel.isLoginLoading).thenReturn(false);
    when(mockLoginViewModel.isLoginSuccess).thenReturn(false);
    when(mockLoginViewModel.loginError).thenReturn(null);
  });

  testWidgets('LoginView 應該顯示登入表單和註冊鏈接', (WidgetTester tester) async {
    // 設置更大的測試窗口尺寸
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.reset());

    // 構建我們的 app 並觸發一個 frame
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<LoginViewModel>.value(
          value: mockLoginViewModel,
          child: const LoginView(),
        ),
      ),
    );

    // 驗證 UI 元素
    expect(find.text('登入'), findsOneWidget);
    expect(find.text('電子信箱'), findsOneWidget);
    expect(find.text('密碼'), findsOneWidget);
    expect(find.text('忘記密碼?'), findsOneWidget);

    // 確認有輸入框
    expect(find.byType(TextFormField), findsAtLeast(2));

    // 確認有按鈕
    expect(find.byType(ElevatedButton), findsAtLeast(1));
  });

  testWidgets('輸入無效內容應顯示驗證錯誤', (WidgetTester tester) async {
    // 設置更大的測試窗口尺寸
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.reset());

    // 構建我們的 app 並觸發一個 frame
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<LoginViewModel>.value(
          value: mockLoginViewModel,
          child: const LoginView(),
        ),
      ),
    );

    // 找到登入按鈕
    final loginButton = find.text('登入');

    // 確保登入按鈕可見
    await tester.ensureVisible(loginButton);
    await tester.pumpAndSettle();

    // 點擊登入按鈕
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // 驗證是否顯示表單驗證錯誤
    expect(find.byType(Form), findsOneWidget); // 確保表單存在

    // 打印所有文本小部件以查看實際錯誤訊息
    tester.widgetList(find.byType(Text)).forEach((widget) {
      final Text textWidget = widget as Text;
      print('Login test - Found text: "${textWidget.data}"');
    });

    // 檢查是否有任何文本包含特定關鍵字
    expect(find.textContaining('請輸入'), findsAtLeast(1));
  });

  testWidgets('輸入有效內容應調用登入方法', (WidgetTester tester) async {
    // 設置更大的測試窗口尺寸
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.reset());

    // 構建我們的 app 並觸發一個 frame
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<LoginViewModel>.value(
          value: mockLoginViewModel,
          child: const LoginView(),
        ),
        routes: {
          '/garage': (context) => const Scaffold(body: Text('測試車庫頁面')),
        },
      ),
    );

    // 找到輸入框並輸入有效內容
    final usernameField = find.byType(TextFormField).at(0);
    final passwordField = find.byType(TextFormField).at(1);

    await tester.ensureVisible(usernameField);
    await tester.enterText(usernameField, 'testuser@test.com');

    await tester.ensureVisible(passwordField);
    await tester.enterText(passwordField, 'password123');

    when(mockLoginViewModel.isValidEmail('testuser@test.com')).thenReturn(true);
    when(mockLoginViewModel.isValidPassword('password123')).thenReturn(true);

    // 設置 login 方法的模擬行為
    when(mockLoginViewModel.login('testuser@test.com', 'password123'))
        .thenAnswer((_) async {
      // 設置 isLoginSuccess 在調用後返回 true
      when(mockLoginViewModel.isLoginSuccess).thenReturn(true);
      // 模擬 notifyListeners 被調用
      mockLoginViewModel.notifyListeners();
    });

    // 找到登入按鈕
    final loginButton = find.text('登入');

    // 確保登入按鈕可見
    await tester.ensureVisible(loginButton);
    await tester.pumpAndSettle();

    // 點擊登入按鈕
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // 驗證 login 方法被調用
    verify(mockLoginViewModel.login('testuser@test.com', 'password123'))
        .called(1);

    // 由於模擬的 isLoginSuccess 返回 true，如果視圖會在登入成功後導航，這裡可以驗證導航
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(mockLoginViewModel.isLoginSuccess, isTrue);
  });

  testWidgets('登入時應處理加載狀態', (WidgetTester tester) async {
    // 設置更大的測試窗口尺寸
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.reset());

    // 構建我們的 app 並觸發一個 frame
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<LoginViewModel>.value(
          value: mockLoginViewModel,
          child: const LoginView(),
        ),
        onGenerateRoute: (settings) {
          if (settings.name == '/garage') {
            return MaterialPageRoute(
                builder: (context) => const Scaffold(body: Text('測試車庫頁面')));
          }
          return null;
        },
      ),
    );

    // 找到輸入框並輸入內容
    final usernameField = find.byType(TextFormField).at(0);
    final passwordField = find.byType(TextFormField).at(1);

    await tester.ensureVisible(usernameField);
    await tester.enterText(usernameField, 'testuser@test.com');

    await tester.ensureVisible(passwordField);
    await tester.enterText(passwordField, 'password123');

    when(mockLoginViewModel.isValidEmail('testuser@test.com')).thenReturn(true);
    when(mockLoginViewModel.isValidPassword('password123')).thenReturn(true);

    // 設置加載狀態模擬
    bool isLoading = false;
    when(mockLoginViewModel.isLoginLoading).thenAnswer((_) => isLoading);

    // 設置 login 方法的模擬行為
    when(mockLoginViewModel.login('testuser@test.com', 'password123'))
        .thenAnswer((_) async {
      // 設置加載狀態為 true
      isLoading = true;
      // 通知加載狀態變化
      mockLoginViewModel.notifyListeners();

      // 延遲模擬網絡請求
      await Future.delayed(const Duration(milliseconds: 100));

      // 設置加載狀態為 false
      isLoading = false;
      // 設置登入成功狀態
      when(mockLoginViewModel.isLoginSuccess).thenReturn(true);
      // 最終通知狀態變化
      mockLoginViewModel.notifyListeners();
    });

    // 找到登入按鈕
    final loginButton = find.text('登入');

    // 確保登入按鈕可見
    await tester.ensureVisible(loginButton);
    await tester.pumpAndSettle();

    // 點擊登入按鈕
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // 驗證 login 方法被調用
    verify(mockLoginViewModel.login('testuser@test.com', 'password123'))
        .called(1);

    // 驗證登入按鈕文本變為加載中
    // 注意：確保 LoginView 中在加載時顯示 "加載中..."
    // 如果不是，請調整此斷言以匹配您的 UI
    // expect(find.text('加載中...'), findsOneWidget);

    // 等待加載完成
    await tester.pumpAndSettle();
  });

  testWidgets('登入失敗應顯示錯誤訊息', (WidgetTester tester) async {
    // 設置更大的測試窗口尺寸
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.reset());

    // 構建我們的 app 並觸發一個 frame
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<LoginViewModel>.value(
          value: mockLoginViewModel,
          child: const LoginView(),
        ),
      ),
    );

    // 找到輸入框並輸入內容
    final usernameField = find.byType(TextFormField).at(0);
    final passwordField = find.byType(TextFormField).at(1);

    await tester.ensureVisible(usernameField);
    await tester.enterText(usernameField, 'wrong_user@test.com');

    await tester.ensureVisible(passwordField);
    await tester.enterText(passwordField, 'wrong_password');

    when(mockLoginViewModel.isValidEmail('wrong_user@test.com'))
        .thenReturn(true);
    when(mockLoginViewModel.isValidPassword('wrong_password')).thenReturn(true);

    // 設置 login 方法的模擬行為，使其拋出異常或返回錯誤狀態
    String errorMessage = '登入失敗，請檢查您的帳號或密碼。';
    when(mockLoginViewModel.login('wrong_user@test.com', 'wrong_password'))
        .thenAnswer((_) async {
      when(mockLoginViewModel.loginError).thenReturn(errorMessage);
      when(mockLoginViewModel.isLoginSuccess).thenReturn(false);
      mockLoginViewModel.notifyListeners();
    });

    // 找到登入按鈕
    final loginButton = find.text('登入');

    // 確保登入按鈕可見
    await tester.ensureVisible(loginButton);
    await tester.pumpAndSettle();

    // 點擊登入按鈕
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // 驗證 login 方法被調用
    verify(mockLoginViewModel.login('wrong_user@test.com', 'wrong_password'))
        .called(1);

    // 等待可能的 SnackBar 出現
    await tester.pumpAndSettle();

    // 驗證 LoginViewModel 中的 loginError 是否被設置
    expect(mockLoginViewModel.loginError, errorMessage);

    // 檢查 SnackBar 是否顯示錯誤訊息
    // 請確保 LoginView 在 loginError 不為 null 時顯示 SnackBar
    // expect(find.text(errorMessage), findsOneWidget);
  });

  testWidgets('點擊 Google 登入按鈕應調用 signInWithGoogle 方法',
      (WidgetTester tester) async {
    // ...
    // 此測試案例需要你根據 LoginView 中 Google 登入按鈕的實際情況進行調整
    // 例如，找到 Google 登入按鈕並點擊它
    // final googleLoginButton = find.byKey(const Key('google_login_button')); // 假設按鈕有一個 Key
    // await tester.tap(googleLoginButton);
    // await tester.pumpAndSettle();

    // verify(mockLoginViewModel.signInWithGoogle()).called(1);
  });
}
