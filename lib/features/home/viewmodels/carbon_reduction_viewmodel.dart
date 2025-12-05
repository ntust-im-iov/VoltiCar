import 'dart:async';
import 'package:flutter/material.dart';
import '../models/carbon_reduction_model.dart';
import '../repositories/carbon_reduction_repositories.dart';

class CarbonReductionViewModel extends ChangeNotifier {
  final CarbonReductionRepository _repository;

  CarbonReductionModel? _carbonReduction;
  bool _isLoading = false;
  String? _error;

  CarbonReductionModel? get carbonReduction => _carbonReduction;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CarbonReductionViewModel({CarbonReductionRepository? repository})
      : _repository = repository ?? CarbonReductionRepository();

  /// 取得減碳量資料
  Future<void> fetchCarbonReduction() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _repository.fetchCarbonReduction();
      _carbonReduction = data;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 儲存減碳量資料
  Future<void> saveCarbonReduction(double totalKwh) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _repository.saveCarbonReduction(totalKwh);
      // 更新本地狀態為後端回傳的減碳量資料
      _carbonReduction = data;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
