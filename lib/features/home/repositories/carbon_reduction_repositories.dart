import '../models/carbon_reduction_model.dart';
import '../services/carbon_reduction_service.dart';

class CarbonReductionRepository {
  final CarbonReductionService _service;

  CarbonReductionRepository({CarbonReductionService? service})
      : _service = service ?? CarbonReductionService();

  /// 取得減碳量資料
  Future<CarbonReductionModel> fetchCarbonReduction() async {
    return await _service.fetchCarbonReduction();
  }

  /// 儲存減碳量資料
  Future<CarbonReductionModel> saveCarbonReduction(double totalKwh) async {
    return await _service.saveCarbonReduction(totalKwh);
  }
}
