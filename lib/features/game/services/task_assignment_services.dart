import 'package:dio/dio.dart';
import 'package:volticar_app/features/game/models/task_model.dart';
import 'package:volticar_app/core/constants/api_constants.dart';
import 'package:volticar_app/core/network/api_client.dart';

class TaskAssignmentServices {
  static final TaskAssignmentServices _instance = TaskAssignmentServices();
  final ApiClient _apiClient = ApiClient();

  factory TaskAssignmentServices() {
    return _instance;
  }

  TaskAssignmentServices._internal();

  Future<Task?> taskassignment(String type) async {
    final response = await _apiClient.post(
      ApiConstants.taskDefinitions,
      data: {
        'type': type,
      },
      options: Options(
        contentType: 'application/x-www-form-urlencoded',
        headers: {
          'Accept': 'application/json',
        },
      ),
    );
  }
}
