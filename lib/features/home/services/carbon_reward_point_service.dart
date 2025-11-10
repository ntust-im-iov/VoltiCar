import 'package:dio/dio.dart';
import '../models/carbon_reward_point_model.dart';
import 'package:volticar_app/core/constants/api_constants.dart';

class CarbonRewardPointService {
  final Dio _dio = Dio();
  // 請將以下 API 路徑替換為實際後端 API
  static const String _fetchUrl =
      '${ApiConstants.baseUrl}${ApiConstants.carbonRewardPoint}';
  static const String _saveUrl =
      '${ApiConstants.baseUrl}${ApiConstants.saveCarbonRewardPoint}';

  /// 提取碳獎勵點數資料
  Future<CarbonRewardPoint> fetchCarbonRewardPoint() async {
    final response = await _dio.get(_fetchUrl);
    return CarbonRewardPoint.fromJson(response.data);
  }

  /// 傳入本次減碳量(kg)，API 回傳本次點數
  Future<CarbonRewardPoint> saveCarbonRewardPoint(double carbonKg) async {
    final response = await _dio.post(
      _saveUrl,
      data: {'carbon_kg': carbonKg},
    );
    return CarbonRewardPoint.fromJson(response.data);
  }
}
