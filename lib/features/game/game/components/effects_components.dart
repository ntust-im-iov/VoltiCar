import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 道路标线组件 - 增加道路感
class RoadMarkings extends Component with HasGameRef {
  final List<RectangleComponent> markings = [];
  final double markingSpeed = 150.0; // 比背景稍快，营造层次感
  final double markingWidth = 8.0;
  final double markingHeight = 40.0;
  final double markingSpacing = 80.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 创建道路标线
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

    for (final marking in markings) {
      marking.position.x -= markingSpeed * dt;

      // 重置标线位置
      if (marking.position.x <= -markingWidth) {
        marking.position.x += markingSpacing * markings.length;
      }
    }
  }
}

/// 云朵组件 - 增加背景层次
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

    // 如果有云朵图片可以加载，否则用简单的白色矩形
    paint = Paint()..color = const Color(0x88FFFFFF);
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.x -= speed * dt;

    // 重置云朵位置
    if (position.x <= -size.x) {
      position.x = game.size.x + size.x;
    }
  }
}

/// 云朵管理器
class CloudManager extends Component with HasGameRef {
  final List<CloudComponent> clouds = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 创建几朵云
    for (int i = 0; i < 3; i++) {
      final cloud = CloudComponent(
        speed: 20.0 + math.Random().nextDouble() * 30.0, // 随机速度
        initialX: math.Random().nextDouble() * game.size.x,
        position: Vector2(
          math.Random().nextDouble() * game.size.x,
          math.Random().nextDouble() * game.size.y * 0.3, // 上半部分
        ),
        size: Vector2(
          60 + math.Random().nextDouble() * 40, // 随机大小
          30 + math.Random().nextDouble() * 20,
        ),
      );
      clouds.add(cloud);
      add(cloud);
    }
  }
}
