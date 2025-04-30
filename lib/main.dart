import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'firebase_options.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/auth/views/login_view.dart';
import 'features/auth/views/register_view.dart';
import 'features/auth/views/reset_password_view.dart';
import 'package:volticar_app/features/home/views/garage_view.dart'; // Import GarageView
import 'package:volticar_app/features/home/views/charging_view.dart'; // Import ChargingView
import 'package:volticar_app/features/home/views/my_car_view.dart'; // Import MyCarView

void main() async {
  // 確保Flutter綁定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 設置為軟體渲染模式
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.top,
    SystemUiOverlay.bottom,
  ]);

  // 創建logger實例
  final logger = Logger();

  // 初始化Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.i('Firebase initialized successfully');
  } catch (e) {
    logger.e('Failed to initialize Firebase: $e');
    rethrow; // 在開發階段，我們需要知道 Firebase 初始化失敗的原因
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
        // Use Provider instead of ChangeNotifierProvider since AuthViewModel no longer extends ChangeNotifier
        Provider(create: (_) => AuthViewModel()),
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
          '/home': (context) => const GarageView(), // Point /home to GarageView
          '/garage': (context) => const GarageView(), // Keep /garage route pointing to GarageView
          '/charging': (context) => const ChargingView(), // Add charging route
          '/mycar': (context) => const MyCarView(), // Add mycar route
        },
      ),
    );
  }
}
