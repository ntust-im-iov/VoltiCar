import 'package:dio/dio.dart';
import 'package:volticar_app/features/game/models/player_task_model.dart';
import 'package:volticar_app/core/constants/api_constants.dart';
import 'package:volticar_app/core/network/api_client.dart';
import 'package:volticar_app/core/exceptions/task_exceptions.dart';
import 'package:logger/logger.dart';

class TaskAcceptService {
  static final TaskAcceptService _instance = TaskAcceptService._internal();
  final ApiClient _apiClient = ApiClient();
  final Logger _logger = Logger();

  factory TaskAcceptService() {
    return _instance;
  }

  TaskAcceptService._internal();

  Future<PlayerTask> acceptTask(String taskId) async {
    try {
      _logger.i('Attempting to accept task: $taskId');
      final response = await _apiClient.post(
        ApiConstants.acceptTask,
        data: {'task_id': taskId},
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      // 檢查回應狀態
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 將後端回傳的資料轉換為PlayerTask模型
        return PlayerTask.fromJson(response.data);
      } else {
        throw Exception('接受任務失敗: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      // 特別處理 403 - 等級不夠的情況
      if (e.response?.statusCode == 403) {
        _logger.w('Task accept blocked due to insufficient level--2');
        _logger.w(e.response?.data);

        // 檢查回應是否包含等級限制訊息
        if (e.response?.data is Map<String, dynamic> &&
            e.response!.data.containsKey('detail')) {
          throw LevelRequirementException(e.response!.data['detail']);
        }

        return PlayerTask.fromJson(e.response?.data);
      }

      // 處理其他網路錯誤
      if (e.response?.statusCode == 400) {
        throw Exception('請求參數錯誤: ${e.response?.data?['message'] ?? '未知錯誤'}');
      } else if (e.response?.statusCode == 401) {
        throw Exception('未授權，請重新登入');
      } else if (e.response?.statusCode == 404) {
        throw Exception('任務不存在');
      } else if (e.response?.statusCode == 409) {
        throw Exception('任務已被接受或不可用');
      } else {
        throw Exception('網路錯誤: ${e.message}');
      }
    } catch (e) {
      throw Exception('未預期的錯誤: $e');
    }
  }

  // 獲取玩家任務的詳細資訊
  Map<String, dynamic> getPlayerTaskDetails(PlayerTask playerTask) {
    return {
      'taskInfo': {
        'id': playerTask.id,
        'taskId': playerTask.taskId,
        'userId': playerTask.userId,
      },
      'status': {
        'current': playerTask.status,
        'isAccepted': playerTask.isAccepted,
        'isCompleted': playerTask.isCompleted,
        'isFailed': playerTask.isFailed,
        'isAbandoned': playerTask.isAbandoned,
      },
      'dates': {
        'acceptedAt': playerTask.acceptedAt,
        'completedAt': playerTask.completedAt,
        'failedAt': playerTask.failedAt,
        'abandonedAt': playerTask.abandonedAt,
        'lastUpdatedAt': playerTask.lastUpdatedAt,
      },
      'progress': {
        'itemsDelivered': playerTask.progress.itemsDeliveredCount,
        'distanceTraveled': playerTask.progress.distanceTraveledForTask,
      },
      'gameSession': playerTask.linkedGameSessionId,
    };
  }

  // 檢查任務進度
  bool hasTaskProgress(PlayerTask playerTask) {
    return playerTask.progress.itemsDeliveredCount != null ||
        playerTask.progress.distanceTraveledForTask != null;
  }

  // 獲取任務進度百分比（需要根據任務需求計算）
  double calculateProgressPercentage(
    PlayerTask playerTask, {
    int? requiredItems,
    double? requiredDistance,
  }) {
    double progress = 0.0;
    int factors = 0;

    if (requiredItems != null &&
        playerTask.progress.itemsDeliveredCount != null) {
      progress += (playerTask.progress.itemsDeliveredCount! / requiredItems)
          .clamp(0.0, 1.0);
      factors++;
    }

    if (requiredDistance != null &&
        playerTask.progress.distanceTraveledForTask != null) {
      progress +=
          (playerTask.progress.distanceTraveledForTask! / requiredDistance)
              .clamp(0.0, 1.0);
      factors++;
    }

    return factors > 0 ? (progress / factors) * 100 : 0.0;
  }
}
