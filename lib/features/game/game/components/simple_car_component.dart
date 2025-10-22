import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class SimpleCarComponent extends RectangleComponent with HasGameRef {
  static const double bounceAmplitude = 5.0; // 上下彈跳的幅度
  static const double bounceFrequency = 2.0; // 彈跳頻率

  double _time = 0.0;
  late Vector2 _initialPosition;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 設定汽車大小和顏色
    size = Vector2(120, 60);
    paint = Paint()..color = Colors.red;

    // 設定汽車位置（左側 1/4 處，垂直置中）
    position = Vector2(game.size.x * 0.25, game.size.y * 0.5 - size.y * 0.5);

    _initialPosition = position.clone();

    // 設定錨點為中心
    anchor = Anchor.center;

    // 新增車窗
    final window = RectangleComponent(
      size: Vector2(80, 30),
      position: Vector2(0, -10),
      paint: Paint()..color = Colors.lightBlue.withOpacity(0.7),
      anchor: Anchor.center,
    );
    add(window);

    // 新增車輪
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

    // 實現輕微的上下彈跳效果，模擬汽車行駛
    final bounceOffset =
        math.sin(_time * bounceFrequency * 2 * math.pi) * bounceAmplitude;
    position.y = _initialPosition.y + bounceOffset;

    // 加入輕微的左右搖擺效果
    final swayOffset = math.sin(_time * bounceFrequency * math.pi) * 2.0;
    position.x = _initialPosition.x + swayOffset;
  }
}
