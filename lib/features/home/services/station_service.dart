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

  // 緩存相關
  List<ChargingStation> _cachedStations = [];
  DateTime? _lastCacheTime;
  final Duration _cacheValidity = const Duration(minutes: 60); // 充電站緩存60分鐘

  // 檢查緩存是否有效
  bool _isCacheValid() {
    if (_cachedStations.isEmpty || _lastCacheTime == null) {
      return false;
    }

    final now = DateTime.now();
    return now.difference(_lastCacheTime!) < _cacheValidity;
  }

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
      _logger.d('Stations overview response data sample (first 2 items): ${response.data is List && (response.data as List).isNotEmpty ? (response.data as List).take(2).toList() : response.data}');

      if (response.statusCode == 200 && response.data is List) {
        List<dynamic> responseData = response.data as List<dynamic>;
        if (responseData.isEmpty) {
          _logger.i('No stations found for the given criteria.');
          return [];
        }
        
        // 檢查第一個項目的結構
        if (responseData.isNotEmpty) {
          _logger.i('First station raw data keys: ${(responseData[0] as Map<String, dynamic>).keys.toList()}');
          if ((responseData[0] as Map<String, dynamic>).containsKey('Connectors')) {
            _logger.i('Connectors data in first station: ${(responseData[0] as Map<String, dynamic>)['Connectors']}');
          } else {
            _logger.w('No Connectors key found in first station data');
          }
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
  Future<ChargingStation?> getStationById(String stationId) async {
    try {
      // 移除詳細的獲取日誌
      // 根據使用者提供的資訊，詳細資訊的端點應為 /stations/id/{stationId}
      final response = await _apiClient.get(
        '${ApiConstants.stations}/id/$stationId', // 修正路徑
      );

      // 移除響應狀態日誌

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        // 假設 API 在找不到時回傳 200 但 data 為空 Map 或特定錯誤結構
        // 或者 API 在找不到時回傳 404，這會在 _apiClient.get 中被 DioError 捕捉
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.isEmpty) { // 或是檢查是否有特定錯誤鍵
          _logger.w('Station with ID $stationId not found or empty response.');
          return null;
        }
        return ChargingStation.fromDetailJson(responseData);
      } else if (response.statusCode == 404) {
        _logger.w('Station with ID $stationId not found (404).');
        return null;
      }
      else {
        _logger.w('Failed to load station details for ID $stationId. Status: ${response.statusCode}');
        return null; // 或拋出異常
      }
    } catch (e, stackTrace) {
      _logger.e('Error fetching station details for ID $stationId', error: e, stackTrace: stackTrace);
      return null; // 或拋出異常
    }
  }

  /// 優化的方法：智能獲取充電站信息
  Future<List<ChargingStation>> getStationsWithDetails({
    double? minLat,
    double? minLon,
    double? maxLat,
    double? maxLon,
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      // 第一步：獲取充電站ID列表
      final overviewStations = await getStationsOverview(
        minLat: minLat,
        minLon: minLon,
        maxLat: maxLat,
        maxLon: maxLon,
        skip: skip,
        limit: limit,
      );
      
      if (overviewStations.isEmpty) {
        return [];
      }
      
      // 優化策略：並行獲取詳細信息，但限制並發數量
      const int maxConcurrent = 5; // 限制並發請求數量
      List<ChargingStation> detailedStations = [];
      int successCount = 0;
      int failCount = 0;
      
      // 分批處理，避免過多並發請求
      for (int i = 0; i < overviewStations.length; i += maxConcurrent) {
        final batch = overviewStations.skip(i).take(maxConcurrent).toList();
        
        // 並行處理當前批次
        final futures = batch.map((station) async {
          try {
            final detailedStation = await getStationById(station.stationID);
            return detailedStation ?? station;
          } catch (e) {
            return station; // 失敗時使用基本信息
          }
        });
        
        final batchResults = await Future.wait(futures);
        
        // 統計結果
        for (int j = 0; j < batchResults.length; j++) {
          final result = batchResults[j];
          final original = batch[j];
          
          if (result.connectors.isNotEmpty && result.stationID == original.stationID) {
            successCount++;
          } else {
            failCount++;
          }
          
          detailedStations.add(result);
        }
        
        // 批次間短暫延遲，避免服務器壓力
        if (i + maxConcurrent < overviewStations.length) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
      
      int stationsWithConnectors = detailedStations.where((station) => station.connectors.isNotEmpty).length;
      _logger.i('獲取完成: ${detailedStations.length}站 (詳細:$successCount, 基本:$failCount, 有connector:$stationsWithConnectors)');
      
      return detailedStations;
      
    } catch (e, stackTrace) {
      _logger.e('批量獲取失敗，回退到基本模式', error: e, stackTrace: stackTrace);
      return await getStationsOverview(
        minLat: minLat,
        minLon: minLon,
        maxLat: maxLat,
        maxLon: maxLon,
        skip: skip,
        limit: limit,
      );
    }
  }

  // 新增缺失的方法 - 添加60分鐘緩存機制
  Future<List<ChargingStation>> getAllRegionsStations() async {
    // 優先使用緩存數據，減少API調用
    if (_isCacheValid()) {
      _logger.i('使用緩存中的充電站數據 (${_cachedStations.length} 個站點)');
      return _cachedStations;
    }

    try {
      _logger.i('從API獲取所有區域充電站數據...');
      final response = await _apiClient.get(
        ApiConstants.stationsOverview,
        queryParameters: {'limit': 1000},
      );

      if (response.statusCode == 200 && response.data is List) {
        List<dynamic> responseData = response.data as List<dynamic>;
        final stations = responseData
            .map((json) => ChargingStation.fromOverviewJson(json as Map<String, dynamic>))
            .toList();
        
        // 更新緩存
        _cachedStations = stations;
        _lastCacheTime = DateTime.now();
        _logger.i('成功獲取並緩存 ${stations.length} 個充電站');
        
        return stations;
      }
      return [];
    } catch (e, stackTrace) {
      _logger.e('獲取所有區域充電站時出錯: $e', error: e, stackTrace: stackTrace);
      
      // 如果有緩存數據，即使過期也返回
      if (_cachedStations.isNotEmpty) {
        _logger.w('使用過期緩存數據 (${_cachedStations.length} 個站點)');
        return _cachedStations;
      }
      
      return [];
    }
  }

  Future<List<ChargingStation>> searchStations(String query) async {
    try {
      _logger.i('Searching stations with query: $query');
      final response = await _apiClient.get(
        ApiConstants.stationsOverview,
        queryParameters: {'search': query, 'limit': 200},
      );

      if (response.statusCode == 200 && response.data is List) {
        List<dynamic> responseData = response.data as List<dynamic>;
        return responseData
            .map((json) => ChargingStation.fromOverviewJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e, stackTrace) {
      _logger.e('Error searching stations', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<List<ChargingStation>> getNearbyStations(double latitude, double longitude, double radius) async {
    try {
      _logger.i('Fetching nearby stations at ($latitude, $longitude) within ${radius}km');
      final response = await _apiClient.get(
        ApiConstants.stationsOverview,
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'radius': radius,
          'limit': 200,
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        List<dynamic> responseData = response.data as List<dynamic>;
        return responseData
            .map((json) => ChargingStation.fromOverviewJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e, stackTrace) {
      _logger.e('Error fetching nearby stations', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // TODO: 實現 getStationsByCity 方法
  Future<List<ChargingStation>> getStationsByCity(String city, {int skip = 0, int limit = 100}) async {
    final Map<String, dynamic> queryParams = {
      'skip': skip,
      'limit': limit,
    };

    try {
      _logger.i('Fetching stations for city: $city with params: $queryParams');
      // 假設 ApiConstants.stationsByCity 的值是 '/stations/city'
      // 完整的路徑會是 /stations/city/{city}
      final response = await _apiClient.get(
        '${ApiConstants.stationsByCity}/$city', // 使用 string interpolation 組合路徑
        queryParameters: queryParams,
      );

      _logger.d('Stations by city response status: ${response.statusCode}');
      // _logger.d('Stations by city response data: ${response.data}');

      if (response.statusCode == 200 && response.data is List) {
        List<dynamic> responseData = response.data as List<dynamic>;
        if (responseData.isEmpty) {
          _logger.i('No stations found for city: $city.');
          return [];
        }
        // 假設回傳的結構與 overview 相似，使用 fromOverviewJson
        return responseData
            .map((json) => ChargingStation.fromOverviewJson(json as Map<String, dynamic>))
            .toList();
      } else {
        _logger.w('Failed to load stations for city $city or invalid response format. Status: ${response.statusCode}');
        return []; // 或拋出異常
      }
    } catch (e, stackTrace) {
      _logger.e('Error fetching stations for city $city', error: e, stackTrace: stackTrace);
      return []; // 或拋出異常
    }
  }
}
