import 'package:dio/dio.dart';
import '../models/carbon_reduction_model.dart';
import 'package:volticar_app/core/constants/api_constants.dart';

class CarbonReductionService {
  final Dio _dio = Dio();
  // 請將以下 API 路徑替換為實際後端 API
  static const String _fetchUrl =
      '${ApiConstants.baseUrl}${ApiConstants.carbonReduction}';
  static const String _saveUrl =
      '${ApiConstants.baseUrl}${ApiConstants.saveCarbonReduction}';

  /// 提取碳減量資料
  Future<CarbonReduction> fetchCarbonReduction() async {
    final response = await _dio.get(_fetchUrl);
    return CarbonReduction.fromJson(response.data);
  }

  /// 傳入本次充電量，API 回傳本次減碳量
  Future<CarbonReduction> saveCarbonReduction(double totalKwh) async {
    final response = await _dio.post(
      _saveUrl,
      data: {'total_kwh': totalKwh},
    );
    return CarbonReduction.fromJson(response.data);
  }
}
