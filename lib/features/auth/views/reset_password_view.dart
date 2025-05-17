import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volticar_app/core/constants/app_colors.dart';
import 'package:volticar_app/features/auth/viewmodels/reset_password_viewmodel.dart';
import 'package:volticar_app/shared/widgets/custom_button.dart';
import 'package:volticar_app/shared/widgets/custom_text_field.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // 步驟控制
  int _currentStep = 0; // 0: 輸入電子郵件, 1: 輸入OTP, 2: 設置新密碼

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (_emailController.text.isEmpty) {
      return;
    }

    final resetPasswordViewModel =
        Provider.of<ResetPasswordViewModel>(context, listen: false);
    resetPasswordViewModel
        .forgotPassword(_emailController.text.trim())
        .then((success) {
      if (success) {
        setState(() {
          _currentStep = 1;
        });

        // 顯示發送成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('驗證碼已發送至您的電子郵件')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('發送驗證碼失敗，請稍後再試')),
        );
      }
    });
  }

  void _verifyOtp() {
    if (_otpController.text.isEmpty) {
      return;
    }

    final resetPasswordViewModel =
        Provider.of<ResetPasswordViewModel>(context, listen: false);
    resetPasswordViewModel
        .verifyResetOtp(_otpController.text.trim())
        .then((success) {
      if (success) {
        setState(() {
          _currentStep = 2;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('驗證碼驗證成功，請設置新密碼')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('驗證碼無效，請重新輸入')),
        );
      }
    });
  }

  void _resetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      final resetPasswordViewModel =
          Provider.of<ResetPasswordViewModel>(context, listen: false);
      resetPasswordViewModel.resetPassword(_passwordController.text.trim());
    }
  }

  Widget _buildEmailStep() {
    return Column(
      children: [
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
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 24),
        Consumer<ResetPasswordViewModel>(
            builder: (context, resetPasswordViewModel, _) {
          return CustomButton(
            text: '發送驗證碼',
            onPressed: _sendOtp,
            isLoading: resetPasswordViewModel.isResetPasswordLoading,
            width: double.infinity,
          );
        }),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      children: [
        CustomTextField(
          controller: _otpController,
          hintText: '驗證碼',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '請輸入驗證碼';
            }
            return null;
          },
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 24),
        Consumer<ResetPasswordViewModel>(
            builder: (context, resetPasswordViewModel, _) {
          return Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: '重新發送',
                  onPressed: _sendOtp,
                  backgroundColor: Colors.white,
                  textColor: AppColors.secondaryColor,
                  width: double.infinity,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: '驗證',
                  onPressed: _verifyOtp,
                  isLoading: resetPasswordViewModel.isResetPasswordLoading,
                  width: double.infinity,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildResetPasswordStep() {
    return Column(
      children: [
        CustomTextField(
          controller: _passwordController,
          hintText: '新密碼',
          obscureText: _obscurePassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '請輸入新密碼';
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
        CustomTextField(
          controller: _confirmPasswordController,
          hintText: '確認新密碼',
          obscureText: _obscureConfirmPassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '請確認新密碼';
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
          onSubmitted: (_) => _resetPassword(),
        ),
        const SizedBox(height: 24),
        Consumer<ResetPasswordViewModel>(
            builder: (context, resetPasswordViewModel, _) {
          return CustomButton(
            text: '重設密碼',
            onPressed: _resetPassword,
            isLoading: resetPasswordViewModel.isResetPasswordLoading,
            width: double.infinity,
          );
        }),
      ],
    );
  }

  Widget _getStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildEmailStep();
      case 1:
        return _buildOtpStep();
      case 2:
        return _buildResetPasswordStep();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ResetPasswordViewModel>(
        builder: (context, resetPasswordViewModel, _) {
      // 重設密碼成功時導航到登入頁面
      if (resetPasswordViewModel.isResetPasswordSuccess && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('密碼重設成功，請使用新密碼登入')),
          );
          // 重置狀態後導航
          resetPasswordViewModel.markResetPasswordSuccessAsHandled();
          Navigator.of(context).pushReplacementNamed('/login');
        });
      }

      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
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
                    onPressed: () {
                      // 返回時重置狀態
                      resetPasswordViewModel.resetPasswordState();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
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
                          // Logo
                          SizedBox(
                            height: 180,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Logo在上方
                                Positioned(
                                  top: 0,
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

                          // 標題
                          const Text(
                            '重設密碼',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 步驟進度顯示
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStepIndicator(0),
                              _buildStepLine(0),
                              _buildStepIndicator(1),
                              _buildStepLine(1),
                              _buildStepIndicator(2),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // 錯誤信息
                          if (resetPasswordViewModel.resetPasswordError !=
                              null) ...[
                            Text(
                              resetPasswordViewModel.resetPasswordError!,
                              style:
                                  const TextStyle(color: AppColors.errorColor),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // 當前步驟內容
                          _getStepContent(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStepIndicator(int step) {
    final isActive = _currentStep >= step;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.primaryColor : Colors.grey,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '${step + 1}',
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine(int step) {
    final isActive = _currentStep > step;

    return Container(
      width: 40,
      height: 2,
      color: isActive ? AppColors.primaryColor : Colors.grey,
    );
  }
}
