import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volticar_app/core/constants/app_colors.dart';
import 'package:volticar_app/core/utils/observer.dart';
import 'package:volticar_app/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:volticar_app/shared/widgets/custom_button.dart';
import 'package:volticar_app/shared/widgets/custom_text_field.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView>
    implements EventObserver {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  late AuthViewModel _authViewModel;

  // 步驟控制
  int _currentStep = 0; // 0: 輸入電子郵件, 1: 輸入OTP, 2: 設置新密碼

  @override
  void initState() {
    super.initState();
    _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    _authViewModel.subscribe(this);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _authViewModel.unsubscribe(this);
    super.dispose();
  }

  void _sendOtp() {
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = '請輸入電子郵件';
      });
      return;
    }

    // 這裡模擬發送OTP的過程
    setState(() {
      _currentStep = 1;
      _errorMessage = null;
    });

    // 顯示發送成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('驗證碼已發送至您的電子郵件')),
    );
  }

  void _verifyOtp() {
    if (_otpController.text.isEmpty) {
      setState(() {
        _errorMessage = '請輸入驗證碼';
      });
      return;
    }

    // 這裡模擬驗證OTP的過程
    setState(() {
      _currentStep = 2;
      _errorMessage = null;
    });
  }

  void _resetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      _authViewModel.resetPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  void notify(ViewEvent event) {
    if (event is ResetPasswordStateEvent) {
      setState(() {
        _isLoading = event.isLoading;
        _errorMessage = event.error;
      });

      if (event.isSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('密碼重設成功，請使用新密碼登入')),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      }
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
        CustomButton(
          text: '發送驗證碼',
          onPressed: _sendOtp,
          isLoading: _isLoading,
          width: double.infinity,
        ),
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
        Row(
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
                isLoading: _isLoading,
                width: double.infinity,
              ),
            ),
          ],
        ),
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
        CustomButton(
          text: '重設密碼',
          onPressed: _resetPassword,
          isLoading: _isLoading,
          width: double.infinity,
        ),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
        ),
        title: const Text(
          '重設密碼',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
                  Image.asset('assets/images/volticar_title.png',
                      height: 80, fit: BoxFit.contain),
                  const SizedBox(height: 24),

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
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.errorColor),
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
      ),
    );
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
