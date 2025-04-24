import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:volticar_app/features/home/views/garage_view.dart';

class AdaptiveComponent extends SpriteComponent
    with TapCallbacks, HasGameRef<VoltiCarGame> {
  AdaptiveComponent(
      this.screenSize,
      this.widthGain,
      this.heightGain,
      this.imagePath,
      this.positionGainofX,
      this.positionGainofY,
      this.onPressed)
      : super(anchor: Anchor.bottomCenter);

  final String imagePath;
  final Vector2 screenSize;
  final double widthGain;
  final double heightGain;
  final double positionGainofX;
  final double positionGainofY;
  final VoidCallback? onPressed;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite(imagePath);

    // Calculate adaptive size and position
    final double componentWith = screenSize.x * widthGain;
    final double componentHeight = componentWith * heightGain;
    size = Vector2(componentWith, componentHeight);

    // Position the component at the horizontal center and a dynamic position from the bottom
    position =
        Vector2(screenSize.x * positionGainofX, screenSize.y * positionGainofY);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPressed?.call(); // Execute the callback on tap
  }
}
