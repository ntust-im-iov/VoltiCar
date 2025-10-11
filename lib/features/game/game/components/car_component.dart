import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'dart:math' as math;

class CarComponent extends SpriteComponent with HasGameRef {
  static const double carSpeed = 0.0; // 汽车不移动，只有动画效果
  static const double bounceAmplitude = 5.0; // 上下弹跳的幅度
  static const double bounceFrequency = 2.0; // 弹跳频率

  double _time = 0.0;
  late Vector2 _initialPosition;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      // 加载汽车精灵
      sprite = await game.loadSprite('car.png');

      // 设置汽车大小 (调整为合适的比例)
      size = Vector2(120, 60);

      // 设置汽车位置 (左侧1/4处，垂直居中)
      position = Vector2(game.size.x * 0.25, game.size.y * 0.5 - size.y * 0.5);

      _initialPosition = position.clone();

      // 设置锚点为中心
      anchor = Anchor.center;
    } catch (e) {
      print('加载汽车精灵失败: $e');
      // 如果加载失败，创建一个简单的彩色矩形作为汽车
      size = Vector2(120, 60);
      position = Vector2(game.size.x * 0.25, game.size.y * 0.5 - size.y * 0.5);
      _initialPosition = position.clone();
      anchor = Anchor.center;
    }
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
