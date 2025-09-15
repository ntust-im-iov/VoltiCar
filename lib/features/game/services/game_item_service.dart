import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:volticar_app/core/constants/api_constants.dart';
import 'package:volticar_app/core/network/api_client.dart';
import '../models/game_item_model.dart';

class GameItemService {
  static final GameItemService _instance = GameItemService._internal();
  final ApiClient _apiClient = ApiClient();
  final Logger _logger = Logger();

  factory GameItemService() {
    return _instance;
  }

  GameItemService._internal();

  /// 取得使用者倉庫內所有物品
  Future<List<GameItem>> fetchUserWarehouseItems() async {
    try {
      _logger.i('Fetching warehouse items from API...');
      final response = await _apiClient.get(
        ApiConstants.playerWarehouse,
        options: null,
      );
      _logger.i('Response status: ${response.statusCode}');
      _logger.i('Response data type: ${response.data.runtimeType}');
      _logger.i('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is String
            ? json.decode(response.data)
            : response.data;
        _logger.i('Found ${data.length} warehouse items');
        return data.map((item) => GameItem.fromJson(item)).toList();
      } else {
        throw Exception('無法取得倉庫物品: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('未授權，請重新登入');
      } else if (e.response?.statusCode == 404) {
        throw Exception('找不到倉庫物品');
      } else {
        throw Exception('網路錯誤: ${e.message}');
      }
    } catch (e) {
      _logger.e('無法取得倉庫物品: $e');
      throw Exception('未預期的錯誤: $e');
    }
  }

  /// 取得單一遊戲物品（顯示用）
  Future<GameItem> fetchGameItemById(String itemId) async {
    try {
      _logger.i('Fetching game item by id: $itemId');
      final response = await _apiClient.get(
        '${ApiConstants.playerWarehouse}/$itemId',
        options: null,
      );
      _logger.i('Response status: ${response.statusCode}');
      _logger.i('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        return GameItem.fromJson(response.data is String
            ? json.decode(response.data)
            : response.data);
      } else {
        throw Exception('無法取得遊戲物品: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('未授權，請重新登入');
      } else if (e.response?.statusCode == 404) {
        throw Exception('找不到該遊戲物品');
      } else {
        throw Exception('網路錯誤: ${e.message}');
      }
    } catch (e) {
      _logger.e('無法取得遊戲物品: $e');
      throw Exception('未預期的錯誤: $e');
    }
  }
}
