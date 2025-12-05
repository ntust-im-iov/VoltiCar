import 'package:volticar_app/features/game/models/player_task_model.dart';
import 'package:volticar_app/features/game/services/task_status_service.dart';

class TaskStatusRepository {
  static final TaskStatusRepository _instance = TaskStatusRepository._internal();
  final TaskStatusService _service = TaskStatusService();

  factory TaskStatusRepository() {
    return _instance;
  }

  TaskStatusRepository._internal();

  /// 獲取玩家任務狀態
  /// 
  /// [statusFilter] 可選的狀態篩選器，例如 "accepted", "completed", "failed", "abandoned" 等
  /// 如果不提供，將返回所有狀態的任務
  Future<List<PlayerTask>> getPlayerTasks({String? statusFilter}) async {
    return await _service.getPlayerTasks(statusFilter: statusFilter);
  }

  /// 獲取玩家已接受的任務
  Future<List<PlayerTask>> getAcceptedTasks() async {
    return await _service.getAcceptedTasks();
  }

  /// 獲取玩家已完成的任務
  Future<List<PlayerTask>> getCompletedTasks() async {
    return await _service.getCompletedTasks();
  }

  /// 獲取玩家失敗的任務
  Future<List<PlayerTask>> getFailedTasks() async {
    return await _service.getFailedTasks();
  }

  /// 獲取玩家已放棄的任務
  Future<List<PlayerTask>> getAbandonedTasks() async {
    return await _service.getAbandonedTasks();
  }

  /// 獲取任務詳細統計資訊
  Map<String, dynamic> getTasksStatistics(List<PlayerTask> tasks) {
    return _service.getTasksStatistics(tasks);
  }
}
