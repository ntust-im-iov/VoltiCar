import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/observer.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> implements EventObserver {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  late AuthViewModel _authViewModel;

  @override
  void initState() {
    super.initState();
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
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      _authViewModel.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).pushReplacementNamed('/register');
  }

  void _navigateToResetPassword() {
    Navigator.of(context).pushReplacementNamed('/reset-password');
  }

  void _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authViewModel.signInWithGoogle();

      if (mounted) {
        if (user != null) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '登入失敗: ${e.toString()}';
      });
    }
  }

  @override
  void notify(ViewEvent event) {
    if (event is LoginStateEvent) {
      setState(() {
        _isLoading = event.isLoading;
        _errorMessage = event.error;
      });

      if (event.isSuccess && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('登入成功')),
        );
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
                  // Logo and Title
                  SizedBox(
                    height: 250, // 設置合適的高度
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Logo在上方
                        Positioned(
                          top: 50,
                          bottom: 80,
                          child: Image.asset(
                            'assets/images/volticar_logo.png',
                            height: 300,
                            fit: BoxFit.contain,
                          ),
                        ),
                        // Title在底部
                        Positioned(
                          bottom: 0,
                          child: Image.asset(
                            'assets/images/volticar_title.png',
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 用戶名輸入框
                  CustomTextField(
                    controller: _usernameController,
                    hintText: '電子郵件',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請輸入電子郵件';
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

                  if (_errorMessage?.contains('驗證') ?? false) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '電子郵件未驗證',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '提示：請檢查您的電子郵件信箱，點擊驗證連結後即可登入',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                    onPressed: _handleGoogleSignIn,
                    icon: Image.asset('assets/images/google_icon.png',
                        width: 24, height: 24),
                    label: const Text('Google 登入'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
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
