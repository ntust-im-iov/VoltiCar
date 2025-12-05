import 'package:flutter/material.dart';
import '../models/player_data_model.dart';
import '../repositories/player_data_repository.dart';

class PlayerDataViewModel extends ChangeNotifier {
  PlayerData? _playerData;
  bool _isLoading = false;
  String? _error;

  PlayerData? get playerData => _playerData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPlayerData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _playerData = await PlayerDataRepository().fetchPlayerData();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
