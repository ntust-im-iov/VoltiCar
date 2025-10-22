import 'package:flame/components.dart';
import 'package:logger/logger.dart';
import 'dart:math' as math;

class CarComponent extends SpriteComponent with HasGameRef {
  final Logger _logger = Logger();
  static const double carSpeed = 0.0; // 汽車不移動，只有動畫效果
  static const double bounceAmplitude = 2.0; // 上下彈跳的幅度
  static const double bounceFrequency = 1.5; // 彈跳頻率

  double _time = 0.0;
  late Vector2 _initialPosition;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      // 載入汽車精靈
      sprite = await game.loadSprite('bus.png');

      // 設定汽車大小（調整為合適的比例）
      size = Vector2(300, 180);

      // 設定汽車位置（左側 1/4 處，垂直置中）
      position = Vector2(game.size.x * 0.25, game.size.y * 0.8 - size.y * 0.5);

      _initialPosition = position.clone();

      // 設定錨點為中心
      anchor = Anchor.center;
    } catch (e) {
      _logger.e(e);
      // 若載入失敗，建立一個簡單的彩色矩形作為汽車
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

    // 實現輕微的上下彈跳效果，模擬汽車行駛
    final bounceOffset =
        math.sin(_time * bounceFrequency * 1.5 * math.pi) * bounceAmplitude;
    position.y = _initialPosition.y + bounceOffset;
  }
}
