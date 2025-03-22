import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart';
import 'views/auth/reset_password_view.dart';
import 'views/home/home_view.dart';

void main() {
  // 確保Flutter綁定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 固定螢幕方向為垂直方向
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoltiCar App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E3364),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/reset-password': (context) => const ResetPasswordView(),
        '/home': (context) => const HomeView(),
      },
    );
  }
}
