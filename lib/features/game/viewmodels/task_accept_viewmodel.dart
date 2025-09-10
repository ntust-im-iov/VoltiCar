import 'package:flutter/foundation.dart';
import 'package:volticar_app/features/game/models/player_task_model.dart';
import 'package:volticar_app/features/game/repositories/task_accept_repository.dart';

/// TaskAcceptViewModel 負責處理任務接受相關的業務邏輯
/// 
/// 這個ViewModel負責協調UI與資料層之間的互動，包含任務接受、
/// 任務進度追蹤，並提供相關狀態給UI層
class TaskAcceptViewModel extends ChangeNotifier {
  final TaskAcceptRepository _repository = TaskAcceptRepository();
  
  // 狀態變數
  bool _isLoading = false;
  String? _errorMessage;
  PlayerTask? _currentTask;
  List<PlayerTask> _activeTasks = [];
  List<PlayerTask> _completedTasks = [];
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PlayerTask? get currentTask => _currentTask;
  List<PlayerTask> get activeTasks => List.unmodifiable(_activeTasks);
  List<PlayerTask> get completedTasks => List.unmodifiable(_completedTasks);
  
  // 進度相關的計算屬性
  bool get hasCurrentTaskProgress => 
      _currentTask != null && _repository.hasTaskProgress(_currentTask!);
  
  double get currentTaskProgress {
    if (_currentTask == null) return 0.0;
    
    // 這裡的參數需要根據任務要求來設定
    // 例如：若任務要求運送5個物品，則requiredItems為5
    return _repository.calculateProgressPercentage(
      _currentTask!,
      requiredItems: 5,  // 這裡應該由任務詳情提供
      requiredDistance: 1000.0,  // 這裡應該由任務詳情提供，單位可能是公尺
    );
  }
  
  /// 接受新任務
  /// 
  /// [taskId] 要接受的任務ID
  /// 
  /// 回傳一個布林值，表示操作是否成功
  Future<bool> acceptTask(String taskId) async {
    _setLoading(true);
    _clearError();
    
    try {
      // 檢查是否可以接受任務
      final String userId = await _getCurrentUserId(); // 獲取當前用戶ID的方法，需要實現
      final bool canAccept = await _repository.canAcceptTask(userId, taskId);
      
      if (!canAccept) {
        _setError("您目前無法接受此任務");
        return false;
      }
      
      // 接受任務
      final PlayerTask playerTask = await _repository.acceptTask(taskId);
      _currentTask = playerTask;
      _activeTasks.add(playerTask);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError("接受任務失敗: ${e.toString()}");
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 獲取玩家正在進行的任務
  Future<void> loadActiveTasks() async {
    _setLoading(true);
    _clearError();
    
    try {
      final String userId = await _getCurrentUserId();
      final List<PlayerTask> tasks = await _repository.getActivePlayerTasks(userId);
      _activeTasks = tasks;
      notifyListeners();
    } catch (e) {
      _setError("載入進行中任務失敗: ${e.toString()}");
    } finally {
      _setLoading(false);
    }
  }
  
  /// 獲取玩家已完成的任務
  Future<void> loadCompletedTasks() async {
    _setLoading(true);
    _clearError();
    
    try {
      final String userId = await _getCurrentUserId();
      final List<PlayerTask> tasks = await _repository.getCompletedPlayerTasks(userId);
      _completedTasks = tasks;
      notifyListeners();
    } catch (e) {
      _setError("載入已完成任務失敗: ${e.toString()}");
    } finally {
      _setLoading(false);
    }
  }
  
  /// 獲取特定任務的詳細資訊
  /// 
  /// [playerTaskId] 要獲取詳情的玩家任務ID
  /// 
  /// 回傳任務詳情的Map，如果找不到則為null
  Future<Map<String, dynamic>?> getTaskDetails(String playerTaskId) async {
    _setLoading(true);
    _clearError();
    
    try {
      // 先檢查當前任務
      if (_currentTask?.playerTaskId == playerTaskId) {
        return _repository.getPlayerTaskDetails(_currentTask!);
      }
      
      // 然後檢查活躍任務列表
      final PlayerTask task = _activeTasks.firstWhere(
        (t) => t.playerTaskId == playerTaskId,
        orElse: () => _completedTasks.firstWhere(
          (t) => t.playerTaskId == playerTaskId,
          orElse: () => throw Exception("找不到指定的任務"),
        ),
      );
      
      return _repository.getPlayerTaskDetails(task);
    } catch (e) {
      _setError("獲取任務詳情失敗: ${e.toString()}");
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 設置當前選中的任務
  /// 
  /// [playerTaskId] 要設置為當前任務的ID
  void setCurrentTask(String playerTaskId) {
    try {
      // 先檢查活躍任務列表
      _currentTask = _activeTasks.firstWhere(
        (t) => t.playerTaskId == playerTaskId,
        orElse: () => _completedTasks.firstWhere(
          (t) => t.playerTaskId == playerTaskId,
          orElse: () => throw Exception("找不到指定的任務"),
        ),
      );
      notifyListeners();
    } catch (e) {
      _setError("設置當前任務失敗: ${e.toString()}");
    }
  }
  
  /// 清除當前選中的任務
  void clearCurrentTask() {
    _currentTask = null;
    notifyListeners();
  }
  
  /// 重置錯誤訊息
  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // 私有輔助方法
  
  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }
  
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
  }
  
  /// 獲取當前登入用戶的ID
  /// 
  /// 這個方法應該從身份驗證服務或本地存儲中獲取用戶ID
  /// 需要根據應用程式的身份驗證機制來實現
  Future<String> _getCurrentUserId() async {
    // 這裡應該實現獲取當前用戶ID的邏輯
    // 例如：從AuthService或本地存儲獲取
    return "current_user_id"; // 這是一個佔位符，實際應用中需要替換
  }
  
  // 注意：以下是任務需求獲取的建議實現，可根據實際需求添加
  //
  // /// 根據任務類型獲取所需的物品數量
  // int _getRequiredItemsForTask(PlayerTask task) {
  //   // 這裡應該根據任務類型或ID來決定所需物品數量
  //   // 可以從task中的信息提取，或者通過其他方式獲取
  //   return 5; // 示例值，實際應用中需要替換
  // }
  // 
  // /// 根據任務類型獲取所需的行駛距離
  // double _getRequiredDistanceForTask(PlayerTask task) {
  //   // 這裡應該根據任務類型或ID來決定所需距離
  //   // 可以從task中的信息提取，或者通過其他方式獲取
  //   return 1000.0; // 示例值，實際應用中需要替換，單位可能是公尺
  // }
}
