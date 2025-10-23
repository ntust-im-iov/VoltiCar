import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import '../game/volti_car_game.dart';
import 'dart:math' as math;

class MainGameView extends StatefulWidget {
  const MainGameView({super.key});

  @override
  State<MainGameView> createState() => _MainGameViewState();
}

class _MainGameViewState extends State<MainGameView> {
  late final VoltiCarGame game;
  final math.Random _random = math.Random();

  // 隨機事件文字列表
  final List<String> _eventTexts = [
    '你遇到了一個障礙物！需要繞過它。',
    '前方有一個加油站，要停下來加油嗎？',
    '遇到了紅綠燈，需要等待通過。',
    '路上有一隻小動物，請小心駕駛！',
    '前方道路施工，請減速慢行。',
    '天氣突然變差，能見度降低。',
    '你發現了一個捷徑，要嘗試嗎？',
    '車輛需要維修保養了。',
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    game = VoltiCarGame();
    // 設定事件觸發回調
    game.onEventTriggered = _showEventDialog;
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

  /// 顯示事件對話框
  void _showEventDialog() {
    // 隨機選擇一個事件文字
    final String eventText = _eventTexts[_random.nextInt(_eventTexts.length)];

    showDialog(
      context: context,
      barrierDismissible: false, // 不允許點擊外部關閉
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '隨機事件',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            eventText,
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 繼續遊戲
                game.resumeGame();
              },
              child: const Text(
                '繼續',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
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
          // 添加遊戲信息顯示
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
