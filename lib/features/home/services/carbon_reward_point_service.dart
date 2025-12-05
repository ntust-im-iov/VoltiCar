import 'package:dio/dio.dart';
import '../models/carbon_reward_point_model.dart';
import 'package:volticar_app/core/constants/api_constants.dart';
import 'dart:async';
import 'package:logger/logger.dart';
import 'package:volticar_app/core/network/api_client.dart';

class CarbonRewardPointService {
  final ApiClient _apiClient = ApiClient();
  final Logger _logger = Logger();
  static final String _carbonRewardPointUrl = ApiConstants.carbonRewardPoint;
  static final String _saveCarbonRewardPointUrl =
      ApiConstants.saveCarbonRewardPoint;

  /// 取得減碳獎勵資料
  Future<CarbonRewardPointModel> fetchCarbonRewardPoint() async {
    _logger.i('[Service] fetchCarbonRewardPoint called');
    try {
      final response = await _apiClient.get(_carbonRewardPointUrl);
      _logger.i('[Service] API requested: $_carbonRewardPointUrl');
      final json = response.data;
      final data = CarbonRewardPointModel.fromJson(json);
      _logger.i('[Service] Parsed data: \\${data.toString()}');
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

  /// 儲存減碳量（kg），回傳對應的減碳點數資料
  Future<CarbonRewardPointModel> saveCarbonRewardPoint(
      double totalCarbonReductionKg) async {
    _logger.i(
        '[Service] saveCarbonRewardPoint called, params: totalCarbonReductionKg=$totalCarbonReductionKg');
    try {
      // 將減碳量傳給後端，後端回傳目前的減碳點數
      // API expects `carbon_kg`; keep `total_carbon_reduction_kg` for backward compatibility
      final requestBody = {
        'carbon_kg': totalCarbonReductionKg,
        'total_carbon_reduction_kg': totalCarbonReductionKg,
      };
      _logger.i('[Service] Request body: $requestBody');
      final response =
          await _apiClient.post(_saveCarbonRewardPointUrl, data: requestBody);
      _logger.i('[Service] API requested: $_saveCarbonRewardPointUrl');
      _logger.i('[Service] Response status: ${response.statusCode}');

      // 解析 response，容錯不同結構
      dynamic json = response.data;
      Map<String, dynamic> payload = {};

      if (json is Map<String, dynamic>) {
        // 如果回傳包在 data 裡面，取出
        if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
          payload = Map<String, dynamic>.from(json['data']);
        } else {
          payload = Map<String, dynamic>.from(json);
        }
      } else if (json is int) {
        payload = {'carbon_reward_points': json};
      } else if (json is String) {
        // 嘗試解析字串為數字
        final p = int.tryParse(json) ?? double.tryParse(json)?.toInt() ?? 0;
        payload = {'carbon_reward_points': p};
      }

      // 支援其他可能的欄位名稱
      if (!payload.containsKey('carbon_reward_points')) {
        if (payload.containsKey('total_points')) {
          payload['carbon_reward_points'] = payload['total_points'];
        } else if (payload.containsKey('points')) {
          payload['carbon_reward_points'] = payload['points'];
        } else if (payload.containsKey('carbon_points')) {
          payload['carbon_reward_points'] = payload['carbon_points'];
        }
      }

      _logger.i('[Service] Parsed payload for model: $payload');
      final data = CarbonRewardPointModel.fromJson(payload);
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
