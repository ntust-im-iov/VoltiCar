import 'package:flutter/material.dart';
import '../models/game_item_model.dart';
import '../repositories/game_item_repository.dart';

class WarehouseViewModel extends ChangeNotifier {
  final GameItemRepository _gameItemRepository;

  List<GameItem> _items = [];
  bool _isLoading = false;
  String? _error;

  WarehouseViewModel({GameItemRepository? gameItemRepository})
      : _gameItemRepository = gameItemRepository ?? GameItemRepository();

  List<GameItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWarehouseItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _gameItemRepository.getUserWarehouseItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
