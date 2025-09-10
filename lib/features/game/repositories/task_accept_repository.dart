import 'package:volticar_app/features/game/models/player_task_model.dart';
import 'package:volticar_app/features/game/services/task_accept_service.dart';

class TaskAcceptRepository {
  static final TaskAcceptRepository _instance = TaskAcceptRepository._internal();
  final TaskAcceptService _service = TaskAcceptService();

  factory TaskAcceptRepository() {
    return _instance;
  }

  TaskAcceptRepository._internal();

  /// 接受任務
  /// 
  /// [taskId] 要接受的任務ID
  /// 
  /// 回傳 [PlayerTask] 實體，包含任務接受後的狀態
  Future<PlayerTask> acceptTask(String taskId) async {
    return await _service.acceptTask(taskId);
  }

  /// 獲取玩家任務的詳細資訊
  /// 
  /// [playerTask] 要查詢詳細資訊的玩家任務
  /// 
  /// 回傳一個包含任務詳細資訊的Map
  Map<String, dynamic> getPlayerTaskDetails(PlayerTask playerTask) {
    return _service.getPlayerTaskDetails(playerTask);
  }

  /// 檢查任務是否有進度
  /// 
  /// [playerTask] 要檢查的玩家任務
  /// 
  /// 回傳一個布林值，表示任務是否有進度
  bool hasTaskProgress(PlayerTask playerTask) {
    return _service.hasTaskProgress(playerTask);
  }

  /// 計算任務進度百分比
  /// 
  /// [playerTask] 要計算進度的玩家任務
  /// [requiredItems] 任務需要的物品數量
  /// [requiredDistance] 任務需要的距離
  /// 
  /// 回傳一個雙精度浮點數，表示任務完成的百分比
  double calculateProgressPercentage(
    PlayerTask playerTask, {
    int? requiredItems,
    double? requiredDistance,
  }) {
    return _service.calculateProgressPercentage(
      playerTask,
      requiredItems: requiredItems,
      requiredDistance: requiredDistance,
    );
  }

  /// 檢查玩家是否可以接受任務
  /// 
  /// [userId] 玩家ID
  /// [taskId] 任務ID
  /// 
  /// 回傳一個布林值，表示玩家是否可以接受任務
  Future<bool> canAcceptTask(String userId, String taskId) async {
    try {
      // 這裡可以添加檢查邏輯，例如：
      // 1. 玩家是否已經有相同的任務
      // 2. 玩家是否符合接受任務的條件
      // 3. 任務是否可用
      // 若需要，可以調用API或本地存儲來檢查
      
      // 簡單示例實現，實際應依需求修改
      return true;
    } catch (e) {
      throw Exception('檢查任務可接受狀態時發生錯誤: $e');
    }
  }

  /// 獲取玩家正在進行的任務列表
  /// 
  /// [userId] 玩家ID
  /// 
  /// 回傳玩家正在進行的任務列表
  Future<List<PlayerTask>> getActivePlayerTasks(String userId) async {
    try {
      // 這裡應該調用API或本地存儲來獲取玩家正在進行的任務
      // 示例僅返回空列表，實際應替換為真實實現
      return [];
    } catch (e) {
      throw Exception('獲取玩家進行中任務失敗: $e');
    }
  }

  /// 獲取玩家已完成的任務列表
  /// 
  /// [userId] 玩家ID
  /// 
  /// 回傳玩家已完成的任務列表
  Future<List<PlayerTask>> getCompletedPlayerTasks(String userId) async {
    try {
      // 這裡應該調用API或本地存儲來獲取玩家已完成的任務
      // 示例僅返回空列表，實際應替換為真實實現
      return [];
    } catch (e) {
      throw Exception('獲取玩家已完成任務失敗: $e');
    }
  }

  /// 獲取任務歷史
  /// 
  /// [userId] 玩家ID
  /// [limit] 限制返回的記錄數
  /// [offset] 分頁偏移量
  /// 
  /// 回傳玩家的任務歷史記錄
  Future<List<PlayerTask>> getTaskHistory(
    String userId, {
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      // 這裡應該調用API或本地存儲來獲取玩家的任務歷史
      // 示例僅返回空列表，實際應替換為真實實現
      return [];
    } catch (e) {
      throw Exception('獲取任務歷史失敗: $e');
    }
  }
}
