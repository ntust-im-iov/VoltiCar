import 'package:flutter/material.dart';
import '../models/carbon_reward_point_model.dart';
import '../repositories/carbon_reward_point_repositories.dart';

class CarbonRewardPointViewModel extends ChangeNotifier {
  final CarbonRewardPointRepository _repository = CarbonRewardPointRepository();

  CarbonRewardPoint? _carbonRewardPoint;
  bool _isLoading = false;
  String? _error;

  CarbonRewardPoint? get carbonRewardPoint => _carbonRewardPoint;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCarbonRewardPoint() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _carbonRewardPoint = await _repository.fetchCarbonRewardPoint();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveCarbonRewardPoint(double carbonKg) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _repository.saveCarbonRewardPoint(carbonKg);
      _carbonRewardPoint = result;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
