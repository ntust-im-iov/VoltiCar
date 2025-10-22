import 'package:flame/components.dart';
import 'package:flame/game.dart';

class ScrollingBackground extends Component with HasGameRef {
  late List<SpriteComponent> backgroundSprites;
  final double scrollSpeed = 120.0; // 像素每秒
  late double backgroundWidth;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 載入背景精靈
    final backgroundSprite = await game.loadSprite('ready_pg_bg.png');

    // 計算背景寬度，稍微加大一些以確保無縫銜接
    backgroundWidth = game.size.x * 1.1;

    // 建立三個背景精靈用於更平滑的無縫滾動
    backgroundSprites = [];

    for (int i = 0; i < 3; i++) {
      final sprite = SpriteComponent(
        sprite: backgroundSprite,
        size: Vector2(backgroundWidth, game.size.y),
        position: Vector2(backgroundWidth * i, 0),
      );
      backgroundSprites.add(sprite);
      add(sprite);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 移動背景
    for (final sprite in backgroundSprites) {
      sprite.position.x -= scrollSpeed * dt;

      // 當背景完全移出螢幕左側時，將其移動到最右側
      if (sprite.position.x <= -backgroundWidth) {
        // 找到最右邊的背景位置
        double rightmostX = backgroundSprites
            .map((s) => s.position.x)
            .reduce((a, b) => a > b ? a : b);
        sprite.position.x = rightmostX + backgroundWidth;
      }
    }
  }
}
