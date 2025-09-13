import "package:dio/dio.dart";
import 'package:volticar_app/core/constants/api_constants.dart';
import 'package:volticar_app/core/network/api_client.dart';
import 'package:volticar_app/features/game/models/destination_model.dart';
import 'package:logger/logger.dart';

class DestinationFetchService {
  static final DestinationFetchService _instance =
      DestinationFetchService._internal();
  final ApiClient _apiClient = ApiClient();
  final Logger _logger = Logger();

  factory DestinationFetchService() {
    return _instance;
  }

  DestinationFetchService._internal();

  Future<List<Destination>> fetchDestinations() async {
    try {
      _logger.i('Fetching destinations from API...');
      final response = await _apiClient.get(
        ApiConstants.fetchDestinations,
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      _logger.i('Response status: ${response.statusCode}');
      _logger.i('Response data type: ${response.data.runtimeType}');
      _logger.i('Response data: ${response.data}');

      if (response.data != null) {
        if (response.data is List) {
          final List<dynamic> destinationData = response.data;
          _logger.i('Found ${destinationData.length} destinations');

          final List<Destination> destinations = [];

          for (int i = 0; i < destinationData.length; i++) {
            try {
              final json = destinationData[i];
              if (json is Map<String, dynamic>) {
                _logger.i(
                    'Parsing destination $i: ${json['destination_id']} - ${json['name']}');
                destinations.add(Destination.fromJson(json));
              } else {
                _logger.w('Skipping destination $i: not a Map');
              }
            } catch (e) {
              _logger.e('Error parsing destination $i: $e');
              _logger.e('Destination data: ${destinationData[i]}');
              // 跳過無法解析的目的地，繼續處理其他目的地
              continue;
            }
          }

          return destinations;
        } else {
          throw Exception('Unexpected response format: not a list');
        }
      } else {
        throw Exception('No data received from the server');
      }
    } catch (e) {
      _logger.e('Failed to fetch destinations: $e');
      rethrow;
    }
  }
}
