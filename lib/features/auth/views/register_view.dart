import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:volticar_app/core/constants/app_colors.dart';
import 'package:volticar_app/features/auth/viewmodels/register_viewmodel.dart';
import 'package:volticar_app/shared/widgets/custom_button.dart';
import 'package:volticar_app/shared/widgets/custom_text_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _accountController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState == null) {
      return;
    }

    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final registerViewModel =
          Provider.of<RegisterViewModel>(context, listen: false);
      registerViewModel.register(
        username: _accountController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _verifyEmail() {
    if (_emailController.text.isEmpty) {
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text)) {
      return;
    }

    final registerViewModel =
        Provider.of<RegisterViewModel>(context, listen: false);
    registerViewModel.sendEmailVerification(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterViewModel>(
        builder: (context, registerViewModel, _) {
      // 註冊成功時導航到登入頁面
      if (registerViewModel.isRegisterSuccess && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('註冊成功')),
          );

          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pushReplacementNamed('/login');
          });
        });
      }

      // 郵件驗證成功時顯示提示
      if (registerViewModel.isEmailVerificationSuccess && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('驗證郵件已發送，請查收')),
          );
        });
      }

      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          top: false, // 不設置頂部安全區域
          child: Stack(
            children: [
              // 返回按鈕
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed('/login'),
                ),
              ),

              // 主要內容
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo and Title
                        SizedBox(
                          height: 250,
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
                        const SizedBox(height: 70),

                        // 使用者名稱輸入框
                        CustomTextField(
                          controller: _accountController,
                          hintText: '使用者名稱',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '請輸入使用者名稱';
                            }
                            return null;
                          },
                          suffixIcon: const Icon(Icons.person_outline),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // 電子信箱輸入框
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _emailController,
                                hintText: '電子信箱',
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '請輸入電子信箱';
                                  }
                                  if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return '請輸入有效的電子信箱';
                                  }
                                  return null;
                                },
                                suffixIcon: const Icon(Icons.email_outlined),
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 90,
                              child: CustomButton(
                                text: '驗證',
                                onPressed: _verifyEmail,
                                isLoading: registerViewModel
                                    .isEmailVerificationLoading,
                                width: 90,
                              ),
                            ),
                          ],
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
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _register(),
                        ),
                        const SizedBox(height: 24),

                        // 錯誤信息 - 註冊錯誤或郵件驗證錯誤
                        if (registerViewModel.registerError != null ||
                            registerViewModel.emailVerificationError !=
                                null) ...[
                          Text(
                            registerViewModel.registerError ??
                                registerViewModel.emailVerificationError!,
                            style: const TextStyle(color: AppColors.errorColor),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // 註冊按鈕
                        CustomButton(
                          text: '註冊',
                          onPressed: _register,
                          isLoading: registerViewModel.isRegisterLoading,
                          width: double.infinity,
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
            ],
          ),
        ),
      );
    });
  }
}
