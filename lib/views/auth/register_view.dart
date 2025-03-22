import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/observer.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'login_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> implements EventObserver {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authViewModel = AuthViewModel();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _authViewModel.subscribe(this);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _authViewModel.unsubscribe(this);
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      _authViewModel.register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void notify(ViewEvent event) {
    if (event is RegisterStateEvent) {
      setState(() {
        _isLoading = event.isLoading;
        _errorMessage = event.error;
      });

      if (event.isSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('註冊成功，請登入')),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
        ),
      ),
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
                    fit: BoxFit.contain
                  ),
                  const SizedBox(height: 24),

                  // 標題
                  const Text(
                    '註冊',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
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
                  
                  // 電子郵件輸入框
                  CustomTextField(
                    controller: _emailController,
                    hintText: '電子郵件',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請輸入電子郵件';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return '請輸入有效的電子郵件地址';
                      }
                      return null;
                    },
                    suffixIcon: const Icon(Icons.email_outlined),
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
                      if (value.length < 6) {
                        return '密碼長度不能少於6個字符';
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
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  
                  // 確認密碼輸入框
                  CustomTextField(
                    controller: _confirmPasswordController,
                    hintText: '確認密碼',
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請確認密碼';
                      }
                      if (value != _passwordController.text) {
                        return '兩次輸入的密碼不一致';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword 
                            ? Icons.visibility_off_outlined 
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _register(),
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
                  
                  // 註冊按鈕
                  CustomButton(
                    text: '註冊',
                    onPressed: _register,
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
                  
                  // Google註冊按鈕
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Google 註冊
                    },
                    icon: Image.asset(
                      'assets/images/volticar_logo.png', 
                      width: 24, 
                      height: 24
                    ),
                    label: const Text('Google 註冊'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // 登入鏈接
                  RichText(
                    text: TextSpan(
                      text: '已經有帳號? ',
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: '登入',
                          style: const TextStyle(
                            color: AppColors.linkColor,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = _navigateToLogin,
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