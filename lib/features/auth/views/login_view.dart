import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart'; // Corrected path
import '../../../core/utils/observer.dart'; // Corrected path
import '../viewmodels/auth_viewmodel.dart'; // Corrected path
import '../../../shared/widgets/custom_button.dart'; // Corrected path
import '../../../shared/widgets/custom_text_field.dart'; // Corrected path

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> implements EventObserver {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late AuthViewModel _authViewModel; // 改為 late 變量，從 Provider 獲取
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 從 Provider 獲取 ViewModel
    _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    _authViewModel.subscribe(this);
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _authViewModel.unsubscribe(this);
    super.dispose();
  }

  void _checkLoginStatus() async {
    final isLoggedIn = await _authViewModel.checkLoginStatus();
    if (isLoggedIn && mounted) {
      Navigator.of(context).pushReplacementNamed('/garage');
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
  void notify(ViewEvent event) {
    if (event is LoginStateEvent) {
      setState(() {
        _isLoading = event.isLoading;
        _errorMessage = event.error;
      });

      if (event.isSuccess && mounted) {
        Navigator.of(context).pushReplacementNamed('/garage');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('登入成功')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
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
                    controller: _usernameController,
                    hintText: '用戶名',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
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
                    controller: _passwordController,
                    hintText: '密碼',
                    obscureText: _obscurePassword,
                    validator: (value) {
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
                    onSubmitted: (_) => _login(),
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
                    text: '登入',
                    onPressed: _login,
                    isLoading: _isLoading,
                    width: double.infinity,
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
