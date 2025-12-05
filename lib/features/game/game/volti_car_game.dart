import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'components/scrolling_background.dart';
import 'components/car_component.dart';
import 'components/effects_components.dart';
import 'components/event_block.dart';
import 'components/event_manager.dart';
import '../models/game_event.dart';
import '../managers/score_manager.dart';
import '../managers/game_storage_manager.dart';

class VoltiCarGame extends FlameGame with HasCollisionDetection {
  late ScrollingBackground background;
  late CarComponent car;
  late RoadMarkings roadMarkings;
  late EventManager eventManager;

  // 計分管理器
  final ScoreManager scoreManager = ScoreManager();

  // 本地存儲管理器
  final GameStorageManager storageManager = GameStorageManager();

  // 遊戲狀態
  GameState gameState = GameState.playing;

  // 事件觸發回調（供 MainGameView 使用）
  Function(GameEvent)? onEventTriggered;

  // 遊戲結束回調（異步，確保 UI 處理完成）
  Future<void> Function()? onGameEnd;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 層次順序很重要－從後往前加入

    // 1. 加入滾動背景
    background = ScrollingBackground();
    add(background);

    // 2. 加入汽車元件（最前景）
    car = CarComponent();
    add(car);

    // 3. 加入事件管理器
    eventManager = EventManager(
      onEventTriggered: _handleEventTriggered,
      onAllEventsCompleted: _handleAllEventsCompleted,
    );
    add(eventManager);
  }

  /// 處理事件觸發
  void _handleEventTriggered(GameEvent event) {
    pauseGame();
    onEventTriggered?.call(event);
  }

  /// 處理所有事件完成（所有題目都已回答）
  Future<void> _handleAllEventsCompleted() async {
    // 自動結束遊戲 - 等待保存完成
    await endGame();
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

  /// 結束遊戲並保存數據
  Future<void> endGame() async {
    gameState = GameState.paused;
    eventManager.pause();

    // 保存遊戲結果
    final summary = scoreManager.getGameSummary();
    await storageManager.saveGameResult(
      score: summary['score'] as int,
      eventsAnswered: summary['totalEvents'] as int,
      correctAnswers: summary['correctAnswers'] as int,
      bestCombo: summary['bestCombo'] as int,
      playTime: summary['gameTime'] as double,
    );

    // 觸發遊戲結束回調（異步）
    await onGameEnd?.call();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 更新遊戲時間和分數（只在遊戲進行中）
    if (gameState == GameState.playing) {
      scoreManager.updateGameTime(dt);
    }
  }

  @override
  Color backgroundColor() => const Color(0xFF87CEEB); // 以天空藍作為預設背景
}
