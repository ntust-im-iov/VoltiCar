import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:volticar_app/core/constants/api_constants.dart';
import 'package:volticar_app/core/network/api_client.dart';
import '../models/game_session_summary_model.dart';

class GameSessionService {
  static final GameSessionService _instance = GameSessionService._internal();
  final ApiClient _apiClient = ApiClient();
  final Logger _logger = Logger();

  factory GameSessionService() {
    return _instance;
  }

  GameSessionService._internal();

  /// 取得遊戲會話摘要
  Future<GameSessionSummary> fetchGameSessionSummary() async {
    try {
      _logger.i('Fetching game session summary from API...');
      final response = await _apiClient.get(
        ApiConstants.gameSessionSummary,
        options: null,
      );
      _logger.i('Response status: ${response.statusCode}');
      _logger.i('Response data type: ${response.data.runtimeType}');
      _logger.i('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String
            ? json.decode(response.data)
            : response.data;
        _logger.i('Parsed game session summary data');
        final summary = GameSessionSummary.fromJson(data);
        _logger.i('Can start game: ${summary.canStartGame}');
        _logger.i('Warnings count: ${summary.startGameWarnings.length}');
        return summary;
      } else {
        throw Exception('無法取得遊戲會話摘要: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('未授權，請重新登入');
      } else if (e.response?.statusCode == 404) {
        throw Exception('找不到遊戲會話資料');
      } else {
        throw Exception('網路錯誤: ${e.message}');
      }
    } catch (e) {
      _logger.e('無法取得遊戲會話摘要: $e');
      throw Exception('未預期的錯誤: $e');
    }
  }
}
