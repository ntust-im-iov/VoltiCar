import 'package:flutter/material.dart';
import '../models/player_model.dart';

class GameViewModel extends ChangeNotifier {
  PlayerModel player = PlayerModel();
  double targetSpeed = 0;
  double accelerationRate = 0.5;
  double decelerationRate = 1;

  ValueNotifier<double> speedNotifier = ValueNotifier<double>(0);

  void setTargetSpeed(double speed) {
    targetSpeed = speed;
    speedNotifier.value = speed;
    notifyListeners();
  }

  void movePlayer(double dt) {
    if (player.speed < targetSpeed) {
      player.speed += accelerationRate * dt;
      if (player.speed > targetSpeed) {
        player.speed = targetSpeed;
      }
    } else if (player.speed > targetSpeed) {
      player.speed -= decelerationRate * dt;
      if (player.speed < targetSpeed) {
        player.speed = targetSpeed;
      }
    }

    player.x += player.speed;
    notifyListeners();
  }
}
