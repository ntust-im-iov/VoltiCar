import 'package:flame/components.dart';
import 'package:flame/game.dart';

class ScrollingBackground extends Component with HasGameRef {
  late List<SpriteComponent> backgroundSprites;
  final double scrollSpeed = 120.0; // 像素每秒
  late double backgroundWidth;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 加载背景精灵
    final backgroundSprite = await game.loadSprite('ready_pg_bg.png');

    // 计算背景宽度，稍微加大一些以确保无缝衔接
    backgroundWidth = game.size.x * 1.1;

    // 创建三个背景精灵用于更平滑的无缝滚动
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

    // 移动背景
    for (final sprite in backgroundSprites) {
      sprite.position.x -= scrollSpeed * dt;

      // 当背景完全移出屏幕左侧时，将其移动到最右侧
      if (sprite.position.x <= -backgroundWidth) {
        // 找到最右边的背景位置
        double rightmostX = backgroundSprites
            .map((s) => s.position.x)
            .reduce((a, b) => a > b ? a : b);
        sprite.position.x = rightmostX + backgroundWidth;
      }
    }
  }
}
