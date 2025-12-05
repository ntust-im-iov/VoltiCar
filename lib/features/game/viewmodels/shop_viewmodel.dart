import 'package:flutter/material.dart';
import '../models/shop_item_model.dart';
import '../repositories/shop_repository.dart';

class ShopViewModel extends ChangeNotifier {
  final ShopRepository _shopRepository;

  List<ShopItem> _items = [];
  bool _isLoading = false;
  String? _error;

  ShopViewModel({ShopRepository? shopRepository})
      : _shopRepository = shopRepository ?? ShopRepository();

  List<ShopItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchShopItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _shopRepository.getShopItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
