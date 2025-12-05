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
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState == null) {
      return;
    }

    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final registerViewModel = Provider.of<RegisterViewModel>(context, listen: false);
      registerViewModel.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _verifyEmail() {
    if (_emailFieldKey.currentState == null) {
      return;
    }
    final isEmailFormatValid = _emailFieldKey.currentState!.validate();

    if (isEmailFormatValid) {
      final email = _emailController.text.trim();
      final registerViewModel = Provider.of<RegisterViewModel>(context, listen: false);

      registerViewModel.sendEmailVerification(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterViewModel>(builder: (context, registerViewModel, _) {
      // 註冊成功時導航到登入頁面
      if (registerViewModel.isRegisterSuccess && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('註冊成功')),
          );

          // 在顯示 SnackBar 後重置狀態
          registerViewModel.markRegisterSuccessAsHandled();

          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/garage');
            }
          });
        });
      }

      // 郵件驗證成功時顯示提示
      if (registerViewModel.isEmailVerificationSuccess && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('驗證郵件已發送，請查收')),
          );
          // 在顯示 SnackBar 後重置狀態
          registerViewModel.markEmailVerificationSuccessAsHandled();
        });
      }

      // 包裹 GestureDetector 以實現點擊空白處收起鍵盤
      return GestureDetector(
        onTap: () {
          // 取消當前焦點
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            top: false, // 不設置頂部安全區域
            child: Stack(
              children: [
                // 主要內容 (先放置)
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
                          const SizedBox(height: 50),

                          // 使用者名稱輸入框
                          CustomTextField(
                            controller: _usernameController,
                            hintText: '使用者名稱',
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '請輸入使用者名稱';
                              }
                              if (registerViewModel.usernameFormatError != null &&
                                  _usernameController.text.isNotEmpty &&
                                  !registerViewModel.isValidUserName(value.trim())) {
                                return registerViewModel.usernameFormatError; // "使用者名稱格式不符。"
                              }
                              if (registerViewModel.usernameAvailabilityMessage != null &&
                                  _usernameController.text.isNotEmpty &&
                                  !registerViewModel.isUsernameAvailable) {
                                return registerViewModel.usernameAvailabilityMessage;
                              }
                              return null;
                            },
                            onChanged: (value) {
                              registerViewModel.checkUsernameAvailability(value.trim());
                            },
                            suffixIcon: registerViewModel.isCheckingUsername
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                  )
                                : (registerViewModel.usernameAvailabilityMessage != null &&
                                        _usernameController.text.isNotEmpty
                                    ? (registerViewModel.isUsernameAvailable
                                        ? const Icon(Icons.check_circle_outline,
                                            color: Colors.green)
                                        : const Icon(Icons.error_outline,
                                            color: AppColors.errorColor))
                                    : (registerViewModel.usernameFormatError != null &&
                                            _usernameController.text.isNotEmpty
                                        ? const Icon(Icons.warning_amber_rounded,
                                            color: AppColors.errorColor) // Icon for format error
                                        : const Icon(Icons.person_outline))),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),

                          // 電子信箱輸入框
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  fieldKey: _emailFieldKey,
                                  controller: _emailController,
                                  hintText: '電子信箱',
                                  keyboardType: TextInputType.emailAddress,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '請輸入電子信箱';
                                    }
                                    if (value.isNotEmpty &&
                                        !registerViewModel.isValidEmail(value)) {
                                      return '請輸入有效的電子信箱格式';
                                    }
                                    if (registerViewModel.emailVerificationError != null) {
                                      return registerViewModel.emailVerificationError;
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
                                  isLoading: registerViewModel.isEmailVerificationLoading,
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
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '請輸入密碼';
                              }
                              if (!registerViewModel.isValidPassword(value)) {
                                return '密碼至少8位數，包含大小寫字母和數字';
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
                            autovalidateMode: AutovalidateMode.onUserInteraction,
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

                          // 錯誤信息 - 註冊錯誤
                          if (registerViewModel.registerError != null) ...[
                            Text(
                              registerViewModel.registerError ?? '',
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
                                  recognizer: TapGestureRecognizer()..onTap = _navigateToLogin,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // 返回按鈕 (後放置，會疊加在 Center 之上)
                Positioned(
                  top: 50, // 你可以根據需要調整這個值，例如 50
                  left: 16,
                  child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.of(context).pushNamed('/login')),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
