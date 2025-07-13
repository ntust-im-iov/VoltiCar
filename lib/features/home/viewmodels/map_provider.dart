import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:volticar_app/features/home/models/charging_station_model.dart';
import 'package:volticar_app/features/home/services/station_service.dart';
import 'package:logger/logger.dart';
import 'dart:async'; // Import for Timer
import 'package:geolocator/geolocator.dart'; // For GPS functionality
// flutter_map.dart 已經在頂部導入，MapController 應該可以直接使用

class MapProvider extends ChangeNotifier {
  final StationService _stationService = StationService();
  final Logger _logger = Logger();
  final MapController mapController = MapController(); // 新增 MapController

  bool _isInitialized = false;
  List<ChargingStation> _stations = [];
  List<Marker> _markers = [];
  bool _isLoading = false;
  LatLng? _currentMapCenter; // 新增：存儲地圖中心點
  ChargingStation? _selectedStationDetail; // 新增：存儲選中充電站的詳細資訊
  bool _isFetchingDetail = false; // 新增：標記是否正在獲取詳細資訊

  bool get isInitialized => _isInitialized;
  List<Marker> get markers => _markers;
  List<ChargingStation> get stations => _stations; // 可以選擇性地暴露原始站點數據
  bool get isLoading => _isLoading; // 恢復原始載入邏輯
  LatLng? get currentMapCenter => _currentMapCenter; // 新增：getter
  ChargingStation? get selectedStationDetail =>
      _selectedStationDetail; // 新增：getter
  bool get isFetchingDetail => _isFetchingDetail; // 新增：getter

  // Filter states
  bool _filterOnlyAvailable = false;
  String _searchQuery = '';
  final List<String> _selectedConnectorTypes = []; // 新增：選中的充電槍類型
  List<String> _availableConnectorTypes = []; // 新增：可用的充電槍類型，將從實際數據中動態獲取

  bool get filterOnlyAvailable => _filterOnlyAvailable;
  String get searchQuery => _searchQuery;
  List<String> get selectedConnectorTypes => _selectedConnectorTypes;
  List<String> get availableConnectorTypes => _availableConnectorTypes;
  
  // 新增缺失的 getter
  List<ChargingStation> _filteredStations = [];
  List<ChargingStation> get filteredStations => _filteredStations;
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

  Future<void> fetchAndSetStationMarkers({
    double? minLat,
    double? minLon,
    double? maxLat,
    double? maxLon,
    double? currentZoom, // 新增：接收當前縮放級別
  }) async {

    _isLoading = true;
    notifyListeners();

    // 根據縮放級別動態計算 limit
    // 如果 currentZoom 未提供，則嘗試從 mapController 獲取
    final double zoomLevel;
    if (currentZoom == null) {
      zoomLevel = MapOptions().initialZoom;
    } else {
      zoomLevel = currentZoom;
    }
    int dynamicLimit = 50; // 預設值
    if (zoomLevel < 8) {
      dynamicLimit = 30;
    } else if (zoomLevel < 10) {
      dynamicLimit = 50;
    } else if (zoomLevel < 12) {
      dynamicLimit = 100;
    } else if (zoomLevel < 14) {
      dynamicLimit = 150;
    } else {
      dynamicLimit = 200; // 更高的縮放級別，請求更多站點 (API 上限可能是 1000 或 200)
    }
    // 移除詳細的動態 limit 日誌

    try {
      final stations = await _stationService.getStationsWithDetails(
        minLat: minLat,
        minLon: minLon,
        maxLat: maxLat,
        maxLon: maxLon,
        limit: dynamicLimit, // 使用動態計算的 limit
      );

      _stations = stations;
      _filteredStations = stations;
      
      // 簡化日誌輸出
      int stationsWithConnectors = _stations.where((station) => station.connectors.isNotEmpty).length;
      _logger.i('地圖載入: ${_stations.length}站 (有connector:$stationsWithConnectors)');

      _markers = _stations.map((station) {
        return Marker(
          width: 40.0, // 調整標記大小
          height: 40.0, // 調整標記大小
          point: LatLng(station.latitude, station.longitude),
          child: GestureDetector(
            // 使用 GestureDetector 保持點擊區域
            onTap: () {
              selectStation(station.stationID);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green, // 外圈綠色背景
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.0), // 白色邊框
                boxShadow: [
                  // 可選：添加一點陰影使其更突出
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.ev_station, // 中間的充電站圖示
                color: Colors.white, // 圖示顏色改為白色
                size: 20.0, // 調整圖示大小
              ),
            ),
          ),
        );
      }).toList();
    } catch (e) {
      _logger.e('載入充電站失敗: $e');
      _stations = [];
      _filteredStations = [];
    }

    // 在獲取新數據後，立即應用當前的篩選條件
    _updateAvailableConnectorTypes(); // 記錄發現的充電槍類型
    applyFilters(); // 應用篩選並更新 UI
  }

  Timer? _debounceTimer;
  bool _isFirstLoad = true; // 新增：標記是否為首次載入

  void onMapPositionChanged(LatLngBounds bounds, LatLng? center) {
    // 修改：接收 center
    if (center != null) {
      _currentMapCenter = center;
    }
    
    // 如果是首次載入，立即執行，不使用 debounce
    if (_isFirstLoad) {
      _isFirstLoad = false;
      final currentZoom = mapController.camera.zoom;
      fetchAndSetStationMarkers(
        minLat: bounds.southWest.latitude,
        minLon: bounds.southWest.longitude,
        maxLat: bounds.northEast.latitude,
        maxLon: bounds.northEast.longitude,
        currentZoom: currentZoom,
      );
      _currentMapCenter = mapController.camera.center;
      notifyListeners();
      return;
    }
    
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      // 恢復原來的1000ms延遲
      
      final currentZoom = mapController.camera.zoom;
      fetchAndSetStationMarkers(
        minLat: bounds.southWest.latitude,
        minLon: bounds.southWest.longitude,
        maxLat: bounds.northEast.latitude,
        maxLon: bounds.northEast.longitude,
        currentZoom: currentZoom,
      );
      _currentMapCenter = mapController.camera.center;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
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
    _logger.i('篩選: ${_stations.length}站 -> 搜索:"$_searchQuery", 可用:$_filterOnlyAvailable, 類型:$_selectedConnectorTypes');
    
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
        if (typeDesc.isNotEmpty && typeDesc != '未知類型' && typeDesc != 'Unknown') {
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
          _currentMapCenter!.latitude,
          _currentMapCenter!.longitude,
          radius
        );
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
