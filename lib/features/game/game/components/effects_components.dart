import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../volti_car_game.dart';
import 'event_block.dart';

/// 道路標線元件－增加道路感
class RoadMarkings extends Component with HasGameRef<VoltiCarGame> {
  final List<RectangleComponent> markings = [];
  final double markingSpeed = 150.0; // 比背景稍快，營造層次感
  final double markingWidth = 8.0;
  final double markingHeight = 40.0;
  final double markingSpacing = 80.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 建立道路標線
    final int markingCount = (game.size.x / markingSpacing).ceil() + 2;

    for (int i = 0; i < markingCount; i++) {
      final marking = RectangleComponent(
        size: Vector2(markingWidth, markingHeight),
        position: Vector2(
            i * markingSpacing, game.size.y * 0.5 - markingHeight * 0.5),
        paint: Paint()..color = const Color(0xFFFFFFFF),
      );
      markings.add(marking);
      add(marking);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 檢查遊戲狀態，如果暫停則不更新
    if (game.gameState == GameState.paused) return;

    for (final marking in markings) {
      marking.position.x -= markingSpeed * dt;

      // 重設標線位置
      if (marking.position.x <= -markingWidth) {
        marking.position.x += markingSpacing * markings.length;
      }
    }
  }
}

/// 雲朵元件－增加背景層次
class CloudComponent extends SpriteComponent with HasGameRef {
  final double speed;
  final double initialX;

  CloudComponent({
    required this.speed,
    required this.initialX,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 若有雲朵圖片可載入，否則使用簡單的白色矩形
    paint = Paint()..color = const Color(0x88FFFFFF);
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.x -= speed * dt;

    // 重設雲朵位置
    if (position.x <= -size.x) {
      position.x = game.size.x + size.x;
    }
  }
}

/// 雲朵管理器
class CloudManager extends Component with HasGameRef {
  final List<CloudComponent> clouds = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 建立幾朵雲
    for (int i = 0; i < 3; i++) {
      final cloud = CloudComponent(
        speed: 20.0 + math.Random().nextDouble() * 30.0, // 隨機速度
        initialX: math.Random().nextDouble() * game.size.x,
        position: Vector2(
          math.Random().nextDouble() * game.size.x,
          math.Random().nextDouble() * game.size.y * 0.3, // 上半部分
        ),
        size: Vector2(
          60 + math.Random().nextDouble() * 40, // 隨機大小
          30 + math.Random().nextDouble() * 20,
        ),
      );
      clouds.add(cloud);
      add(cloud);
    }
  }
}
