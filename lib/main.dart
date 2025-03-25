import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/auth/views/login_view.dart';
import 'features/auth/views/register_view.dart';
import 'features/auth/views/reset_password_view.dart';
import 'features/home/views/home_view.dart';

void main() async {
  // 確保Flutter綁定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 創建logger實例
  final logger = Logger();
  
  // 初始化Firebase (有條件地初始化)
  try {
    if (Platform.isAndroid || Platform.isIOS) {
      await Firebase.initializeApp();
      logger.i('Firebase initialized successfully');
    } else {
      logger.w('Firebase initialization skipped on this platform');
    }
  } catch (e) {
    logger.e('Failed to initialize Firebase: $e');
    // Continue without Firebase for development purposes
  }
  
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}
