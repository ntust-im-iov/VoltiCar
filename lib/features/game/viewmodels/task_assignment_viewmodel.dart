import 'package:flutter/material.dart';
import 'package:volticar_app/features/game/models/task_model.dart';
import 'package:volticar_app/features/game/models/player_task_model.dart';
import 'package:volticar_app/features/game/repositories/task_assignment_repositories.dart';
import 'package:volticar_app/features/game/viewmodels/task_accept_viewmodel.dart';

class TaskAssignmentViewModel extends ChangeNotifier {
  final TaskAssignmentRepositories _taskAssignmentRepositories;
  final TaskAcceptViewModel _taskAcceptViewModel;

  //任務切換相關物件
  bool _isMainTask = false;
  String _taskDescription = '';
  List<Task> _assignmentTasks = [];
  List<Task> _acceptedTasks = [];
  Task? _selectedTask;

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
  Task? get selectedTask => _selectedTask;
  bool get isMainTask => _isMainTask;
  String get taskDescription => _taskDescription;

  Future<void> fetchTasks(String type) async {
    _updateTaskState(isLoading: true, error: null, isSuccess: false);

    try {
      final tasks = await _taskAssignmentRepositories.taskassignment(type);
      _assignmentTasks = tasks;
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

  void abandonTask() {
    if (_selectedTask == null) return;
    final taskToAbandon = _selectedTask!;
    if (!_acceptedTasks.any((task) => task.taskId == taskToAbandon.taskId))
      return;

    // 從已接受任務中移除
    _acceptedTasks = _acceptedTasks
        .where((task) => task.taskId != taskToAbandon.taskId)
        .toList();
        
    // 檢查任務是否已經存在於可用任務列表中
    bool taskAlreadyInAssignments = _assignmentTasks
        .any((task) => task.taskId == taskToAbandon.taskId);
        
    // 只有當任務不在可用任務列表中時，才將其添加回去
    if (!taskAlreadyInAssignments) {
      _assignmentTasks = [..._assignmentTasks, taskToAbandon];
    }
    
    _selectedTask = null;
    notifyListeners();
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

  @override
  void dispose() {
    super.dispose();
  }
}
