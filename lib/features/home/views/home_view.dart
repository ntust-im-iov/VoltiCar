import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';

import '../../../core/constants/app_colors.dart';
import '../../../features/auth/viewmodels/auth_viewmodel.dart';

//主頁定義
class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

//主頁狀態定義
class _HomeViewState extends State<HomeView> {
  final AuthViewModel _authViewModel = AuthViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VoltiCar',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textPrimary),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: GameWidget(game: VoltiCarGame()),
    );
  }

  Future<void> _handleLogout() async {
    await _authViewModel.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}

class VoltiCarGame extends FlameGame {
  MapPopup? _currentMapPopup;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Button size
    final buttonSize = Vector2(150, 50);

    // Button positions (grid layout)
    final buttonPositions = [
      Vector2(size.x / 4 - buttonSize.x / 2, size.y / 3 - buttonSize.y / 2),
      Vector2(size.x * 3 / 4 - buttonSize.x / 2, size.y / 3 - buttonSize.y / 2),
      Vector2(size.x / 4 - buttonSize.x / 2, size.y * 2 / 3 - buttonSize.y / 2),
      Vector2(
          size.x * 3 / 4 - buttonSize.x / 2, size.y * 2 / 3 - buttonSize.y / 2),
    ];

    // Button texts
    final buttonTexts = ['地圖', '資訊頁面', '遊戲配置', '系統設定', '遊戲入口'];

    for (int i = 0; i < buttonTexts.length; i++) {
      final button = ButtonComponent(
        buttonSize: buttonSize,
        buttonPosition: i < 4
            ? buttonPositions[i]
            : Vector2(size.x / 2 - buttonSize.x / 2,
                size.y * 5 / 6 - buttonSize.y / 2),
        buttonText: buttonTexts[i],
        onPressed: () {
          if (buttonTexts[i] == '地圖') {
            // Only add a new popup if one isn't already visible
            if (_currentMapPopup == null ||
                _currentMapPopup?.isMounted == false) {
              final newPopup = MapPopup(onClose: () {
                _currentMapPopup = null; // Clear the reference when closed
              });
              _currentMapPopup = newPopup;
              add(newPopup);
            }
          }
        },
      );
      add(button);
    }
  }
}

class ButtonComponent extends PositionComponent with TapCallbacks {
  ButtonComponent({
    required this.buttonSize,
    required this.buttonPosition,
    required this.buttonText,
    this.onPressed,
  }) : super(size: buttonSize, position: buttonPosition);

  final Vector2 buttonSize;
  final Vector2 buttonPosition;
  final String buttonText;
  final VoidCallback? onPressed;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final buttonPaint = BasicPalette.white.paint();
    final textPaint =
        TextPaint(style: TextStyle(color: Colors.black, fontSize: 20));

    add(
      RectangleComponent(
        size: buttonSize,
        paint: buttonPaint,
      ),
    );

    add(
      TextComponent(
        text: buttonText,
        textRenderer: textPaint,
        anchor: Anchor.center,
        position: buttonSize / 2,
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPressed?.call();
  }
}

class MapPopup extends PositionComponent {
  final VoidCallback onClose;

  MapPopup({required this.onClose})
      : super(
          size: Vector2(350, 600),
          position: Vector2(
              22, 50), // Adjust position as needed relative to game size
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Semi-transparent background
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = Colors.white.withOpacity(0.5),
      ),
    );

    // Close button
    add(
      ButtonComponent(
        buttonSize: Vector2(30, 20),
        buttonPosition: Vector2(size.x - 30, 0),
        buttonText: 'X',
        onPressed: () {
          onClose(); // Notify the game it's closing
          removeFromParent(); // Remove the popup itself
        },
      ),
    );
  }
}

// import 'package:flame/events.dart';
// import 'package:flame/flame.dart';
// import 'package:flutter/material.dart';
// import 'package:flame/game.dart';
// import 'package:flame/components.dart';
// import 'package:flame/palette.dart';
// import 'package:flutter_map/flutter_map.dart' as fMap;
// import 'package:latlong2/latlong.dart';

// import '../../../core/constants/app_colors.dart';
// import '../../../features/auth/viewmodels/auth_viewmodel.dart';

// class HomeView extends StatefulWidget {
//   const HomeView({Key? key}) : super(key: key);

//   @override
//   _HomeViewState createState() => _HomeViewState();
// }

// class _HomeViewState extends State<HomeView> {
//   final AuthViewModel _authViewModel = AuthViewModel();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('VoltiCar',
//             style: TextStyle(
//                 color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
//         backgroundColor: AppColors.background,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout, color: AppColors.textPrimary),
//             onPressed: _handleLogout,
//           ),
//         ],
//       ),
//       body: GameWidget(game: VoltiCarGame()),
//     );
//   }

//   Future<void> _handleLogout() async {
//     await _authViewModel.logout();
//     if (mounted) {
//       Navigator.of(context).pushReplacementNamed('/login');
//     }
//   }
// }

// class VoltiCarGame extends FlameGame with HasGameRef {
//   MapPopup? _currentMapPopup;

//   @override
//   Future<void> onLoad() async {
//     super.onLoad();

//     // Button size
//     final buttonSize = Vector2(150, 50);

//     // Button positions (grid layout)
//     final buttonPositions = [
//       Vector2(size.x / 4 - buttonSize.x / 2, size.y / 3 - buttonSize.y / 2),
//       Vector2(size.x * 3 / 4 - buttonSize.x / 2, size.y / 3 - buttonSize.y / 2),
//       Vector2(size.x / 4 - buttonSize.x / 2, size.y * 2 / 3 - buttonSize.y / 2),
//       Vector2(
//           size.x * 3 / 4 - buttonSize.x / 2, size.y * 2 / 3 - buttonSize.y / 2),
//     ];

//     // Button texts
//     final buttonTexts = ['Button 1', 'Button 2', 'Button 3', 'Button 4', '地圖'];

//     for (int i = 0; i < buttonTexts.length; i++) {
//       final button = ButtonComponent(
//         buttonSize: buttonSize,
//         buttonPosition: i < 4
//             ? buttonPositions[i]
//             : Vector2(size.x / 2 - buttonSize.x / 2,
//                 size.y * 5 / 6 - buttonSize.y / 2),
//         buttonText: buttonTexts[i],
//         onPressed: () {
//           if (buttonTexts[i] == '地圖') {
//             // Only add a new popup if one isn't already visible
//             if (_currentMapPopup == null ||
//                 _currentMapPopup?.isMounted == false) {
//               final newPopup = MapPopup(
//                 size: Vector2(size.x * 0.9, size.y * 0.7),
//                 position: Vector2(size.x * 0.05, size.y * 0.15),
//                 onClose: () {
//                   _currentMapPopup = null; // Clear the reference when closed
//                 },
//               );
//               _currentMapPopup = newPopup;
//               add(newPopup);
//             }
//           }
//         },
//       );
//       add(button);
//     }
//   }
// }

// class ButtonComponent extends PositionComponent with TapCallbacks {
//   ButtonComponent({
//     required this.buttonSize,
//     required this.buttonPosition,
//     required this.buttonText,
//     this.onPressed,
//   }) : super(size: buttonSize, position: buttonPosition);

//   final Vector2 buttonSize;
//   final Vector2 buttonPosition;
//   final String buttonText;
//   final VoidCallback? onPressed;

//   @override
//   Future<void> onLoad() async {
//     super.onLoad();

//     final buttonPaint = BasicPalette.white.paint();
//     final textPaint =
//         TextPaint(style: TextStyle(color: Colors.black, fontSize: 20));

//     add(
//       RectangleComponent(
//         size: buttonSize,
//         paint: buttonPaint,
//       ),
//     );

//     add(
//       TextComponent(
//         text: buttonText,
//         textRenderer: textPaint,
//         anchor: Anchor.center,
//         position: buttonSize / 2,
//       ),
//     );
//   }

//   @override
//   void onTapDown(TapDownEvent event) {
//     onPressed?.call();
//   }
// }

// class MapPopup extends PositionComponent with HasGameRef, TapCallbacks {
//   final VoidCallback onClose;
//   // 預設地圖中心座標 (台北市)
//   final LatLng defaultLocation = LatLng(25.0330, 121.5654);

//   // 預設縮放級別
//   final double defaultZoom = 13.0;

//   MapPopup({
//     required Vector2 size,
//     required Vector2 position,
//     required this.onClose,
//   }) : super(size: size, position: position);

//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();

//     // 半透明背景
//     add(
//       RectangleComponent(
//         size: size,
//         paint: Paint()..color = Colors.white.withOpacity(0.9),
//       ),
//     );

//     // 標題
//     final headerPaint = TextPaint(
//       style: const TextStyle(
//         color: Colors.black,
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//       ),
//     );
//     add(
//       TextComponent(
//         text: '地圖',
//         textRenderer: headerPaint,
//         position: Vector2(size.x / 2, 20),
//         anchor: Anchor.center,
//       ),
//     );

//     // 關閉按鈕
//     add(
//       ButtonComponent(
//         buttonSize: Vector2(40, 30),
//         buttonPosition: Vector2(size.x - 50, 10),
//         buttonText: 'X',
//         onPressed: () {
//           onClose();
//           removeFromParent();
//         },
//       ),
//     );

//     // 地圖顯示按鈕 - 點擊後使用原生導航打開地圖畫面
//     add(
//       ButtonComponent(
//         buttonSize: Vector2(size.x - 40, 60),
//         buttonPosition: Vector2(20, size.y / 2 - 30),
//         buttonText: '打開地圖',
//         onPressed: () {
//           // 使用上下文導航到地圖頁面
//           gameRef.overlays.add('map_overlay');
//         },
//       ),
//     );
//   }
// }
