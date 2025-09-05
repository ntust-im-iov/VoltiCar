import 'package:volticar_app/features/game/models/task_model.dart';
import 'package:volticar_app/features/game/services/task_assignment_services.dart';

class TaskAssignmentRepositories {
  final TaskAssignmentServices _taskAssignmentServices =
      TaskAssignmentServices();

  Future<List<Task>> taskassignment(String type) async {
    final tasks = await _taskAssignmentServices.taskassignment(type);
    return tasks;
  }
}
