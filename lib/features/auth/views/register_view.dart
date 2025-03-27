import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/observer.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> implements EventObserver {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  PhoneNumber? _phoneNumber;
  late AuthViewModel _authViewModel;

  @override
  void initState() {
    super.initState();
    _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    _authViewModel.subscribe(this);
    // 設置默認國家為台灣
    _phoneNumber = PhoneNumber(isoCode: 'TW');
  }

  @override
  void dispose() {
    _accountController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _authViewModel.unsubscribe(this);
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState == null) {
      setState(() {
        _errorMessage = '系統錯誤：表單狀態無效';
      });
      return;
    }

    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      _authViewModel
          .register(
        username: _accountController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneNumber?.phoneNumber ?? '',
      )
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      }).catchError((error) {
        setState(() {
          _errorMessage = '註冊失敗：$error';
          _isLoading = false;
        });
      });
    } else {
      setState(() {
        _errorMessage = '請檢查所有必填欄位';
      });
    }
  }

  void _navigateToLogin() {
    Navigator.of(context)
        .pushReplacementNamed('/login')
        .then((_) {})
        .catchError((error) {});
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
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context)
              .pushReplacementNamed('/login')
              .then((_) {})
              .catchError((error) {});
        });
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

                  // 標題
                  // const Text(
                  //   '註冊',
                  //   style: TextStyle(
                  //     fontSize: 24,
                  //     fontWeight: FontWeight.bold,
                  //     color: AppColors.primaryColor,
                  //   ),
                  // ),
                  // const SizedBox(height: 32),

                  // 帳號輸入框
                  CustomTextField(
                    controller: _accountController,
                    hintText: '帳號',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請輸入帳號';
                      }
                      return null;
                    },
                    suffixIcon: const Icon(Icons.person_outline),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // 電話輸入框
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InternationalPhoneNumberInput(
                      onInputChanged: (PhoneNumber number) {
                        setState(() {
                          _phoneNumber = number;
                        });
                      },
                      onInputValidated: (bool value) {
                        // 不需要任何操作
                      },
                      selectorConfig: const SelectorConfig(
                        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                        setSelectorButtonAsPrefixIcon: true,
                        leadingPadding: 16,
                        showFlags: true,
                      ),
                      ignoreBlank: false,
                      autoValidateMode: AutovalidateMode.disabled,
                      initialValue: _phoneNumber,
                      textFieldController: _phoneController,
                      formatInput: true,
                      keyboardType: TextInputType.phone,
                      inputDecoration: const InputDecoration(
                        hintText: '電話號碼',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '請輸入電話號碼';
                        }
                        return null;
                      },
                    ),
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
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
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
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(color: AppColors.textSecondary),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          '或',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
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
                    icon: Image.asset('assets/images/google_icon.png',
                        width: 24, height: 24),
                    label: const Text('Google 註冊'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
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
