import "package:dio/dio.dart";
import 'package:volticar_app/core/constants/api_constants.dart';
import 'package:volticar_app/core/network/api_client.dart';
import 'package:volticar_app/features/game/models/destination_choose_model.dart';
import 'package:logger/logger.dart';

class DestinationChooseService {
  static final DestinationChooseService _instance =
      DestinationChooseService._internal();
  final ApiClient _apiClient = ApiClient();
  final Logger _logger = Logger();

  factory DestinationChooseService() {
    return _instance;
  }

  DestinationChooseService._internal();

  Future<DestinationChooseModel> chooseDestination(String destinationId) async {
    try {
      _logger.i('Choosing destination with ID: $destinationId');
      final response = await _apiClient.put(
        ApiConstants.chooseDestination,
        data: {
          'destination_id': destinationId,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      _logger.i('Response status: ${response.statusCode}');
      _logger.i('Response data: ${response.data}');

      // 檢查重定向狀態碼
      if (response.statusCode == 307) {
        _logger.i(
            'Received temporary redirect (307), request was automatically redirected');
      }

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 307) {
        _logger.i('Destination chosen successfully.');

        // 檢查響應數據是否包含必要信息
        if (response.data != null) {
          try {
            final result = DestinationChooseModel.fromJson(response.data);
            _logger.i('Parsed destination: ${result.destinationId}');
            return result;
          } catch (parseError) {
            _logger.e('Failed to parse response data: $parseError');
            _logger.e('Response data was: ${response.data}');
            return DestinationChooseModel(
              destinationId: '',
              name: '',
              region: '',
            );
          }
        } else {
          _logger.w('Response data is null');
          return DestinationChooseModel(
            destinationId: '',
            name: '',
            region: '',
          );
        }
      } else {
        _logger.w(
            'Failed to choose destination. Status code: ${response.statusCode}');
        return DestinationChooseModel(
          destinationId: '',
          name: '',
          region: '',
        );
      }
    } catch (e) {
      _logger.e('Error choosing destination: $e');
      return DestinationChooseModel(
        destinationId: '',
        name: '',
        region: '',
      );
    }
  }
}
