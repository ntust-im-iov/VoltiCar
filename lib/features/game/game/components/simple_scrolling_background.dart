import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class SimpleScrollingBackground extends Component with HasGameRef {
  late List<RectangleComponent> backgroundRects;
  final double scrollSpeed = 120.0; // 像素每秒
  late double backgroundWidth;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 計算背景寬度
    backgroundWidth = game.size.x;

    // 建立三個背景矩形用於無縫滾動
    backgroundRects = [];

    for (int i = 0; i < 3; i++) {
      final rect = RectangleComponent(
        size: Vector2(backgroundWidth, game.size.y),
        position: Vector2(backgroundWidth * i, 0),
        paint: Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF87CEEB), // 天空藍
              const Color(0xFF98FB98), // 淺綠色（地面）
            ],
            stops: const [0.6, 1.0],
          ).createShader(Rect.fromLTWH(0, 0, backgroundWidth, game.size.y)),
      );
      backgroundRects.add(rect);
      add(rect);
    }

    // 加入地平線
    final horizon = RectangleComponent(
      size: Vector2(backgroundWidth * 3, 4),
      position: Vector2(0, game.size.y * 0.65),
      paint: Paint()..color = const Color(0xFF228B22), // 深綠色
    );
    add(horizon);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 移動背景
    for (final rect in backgroundRects) {
      rect.position.x -= scrollSpeed * dt;

      // 當背景完全移出螢幕左側時，將其移動到最右側
      if (rect.position.x <= -backgroundWidth) {
        // 找到最右邊的背景位置
        double rightmostX = backgroundRects
            .map((r) => r.position.x)
            .reduce((a, b) => a > b ? a : b);
        rect.position.x = rightmostX + backgroundWidth;
      }
    }
  }
}
