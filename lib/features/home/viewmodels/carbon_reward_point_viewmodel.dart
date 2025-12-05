import 'dart:async';
import 'package:flutter/material.dart';
import '../models/carbon_reward_point_model.dart';
import '../repositories/carbon_reward_point_repositories.dart';

class CarbonRewardPointViewModel extends ChangeNotifier {
  final CarbonRewardPointRepository _repository;

  CarbonRewardPointModel? _carbonRewardPoint;
  bool _isLoading = false;
  String? _error;

  CarbonRewardPointModel? get carbonRewardPoint => _carbonRewardPoint;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CarbonRewardPointViewModel({CarbonRewardPointRepository? repository})
      : _repository = repository ?? CarbonRewardPointRepository();

  /// 取得減碳獎勵資料
  Future<void> fetchCarbonRewardPoint() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _repository.fetchCarbonRewardPoint();
      _carbonRewardPoint = data;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 儲存減碳量（kg），回傳對應的減碳點數資料
  Future<void> saveCarbonRewardPoint(double totalCarbonReductionKg) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data =
          await _repository.saveCarbonRewardPoint(totalCarbonReductionKg);
      // 更新本地狀態為後端回傳的減碳獎勵資料
      _carbonRewardPoint = data;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
