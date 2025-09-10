import 'package:dio/dio.dart';
import 'package:volticar_app/features/game/models/player_task_model.dart';
import 'package:volticar_app/core/constants/api_constants.dart';
import 'package:volticar_app/core/network/api_client.dart';

class TaskStatusService {
  static final TaskStatusService _instance = TaskStatusService._internal();
  final ApiClient _apiClient = ApiClient();

  factory TaskStatusService() {
    return _instance;
  }

  TaskStatusService._internal();

  /// 獲取玩家任務狀態
  /// 
  /// [statusFilter] 可選的狀態篩選器，例如 "accepted", "completed", "failed", "abandoned" 等
  /// 如果不提供，將返回所有狀態的任務
  /// 
  /// 返回一個 [List<PlayerTask>]，包含符合狀態篩選條件的任務
  Future<List<PlayerTask>> getPlayerTasks({String? statusFilter}) async {
    try {
      // 構建查詢參數
      Map<String, dynamic> queryParams = {};
      if (statusFilter != null && statusFilter.isNotEmpty) {
        queryParams['status_filter'] = statusFilter;
      }

      final response = await _apiClient.get(
        ApiConstants.acceptTask,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      // 檢查回應狀態
      if (response.statusCode == 200) {
        // 將後端回傳的資料轉換為PlayerTask模型列表
        final List<dynamic> data = response.data;
        return data.map((json) => PlayerTask.fromJson(json)).toList();
      } else {
        throw Exception('獲取任務狀態失敗: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      // 處理網路錯誤
      if (e.response?.statusCode == 400) {
        throw Exception('請求參數錯誤: ${e.response?.data?['message'] ?? '未知錯誤'}');
      } else if (e.response?.statusCode == 401) {
        throw Exception('未授權，請重新登入');
      } else if (e.response?.statusCode == 404) {
        throw Exception('找不到任務資料');
      } else {
        throw Exception('網路錯誤: ${e.message}');
      }
    } catch (e) {
      throw Exception('未預期的錯誤: $e');
    }
  }

  /// 獲取特定狀態的玩家任務
  /// 
  /// 便捷方法，用於獲取特定狀態的任務
  Future<List<PlayerTask>> getAcceptedTasks() async {
    return getPlayerTasks(statusFilter: 'accepted');
  }

  Future<List<PlayerTask>> getCompletedTasks() async {
    return getPlayerTasks(statusFilter: 'completed');
  }

  Future<List<PlayerTask>> getFailedTasks() async {
    return getPlayerTasks(statusFilter: 'failed');
  }

  Future<List<PlayerTask>> getAbandonedTasks() async {
    return getPlayerTasks(statusFilter: 'abandoned');
  }

  /// 獲取任務詳細統計資訊
  Map<String, dynamic> getTasksStatistics(List<PlayerTask> tasks) {
    int acceptedCount = 0;
    int completedCount = 0;
    int failedCount = 0;
    int abandonedCount = 0;

    for (final task in tasks) {
      if (task.isAccepted) acceptedCount++;
      if (task.isCompleted) completedCount++;
      if (task.isFailed) failedCount++;
      if (task.isAbandoned) abandonedCount++;
    }

    return {
      'total': tasks.length,
      'accepted': acceptedCount,
      'completed': completedCount,
      'failed': failedCount,
      'abandoned': abandonedCount,
    };
  }
}
