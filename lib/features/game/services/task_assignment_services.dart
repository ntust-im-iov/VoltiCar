import 'package:dio/dio.dart';
import 'package:volticar_app/features/game/models/task_model.dart';
import 'package:volticar_app/core/constants/api_constants.dart';
import 'package:volticar_app/core/network/api_client.dart';

class TaskAssignmentServices {
  static final TaskAssignmentServices _instance =
      TaskAssignmentServices._internal();
  final ApiClient _apiClient = ApiClient();

  factory TaskAssignmentServices() {
    return _instance;
  }

  TaskAssignmentServices._internal();

  Future<List<Task>> taskassignment(String type) async {
    final response = await _apiClient.get(
      ApiConstants.taskDefinitions,
      queryParameters: {
        'type': type,
      },
      options: Options(
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    if (response.data != null) {
      final List<dynamic> taskData = response.data;
      return taskData.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }
}
