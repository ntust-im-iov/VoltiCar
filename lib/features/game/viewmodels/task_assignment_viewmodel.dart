import 'package:flutter/material.dart';
import 'package:volticar_app/features/game/models/task_model.dart';
import 'package:volticar_app/features/game/repositories/task_assignment_repositories.dart';

class TaskAssignmentViewModel extends ChangeNotifier {
  final TaskAssignmentRepositories _taskAssignmentRepositories;
  Task? _assignmentTask;

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

  Future<Task?> taskassignment(String type) async {
    // 狀態初始化
    _isTaskLoading = true;
    _isTaskSuccess = false;
    _isTaskError = null;
    notifyListeners();

    try {
      _updateTaskState(isLoading: true, error: null);

      final task = await _taskAssignmentRepositories.taskassignment(type);

      if (task != null) {
        _assignmentTask = task;
        _updateTaskState(isLoading: false, isSuccess: true);
      } else {
        _updateTaskState(
          isLoading: false,
          error: '擷取失敗',
          isSuccess: false,
        );
      }
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
    return _assignmentTask;
  }

  void _updateTaskState({bool? isLoading, String? error, bool? isSuccess}) {
    if (isLoading != null) _isTaskLoading = isLoading;
    if (error != null) {
      _isTaskError = error;
    }
    if (isSuccess != null) _isTaskSuccess = isSuccess;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
