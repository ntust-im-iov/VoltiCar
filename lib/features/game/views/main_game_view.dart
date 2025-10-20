import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import '../game/volti_car_game.dart';

class MainGameView extends StatefulWidget {
  const MainGameView({super.key});

  @override
  State<MainGameView> createState() => _MainGameViewState();
}

class _MainGameViewState extends State<MainGameView> {
  late final VoltiCarGame game;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    game = VoltiCarGame();
  }

  @override
  void dispose() {
    // 恢复到横向，因为 SetupView 也是横向的
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),
          // 添加返回按钮
          Positioned(
            top: 10,
            left: 1,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
                iconSize: 30,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          // 添加游戏信息显示
          Positioned(
            top: 40,
            right: 20,
            child: SafeArea(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Gaming...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
