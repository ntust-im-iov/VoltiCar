import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class SimpleCarComponent extends RectangleComponent with HasGameRef {
  static const double bounceAmplitude = 5.0; // 上下弹跳的幅度
  static const double bounceFrequency = 2.0; // 弹跳频率

  double _time = 0.0;
  late Vector2 _initialPosition;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 设置汽车大小和颜色
    size = Vector2(120, 60);
    paint = Paint()..color = Colors.red;

    // 设置汽车位置 (左侧1/4处，垂直居中)
    position = Vector2(game.size.x * 0.25, game.size.y * 0.5 - size.y * 0.5);

    _initialPosition = position.clone();

    // 设置锚点为中心
    anchor = Anchor.center;

    // 添加车窗
    final window = RectangleComponent(
      size: Vector2(80, 30),
      position: Vector2(0, -10),
      paint: Paint()..color = Colors.lightBlue.withOpacity(0.7),
      anchor: Anchor.center,
    );
    add(window);

    // 添加车轮
    final frontWheel = CircleComponent(
      radius: 12,
      position: Vector2(30, 25),
      paint: Paint()..color = Colors.black,
      anchor: Anchor.center,
    );
    add(frontWheel);

    final rearWheel = CircleComponent(
      radius: 12,
      position: Vector2(-30, 25),
      paint: Paint()..color = Colors.black,
      anchor: Anchor.center,
    );
    add(rearWheel);
  }

  @override
  void update(double dt) {
    super.update(dt);

    _time += dt;

    // 实现轻微的上下弹跳效果，模拟汽车行驶
    final bounceOffset =
        math.sin(_time * bounceFrequency * 2 * math.pi) * bounceAmplitude;
    position.y = _initialPosition.y + bounceOffset;

    // 添加轻微的左右摇摆效果
    final swayOffset = math.sin(_time * bounceFrequency * math.pi) * 2.0;
    position.x = _initialPosition.x + swayOffset;
  }
}
