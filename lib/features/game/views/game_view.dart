import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../viewmodels/game_viewmodel.dart';
import 'package:flutter/gestures.dart';

class GameView extends StatefulWidget {
  const GameView({Key? key}) : super(key: key);

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  double _targetSpeed = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        Provider.of<GameViewModel>(context, listen: false).speedNotifier.value =
            10;
      },
      onTapUp: (details) {
        Provider.of<GameViewModel>(context, listen: false).speedNotifier.value =
            0;
      },
      onTapCancel: () {
        Provider.of<GameViewModel>(context, listen: false).speedNotifier.value =
            0;
      },
      onLongPress: () {
        Provider.of<GameViewModel>(context, listen: false).speedNotifier.value =
            20;
      },
      onLongPressUp: () {
        Provider.of<GameViewModel>(context, listen: false).speedNotifier.value =
            0;
      },
      child: Scaffold(
        body: GameWidget(
          game: MyGame(context: context),
        ),
      ),
    );
  }
}

class MyGame extends FlameGame {
  late GameViewModel viewModel;
  late SpriteComponent playerSprite;
  BuildContext context;

  MyGame({required this.context});

  @override
  Future<void> onLoad() async {
    await Flame.images.load('car.png');
    viewModel = Provider.of<GameViewModel>(context, listen: false);

    // Load player sprite
    playerSprite = SpriteComponent(
      sprite: await Sprite.load('car.png'),
      size: Vector2(50, 50),
      position: Vector2(viewModel.player.x, viewModel.player.y),
    );
    add(playerSprite);

    viewModel.speedNotifier.addListener(() {
      viewModel.targetSpeed = viewModel.speedNotifier.value;
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    viewModel.movePlayer(dt);
    playerSprite.position = Vector2(viewModel.player.x, viewModel.player.y);
  }
}
