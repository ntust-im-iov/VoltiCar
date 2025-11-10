import "package:dio/dio.dart";
import 'package:volticar_app/core/constants/api_constants.dart';
import 'package:volticar_app/core/network/api_client.dart';
import 'package:volticar_app/features/game/models/vehicle_choose_model.dart';
import 'package:logger/logger.dart';

class VehicleChooseService {
  static final VehicleChooseService _instance =
      VehicleChooseService._internal();
  final ApiClient _apiClient = ApiClient();
  final Logger _logger = Logger();

  factory VehicleChooseService() {
    return _instance;
  }

  VehicleChooseService._internal();

  Future<VehicleChooseModel> chooseVehicle(String vehicleId) async {
    try {
      _logger.i('Choosing vehicle with ID: $vehicleId');
      final response = await _apiClient.put(
        ApiConstants.chooseVehicle,
        data: {
          'vehicle_id': vehicleId,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      _logger.i('Response status: ${response.statusCode}');
      _logger.i('Response data: ${response.data}');

      // 檢查重定向狀態碼
      if (response.statusCode == 307) {
        _logger.i(
            'Received temporary redirect (307), request was automatically redirected');
      }

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 307) {
        _logger.i('Vehicle chosen successfully.');

        // 檢查響應數據是否包含必要信息
        if (response.data != null) {
          try {
            final result = VehicleChooseModel.fromJson(response.data);
            _logger.i('Parsed vehicle: ${result.selectedVehicle.vehicleId}');
            _logger.i('Message: ${result.message}');
            _logger.i('Cleared cargo: ${result.clearedCargo}');
            return result;
          } catch (parseError) {
            _logger.e('Failed to parse response data: $parseError');
            _logger.e('Response data was: ${response.data}');
            throw Exception('解析車輛選擇回應失敗: $parseError');
          }
        } else {
          _logger.w('Response data is null');
          throw Exception('伺服器回應資料為空');
        }
      } else {
        _logger
            .w('Failed to choose vehicle. Status code: ${response.statusCode}');
        throw Exception('選擇車輛失敗，狀態碼: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('DioException when choosing vehicle: $e');
      if (e.response?.statusCode == 401) {
        throw Exception('未授權，請重新登入');
      } else if (e.response?.statusCode == 404) {
        throw Exception('找不到該車輛');
      } else if (e.response?.statusCode == 400) {
        throw Exception('無效的車輛選擇請求');
      } else {
        throw Exception('網路錯誤: ${e.message}');
      }
    } catch (e) {
      _logger.e('Error choosing vehicle: $e');
      throw Exception('選擇車輛時發生錯誤: $e');
    }
  }
}
