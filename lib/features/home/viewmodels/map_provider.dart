import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:volticar_app/features/home/models/charging_station_model.dart';
import 'package:volticar_app/features/home/models/parking_lot_model.dart';
import 'package:volticar_app/features/home/services/station_service.dart';
import 'package:volticar_app/features/home/services/parking_service.dart';
import 'package:logger/logger.dart';
import 'dart:async'; // Import for Timer
import 'dart:math' as math; // Import for math functions
import 'package:geolocator/geolocator.dart'; // For GPS functionality
// flutter_map.dart 已經在頂部導入，MapController 應該可以直接使用

// 地圖類型枚舉
enum MapType {
  chargingStation,
  parking,
}

class MapProvider extends ChangeNotifier {
  final StationService _stationService = StationService();
  final ParkingService _parkingService = ParkingService();
  final Logger _logger = Logger();
  final MapController mapController = MapController();

  bool _isInitialized = false;
  
  // 地圖類型相關
  MapType _currentMapType = MapType.chargingStation;
  
  // 充電站相關數據
  List<ChargingStation> _stations = [];
  List<ChargingStation> _filteredStations = [];
  ChargingStation? _selectedStationDetail;
  
  // 停車場相關數據
  List<ParkingLot> _parkingLots = [];
  ParkingLot? _selectedParkingDetail;
  
  // 通用數據
  List<Marker> _markers = [];
  bool _isLoading = false;
  LatLng? _currentMapCenter;
  bool _isFetchingDetail = false;

  // 性能優化：添加緩存機制
  final Map<String, List<ChargingStation>> _stationCache = {};
  final Map<String, List<ParkingLot>> _parkingCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5); // 緩存5分鐘
  static const Duration _parkingCacheExpiry = Duration(minutes: 1); // 停車場緩存1分鐘，實現更頻繁的更新
  
  // 實時更新機制
  Timer? _realTimeUpdateTimer;
  static const Duration _realTimeUpdateInterval = Duration(seconds: 30); // 每30秒更新一次停車場數據

  // 性能優化：防抖和節流
  Timer? _debounceTimer;
  Timer? _throttleTimer;
  bool _isFirstLoad = true;
  LatLngBounds? _lastFetchBounds;
  double? _lastFetchZoom;
  
  // 速度優化：預測性載入
  Timer? _preloadTimer;
  LatLng? _lastMapCenter;
  LatLng? _mapMoveDirection;

  // Getters
  bool get isInitialized => _isInitialized;
  List<Marker> get markers => _markers;
  bool get isLoading => _isLoading;
  LatLng? get currentMapCenter => _currentMapCenter;
  bool get isFetchingDetail => _isFetchingDetail;
  
  // 地圖類型相關 getters
  MapType get currentMapType => _currentMapType;
  bool get isChargingStationMap => _currentMapType == MapType.chargingStation;
  bool get isParkingMap => _currentMapType == MapType.parking;
  
  // 充電站相關 getters
  List<ChargingStation> get stations => _stations;
  List<ChargingStation> get filteredStations => _filteredStations;
  ChargingStation? get selectedStationDetail => _selectedStationDetail;
  
  // 停車場相關 getters
  List<ParkingLot> get parkingLots => _parkingLots;
  ParkingLot? get selectedParkingDetail => _selectedParkingDetail;
  
  // 新增：獲取當前視野範圍內的停車場數量
  int get visibleParkingCount {
    if (_parkingLots.isEmpty) return 0;
    
    try {
      final bounds = mapController.camera.visibleBounds;
      return _parkingLots.where((parking) {
        return parking.latitude >= bounds.south &&
               parking.latitude <= bounds.north &&
               parking.longitude >= bounds.west &&
               parking.longitude <= bounds.east;
      }).length;
    } catch (e) {
      // 如果無法獲取視野範圍，返回所有停車場數量
      return _parkingLots.length;
    }
  }
  
  // 新增：獲取當前視野範圍內的充電站數量
  int get visibleStationCount {
    if (_stations.isEmpty) return 0;
    
    try {
      final bounds = mapController.camera.visibleBounds;
      return _stations.where((station) {
        return station.latitude >= bounds.south &&
               station.latitude <= bounds.north &&
               station.longitude >= bounds.west &&
               station.longitude <= bounds.east;
      }).length;
    } catch (e) {
      // 如果無法獲取視野範圍，返回所有充電站數量
      return _stations.length;
    }
  }

  // Filter states
  bool _filterOnlyAvailable = false;
  String _searchQuery = '';
  final List<String> _selectedConnectorTypes = []; // 新增：選中的充電槍類型
  List<String> _availableConnectorTypes = []; // 新增：可用的充電槍類型，將從實際數據中動態獲取

  bool get filterOnlyAvailable => _filterOnlyAvailable;
  String get searchQuery => _searchQuery;
  List<String> get selectedConnectorTypes => _selectedConnectorTypes;
  List<String> get availableConnectorTypes => _availableConnectorTypes;

  String? get lastError => null;
  LatLng? get currentLocation => _currentMapCenter;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 首先初始化完整的充電槍類型列表，確保用戶可以看到所有可能的選項
    _initializeAllConnectorTypes();

    // 載入初始區域的充電站數據（台北市周圍）
    const initialCenter = LatLng(25.0340, 121.5645);
    const initialZoom = 10.0;

    // 根據縮放級別估算可視範圍
    final latDelta = 1.0 / (initialZoom * 0.1);
    final lngDelta = 1.0 / (initialZoom * 0.1);

    await fetchAndSetStationMarkers(
      minLat: initialCenter.latitude - latDelta,
      maxLat: initialCenter.latitude + latDelta,
      minLon: initialCenter.longitude - lngDelta,
      maxLon: initialCenter.longitude + lngDelta,
      currentZoom: initialZoom,
    ); // 首次加載數據
    _isInitialized = true;
    debugPrint('MapProvider initialized and initial markers fetched');
  }

  // 切換地圖類型
  void toggleMapType() {
    if (_currentMapType == MapType.chargingStation) {
      _currentMapType = MapType.parking;
      _logger.i('切換到停車場地圖');
      _startRealTimeUpdates(); // 啟動實時更新
      
      // 立即載入當前視野範圍的停車場數據
      if (_lastFetchBounds != null && _lastFetchZoom != null) {
        fetchAndSetParkingMarkers(
          minLat: _lastFetchBounds!.south,
          minLon: _lastFetchBounds!.west,
          maxLat: _lastFetchBounds!.north,
          maxLon: _lastFetchBounds!.east,
          currentZoom: _lastFetchZoom,
        );
      }
    } else {
      _currentMapType = MapType.chargingStation;
      _logger.i('切換到充電站地圖');
      _stopRealTimeUpdates(); // 停止實時更新
      
      // 立即載入當前視野範圍的充電站數據
      if (_lastFetchBounds != null && _lastFetchZoom != null) {
        fetchAndSetStationMarkers(
          minLat: _lastFetchBounds!.south,
          minLon: _lastFetchBounds!.west,
          maxLat: _lastFetchBounds!.north,
          maxLon: _lastFetchBounds!.east,
          currentZoom: _lastFetchZoom,
        );
      }
    }
    
    // 清空當前標記
    _markers.clear();
    
    // 重新載入對應類型的數據
    if (_lastFetchBounds != null && _lastFetchZoom != null) {
      if (_currentMapType == MapType.chargingStation) {
        _fetchStationsForBounds(_lastFetchBounds!, _lastFetchZoom!);
      } else {
        _fetchParkingForBounds(_lastFetchBounds!, _lastFetchZoom!);
      }
    }
    
    notifyListeners();
  }

  Future<void> fetchAndSetStationMarkers({
    double? minLat,
    double? minLon,
    double? maxLat,
    double? maxLon,
    double? currentZoom, // 新增：接收當前縮放級別
  }) async {
    _isLoading = true;
    notifyListeners();

    // 獲取當前縮放級別用於緩存鍵值
    final double zoomLevel;
    if (currentZoom == null) {
      zoomLevel = MapOptions().initialZoom;
    } else {
      zoomLevel = currentZoom;
    }

    try {
      // 性能優化：檢查緩存
      final cacheKey =
          _generateCacheKey(minLat, minLon, maxLat, maxLon, zoomLevel);

      if (_isValidCache(cacheKey)) {
        _stations = _stationCache[cacheKey]!;
        _filteredStations = _stations;
        _logger.i('使用緩存: ${_stations.length}站');
        _updateAvailableConnectorTypes();
        applyFilters();
        _isLoading = false;
        notifyListeners();
        return;
      }

      final stations = await _stationService.getStationsWithDetails(
        minLat: minLat,
        minLon: minLon,
        maxLat: maxLat,
        maxLon: maxLon,
        limit: 3000, // 與停車場一樣，獲取所有充電站數據
      );

      // 更新緩存
      _stationCache[cacheKey] = stations;
      _cacheTimestamps[cacheKey] = DateTime.now();
      _cleanExpiredCache();

      _stations = stations;
      _filteredStations = stations;
      _updateStationMarkers(zoomLevel);
      _updateAvailableConnectorTypes();
      applyFilters();

      _logger.i('充電站載入: ${_stations.length}個');
    } catch (e) {
      _logger.e('載入充電站失敗: $e');
      _stations = [];
      _filteredStations = [];
    }

    // 在獲取新數據後，立即應用當前的篩選條件
    _updateAvailableConnectorTypes(); // 記錄發現的充電槍類型
    applyFilters(); // 應用篩選並更新 UI
  }

  // 移除重複的變量定義

  void onMapPositionChanged(LatLngBounds bounds, LatLng? center) {
    // 修改：接收 center
    if (center != null) {
      _currentMapCenter = center;
    }

    final currentZoom = mapController.camera.zoom;
    final currentCenter = _currentMapCenter!;
    
    // 如果是首次載入，立即執行
    if (_isFirstLoad) {
      _isFirstLoad = false;
      _fetchStationsForBounds(bounds, currentZoom);
      return;
    }

    // 取消之前的計時器
    _debounceTimer?.cancel();
    _throttleTimer?.cancel();
    
    // 使用防抖機制，縮短延遲時間以提供更好的實時體驗
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      // 檢查是否真的需要更新數據
      if (_shouldUpdateForMapChange(bounds, currentZoom, currentCenter)) {
        // 根據當前地圖類型載入對應數據
        if (_currentMapType == MapType.chargingStation) {
          _fetchStationsForBounds(bounds, currentZoom);
        } else {
          _fetchParkingForBounds(bounds, currentZoom);
        }
      } else {
        // 即使不需要載入新數據，也要更新UI以反映視野範圍內數量的變化
        notifyListeners();
      }
    });
    
    // 計算移動方向（用於預測性載入）
    if (_lastMapCenter != null && _currentMapCenter != null) {
      _mapMoveDirection = LatLng(
        _currentMapCenter!.latitude - _lastMapCenter!.latitude,
        _currentMapCenter!.longitude - _lastMapCenter!.longitude,
      );
      
      // 啟動預測性載入
      _startPredictiveLoading(bounds, currentZoom);
    }
    _lastMapCenter = _currentMapCenter;
    
    // 立即更新 UI 狀態，讓用戶知道地圖位置已改變
    notifyListeners();
  }

  // 提取獲取充電站數據的邏輯（添加快速響應優化）
  void _fetchStationsForBounds(LatLngBounds bounds, double zoom) {
    // 立即設置載入狀態，提供即時視覺反饋
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners(); // 立即通知UI顯示載入狀態
    }
    
    fetchAndSetStationMarkers(
      minLat: bounds.south,
      minLon: bounds.west,
      maxLat: bounds.north,
      maxLon: bounds.east,
      currentZoom: zoom,
    );
    
    // 更新記錄的範圍和縮放級別
    _lastFetchBounds = bounds;
    _lastFetchZoom = zoom;
  }

  // 提取獲取停車場數據的邏輯
  void _fetchParkingForBounds(LatLngBounds bounds, double zoom) {
    // 立即設置載入狀態，提供即時視覺反饋
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners(); // 立即通知UI顯示載入狀態
    }
    
    fetchAndSetParkingMarkers(
      minLat: bounds.south,
      minLon: bounds.west,
      maxLat: bounds.north,
      maxLon: bounds.east,
      currentZoom: zoom,
    );
    
    // 更新記錄的範圍和縮放級別
    _lastFetchBounds = bounds;
    _lastFetchZoom = zoom;
  }

  // 獲取停車場標記
  Future<void> fetchAndSetParkingMarkers({
    double? minLat,
    double? minLon,
    double? maxLat,
    double? maxLon,
    double? currentZoom,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 性能優化：檢查緩存
      final zoomLevel = currentZoom ?? 10.0;
      final cacheKey = _generateCacheKey(minLat, minLon, maxLat, maxLon, zoomLevel);
      
      if (_isValidParkingCache(cacheKey)) {
        _parkingLots = _parkingCache[cacheKey]!;
        _updateParkingMarkers(zoomLevel);
        _logger.i('使用停車場緩存: ${_parkingLots.length}個');
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 對於停車場，獲取所有數據然後在客戶端篩選
      final parkingLots = await _parkingService.getParkingsWithDetails(
        minLat: minLat,
        minLon: minLon,
        maxLat: maxLat,
        maxLon: maxLon,
        limit: 3000, // 獲取所有停車場數據
      );

      // 更新緩存
      _parkingCache[cacheKey] = parkingLots;
      _cacheTimestamps[cacheKey] = DateTime.now();
      _cleanExpiredCache();

      _parkingLots = parkingLots;
      _updateParkingMarkers(zoomLevel);
      
      _logger.i('停車場載入: ${_parkingLots.length}個');

    } catch (e) {
      _logger.e('載入停車場失敗: $e');
      _parkingLots = [];
      _markers = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // 更新充電站標記
  void _updateStationMarkers([double? zoomLevel]) {
    // 根據縮放級別和視野範圍篩選充電站
    List<ChargingStation> visibleStations = _stations;
    
    if (zoomLevel != null) {
      // 計算動態限制
      final limit = _calculateDynamicLimit(zoomLevel);
      
      try {
        // 獲取當前視野範圍
        final bounds = mapController.camera.visibleBounds;
        
        // 篩選視野範圍內的充電站
        final stationsInView = _stations.where((station) {
          return station.latitude >= bounds.south &&
                 station.latitude <= bounds.north &&
                 station.longitude >= bounds.west &&
                 station.longitude <= bounds.east;
        }).toList();
        
        // 如果視野內的充電站數量超過限制，按距離排序並取前N個
        if (stationsInView.length > limit) {
          final center = bounds.center;
          stationsInView.sort((a, b) {
            final distanceA = _calculateDistance(
                center.latitude, center.longitude, a.latitude, a.longitude);
            final distanceB = _calculateDistance(
                center.latitude, center.longitude, b.latitude, b.longitude);
            return distanceA.compareTo(distanceB);
          });
          visibleStations = stationsInView.take(limit).toList();
        } else {
          visibleStations = stationsInView;
        }
        
        _logger.i(
            '顯示 ${visibleStations.length} 個充電站（縮放級別: $zoomLevel, 限制: $limit）');
      } catch (e) {
        // 如果無法獲取視野範圍，使用距離中心點最近的充電站
        if (_stations.length > limit) {
          final center = _currentMapCenter ?? LatLng(25.0330, 121.5654); // 預設台北
          _stations.sort((a, b) {
            final distanceA = _calculateDistance(
                center.latitude, center.longitude, a.latitude, a.longitude);
            final distanceB = _calculateDistance(
                center.latitude, center.longitude, b.latitude, b.longitude);
            return distanceA.compareTo(distanceB);
          });
          visibleStations = _stations.take(limit).toList();
        }
      }
    }
    
    // 更新 _filteredStations 以供其他方法使用
    _filteredStations = visibleStations;
    
    // 生成充電站標記
    _markers = visibleStations.map((station) {
      return Marker(
        width: 50.0,
        height: 50.0,
        point: LatLng(station.latitude, station.longitude),
        child: GestureDetector(
          onTap: () {
            selectStation(station.stationID);
          },
          child: Container(
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
              color: _getStationStatusColor(station),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 主要充電站圖標
                Center(
                  child: Icon(
                    Icons.ev_station,
                    color: Colors.white,
                    size: 24,
                    weight: 700,
                  ),
                ),
                // 充電點數量指示器
                if (station.chargingPoints > 0)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${station.chargingPoints}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // 計算動態限制的輔助方法
  int _calculateDynamicLimit(double zoomLevel) {
    // 停車場和充電站使用相同的動態限制邏輯
    if (zoomLevel < 8) return 20;
    if (zoomLevel < 10) return 40;
    if (zoomLevel < 12) return 80;
    if (zoomLevel < 14) return 120;
    return 150;
  }

  // 計算兩點間距離（公里）
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // 地球半徑（公里）
    
    final double dLat = (lat2 - lat1) * math.pi / 180;
    final double dLon = (lon2 - lon1) * math.pi / 180;
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  // 更新停車場標記
  void _updateParkingMarkers([double? zoomLevel]) {
    // 根據縮放級別和視野範圍篩選停車場
    List<ParkingLot> visibleParkings = _parkingLots;
    
    if (zoomLevel != null) {
      // 計算動態限制
      final limit = _calculateDynamicLimit(zoomLevel);
      
      try {
        // 獲取當前視野範圍
        final bounds = mapController.camera.visibleBounds;
        
        // 篩選視野範圍內的停車場
        final parkingsInView = _parkingLots.where((parking) {
          return parking.latitude >= bounds.south &&
                 parking.latitude <= bounds.north &&
                 parking.longitude >= bounds.west &&
                 parking.longitude <= bounds.east;
        }).toList();
        
        // 如果視野內的停車場數量超過限制，按距離排序並取前N個
        if (parkingsInView.length > limit) {
          final center = bounds.center;
          parkingsInView.sort((a, b) {
            final distanceA = _calculateDistance(center.latitude, center.longitude, a.latitude, a.longitude);
            final distanceB = _calculateDistance(center.latitude, center.longitude, b.latitude, b.longitude);
            return distanceA.compareTo(distanceB);
          });
          visibleParkings = parkingsInView.take(limit).toList();
        } else {
          visibleParkings = parkingsInView;
        }
        
        _logger.i('顯示 ${visibleParkings.length} 個停車場（縮放級別: $zoomLevel, 限制: $limit）');
      } catch (e) {
        // 如果無法獲取視野範圍，使用距離中心點最近的停車場
        if (_parkingLots.length > limit) {
          final center = _currentMapCenter ?? LatLng(25.0330, 121.5654); // 預設台北
          _parkingLots.sort((a, b) {
            final distanceA = _calculateDistance(center.latitude, center.longitude, a.latitude, a.longitude);
            final distanceB = _calculateDistance(center.latitude, center.longitude, b.latitude, b.longitude);
            return distanceA.compareTo(distanceB);
          });
          visibleParkings = _parkingLots.take(limit).toList();
        }
      }
    }
    
    _markers = visibleParkings.map((parking) {
      return Marker(
        width: 50.0,
        height: 50.0,
        point: LatLng(parking.latitude, parking.longitude),
        child: GestureDetector(
          onTap: () {
            selectParkingLot(parking.parkingID);
          },
          child: Container(
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3), // 藍色背景
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 主要停車場圖標
                Center(
                  child: Icon(
                    Icons.local_parking,
                    color: Colors.white,
                    size: 24,
                    weight: 700,
                  ),
                ),
                // 可用性指示器（如果有可用空間數據）
                if (parking.availableSpaces != null && parking.totalSpaces != null)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getParkingAvailabilityColor(parking),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // 根據停車場可用性獲取顏色
  Color _getParkingAvailabilityColor(ParkingLot parking) {
    if (parking.availableSpaces == null || parking.totalSpaces == null) {
      return Colors.grey; // 未知狀態
    }
    
    final availabilityRatio = parking.availableSpaces! / parking.totalSpaces!;
    
    if (availabilityRatio > 0.5) {
      return Colors.green; // 充足
    } else if (availabilityRatio > 0.2) {
      return Colors.orange; // 有限
    } else {
      return Colors.red; // 幾乎滿了
    }
  }

  // 根據充電站狀態獲取顏色
  Color _getStationStatusColor(ChargingStation station) {
    if (station.chargingPoints <= 0) {
      return const Color(0xFFFF5722); // 紅色：無充電點
    }
    
    // 根據充電點數量和連接器數量判斷狀態
    final connectorCount = station.connectors.length;
    
    if (connectorCount == 0) {
      return const Color(0xFFFF9800); // 橙色：無詳細信息
    }
    
    // 根據充電點數量決定顏色深淺
    if (station.chargingPoints >= 4) {
      return const Color(0xFF2E7D32); // 深綠色：充電點充足
    } else if (station.chargingPoints >= 2) {
      return const Color(0xFF4CAF50); // 綠色：充電點適中
    } else {
      return const Color(0xFF8BC34A); // 淺綠色：充電點較少
    }
  }

  // 檢查停車場緩存是否有效 - 使用更短的緩存時間以實現實時更新
  bool _isValidParkingCache(String cacheKey) {
    if (!_parkingCache.containsKey(cacheKey) || !_cacheTimestamps.containsKey(cacheKey)) {
      return false;
    }
    
    final cacheTime = _cacheTimestamps[cacheKey]!;
    return DateTime.now().difference(cacheTime) < _parkingCacheExpiry;
  }

  // 選擇停車場
  Future<void> selectParkingLot(String parkingId) async {
    _isFetchingDetail = true;
    notifyListeners();

    try {
      final parkingDetail = await _parkingService.getParkingById(parkingId);
      _selectedParkingDetail = parkingDetail;
    } catch (e) {
      _logger.e('獲取停車場詳情失敗: $e');
      _selectedParkingDetail = null;
    }

    _isFetchingDetail = false;
    notifyListeners();
  }

  // 預測性載入方法
  void _startPredictiveLoading(LatLngBounds currentBounds, double zoom) {
    // 取消之前的預載入計時器
    _preloadTimer?.cancel();
    
    // 如果沒有移動方向，跳過預測
    if (_mapMoveDirection == null) return;
    
    // 延遲啟動預測載入，避免過於頻繁
    _preloadTimer = Timer(const Duration(milliseconds: 500), () {
      _preloadAdjacentAreas(currentBounds, zoom);
    });
  }
  
  // 預載入相鄰區域的數據
  void _preloadAdjacentAreas(LatLngBounds currentBounds, double zoom) {
    if (_mapMoveDirection == null) return;
    
    // 計算預測的下一個區域
    final moveScale = 0.3; // 預測移動30%的當前視野範圍
    final latDelta = (currentBounds.north - currentBounds.south) * moveScale;
    final lonDelta = (currentBounds.east - currentBounds.west) * moveScale;
    
    // 根據移動方向計算預測區域
    final predictedLat = _mapMoveDirection!.latitude > 0 ? 
        currentBounds.north + latDelta : currentBounds.south - latDelta;
    final predictedLon = _mapMoveDirection!.longitude > 0 ? 
        currentBounds.east + lonDelta : currentBounds.west - lonDelta;
    
    // 創建預測區域的邊界
    final predictedBounds = LatLngBounds(
      LatLng(predictedLat - latDelta, predictedLon - lonDelta),
      LatLng(predictedLat + latDelta, predictedLon + lonDelta),
    );
    
    // 檢查是否已經有這個區域的緩存
    final cacheKey = _generateCacheKey(
      predictedBounds.south,
      predictedBounds.west,
      predictedBounds.north,
      predictedBounds.east,
      zoom,
    );
    
    // 如果沒有緩存，在背景中預載入
    if (!_isValidCache(cacheKey)) {
      _preloadStationsInBackground(predictedBounds, zoom, cacheKey);
    }
  }
  
  // 背景預載入充電站數據
  void _preloadStationsInBackground(LatLngBounds bounds, double zoom, String cacheKey) async {
    try {
      // 計算動態限制（預載入時使用較小的限制）
      final limit = _calculateDynamicLimit(zoom) ~/ 2; // 預載入時減半
      
      final stations = await _stationService.getStationsWithDetails(
        minLat: bounds.south,
        minLon: bounds.west,
        maxLat: bounds.north,
        maxLon: bounds.east,
        limit: limit,
      );
      
      // 將預載入的數據存入緩存
      _stationCache[cacheKey] = stations;
      _cacheTimestamps[cacheKey] = DateTime.now();
      
      _logger.i('預載入完成: ${stations.length}站');
    } catch (e) {
      // 預載入失敗不影響主要功能
      _logger.w('預載入失敗: $e');
    }
  }
  
  // 啟動實時更新
  void _startRealTimeUpdates() {
    _stopRealTimeUpdates(); // 先停止現有的定時器
    
    _realTimeUpdateTimer = Timer.periodic(_realTimeUpdateInterval, (timer) {
      if (_currentMapType == MapType.parking && _lastFetchBounds != null && _lastFetchZoom != null) {
        _logger.i('執行停車場實時更新');
        // 強制清除緩存以獲取最新數據
        _clearParkingCache();
        _fetchParkingForBounds(_lastFetchBounds!, _lastFetchZoom!);
      }
    });
    
    _logger.i('啟動停車場實時更新，間隔: ${_realTimeUpdateInterval.inSeconds}秒');
  }
  
  // 停止實時更新
  void _stopRealTimeUpdates() {
    _realTimeUpdateTimer?.cancel();
    _realTimeUpdateTimer = null;
    _logger.i('停止停車場實時更新');
  }
  
  // 清除停車場緩存
  void _clearParkingCache() {
    _parkingCache.clear();
    // 只清除停車場相關的緩存時間戳
    _cacheTimestamps.removeWhere((key, value) => key.contains('parking'));
  }
  
  // 手動刷新停車場數據
  Future<void> refreshParkingData() async {
    if (_currentMapType != MapType.parking) return;
    
    _logger.i('手動刷新停車場數據');
    _clearParkingCache();
    
    if (_lastFetchBounds != null && _lastFetchZoom != null) {
      await fetchAndSetParkingMarkers(
        minLat: _lastFetchBounds!.south,
        minLon: _lastFetchBounds!.west,
        maxLat: _lastFetchBounds!.north,
        maxLon: _lastFetchBounds!.east,
      );
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _throttleTimer?.cancel();
    _preloadTimer?.cancel();
    _realTimeUpdateTimer?.cancel(); // 清理實時更新定時器
    _stationCache.clear();
    _parkingCache.clear();
    _cacheTimestamps.clear();
    super.dispose();
  }

  // 性能優化：緩存相關方法
  String _generateCacheKey(double? minLat, double? minLon, double? maxLat,
      double? maxLon, double zoom) {
    final lat = ((minLat ?? 0) * 100).round() / 100;
    final lon = ((minLon ?? 0) * 100).round() / 100;
    final lat2 = ((maxLat ?? 0) * 100).round() / 100;
    final lon2 = ((maxLon ?? 0) * 100).round() / 100;
    final z = (zoom * 10).round() / 10;
    return '${lat}_${lon}_${lat2}_${lon2}_$z';
  }

  bool _isValidCache(String cacheKey) {
    if (!_stationCache.containsKey(cacheKey) ||
        !_cacheTimestamps.containsKey(cacheKey)) {
      return false;
    }

    final cacheTime = _cacheTimestamps[cacheKey]!;
    return DateTime.now().difference(cacheTime) < _cacheExpiry;
  }

  void _cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) > _cacheExpiry) {
        expiredKeys.add(key);
      }
    });

    for (final key in expiredKeys) {
      _stationCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  // 清理所有緩存
  void clearCache() {
    _stationCache.clear();
    _cacheTimestamps.clear();
    _logger.i('緩存已清理');
  }

  // 智能判斷是否需要更新地圖數據
  bool _shouldUpdateForMapChange(
      LatLngBounds bounds, double zoom, LatLng center) {
    // 如果正在加載，跳過
    if (_isLoading) {
      return false;
    }

    // 如果沒有之前的數據，必須更新
    if (_lastFetchBounds == null || _lastFetchZoom == null) {
      return true;
    }
    
    // 檢查縮放級別變化（降低閾值以提供更實時的體驗）
    final zoomDiff = (zoom - _lastFetchZoom!).abs();
    if (zoomDiff > 0.5) { // 縮放變化超過0.5級別就更新
      return true;
    }
    
    // 檢查地圖範圍變化（更敏感的觸發條件）
    final overlapRatio = _calculateBoundsOverlap(bounds, _lastFetchBounds!);
    if (overlapRatio < 0.8) { // 重疊少於80%時更新（更敏感）
      return true;
    }
    
    // 檢查地圖中心移動距離（更小的觸發距離）
    final lastCenter = LatLng(
      (_lastFetchBounds!.north + _lastFetchBounds!.south) / 2,
      (_lastFetchBounds!.east + _lastFetchBounds!.west) / 2,
    );
    final distance = _calculateDistance(lastCenter.latitude, lastCenter.longitude, center.latitude, center.longitude);
    
    // 根據縮放級別調整觸發距離（更敏感的距離）
    double triggerDistance;
    if (zoom < 10) {
      triggerDistance = 2000; // 2km
    } else if (zoom < 12) {
      triggerDistance = 1000; // 1km
    } else if (zoom < 14) {
      triggerDistance = 500;  // 500m
    } else {
      triggerDistance = 250;  // 250m
    }
    
    if (distance > triggerDistance) {
      return true;
    }

    return false;
  }

  // 計算兩個邊界的重疊比例
  double _calculateBoundsOverlap(LatLngBounds bounds1, LatLngBounds bounds2) {
    final intersectionSouth =
        [bounds1.south, bounds2.south].reduce((a, b) => a > b ? a : b);
    final intersectionNorth =
        [bounds1.north, bounds2.north].reduce((a, b) => a < b ? a : b);
    final intersectionWest =
        [bounds1.west, bounds2.west].reduce((a, b) => a > b ? a : b);
    final intersectionEast =
        [bounds1.east, bounds2.east].reduce((a, b) => a < b ? a : b);

    if (intersectionSouth >= intersectionNorth ||
        intersectionWest >= intersectionEast) {
      return 0.0; // 沒有重疊
    }

    final intersectionArea = (intersectionNorth - intersectionSouth) *
        (intersectionEast - intersectionWest);
    final bounds1Area =
        (bounds1.north - bounds1.south) * (bounds1.east - bounds1.west);

    return intersectionArea / bounds1Area;
  }



  void setFilterOnlyAvailable(bool value) {
    _filterOnlyAvailable = value;
    applyFilters();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    applyFilters();
  }

  /// 新的簡潔篩選邏輯
  void applyFilters() {
    _logger.i(
        '篩選: ${_stations.length}站 -> 搜索:"$_searchQuery", 可用:$_filterOnlyAvailable, 類型:$_selectedConnectorTypes');

    _isLoading = true;
    notifyListeners();

    // 從原始數據開始篩選
    List<ChargingStation> result = List.from(_stations);

    // 1. 搜索篩選
    if (_searchQuery.isNotEmpty) {
      String query = _searchQuery.toLowerCase().trim();
      result = result.where((station) {
        return station.stationName.toLowerCase().contains(query) ||
            (station.fullAddress?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // 2. 可用性篩選
    if (_filterOnlyAvailable) {
      result = result.where((station) => station.chargingPoints > 0).toList();
    }

    // 3. 充電槍類型篩選
    if (_selectedConnectorTypes.isNotEmpty) {
      result = result.where((station) {
        if (station.connectors.isEmpty) {
          return false; // 沒有 connector 數據就排除
        }

        // 檢查是否有匹配的充電槍類型
        return station.connectors.any((connector) {
          return _selectedConnectorTypes.contains(connector.typeDescription);
        });
      }).toList();
    }

    // 更新結果
    _filteredStations = result;
    _updateMarkers();

    _logger.i('篩選完成: ${_filteredStations.length}站');

    _isLoading = false;
    notifyListeners();
  }

  /// 更新地圖標記
  void _updateMarkers() {
    _markers = _filteredStations.map((station) {
      return Marker(
        width: 40.0,
        height: 40.0,
        point: LatLng(station.latitude, station.longitude),
        child: GestureDetector(
          onTap: () => selectStation(station.stationID),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Icon(
              Icons.ev_station,
              color: Colors.white,
              size: 20.0,
            ),
          ),
        ),
      );
    }).toList();
  }

  Future<void> selectStation(String stationId) async {
    if (_isFetchingDetail) return;

    _isFetchingDetail = true;
    _selectedStationDetail = null;
    notifyListeners();

    try {
      final stationDetail = await _stationService.getStationById(stationId);
      if (stationDetail != null) {
        _selectedStationDetail = stationDetail;
      }
    } catch (e) {
      _logger.e('獲取站點詳情失敗: $e');
      _selectedStationDetail = null;
    } finally {
      _isFetchingDetail = false;
      notifyListeners();
    }
  }

  void clearSelectedStation() {
    _selectedStationDetail = null;
    _isFetchingDetail = false;
    notifyListeners();
  }

  // --- Map Control Methods ---
  void zoomIn() {
    final currentZoom = mapController.camera.zoom;
    mapController.move(mapController.camera.center, currentZoom + 1);
  }

  void zoomOut() {
    final currentZoom = mapController.camera.zoom;
    mapController.move(mapController.camera.center, currentZoom - 1);
  }

  Future<void> moveToCurrentUserLocation() async {
    _isLoading = true;
    notifyListeners();
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium);
      } catch (e) {
        _logger.e('Error getting current position: $e');
        _isLoading = false;
        notifyListeners();
        return;
      }

      final userLocation = LatLng(position.latitude, position.longitude);
      try {
        mapController.move(userLocation, mapController.camera.zoom);
        _currentMapCenter = userLocation;
      } catch (e) {
        _logger.e('Error moving map: $e');
      }

      // 可選：如果地圖移動未觸發 onPositionChanged (例如，如果位置未顯著改變)，
      // 或者如果希望立即基於新中心點加載數據，可以在此處手動觸發。
      // 但通常 onMapPositionChanged 中的 debounce 機制會處理。
      // 我們在這裡確保 _currentMapCenter 更新後 UI 能響應（例如左下角的座標顯示）。
      // fetchAndSetStationMarkers 的 notifyListeners 會處理 markers 的更新。
      // onMapPositionChanged 中的 notifyListeners 會處理 _currentMapCenter 的更新。
      // 這裡的 notifyListeners 主要是為了 _isLoading 和可能的 _currentMapCenter 的即時更新（如果 onMapPositionChanged 中的 notify 被註解掉）。
      // 實際上，在 fetchAndSetStationMarkers 和 applyFilters 的末尾都有 notifyListeners，
      // onMapPositionChanged 的 debounce 後也會 notifyListeners。
      // 所以這裡的 _isLoading = false; notifyListeners(); 應該是足夠的。

      // 可選地，如果希望在定位後立即加載該位置的站點，可以這樣做：
      // final newBounds = mapController.camera.visibleBounds; // 需要確保 mapController 已準備好
      // if (newBounds != null) {
      //   fetchAndSetStationMarkers(
      //     minLat: newBounds.southWest.latitude,
      //     minLon: newBounds.southWest.longitude,
      //     maxLat: newBounds.northEast.latitude,
      //     maxLon: newBounds.northEast.longitude,
      //   );
      // }

      // Optionally, fetch stations for this new location if not covered by onPositionChanged
      // For now, onPositionChanged should handle it if the move is significant enough
      // to trigger the debounce. We also update _currentMapCenter and notify.
    } catch (e) {
      _logger.e('Error moving to current user location: $e');
    }
    _isLoading = false;
    notifyListeners(); // Notify to update UI (e.g. center coordinates display)
  }

  /// 簡化的充電槍類型初始化
  void _initializeAllConnectorTypes() {
    // 直接使用固定的常見充電槍類型列表，按使用頻率排序
    _availableConnectorTypes = [
      'CCS2',
      'CCS1',
      'CHAdeMO',
      'J1772(Type1)',
      'Mennekes(Type2)',
      'Tesla TPC',
      'Others'
    ];

    // 移除初始化日誌
    notifyListeners();
  }

  /// 簡化的充電槍類型更新 - 只記錄實際發現的類型
  void _updateAvailableConnectorTypes() {
    Set<String> foundTypes = <String>{};

    // 統計實際充電站中發現的充電槍類型
    for (var station in _stations) {
      for (var connector in station.connectors) {
        String typeDesc = connector.typeDescription;
        if (typeDesc.isNotEmpty &&
            typeDesc != '未知類型' &&
            typeDesc != 'Unknown') {
          foundTypes.add(typeDesc);
        }
      }
    }

    // 移除充電槍類型發現日誌，減少輸出
  }

  // 新的簡化充電槍類型篩選方法
  void toggleConnectorTypeFilter(String connectorType) {
    if (_selectedConnectorTypes.contains(connectorType)) {
      _selectedConnectorTypes.remove(connectorType);
    } else {
      _selectedConnectorTypes.add(connectorType);
    }

    _logger.i('充電槍篩選: $_selectedConnectorTypes');
    applyFilters();
  }

  void addConnectorTypeFilter(String connectorType) {
    if (!_selectedConnectorTypes.contains(connectorType)) {
      _selectedConnectorTypes.add(connectorType);
      applyFilters();
    }
  }

  void removeConnectorTypeFilter(String connectorType) {
    if (_selectedConnectorTypes.remove(connectorType)) {
      applyFilters();
    }
  }

  void clearConnectorTypeFilters() {
    _selectedConnectorTypes.clear();
    applyFilters();
  }

  void clearAllFilters() {
    _filterOnlyAvailable = false;
    _searchQuery = '';
    _selectedConnectorTypes.clear();
    applyFilters();
  }

  // 新增：重置地圖狀態，用於每次打開地圖overlay時
  void resetMapState() {
    _isFirstLoad = true;
  }

  // 新增缺失的方法
  Future<void> fetchCurrentLocation() async {
    try {
      _currentMapCenter = const LatLng(25.0340, 121.5645);
      notifyListeners();
    } catch (e) {
      _logger.e('獲取當前位置失敗: $e');
    }
  }

  Future<void> searchChargingStations(String query) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (query.isEmpty) {
        _stations = await _stationService.getAllRegionsStations();
      } else {
        _stations = await _stationService.searchStations(query);
      }

      _updateMarkersFromStations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.e('搜索充電站失敗: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchNearbyChargingStations(String query, double radius) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_currentMapCenter != null) {
        _stations = await _stationService.getNearbyStations(
            _currentMapCenter!.latitude, _currentMapCenter!.longitude, radius);
      }

      _updateMarkersFromStations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.e('搜索附近充電站失敗: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // 新增缺失的 _updateMarkersFromStations 方法
  void _updateMarkersFromStations() {
    _markers = _stations.map((station) {
      return Marker(
        point: LatLng(station.location.latitude, station.location.longitude),
        width: 40,
        height: 40,
        child: Icon(
          Icons.ev_station,
          color: station.isAvailable ? Colors.green : Colors.red,
          size: 30,
        ),
      );
    }).toList();
  }
}
