import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'components/simple_scrolling_background.dart';
import 'components/car_component.dart';
import 'components/effects_components.dart';
import 'components/event_block.dart';
import 'components/event_manager.dart';

class VoltiCarGame extends FlameGame with HasCollisionDetection {
  late SimpleScrollingBackground background;
  late CarComponent car;
  late RoadMarkings roadMarkings;
  late EventManager eventManager;

  // 遊戲狀態
  GameState gameState = GameState.playing;

  // 事件觸發回調（供 MainGameView 使用）
  Function()? onEventTriggered;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 層次順序很重要－從後往前加入

    // 1. 加入滾動背景
    background = SimpleScrollingBackground();
    add(background);

    // 2. 加入道路標線
    roadMarkings = RoadMarkings();
    add(roadMarkings);

    // 3. 加入汽車元件（最前景）
    car = CarComponent();
    add(car);

    // 4. 加入事件管理器
    eventManager = EventManager(onEventTriggered: _handleEventTriggered);
    add(eventManager);
  }

  /// 處理事件觸發
  void _handleEventTriggered() {
    pauseGame();
    onEventTriggered?.call();
  }

  /// 暫停遊戲
  void pauseGame() {
    gameState = GameState.paused;
    eventManager.pause();
  }

  /// 繼續遊戲
  void resumeGame() {
    gameState = GameState.playing;
    eventManager.resume();
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  Color backgroundColor() => const Color(0xFF87CEEB); // 以天空藍作為預設背景
}
