import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:volticar_app/core/constants/api_constants.dart';
import 'package:volticar_app/core/network/api_client.dart';
import '../models/vehicle_model.dart';

class VehicleService {
  static final VehicleService _instance = VehicleService._internal();
  final ApiClient _apiClient = ApiClient();
  final Logger _logger = Logger();

  factory VehicleService() {
    return _instance;
  }

  VehicleService._internal();

  /// 取得使用者的車輛列表
  Future<List<Vehicle>> fetchUserVehicles() async {
    try {
      _logger.i('Fetching vehicles from API...');
      final response = await _apiClient.get(
        ApiConstants.playerVehicles,
        options: null,
      );
      _logger.i('Response status: ${response.statusCode}');
      _logger.i('Response data type: ${response.data.runtimeType}');
      _logger.i('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is String
            ? json.decode(response.data)
            : response.data;
        _logger.i('API vehicles count: ${data.length}');
        for (var i = 0; i < data.length; i++) {
          _logger.i('Vehicle[$i]: ${data[i]}');
        }
        final vehicles = data.map((vehicle) => Vehicle.fromJson(vehicle)).toList();
        _logger.i('Parsed Vehicle count: ${vehicles.length}');
        for (var i = 0; i < vehicles.length; i++) {
          _logger.i(
              'Vehicle[$i]: ${vehicles[i].name}, status: ${vehicles[i].status}');
        }
        return vehicles;
      } else {
        throw Exception('無法取得車輛列表: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('未授權，請重新登入');
      } else if (e.response?.statusCode == 404) {
        throw Exception('找不到車輛資料');
      } else {
        throw Exception('網路錯誤: ${e.message}');
      }
    } catch (e) {
      _logger.e('無法取得車輛列表: $e');
      throw Exception('未預期的錯誤: $e');
    }
  }
}
