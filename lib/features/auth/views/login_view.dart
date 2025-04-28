import 'package:flutter/material.dart'; // Flutter UI 庫
import 'package:flutter/gestures.dart'; // 手勢處理
import 'package:provider/provider.dart'; // Provider 狀態管理
import 'package:volticar_app/core/constants/app_colors.dart'; // 自定義顏色常量
import 'package:volticar_app/core/utils/observer.dart'; // 觀察者模式工具
import 'package:volticar_app/features/auth/viewmodels/auth_viewmodel.dart'; // 身分驗證 viewmodel
import 'package:volticar_app/shared/widgets/custom_button.dart'; // 自定義按鈕
import 'package:volticar_app/shared/widgets/custom_text_field.dart'; // 自定義文本輸入框

class LoginView extends StatefulWidget { // 繼承 StatefulWidget (LoginView是個有狀態的元件)
  const LoginView({super.key}); // 構造函數，super.key 用於傳遞父類別的 key

  @override
  State<LoginView> createState() => _LoginViewState(); // 返回 _LoginViewState 實例(下劃線前綴表示 _LoginViewState 是一個'私有類'，只在當前檔案內可見)
}

class _LoginViewState extends State<LoginView> implements EventObserver { // 繼承 State<LoginView>(負責管理 LoginView 的狀態) 並實現 EventObserver(接收和處理事件通知)
  final _formKey = GlobalKey<FormState>(); // 管理表單的狀態
  final _usernameController = TextEditingController(); // 管理用戶名輸入框的狀態
  final _passwordController = TextEditingController(); // 管理密碼輸入框的狀態
  late AuthViewModel _authViewModel; // 改為 late 變量，從 Provider 獲取
  bool _isLoading = false; // 跟蹤是否處於載入狀態
  bool _obscurePassword = true; // 控制密碼是否可見
  String? _errorMessage; // 儲存錯誤訊息(可為 null)

  @override // 覆寫 父類別 initState 方法
  void initState() { // 初始化狀態
    super.initState(); // 調用父類別的 initState 方法
    _authViewModel = Provider.of<AuthViewModel>(context, listen: false); // 從 Provider 獲取 AuthViewModel
    _authViewModel.subscribe(this); // 訂閱 AuthViewModel(每次狀態更新 AuthViewModel 會通知所有訂閱者)
    _checkLoginStatus(); // 檢查用戶是否已登入
  }

  @override
  void dispose() { // 資源釋放
    _usernameController.dispose(); // 釋放用戶名輸入框的資源
    _passwordController.dispose(); // 釋放密碼輸入框的資源
    _authViewModel.unsubscribe(this); // 取消訂閱 AuthViewModel
    super.dispose(); // 調用父類別的 dispose 方法
  }

  void _checkLoginStatus() async { // 檢查用戶是否已登入(async 異步處理)
    final isLoggedIn = await _authViewModel.checkLoginStatus(); // await 暫停執行，直到 checkLoginStatus 完成
    if (isLoggedIn && mounted) { // 用戶已登入且當前視圖仍然存在
      Navigator.of(context).pushReplacementNamed('/garage'); // 條件成立 立即導航到 garage 頁面
    }
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      if(!_isInTest()){
        Navigator.of(context).pushReplacementNamed('/garage'); //測試用
      }
    }
    // if (_formKey.currentState?.validate() ?? false) {
    //   _authViewModel.login(
    //     _usernameController.text.trim(),
    //     _passwordController.text.trim(),
    //   );
    // }
  }

  // 檢查是否在測試環境中
  bool _isInTest() {
    return const bool.fromEnvironment('FLUTTER_TEST', defaultValue: false);
  }

  void _navigateToRegister() {
    Navigator.of(context).pushReplacementNamed('/register');
  }

  void _navigateToResetPassword() {
    Navigator.of(context).pushReplacementNamed('/reset-password');
  }

  @override
  void notify(ViewEvent event) { // 接收 ViewEvent 事件
    if (event is LoginStateEvent) { // 如果 event 是 LoginStateEvent 類型
      setState(() { // 更新狀態
        _isLoading = event.isLoading; // 更新 _isLoading 狀態
        _errorMessage = event.error;
      });

      if (event.isSuccess && mounted) { // 登入成功且畫面存在
        Navigator.of(context).pushReplacementNamed('/garage'); // 導航到 garage 頁面
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('登入成功'))); // 顯示登入成功訊息
      }
    }
  }

  @override
  Widget build(BuildContext context) { // 構建 UI
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea( // SafeArea 是 Flutter 提供的一個 widget，用於防止 UI 元素超出安全區域
        child: Center( 
          child: SingleChildScrollView( // SingleChildScrollView 是 Flutter 提供的一個 widget，用於處理滾動事件
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey, // 管理表單驗證
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/volticar_title.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 40),

                  // 用戶名輸入框
                  CustomTextField(
                    controller: _usernameController, // 管理用戶名輸入框的狀態
                    hintText: '用戶名', // 提示文字
                    validator: (value) { // 驗證器
                      if (value == null || value.isEmpty) { // 如果 value 為 null 或空字串
                        return '請輸入用戶名';
                      }
                      return null;
                    },
                    suffixIcon: const Icon(Icons.person_outline),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // 密碼輸入框
                  CustomTextField(
                    controller: _passwordController, // 管理密碼輸入框的狀態
                    hintText: '密碼', // 提示文字
                    obscureText: _obscurePassword, // 控制密碼是否可見
                    validator: (value) { // 驗證器
                      if (value == null || value.isEmpty) {
                        return '請輸入密碼';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _login(), // 當用戶按下 Enter 鍵時，調用 _login 方法
                  ),
                  const SizedBox(height: 8),

                  // 忘記密碼
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _navigateToResetPassword,
                      child: Text(
                        '忘記密碼?',
                        style: TextStyle(
                          color: AppColors.linkColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 錯誤信息
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.errorColor),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 登入按鈕
                  CustomButton(
                    text: '登入', // 按鈕文字
                    onPressed: _login, // 按鈕點擊事件
                    isLoading: _isLoading, // 是否處於載入狀態
                    width: double.infinity, // 寬度
                  ),
                  const SizedBox(height: 24),

                  // 分隔線
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: AppColors.textSecondary),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          '或',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Google登入按鈕
                  OutlinedButton.icon(
                    onPressed: () {
                      _authViewModel
                          .signInWithGoogle(); // 呼叫 ViewModel 中的 Google 登入方法
                    },
                    icon: Image.asset(
                      'assets/images/google_icon.png', // 使用 Google 圖示
                      width: 24,
                      height: 24,
                    ),
                    label: const Text('Google 登入'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 註冊鏈接
                  RichText(
                    text: TextSpan(
                      text: '還沒有帳號? ',
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: '註冊',
                          style: const TextStyle(
                            color: AppColors.linkColor,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = _navigateToRegister,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
