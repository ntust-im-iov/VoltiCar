import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../volti_car_game.dart';

/// 遊戲狀態枚舉
enum GameState {
  playing,
  paused,
}

/// 事件方塊組件
class EventBlock extends RectangleComponent
    with HasGameRef<VoltiCarGame>, CollisionCallbacks {
  final double speed = 150.0; // 移動速度
  final VoidCallback onBlockCollision; // 碰撞回調

  EventBlock({
    required Vector2 position,
    required this.onBlockCollision,
  }) : super(
          position: position,
          size: Vector2(40, 40), // 方塊大小
          paint: Paint()
            ..color = Colors.orange
            ..style = PaintingStyle.fill,
        ) {
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 添加矩形碰撞形狀
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 檢查遊戲狀態，如果暫停則不更新
    if (game.gameState == GameState.paused) return;

    // 向左移動
    position.x -= speed * dt;

    // 如果移出螢幕左側，移除此組件
    if (position.x < -size.x) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    // 觸發碰撞回調
    onBlockCollision();

    // 從遊戲中移除此方塊
    removeFromParent();
  }
}
