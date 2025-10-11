import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class EnhancedCarComponent extends PositionComponent with HasGameRef {
  late SpriteComponent carBody;
  late List<CircleComponent> wheels;

  static const double bounceAmplitude = 3.0;
  static const double bounceFrequency = 3.0;
  static const double wheelRotationSpeed = 8.0; // 轮子旋转速度

  double _time = 0.0;
  late Vector2 _initialPosition;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 设置汽车位置
    position = Vector2(game.size.x * 0.2, game.size.y * 0.6);
    _initialPosition = position.clone();

    // 创建汽车车身
    final carSprite = await game.loadSprite('car.png');
    carBody = SpriteComponent(
      sprite: carSprite,
      size: Vector2(140, 70),
      anchor: Anchor.center,
    );
    add(carBody);

    // 创建轮子
    wheels = [];

    // 前轮
    final frontWheel = CircleComponent(
      radius: 15,
      position: Vector2(35, 25), // 相对于汽车车身的位置
      paint: Paint()..color = const Color(0xFF333333),
      anchor: Anchor.center,
    );
    wheels.add(frontWheel);
    add(frontWheel);

    // 后轮
    final rearWheel = CircleComponent(
      radius: 15,
      position: Vector2(-35, 25), // 相对于汽车车身的位置
      paint: Paint()..color = const Color(0xFF333333),
      anchor: Anchor.center,
    );
    wheels.add(rearWheel);
    add(rearWheel);

    // 为轮子添加轮辐效果
    for (final wheel in wheels) {
      _addWheelSpokes(wheel);
    }
  }

  void _addWheelSpokes(CircleComponent wheel) {
    // 添加轮辐
    for (int i = 0; i < 4; i++) {
      final spoke = RectangleComponent(
        size: Vector2(2, wheel.radius * 1.5),
        position: Vector2(0, 0),
        paint: Paint()..color = const Color(0xFF666666),
        anchor: Anchor.center,
      );
      spoke.angle = (i * math.pi / 2);
      wheel.add(spoke);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    _time += dt;

    // 汽车整体的轻微弹跳
    final bounceOffset =
        math.sin(_time * bounceFrequency * 2 * math.pi) * bounceAmplitude;
    position.y = _initialPosition.y + bounceOffset;

    // 轻微的水平摇摆
    final swayOffset = math.sin(_time * bounceFrequency * math.pi * 0.5) * 1.5;
    position.x = _initialPosition.x + swayOffset;

    // 轮子旋转
    for (final wheel in wheels) {
      wheel.angle += wheelRotationSpeed * dt;
    }
  }
}
