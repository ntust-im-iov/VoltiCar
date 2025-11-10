import 'package:flutter/material.dart';
import '../models/carbon_reduction_model.dart';
import '../repositories/carbon_reduction_repositories.dart';

class CarbonReductionViewModel extends ChangeNotifier {
  final CarbonReductionRepository _repository = CarbonReductionRepository();

  CarbonReduction? _carbonReduction;
  bool _isLoading = false;
  String? _error;

  CarbonReduction? get carbonReduction => _carbonReduction;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCarbonReduction() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _carbonReduction = await _repository.fetchCarbonReduction();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveCarbonReduction(double totalKwh) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _repository.saveCarbonReduction(totalKwh);
      _carbonReduction = result;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
