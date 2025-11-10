import 'package:volticar_app/features/home/models/carbon_reward_point_model.dart';
import 'package:volticar_app/features/home/services/carbon_reward_point_service.dart';

class CarbonRewardPointRepository {
  final CarbonRewardPointService _carbonRewardPointService =
      CarbonRewardPointService();

  Future<CarbonRewardPoint> fetchCarbonRewardPoint() async {
    final result = await _carbonRewardPointService.fetchCarbonRewardPoint();
    return result;
  }

  Future<CarbonRewardPoint> saveCarbonRewardPoint(double carbonKg) async {
    final result =
        await _carbonRewardPointService.saveCarbonRewardPoint(carbonKg);
    return result;
  }
}
