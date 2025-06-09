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
  List<String> _selectedConnectorTypes = []; // 新增：選中的充電槍類型
  List<String> _availableConnectorTypes = [
    'CCS1', 'CCS2', 'CHAdeMO', 'Tesla TPC', 'J1772(Type1)', 'Mennekes(Type2)'
  ]; // 新增：可用的充電槍類型，初始化時提供常見類型

  bool get filterOnlyAvailable => _filterOnlyAvailable;
  String get searchQuery => _searchQuery;
  List<String> get selectedConnectorTypes => _selectedConnectorTypes;
  List<String> get availableConnectorTypes => _availableConnectorTypes;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await fetchAndSetStationMarkers(); // 首次加載數據
    _updateAvailableConnectorTypes(); // 更新可用的充電槍類型
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
    final zoomLevel;
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
    _logger.i(
        'Fetching stations with dynamic limit: $dynamicLimit based on zoom: $zoomLevel');

    try {
      _stations = await _stationService.getStationsOverview(
        minLat: minLat,
        minLon: minLon,
        maxLat: maxLat,
        maxLon: maxLon,
        limit: dynamicLimit, // 使用動態計算的 limit
      );

      _logger.i('Fetched ${_stations.length} stations from API.');
      
      // 檢查是否需要從詳細API獲取充電槍資訊
      int stationsWithConnectors = _stations.where((station) => station.connectors.isNotEmpty).length;
      
      if (_stations.isNotEmpty && stationsWithConnectors == 0) {
        _logger.i('正在獲取充電槍類型資訊...');
        await _fetchConnectorTypesFromDetails();
      }

      _markers = _stations.map((station) {
        return Marker(
          width: 40.0, // 調整標記大小
          height: 40.0, // 調整標記大小
          point: LatLng(station.latitude, station.longitude),
          child: GestureDetector(
            // 使用 GestureDetector 保持點擊區域
            onTap: () {
              _logger.i(
                  'Tapped on station: ${station.stationName}, ID: ${station.stationID}');
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
                    color: Colors.black.withOpacity(0.3),
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
      _logger.e('Error fetching station markers: $e');
      _stations = []; // 出錯時清空原始站點數據
    }

    // 在獲取新數據後，立即應用當前的篩選和搜索條件
    _updateAvailableConnectorTypes(); // 在新數據後更新可用的充電槍類型
    applyFilters();
    // applyFilters 內部會設置 _isLoading = false 和 notifyListeners()，所以這裡不再需要

    // _isLoading = false; // 由 applyFilters 處理
    // notifyListeners(); // 由 applyFilters 處理
  }

  Timer? _debounceTimer;

  void onMapPositionChanged(LatLngBounds bounds, LatLng? center) {
    // 修改：接收 center
    if (center != null) {
      _currentMapCenter = center;
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

  void applyFilters() {
    _isLoading = true;
    notifyListeners();

    List<ChargingStation> filteredStations = _stations;

    // 1. 應用 "僅顯示可用" 篩選
    if (_filterOnlyAvailable) {
      // TODO: 實現可用性篩選邏輯
    }

    // 2. 應用充電槍類型篩選
    if (_selectedConnectorTypes.isNotEmpty) {
      int stationsWithConnectors = filteredStations.where((s) => s.connectors.isNotEmpty).length;
      
      if (stationsWithConnectors == 0) {
        // 使用模擬篩選邏輯
        filteredStations = filteredStations.where((station) {
          int stationHash = station.stationID.hashCode.abs();
          List<String> simulatedTypes = [
            'CCS1', 'CCS2', 'CHAdeMO', 'Tesla TPC', 'J1772(Type1)', 'Mennekes(Type2)'
          ];
          
          int typeCount = (stationHash % 3) + 1;
          Set<String> stationTypes = <String>{};
          for (int i = 0; i < typeCount; i++) {
            int typeIndex = (stationHash + i) % simulatedTypes.length;
            stationTypes.add(simulatedTypes[typeIndex]);
          }
          
          return _selectedConnectorTypes.any((selectedType) => stationTypes.contains(selectedType));
        }).toList();
        
      } else {
        // 使用真實的connector數據
        filteredStations = filteredStations.where((station) {
          if (station.connectors.isEmpty) return false;
          
          return station.connectors.any((connector) {
            return _selectedConnectorTypes.contains(connector.typeDescription);
          });
        }).toList();
      }
    }

    // 3. 應用搜索查詢
    if (_searchQuery.isNotEmpty) {
      String query = _searchQuery.toLowerCase();
      filteredStations = filteredStations.where((station) {
        return station.stationName.toLowerCase().contains(query) ||
            (station.fullAddress?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // 根據過濾後的站點重新生成 markers
    _markers = filteredStations.map((station) {
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
                  color: Colors.black.withOpacity(0.3),
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

    _isLoading = false;
    notifyListeners();
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
      _logger.e('Error fetching station details: $e');
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

  void _updateAvailableConnectorTypes() {
    Set<String> types = <String>{};
    
    for (var station in _stations) {
      for (var connector in station.connectors) {
        types.add(connector.typeDescription);
      }
    }
    
    if (types.isNotEmpty) {
      _availableConnectorTypes = types.toList();
    }
    
    notifyListeners();
  }

  // 充電槍類型篩選相關方法
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

  Future<void> _fetchConnectorTypesFromDetails() async {
    int fetchCount = _stations.length > 10 ? 10 : _stations.length;
    Set<String> detectedTypes = <String>{};
    
    for (int i = 0; i < fetchCount; i++) {
      try {
        String stationId = _stations[i].stationID;
        ChargingStation? detailStation = await _stationService.getStationById(stationId);
        
        if (detailStation != null && detailStation.connectors.isNotEmpty) {
          for (var connector in detailStation.connectors) {
            String typeDesc = connector.typeDescription;
            if (typeDesc.isNotEmpty && typeDesc != '未知類型') {
              detectedTypes.add(typeDesc);
            }
          }
        }
        
        if (detectedTypes.length >= 5) break;
        
      } catch (e) {
        // 忽略個別錯誤，繼續處理
      }
    }
    
    if (detectedTypes.isNotEmpty) {
      _availableConnectorTypes = detectedTypes.toList()..sort();
      notifyListeners();
    }
  }
}
