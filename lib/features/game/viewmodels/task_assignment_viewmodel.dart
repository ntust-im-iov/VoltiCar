import 'package:flutter/material.dart';
import 'package:volticar_app/features/game/models/player_task_model.dart';
import 'package:volticar_app/features/game/models/task_model.dart';
import 'package:volticar_app/features/game/repositories/task_assignment_repositories.dart';
import 'package:volticar_app/features/game/repositories/task_status_repository.dart';
import 'package:volticar_app/features/game/services/task_abandon_service.dart';
import 'package:volticar_app/features/game/viewmodels/task_accept_viewmodel.dart';
import 'package:volticar_app/core/exceptions/task_exceptions.dart';

class TaskAssignmentViewModel extends ChangeNotifier {
  final TaskAssignmentRepositories _taskAssignmentRepositories;
  final TaskAcceptViewModel _taskAcceptViewModel;
  final TaskAbandonService _taskAbandonService = TaskAbandonService();
  final TaskStatusRepository _taskStatusRepository = TaskStatusRepository();

  //任務切換相關物件
  bool _isMainTask = false;
  String _taskDescription = '';
  List<Task> _assignmentTasks = [];
  List<Task> _acceptedTasks = [];
  Task? _selectedTask;
  
  // 存儲已接受任務的 PlayerTask 對象
  List<PlayerTask> _playerTasks = [];
  
  // 存儲已放棄任務的ID列表，用於從可用任務列表中過濾掉已放棄的任務
  Set<String> _abandonedTaskIds = {};

  // 任務指派相關狀態
  bool _isTaskLoading = false;
  String? _fetchTasksError; // 載入任務列表的錯誤
  String? _acceptTaskError; // 接受任務的錯誤
  bool _isTaskSuccess = false;

  TaskAssignmentViewModel({
    TaskAssignmentRepositories? taskAssignmentRepositories,
    TaskAcceptViewModel? taskAcceptViewModel,
  })  : _taskAssignmentRepositories =
            taskAssignmentRepositories ?? TaskAssignmentRepositories(),
        _taskAcceptViewModel = taskAcceptViewModel ?? TaskAcceptViewModel();

  // 狀態 getter
  bool get isTaskLoading => _isTaskLoading;
  String? get isTaskError => _fetchTasksError; // 只有載入任務的錯誤會影響整個畫面
  String? get acceptTaskError => _acceptTaskError; // 接受任務的錯誤用於 SnackBar
  bool get isTaskSuccess => _isTaskSuccess;
  
  // 過濾availableTasks，確保已接受的任務和已放棄的任務不會顯示在可用任務列表中
  List<Task> get availableTasks => _assignmentTasks
      .where((task) => 
        // 排除已接受的任務
        !_acceptedTasks.any((accepted) => accepted.taskId == task.taskId) &&
        // 排除已放棄的任務
        !_abandonedTaskIds.contains(task.taskId)
      )
      .toList();
  
  List<Task> get acceptedTasks => _acceptedTasks;
  List<PlayerTask> get playerTasks => List.unmodifiable(_playerTasks);
  Task? get selectedTask => _selectedTask;
  bool get isMainTask => _isMainTask;
  String get taskDescription => _taskDescription;

  Future<void> fetchTasks(String mode) async {
    _updateTaskState(isLoading: true, fetchError: null, isSuccess: false);

    try {
      final tasks = await _taskAssignmentRepositories.taskassignment(mode);
      _assignmentTasks = tasks;
      
      // 加載已接受的任務
      await _loadAcceptedTasks();
      
      _updateTaskState(isLoading: false, isSuccess: true);
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.split('Exception:').last.trim();
      }
      _updateTaskState(
        isLoading: false,
        fetchError: errorMessage,
        isSuccess: false,
      );
    }
  }
  
  // 加載已接受和已放棄的任務
  Future<void> _loadAcceptedTasks() async {
    try {
      // 使用TaskStatusRepository獲取玩家已接受的任務
      final activeTasks = await _taskStatusRepository.getAcceptedTasks();
      
      // 清空現有數據
      _playerTasks = [];
      
      // 先保留現有的已接受任務，以防切換類型後找不到對應的任務
      final existingAcceptedTasks = Map<String, Task>.fromIterable(
        _acceptedTasks,
        key: (task) => task.taskId,
        value: (task) => task
      );
      
      _acceptedTasks = [];
      
      // 為每個PlayerTask創建對應的Task對象
      for (final playerTask in activeTasks) {
        // 先檢查現有的已接受任務中是否有對應的Task
        Task matchingTask;
        if (existingAcceptedTasks.containsKey(playerTask.taskId)) {
          matchingTask = existingAcceptedTasks[playerTask.taskId]!;
        } else {
          // 尋找當前載入的可用任務中是否有對應的Task
          try {
            matchingTask = _assignmentTasks.firstWhere(
              (task) => task.taskId == playerTask.taskId
            );
          } catch (e) {
            // 從任務ID中獲取任務類型和名稱
            String taskType = 'unknown';
            String taskTitle = '未知任務';
            
            // 從taskId中嘗試判斷任務類型
            if (playerTask.taskId.toLowerCase().contains('daily')) {
              taskType = 'daily';
              taskTitle = '日常任務';
            } else if (playerTask.taskId.toLowerCase().contains('story')) {
              taskType = 'story';
              taskTitle = '主線任務';
            } else {
              // 如果無法判斷，根據當前顯示模式推測
              taskType = _isMainTask ? 'daily' : 'story';
              taskTitle = _isMainTask ? '日常任務' : '主線任務';
            }
            
            // 創建臨時Task對象
            matchingTask = Task(
              taskId: playerTask.taskId,
              title: taskTitle,
              description: '此任務的詳細信息將在下次刷新時更新',
              type: taskType,
              mode: taskType, // 使用同樣的值填充mode字段
              requirements: {},
              rewards: {},
              isRepeatable: true,
              isActive: true,
              prerequisiteTaskIds: [],
            );
          }
        }
        
        // 將任務添加到列表中
        _acceptedTasks.add(matchingTask);
        _playerTasks.add(playerTask);
      }
      
      // 加載已放棄的任務，僅用於過濾可用任務列表
      await _loadAbandonedTasks();
      
    } catch (e) {
      print('加載已接受任務失敗: $e');
      // 這裡我們不拋出異常，而是靜默處理失敗
      // 用戶仍然可以看到可用任務
    }
  }
  
  // 加載已放棄的任務
  Future<void> _loadAbandonedTasks() async {
    try {
      // 使用TaskStatusRepository獲取玩家已放棄的任務
      final abandonedTasks = await _taskStatusRepository.getAbandonedTasks();
      
      // 清空現有已放棄任務ID列表
      _abandonedTaskIds.clear();
      
      // 將已放棄任務的taskId添加到列表中
      for (final playerTask in abandonedTasks) {
        _abandonedTaskIds.add(playerTask.taskId);
      }
      
    } catch (e) {
      print('加載已放棄任務失敗: $e');
      // 這裡我們不拋出異常，而是靜默處理失敗
    }
  }

  void selectTask(Task? task) {
    if (_selectedTask?.taskId == task?.taskId) {
      _selectedTask = null;
      _taskDescription = "";
    } else {
      _selectedTask = task;
      _taskDescription = task?.description ?? '無任務描述';
    }
    notifyListeners();
  }

  Future<void> acceptTask() async {
    if (_selectedTask == null) return;
    if (_acceptedTasks.any((task) => task.taskId == _selectedTask!.taskId))
      return;

    _updateTaskState(isLoading: true);
    _clearAcceptTaskError(); // 清除之前的接受任務錯誤
    
    try {
      // 使用TaskAcceptViewModel的acceptTask方法
      final success = await _taskAcceptViewModel.acceptTask(_selectedTask!.taskId);
      
      if (success) {
        // 如果成功，更新本地狀態
        final taskToAccept = _selectedTask!;
        _acceptedTasks = [..._acceptedTasks, taskToAccept];
        
        // 從TaskAcceptViewModel中獲取當前任務（剛剛接受的任務）
        final currentTask = _taskAcceptViewModel.currentTask;
        if (currentTask != null) {
          // 存儲PlayerTask對象
          _playerTasks = [..._playerTasks, currentTask];
        }
        
        // 不需要在這裡從_assignmentTasks中移除，因為availableTasks getter已經處理了過濾邏輯
        // 但為了保持資料一致性，仍然執行這一步
        _assignmentTasks = _assignmentTasks
            .where((task) => task.taskId != taskToAccept.taskId)
            .toList();
            
        _selectedTask = null;
        _updateTaskState(isLoading: false, isSuccess: true);
      } else {
        // 如果失敗，顯示錯誤信息
        // 特別處理等級限制錯誤訊息，確保完整顯示後端回傳的訊息
        String errorMessage = _taskAcceptViewModel.errorMessage ?? "接受任務失敗";
        _updateTaskState(
          isLoading: false, 
          acceptError: errorMessage, 
          isSuccess: false
        );
      }
    } on LevelRequirementException catch (e) {
      // 直接處理等級限制異常，確保訊息完整傳遞
      _updateTaskState(
        isLoading: false,
        acceptError: e.message,
        isSuccess: false,
      );
    } catch (e) {
      _updateTaskState(
        isLoading: false,
        acceptError: e.toString(),
        isSuccess: false,
      );
    }
  }

  Future<void> abandonTask() async {
    if (_selectedTask == null) return;
    final taskToAbandon = _selectedTask!;
    if (!_acceptedTasks.any((task) => task.taskId == taskToAbandon.taskId))
      return;
    
    // 檢查是否為故事模式任務，故事模式任務不可放棄
    if (!canAbandonTask(taskToAbandon)) {
      _updateTaskState(
        isLoading: false, 
        acceptError: '故事模式任務不可放棄', 
        isSuccess: false
      );
      return;
    }
    
    _updateTaskState(isLoading: true);
    
    try {
      // 查找對應的PlayerTask對象
      final playerTask = _playerTasks.firstWhere(
        (pt) => pt.taskId == taskToAbandon.taskId,
        orElse: () => throw Exception('無法找到對應的PlayerTask對象')
      );
      
      // 呼叫放棄任務服務，使用playerTaskId
      await _taskAbandonService.abandonTask(playerTask.playerTaskId);
      
      // 從已接受任務中移除
      _acceptedTasks = _acceptedTasks
          .where((task) => task.taskId != taskToAbandon.taskId)
          .toList();
      
      // 從PlayerTasks列表中移除
      _playerTasks = _playerTasks
          .where((pt) => pt.taskId != taskToAbandon.taskId)
          .toList();
      
      // 將放棄的任務ID添加到已放棄任務集合中
      _abandonedTaskIds.add(taskToAbandon.taskId);
      
      _selectedTask = null;
      _updateTaskState(isLoading: false, isSuccess: true);
      
      // 清除之前的錯誤
      _clearAcceptTaskError();
      
      // 不需要將任務添加回可用任務列表，因為放棄的任務不會回到委託任務中
      
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.split('Exception:').last.trim();
      }
      _updateTaskState(
        isLoading: false,
        acceptError: errorMessage,
        isSuccess: false,
      );
    }
  }

  void _updateTaskState({
    bool? isLoading, 
    String? fetchError, 
    String? acceptError, 
    bool? isSuccess
  }) {
    _isTaskLoading = isLoading ?? _isTaskLoading;
    if (fetchError != null) _fetchTasksError = fetchError;
    if (acceptError != null) _acceptTaskError = acceptError;
    _isTaskSuccess = isSuccess ?? _isTaskSuccess;
    notifyListeners();
  }

  void _clearAcceptTaskError() {
    _acceptTaskError = null;
  }

  void toggleTaskType() {
    _isMainTask = !_isMainTask;
    _selectedTask = null;
    
    // 不需要清除已接受任務，這樣切換類型時已接受任務仍然會顯示
    // 在fetchTasks中會重新加載可用任務，並保留已接受任務
    
    notifyListeners(); // 通知 UI 更新
  }
  
  // 根據Task查找對應的PlayerTask
  PlayerTask? getPlayerTaskForTask(Task task) {
    try {
      return _playerTasks.firstWhere((pt) => pt.taskId == task.taskId);
    } catch (e) {
      return null;
    }
  }
  
  // 檢查任務是否可以放棄
  // 故事模式（mode:story）的任務不可放棄
  bool canAbandonTask(Task task) {
    return task.mode.toLowerCase() != 'story';
  }
  
  // 手動刷新任務狀態
  Future<void> refreshTaskStatus() async {
    _updateTaskState(isLoading: true);
    try {
      await _loadAcceptedTasks();
      _updateTaskState(isLoading: false, isSuccess: true);
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.split('Exception:').last.trim();
      }
      _updateTaskState(
        isLoading: false,
        fetchError: errorMessage,
        isSuccess: false,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
