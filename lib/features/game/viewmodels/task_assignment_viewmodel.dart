import 'package:flutter/material.dart';
import 'package:volticar_app/features/game/models/player_task_model.dart';
import 'package:volticar_app/features/game/models/task_model.dart';
import 'package:volticar_app/features/game/repositories/task_assignment_repositories.dart';
import 'package:volticar_app/features/game/repositories/task_status_repository.dart';
import 'package:volticar_app/features/game/services/task_abandon_service.dart';
import 'package:volticar_app/features/game/viewmodels/task_accept_viewmodel.dart';

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

  // 任務指派相關狀態
  bool _isTaskLoading = false;
  String? _isTaskError;
  bool _isTaskSuccess = false;

  TaskAssignmentViewModel({
    TaskAssignmentRepositories? taskAssignmentRepositories,
    TaskAcceptViewModel? taskAcceptViewModel,
  })  : _taskAssignmentRepositories =
            taskAssignmentRepositories ?? TaskAssignmentRepositories(),
        _taskAcceptViewModel = taskAcceptViewModel ?? TaskAcceptViewModel();

  // 狀態 getter
  bool get isTaskLoading => _isTaskLoading;
  String? get isTaskError => _isTaskError;
  bool get isTaskSuccess => _isTaskSuccess;
  
  // 過濾availableTasks，確保已接受的任務不會顯示在可用任務列表中
  List<Task> get availableTasks => _assignmentTasks
      .where((task) => !_acceptedTasks.any((accepted) => accepted.taskId == task.taskId))
      .toList();
  
  List<Task> get acceptedTasks => _acceptedTasks;
  List<PlayerTask> get playerTasks => List.unmodifiable(_playerTasks);
  Task? get selectedTask => _selectedTask;
  bool get isMainTask => _isMainTask;
  String get taskDescription => _taskDescription;

  Future<void> fetchTasks(String type) async {
    _updateTaskState(isLoading: true, error: null, isSuccess: false);

    try {
      final tasks = await _taskAssignmentRepositories.taskassignment(type);
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
        error: errorMessage,
        isSuccess: false,
      );
    }
  }
  
  // 加載已接受的任務
  Future<void> _loadAcceptedTasks() async {
    try {
      // 使用TaskStatusRepository獲取玩家已接受的任務
      final activeTasks = await _taskStatusRepository.getAcceptedTasks();
      
      // 清空現有數據
      _acceptedTasks = [];
      _playerTasks = [];
      
      // 為每個PlayerTask創建對應的Task對象
      for (final playerTask in activeTasks) {
        // 尋找對應的Task
        final matchingTask = _assignmentTasks.firstWhere(
          (task) => task.taskId == playerTask.taskId,
          orElse: () => Task(
            taskId: playerTask.taskId,
            title: '任務 ${playerTask.taskId}',  // 簡單的標題
            description: '此任務的詳細信息無法顯示',
            type: 'unknown',
            requirements: {},
            rewards: {},
            isRepeatable: false,
            isActive: true,
            prerequisiteTaskIds: [],
          ),
        );
        
        // 將任務添加到列表中
        _acceptedTasks.add(matchingTask);
        _playerTasks.add(playerTask);
      }
    } catch (e) {
      print('加載已接受任務失敗: $e');
      // 這裡我們不拋出異常，而是靜默處理失敗
      // 用戶仍然可以看到可用任務
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

    _updateTaskState(isLoading: true, error: null);
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
        _updateTaskState(
          isLoading: false, 
          error: _taskAcceptViewModel.errorMessage ?? "接受任務失敗", 
          isSuccess: false
        );
      }
    } catch (e) {
      _updateTaskState(
        isLoading: false,
        error: e.toString(),
        isSuccess: false,
      );
    }
  }

  Future<void> abandonTask() async {
    if (_selectedTask == null) return;
    final taskToAbandon = _selectedTask!;
    if (!_acceptedTasks.any((task) => task.taskId == taskToAbandon.taskId))
      return;
    
    _updateTaskState(isLoading: true, error: null);
    
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
      
      _selectedTask = null;
      _updateTaskState(isLoading: false, isSuccess: true);
      
      // 將成功訊息設置為可以被UI讀取的值
      _isTaskError = null;  // 清除之前的錯誤
      
      // 不需要將任務添加回可用任務列表，因為放棄的任務不會回到委託任務中
      
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.split('Exception:').last.trim();
      }
      _updateTaskState(
        isLoading: false,
        error: errorMessage,
        isSuccess: false,
      );
    }
  }

  void _updateTaskState({bool? isLoading, String? error, bool? isSuccess}) {
    _isTaskLoading = isLoading ?? _isTaskLoading;
    _isTaskError = error;
    _isTaskSuccess = isSuccess ?? _isTaskSuccess;
    notifyListeners();
  }

  void toggleTaskType() {
    _isMainTask = !_isMainTask;
    _selectedTask = null;
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
  
  // 手動刷新任務狀態
  Future<void> refreshTaskStatus() async {
    _updateTaskState(isLoading: true, error: null);
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
        error: errorMessage,
        isSuccess: false,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
