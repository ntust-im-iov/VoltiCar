import '../models/carbon_reward_point_model.dart';
import '../services/carbon_reward_point_service.dart';

class CarbonRewardPointRepository {
  final CarbonRewardPointService _service;

  CarbonRewardPointRepository({CarbonRewardPointService? service})
      : _service = service ?? CarbonRewardPointService();

  /// 取得減碳獎勵資料
  Future<CarbonRewardPointModel> fetchCarbonRewardPoint() async {
    return await _service.fetchCarbonRewardPoint();
  }

  /// 儲存減碳量（kg），回傳對應的減碳點數資料
  Future<CarbonRewardPointModel> saveCarbonRewardPoint(
      double totalCarbonReductionKg) async {
    return await _service.saveCarbonRewardPoint(totalCarbonReductionKg);
  }
}
