import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:volticar_app/core/constants/api_constants.dart';
import 'package:volticar_app/core/network/api_client.dart';
import '../models/shop_item_model.dart';

class ShopService {
  static final ShopService _instance = ShopService._internal();
  final ApiClient _apiClient = ApiClient();
  final Logger _logger = Logger();

  factory ShopService() {
    return _instance;
  }

  ShopService._internal();

  /// 取得商店商品列表
  Future<List<ShopItem>> fetchShopItems() async {
    try {
      _logger.i('Fetching shop items from API...');
      final response = await _apiClient.get(
        ApiConstants.shopItems,
        options: null,
      );
      _logger.i('Response status: ${response.statusCode}');
      _logger.i('Response data type: ${response.data.runtimeType}');
      _logger.i('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is String
            ? json.decode(response.data)
            : response.data;
        _logger.i('API shop items count: ${data.length}');
        for (var i = 0; i < data.length; i++) {
          _logger.i('ShopItem[$i]: ${data[i]}');
        }
        final items = data.map((item) => ShopItem.fromJson(item)).toList();
        _logger.i('Parsed ShopItem count: ${items.length}');
        for (var i = 0; i < items.length; i++) {
          _logger
              .i('ShopItem[$i]: ${items[i].name}, price: \$${items[i].price}');
        }
        return items;
      } else {
        throw Exception('無法取得商店商品: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('未授權，請重新登入');
      } else if (e.response?.statusCode == 404) {
        throw Exception('找不到商店商品');
      } else {
        throw Exception('網路錯誤: ${e.message}');
      }
    } catch (e) {
      _logger.e('無法取得商店商品: $e');
      throw Exception('未預期的錯誤: $e');
    }
  }
}
