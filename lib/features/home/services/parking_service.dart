import 'package:dio/dio.dart';
import 'dart:math' as math;
// 為避免衝突，給latlong2包重命名
import 'package:latlong2/latlong.dart' as latlng2;
import '../../../core/constants/api_constants.dart';
// 為避免衝突，給google_maps_flutter包重命名
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:logger/logger.dart';
import '../models/parking_lot_model.dart';

class ParkingService {
  late final Dio _dio;
  final Logger _logger = Logger();

  // 緩存相關
  List<ParkingLot> _cachedParkings = [];
  DateTime? _lastCacheTime;
  final Duration _cacheValidity = const Duration(minutes: 60); // 修改為60分鐘緩存

  // 用於記錄最後一次API請求的錯誤
  String? lastError;

  ParkingService() {
    // 初始化Dio客戶端
    _dio = Dio(BaseOptions(
      baseUrl: 'https://volticar.dynns.com:22000',
      connectTimeout: Duration(milliseconds: ApiConstants.connectionTimeout),
      receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _logger.i('停車場服務已初始化，使用API: https://volticar.dynns.com:22000');
  }

  // 檢查緩存是否有效
  bool _isCacheValid() {
    if (_cachedParkings.isEmpty || _lastCacheTime == null) {
      return false;
    }

    final now = DateTime.now();
    return now.difference(_lastCacheTime!) < _cacheValidity;
  }

  // 獲取所有停車場
  Future<List<ParkingLot>> getAllRegionsParkings() async {
    // 優先使用緩存數據，減少連接問題影響
    if (_isCacheValid()) {
      _logger.i('使用緩存中的停車場數據 (${_cachedParkings.length} 個停車場)');
      return _cachedParkings;
    }

    try {
      _logger.i('從API獲取停車場數據...');

      final response = await _dio.get('/parkings/overview',
          queryParameters: {
            'skip': 0,
            'limit': 3000,
          },
          options: Options(
            sendTimeout: Duration(milliseconds: 20000),
            receiveTimeout: Duration(milliseconds: 30000),
          ));

      _logger.i('API 響應狀態碼: ${response.statusCode}');
      _logger.i('API 響應數據類型: ${response.data.runtimeType}');
      if (response.data is List) {
        _logger.i('API 返回陣列長度: ${(response.data as List).length}');
      }

      if (response.statusCode == 200) {
        _logger.i('成功獲取停車場數據');

        List<ParkingLot> parkings = [];

        if (response.data is List) {
          final List<dynamic> parkingsData = response.data;
          _logger.i('開始解析 ${parkingsData.length} 個停車場數據...');
          
          // 逐個解析，捕獲解析錯誤
          for (int i = 0; i < parkingsData.length; i++) {
            try {
              final parking = ParkingLot.fromJson(parkingsData[i]);
              parkings.add(parking);
            } catch (e) {
              _logger.w('解析第 ${i + 1} 個停車場數據失敗: $e');
              _logger.w('問題數據: ${parkingsData[i]}');
            }
          }
          
          _logger.i('成功解析 ${parkings.length} 個停車場數據（總共 ${parkingsData.length} 個）');
        } else if (response.data is Map<String, dynamic>) {
          // 嘗試處理單個停車場或包含停車場列表的對象
          final Map<String, dynamic> data = response.data;

          if (data.containsKey('parkings') && data['parkings'] is List) {
            final List<dynamic> parkingsData = data['parkings'];
            parkings = parkingsData.map((data) => ParkingLot.fromJson(data)).toList();
          } else if (data.containsKey('data') && data['data'] is List) {
            final List<dynamic> parkingsData = data['data'];
            parkings = parkingsData.map((data) => ParkingLot.fromJson(data)).toList();
          } else {
            try {
              final parking = ParkingLot.fromJson(data);
              parkings = [parking];
            } catch (e) {
              _logger.e('解析單個停車場對象失敗: $e');
            }
          }
        } else {
          _logger.w('API 返回的數據格式不正確: ${response.data.runtimeType}');
        }

        if (parkings.isNotEmpty) {
          // 更新緩存
          _cachedParkings = parkings;
          _lastCacheTime = DateTime.now();
          _logger.i('找到 ${parkings.length} 個停車場');
          return parkings;
        }
      }
    } catch (e) {
      _logger.e('獲取停車場時出錯: $e');
      lastError = '獲取停車場時出錯: $e';

      // 如果有緩存數據，即使過期也返回
      if (_cachedParkings.isNotEmpty) {
        _logger.w('使用緩存數據 (${_cachedParkings.length} 個停車場)');
        return _cachedParkings;
      }
    }

    // 如果所有嘗試都失敗，返回空列表
    _logger.w('無法獲取停車場數據，返回空列表');
    return [];
  }

  // 獲取附近的停車場（根據經緯度和半徑）
  Future<List<ParkingLot>> getNearbyParkings(
      double lat, double lng, double radiusKm) async {
    try {
      // 首先獲取所有停車場
      final allParkings = await getAllRegionsParkings();

      // 過濾出範圍內的停車場
      return allParkings.where((parking) {
        final distance = _calculateDistance(
            lat, lng, parking.latitude, parking.longitude);
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      _logger.e('獲取附近停車場時出錯: $e');
      return [];
    }
  }

  // 計算兩點之間的距離（千米）
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // 地球半徑，單位為千米
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  // 將角度轉換為弧度
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  // 將停車場座標轉換為Google Map標記
  gmaps.LatLng convertToGoogleLatLng(latlng2.LatLng latLng) {
    return gmaps.LatLng(latLng.latitude, latLng.longitude);
  }

  // 將Google Map標記轉換為停車場LatLng
  latlng2.LatLng convertFromGoogleLatLng(gmaps.LatLng latLng) {
    return latlng2.LatLng(latLng.latitude, latLng.longitude);
  }

  // 獲取最近的一個停車場
  Future<ParkingLot?> getNearestParking(
      double latitude, double longitude) async {
    try {
      // 獲取5公里範圍內的停車場
      final nearbyParkings = await getNearbyParkings(latitude, longitude, 5);

      if (nearbyParkings.isEmpty) {
        // 如果5公里內沒有，擴大到20公里
        final widerRangeParkings =
            await getNearbyParkings(latitude, longitude, 20);
        if (widerRangeParkings.isEmpty) {
          return null;
        }
        return widerRangeParkings.first; // 返回最近的一個
      }

      return nearbyParkings.first; // 已經按距離排序，返回第一個即為最近的
    } catch (e) {
      _logger.e('獲取最近停車場時出錯: $e');
      return null;
    }
  }

  // 根據城市獲取停車場
  Future<List<ParkingLot>> getParkingsByCity({
    String? city,
    double? minLat,
    double? minLon,
    double? maxLat,
    double? maxLon,
    int skip = 0,
    int limit = 3000,
  }) async {
    try {
      final response = await _dio.get('/parkings/overview',
          queryParameters: {
            'skip': skip,
            'limit': limit,
            if (city != null) 'city': city,
            if (minLat != null) 'minLat': minLat,
            if (minLon != null) 'minLon': minLon,
            if (maxLat != null) 'maxLat': maxLat,
            if (maxLon != null) 'maxLon': maxLon,
          });

      if (response.statusCode == 200) {
        List<ParkingLot> parkingsList = [];
        
        if (response.data is List) {
          final List<dynamic> parkingsData = response.data;
          parkingsList = parkingsData.map((data) => ParkingLot.fromJson(data)).toList();
        }
        
        return parkingsList;
      }
    } catch (e) {
      _logger.e('獲取停車場時出錯: $e');
    }
    
    return [];
  }

  // 獲取詳細停車場信息
  Future<List<ParkingLot>> getParkingsWithDetails({
    String? city,
    double? minLat,
    double? minLon,
    double? maxLat,
    double? maxLon,
    int skip = 0,
    int limit = 3000,
  }) async {
    // 對於停車場，詳細信息和概覽信息相同
    return getParkingsByCity(
      city: city,
      minLat: minLat,
      minLon: minLon,
      maxLat: maxLat,
      maxLon: maxLon,
      skip: skip,
      limit: limit,
    );
  }

  // 根據ID獲取單個停車場
  Future<ParkingLot?> getParkingById(String parkingId) async {
    try {
      // 首先嘗試從緩存中查找
      if (_cachedParkings.isNotEmpty) {
        try {
          final parking = _cachedParkings.firstWhere(
            (p) => p.parkingID == parkingId,
          );
          return parking;
        } catch (e) {
          // 緩存中沒有找到，繼續從API獲取
        }
      }
      
      // 如果緩存中沒有，從所有停車場中查找
      final allParkings = await getAllRegionsParkings();
      return allParkings.firstWhere(
        (p) => p.parkingID == parkingId,
        orElse: () => throw StateError('Parking not found'),
      );
    } catch (e) {
      _logger.e('根據ID獲取停車場失敗: $e');
      return null;
    }
  }
}
