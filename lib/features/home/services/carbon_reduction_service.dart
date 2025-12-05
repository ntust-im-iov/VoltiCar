import 'package:dio/dio.dart';
import '../models/carbon_reduction_model.dart';
import 'package:volticar_app/core/constants/api_constants.dart';
import 'dart:async';
import 'package:logger/logger.dart';
import 'package:volticar_app/core/network/api_client.dart';

class CarbonReductionService {
  final ApiClient _apiClient = ApiClient();
  final Logger _logger = Logger();
  static final String _carbonReductionUrl = ApiConstants.carbonReduction;
  static final String _saveCarbonReductionUrl =
      ApiConstants.saveCarbonReduction;

  /// 取得減碳量資料
  Future<CarbonReductionModel> fetchCarbonReduction() async {
    _logger.i('[Service] fetchCarbonReduction called');
    try {
      final response = await _apiClient.get(_carbonReductionUrl);
      _logger.i('[Service] API requested: $_carbonReductionUrl');
      final json = response.data;
      final data = CarbonReductionModel.fromJson(json);
      _logger.i('[Service] Parsed data: \\${data.toString()}');
      return data;
    } catch (e) {
      _logger.e('[Service] API error: $e');
      rethrow;
    }
  }

  /// 儲存減碳量資料，回傳後端計算的減碳量（kg）資料
  Future<CarbonReductionModel> saveCarbonReduction(double totalKwh) async {
    _logger
        .i('[Service] saveCarbonReduction called, params: totalKwh=$totalKwh');
    try {
      final requestBody = {'total_kwh': totalKwh};
      final response =
          await _apiClient.post(_saveCarbonReductionUrl, data: requestBody);
      _logger.i('[Service] API requested: $_saveCarbonReductionUrl');
      _logger.i('[Service] Response status: ${response.statusCode}');

      final json = response.data;
      final data = CarbonReductionModel.fromJson(json);
      _logger.i('[Service] Parsed data: ${data.toString()}');
      return data;
    } on DioException catch (e) {
      _logger.e(
          '[Service] API error status: ${e.response?.statusCode}, body: ${e.response?.data}');
      rethrow;
    } catch (e) {
      _logger.e('[Service] API error: $e');
      rethrow;
    }
  }
}
