import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'components/simple_scrolling_background.dart';
import 'components/simple_car_component.dart';
import 'components/effects_components.dart';

class VoltiCarGame extends FlameGame with HasCollisionDetection {
  late SimpleScrollingBackground background;
  late SimpleCarComponent car;
  late RoadMarkings roadMarkings;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 层次顺序很重要 - 从后往前添加

    // 1. 添加滚动背景
    background = SimpleScrollingBackground();
    add(background);

    // 2. 添加道路标线
    roadMarkings = RoadMarkings();
    add(roadMarkings);

    // 3. 添加汽车组件 (最前景)
    car = SimpleCarComponent();
    add(car);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  Color backgroundColor() => const Color(0xFF87CEEB); // 天空蓝色作为默认背景
}
