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

  Future<List<Task>> taskassignment(String mode) async {
    try {
      print('Fetching tasks with mode: $mode');
      print('Request URL: ${ApiConstants.baseUrl}${ApiConstants.taskDefinitions}');
      
      final response = await _apiClient.get(
        ApiConstants.taskDefinitions,
        queryParameters: {
          'mode': mode,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data type: ${response.data.runtimeType}');
      print('Response data: ${response.data}');

      if (response.data != null) {
        if (response.data is List) {
          final List<dynamic> taskData = response.data;
          print('Found ${taskData.length} tasks');
          
          final List<Task> tasks = [];
          
          for (int i = 0; i < taskData.length; i++) {
            try {
              final json = taskData[i];
              if (json is Map<String, dynamic>) {
                print('Parsing task $i: ${json['task_id']} - ${json['title']}');
                tasks.add(Task.fromJson(json));
              } else {
                print('Skipping task $i: not a Map');
              }
            } catch (e) {
              print('Error parsing task $i: $e');
              print('Task data: ${taskData[i]}');
              // 跳過無法解析的任務，繼續處理其他任務
              continue;
            }
          }
          
          print('Successfully parsed ${tasks.length} tasks');
          return tasks;
        } else {
          throw Exception('Invalid response format: expected List but got ${response.data.runtimeType}');
        }
      } else {
        throw Exception('No data received from server');
      }
    } catch (e) {
      print('TaskAssignmentServices error: $e');
      if (e is DioException) {
        print('DioException details:');
        print('Type: ${e.type}');
        print('Message: ${e.message}');
        if (e.response != null) {
          print('Status code: ${e.response!.statusCode}');
          print('Response data: ${e.response!.data}');
          throw Exception('Server error (${e.response!.statusCode}): ${e.response!.data}');
        } else {
          throw Exception('Network error: ${e.message}');
        }
      } else {
        throw Exception('Failed to load tasks: $e');
      }
    }
  }
}
