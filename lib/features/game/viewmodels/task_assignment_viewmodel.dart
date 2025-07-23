import 'package:flutter/material.dart';
import 'package:volticar_app/features/game/models/task_model.dart';
import 'package:volticar_app/features/game/repositories/task_assignment_repositories.dart';

class TaskAssignmentViewModel extends ChangeNotifier {
  final TaskAssignmentRepositories _taskAssignmentRepositories;

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

  TaskAssignmentViewModel(
      {TaskAssignmentRepositories? taskAssignmentRepositories})
      : _taskAssignmentRepositories =
            taskAssignmentRepositories ?? TaskAssignmentRepositories();

  // 狀態 getter
  bool get isTaskLoading => _isTaskLoading;
  String? get isTaskError => _isTaskError;
  bool get isTaskSuccess => _isTaskSuccess;
  List<Task> get availableTasks => _assignmentTasks;
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

  void acceptTask() {
    if (_selectedTask == null) return;
    if (_acceptedTasks.any((task) => task.taskId == _selectedTask!.taskId))
      return;

    _acceptedTasks = [..._acceptedTasks, _selectedTask!];
    _assignmentTasks = _assignmentTasks
        .where((task) => task.taskId != _selectedTask!.taskId)
        .toList();
    _selectedTask = null;
    notifyListeners();
  }

  void abandonTask() {
    if (_selectedTask == null) return;
    final taskToAbandon = _selectedTask!;
    if (!_acceptedTasks.any((task) => task.taskId == taskToAbandon.taskId))
      return;

    _acceptedTasks = _acceptedTasks
        .where((task) => task.taskId != taskToAbandon.taskId)
        .toList();
    // For now, abandoning a task removes it permanently.
    // We could add it back to the available list if needed:
    _assignmentTasks = [..._assignmentTasks, taskToAbandon];
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
