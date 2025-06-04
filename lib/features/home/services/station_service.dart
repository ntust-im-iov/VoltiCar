import 'package:volticar_app/core/network/api_client.dart';
import 'package:volticar_app/core/constants/api_constants.dart';
import '../models/charging_station_model.dart';
import 'package:logger/logger.dart';

// 您可能需要定義一個 BoundingBox 類別，或者直接傳遞四個座標參數
// class BoundingBox {
//   final double minLat, minLon, maxLat, maxLon;
//   BoundingBox({required this.minLat, required this.minLon, required this.maxLat, required this.maxLon});
// }

class StationService {
  final ApiClient _apiClient = ApiClient();
  final Logger _logger = Logger();

  Future<List<ChargingStation>> getStationsOverview({
    double? minLat,
    double? minLon,
    double? maxLat,
    double? maxLon,
    int skip = 0,
    int limit = 200, // API 預設是 1000，這裡可以根據需要調整，例如先載入少量
  }) async {
    final Map<String, dynamic> queryParams = {
      'skip': skip,
      'limit': limit,
    };
    if (minLat != null) queryParams['min_lat'] = minLat;
    if (minLon != null) queryParams['min_lon'] = minLon;
    if (maxLat != null) queryParams['max_lat'] = maxLat;
    if (maxLon != null) queryParams['max_lon'] = maxLon;

    try {
      _logger.i('Fetching stations overview with params: $queryParams');
      // 假設 ApiConstants.stationsOverview 的值是 '/stations/overview'
      // 您需要在您的 api_constants.dart 檔案中定義它
      final response = await _apiClient.get(
        ApiConstants.stationsOverview, // 請確保 ApiConstants.stationsOverview 已定義
        queryParameters: queryParams,
      );

      _logger.d('Stations overview response status: ${response.statusCode}');
      // _logger.d('Stations overview response data: ${response.data}');

      if (response.statusCode == 200 && response.data is List) {
        List<dynamic> responseData = response.data as List<dynamic>;
        if (responseData.isEmpty) {
          _logger.i('No stations found for the given criteria.');
          return [];
        }
        return responseData
            .map((json) => ChargingStation.fromOverviewJson(json as Map<String, dynamic>))
            .toList();
      } else {
        _logger.w('Failed to load stations overview or invalid response format. Status: ${response.statusCode}');
        return []; // 或拋出異常
      }
    } catch (e, stackTrace) {
      _logger.e('Error fetching stations overview', error: e, stackTrace: stackTrace);
      return []; // 或拋出異常
    }
  }

  // TODO: 實現 getStationById 方法
  // Future<ChargingStation?> getStationById(String stationId) async { ... }

  // TODO: 實現 getStationsByCity 方法
  // Future<List<ChargingStation>> getStationsByCity(String city, {int skip = 0, int limit = 100}) async { ... }
}
