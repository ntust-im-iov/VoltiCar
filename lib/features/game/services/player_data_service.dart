import 'package:dio/dio.dart';
import '../models/player_data_model.dart';
import 'package:volticar_app/core/constants/api_constants.dart';
import 'package:volticar_app/core/network/api_client.dart';

class PlayerDataService {
  static final PlayerDataService _instance = PlayerDataService._internal();
  final ApiClient _apiClient = ApiClient();

  factory PlayerDataService() {
    return _instance;
  }

  PlayerDataService._internal();

  /// 取得玩家資料
  Future<PlayerData> getPlayerData() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.playerData,
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        return PlayerData.fromJson(response.data);
      } else {
        throw Exception('獲取玩家資料失敗: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('未授權，請重新登入');
      } else if (e.response?.statusCode == 404) {
        throw Exception('找不到玩家資料');
      } else {
        throw Exception('網路錯誤: ${e.message}');
      }
    } catch (e) {
      throw Exception('未預期的錯誤: $e');
    }
  }
}
