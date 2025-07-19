import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'firebase_options.dart';
import 'features/auth/viewmodels/login_viewmodel.dart';
import 'features/auth/viewmodels/register_viewmodel.dart';
import 'features/auth/viewmodels/reset_password_viewmodel.dart';
import 'features/auth/views/login_view.dart';
import 'features/auth/views/register_view.dart';
import 'features/auth/views/reset_password_view.dart';
import 'package:volticar_app/features/home/views/garage_view.dart'; // Import GarageView
import 'package:volticar_app/features/home/views/charging_view.dart'; // Import ChargingView
import 'package:volticar_app/features/home/views/my_car_view.dart'; // Import MyCarView
import 'features/game/viewmodels/game_viewmodel.dart';
import 'features/game/views/game_view.dart';
import 'features/game/views/setup_view.dart';
import 'features/home/services/station_service.dart'; // Import StationService
import 'features/home/viewmodels/map_provider.dart'; // Import MapProvider

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
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => ResetPasswordViewModel()),
        ChangeNotifierProvider(create: (_) => GameViewModel()), // Added from feature/game
        Provider(create: (_) => StationService()), // Provide StationService
        ChangeNotifierProvider(create: (_) => MapProvider()), // Provide MapProvider
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
        onGenerateRoute: (RouteSettings settings) {
          debugPrint('Generating route: ${settings.name}'); // 方便調試

          WidgetBuilder builder; // 用於構建頁面的 Widget

          switch (settings.name) {
            case '/login':
              return PageRouteBuilder(
                settings: settings, // 傳遞路由設定
                pageBuilder: (context, animation, secondaryAnimation) => const LoginView(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    //transitionType: SharedAxisTransitionType.scaled,
                    //fillColor: Colors.transparent,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              );

            case '/register': // 自訂 /register 的過場動畫
              return PageRouteBuilder(
                settings: settings, // 傳遞路由設定
                pageBuilder: (context, animation, secondaryAnimation) => const RegisterView(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    //transitionType: SharedAxisTransitionType.scaled,
                    //fillColor: Colors.transparent,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              );

            case '/reset-password':
              return PageRouteBuilder(
                settings: settings, // 傳遞路由設定
                pageBuilder: (context, animation, secondaryAnimation) => const ResetPasswordView(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    //transitionType: SharedAxisTransitionType.scaled,
                    //fillColor: Colors.transparent,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              );
            case '/home':
              builder = (BuildContext _) => const GarageView();
              return MaterialPageRoute(builder: builder, settings: settings);
            case '/garage':
              builder = (BuildContext _) => const GarageView();
              return MaterialPageRoute(builder: builder, settings: settings);
            case '/charging':
              builder = (BuildContext _) => const ChargingView();
              return MaterialPageRoute(builder: builder, settings: settings);
            case '/mycar':
              builder = (BuildContext _) => const MyCarView();
              return MaterialPageRoute(builder: builder, settings: settings);
            case '/setup':
              builder = (BuildContext _) => const SetupView();
              return MaterialPageRoute(builder: builder, settings: settings);
            case '/game':
              builder = (BuildContext _) => const GameView();
              return MaterialPageRoute(builder: builder, settings: settings);

            default:
              // 處理未知路由
              builder = (BuildContext _) => Scaffold(
                    body: Center(
                      child: Text('Error: Route not found: ${settings.name}'),
                    ),
                  );
              return MaterialPageRoute(builder: builder, settings: settings);
          }
        },
      ),
    );
  }
}
