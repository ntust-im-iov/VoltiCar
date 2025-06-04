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

  bool get isInitialized => _isInitialized;
  List<Marker> get markers => _markers;
  List<ChargingStation> get stations => _stations; // 可以選擇性地暴露原始站點數據
  bool get isLoading => _isLoading;
  LatLng? get currentMapCenter => _currentMapCenter; // 新增：getter

  // Filter states
  bool _filterOnlyAvailable = false;
  String _searchQuery = '';

  bool get filterOnlyAvailable => _filterOnlyAvailable;
  String get searchQuery => _searchQuery;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await fetchAndSetStationMarkers(); // 首次加載數據
    _isInitialized = true;
    debugPrint('MapProvider initialized and initial markers fetched');
  }

  Future<void> fetchAndSetStationMarkers({
    double? minLat,
    double? minLon,
    double? maxLat,
    double? maxLon,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _stations = await _stationService.getStationsOverview(
        minLat: minLat,
        minLon: minLon,
        maxLat: maxLat,
        maxLon: maxLon,
        limit: 50, // 示例：限制首次加載數量，可以根據地圖縮放級別調整
      );

      _markers = _stations.map((station) {
        return Marker(
          width: 40.0, // 調整標記大小
          height: 40.0, // 調整標記大小
          point: LatLng(station.latitude, station.longitude),
          child: GestureDetector( // 使用 GestureDetector 保持點擊區域
            onTap: () {
              _logger.i('Tapped on station: ${station.stationName}');
              // TODO: 實現點擊標記後的動作，例如顯示詳細資訊彈窗
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green, // 外圈綠色背景
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.0), // 白色邊框
                boxShadow: [ // 可選：添加一點陰影使其更突出
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
      _logger.i('Fetched ${_stations.length} raw stations from API.');
    } catch (e) {
      _logger.e('Error fetching station markers: $e');
      _stations = []; // 出錯時清空原始站點數據
    }
    
    // 在獲取新數據後，立即應用當前的篩選和搜索條件
    applyFilters(); 
    // applyFilters 內部會設置 _isLoading = false 和 notifyListeners()，所以這裡不再需要

    // _isLoading = false; // 由 applyFilters 處理
    // notifyListeners(); // 由 applyFilters 處理
  }

  Timer? _debounceTimer;

  void onMapPositionChanged(LatLngBounds bounds, LatLng? center) { // 修改：接收 center
    if (center != null) {
      _currentMapCenter = center;
      // notifyListeners(); // 如果希望UI立即更新中心座標，則取消註解，但可能導致頻繁刷新
    }
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 700), () { // 700ms 的延遲
      _logger.i('Debounced map position change. New bounds: ${bounds.southWest} to ${bounds.northEast}');
      fetchAndSetStationMarkers(
        minLat: bounds.southWest.latitude,
        minLon: bounds.southWest.longitude,
        maxLat: bounds.northEast.latitude,
        maxLon: bounds.northEast.longitude,
      );
      // 在獲取數據後通知，這樣中心座標和站點數量可以一起更新
      if (center != null && _currentMapCenter == center) { // 確保是同一次的中心點
         notifyListeners();
      } else if (center == null) {
         notifyListeners(); // 如果沒有中心點資訊，也更新
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void setFilterOnlyAvailable(bool value) {
    _filterOnlyAvailable = value;
    // 通常在調用 applyFilters 時才 notifyListeners，或者如果希望立即響應則在這裡調用
    // notifyListeners(); 
    _logger.i('Filter only available set to: $value');
    // 立即應用篩選或等待 applyFilters 被調用
    applyFilters(); 
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    // notifyListeners(); // 同上，通常在 applyFilters 中統一處理
    _logger.i('Search query updated to: $query');
    applyFilters();
  }

  void applyFilters() {
    _isLoading = true;
    notifyListeners();

    List<ChargingStation> filteredStations = _stations; // 從原始的完整列表開始

    // 1. 應用 "僅顯示可用" 篩選 (假設 ChargingStation 有 'isAvailable' 或類似屬性)
    if (_filterOnlyAvailable) {
      // filteredStations = filteredStations.where((station) => station.isAvailable).toList();
      // TODO: 實際的 'isAvailable' 邏輯需要根據 ChargingStation 模型和 API 數據來確定
      // 暫時我們先假設所有站點都符合，或者您可以根據現有欄位（如 ChargingPoints > 0）做一個簡單判斷
       _logger.i('Applying filter: Only Available (Not yet fully implemented)');
    }

    // 2. 應用搜索查詢 (根據站點名稱或地址)
    if (_searchQuery.isNotEmpty) {
      String query = _searchQuery.toLowerCase();
      filteredStations = filteredStations.where((station) {
        return station.stationName.toLowerCase().contains(query) ||
               (station.fullAddress?.toLowerCase().contains(query) ?? false); // 假設有 fullAddress
      }).toList();
      _logger.i('Applying search query: $_searchQuery. Found ${filteredStations.length} stations.');
    }

    // 根據過濾後的站點重新生成 markers
    // 如果 filteredStations 為空，_markers 也會為空
    _markers = filteredStations.map((station) {
      return Marker(
        width: 40.0,
        height: 40.0,
        point: LatLng(station.latitude, station.longitude),
        child: GestureDetector(
          onTap: () {
            _logger.i('Tapped on station: ${station.stationName}');
            // TODO: 實現點擊標記後的動作
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green, // 保持之前的樣式
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
    
    _isLoading = false; // 在 applyFilters 的末尾設置 isLoading
    notifyListeners();
    _logger.i('Filters applied. Displaying ${_markers.length} markers.');
  }

  // --- Map Control Methods ---
  void zoomIn() {
    final currentZoom = mapController.camera.zoom;
    mapController.move(mapController.camera.center, currentZoom + 1);
    _logger.i('Map zoomed in to ${currentZoom + 1}');
  }

  void zoomOut() {
    final currentZoom = mapController.camera.zoom;
    mapController.move(mapController.camera.center, currentZoom - 1);
    _logger.i('Map zoomed out to ${currentZoom - 1}');
  }

  Future<void> moveToCurrentUserLocation() async {
    _isLoading = true;
    notifyListeners();
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      _logger.i('Location service enabled: $serviceEnabled'); // 詳細日誌
      if (!serviceEnabled) {
        _logger.w('Location services are disabled.');
        // TODO: Optionally, prompt user to enable location services
        _isLoading = false;
        notifyListeners();
        return;
      }

      permission = await Geolocator.checkPermission();
      _logger.i('Initial permission status: $permission'); // 詳細日誌

      if (permission == LocationPermission.denied) {
        _logger.i('Permission was denied, attempting to request permission...'); // 詳細日誌
        permission = await Geolocator.requestPermission();
        _logger.i('Permission status after request: $permission'); // 詳細日誌

        if (permission == LocationPermission.denied) {
          _logger.w('Location permissions are still denied after request.');
          // TODO: Optionally, inform user that permission is needed
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _logger.w('Location permissions are permanently denied.');
        // TODO: Optionally, direct user to app settings
        _isLoading = false;
        notifyListeners();
        return;
      }

      _logger.i('Permission granted. Attempting to get current position...');
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium); // 嘗試降低精度
        _logger.i('Successfully got position: $position');
      } catch (e) {
        _logger.e('Error getting current position: $e');
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      final userLocation = LatLng(position.latitude, position.longitude);
      _logger.i('User location: $userLocation. Attempting to move map...');
      try {
        mapController.move(userLocation, mapController.camera.zoom); // 或者一個預設的縮放級別，例如 15.0
        _currentMapCenter = userLocation; // 更新地圖中心點
        _logger.i('Map moved to current user location: $userLocation');
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
}
