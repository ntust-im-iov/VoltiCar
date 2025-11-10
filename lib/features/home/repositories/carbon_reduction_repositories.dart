import 'package:volticar_app/features/home/models/carbon_reduction_model.dart';
import 'package:volticar_app/features/home/services/carbon_reduction_service.dart';

class CarbonReductionRepository {
  final CarbonReductionService _carbonReductionService =
      CarbonReductionService();

  Future<CarbonReduction> fetchCarbonReduction() async {
    final result = await _carbonReductionService.fetchCarbonReduction();
    return result;
  }

  Future<CarbonReduction> saveCarbonReduction(double totalKwh) async {
    final result = await _carbonReductionService.saveCarbonReduction(totalKwh);
    return result;
  }
}
