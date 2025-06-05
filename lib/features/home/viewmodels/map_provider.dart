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
  bool get isLoading => _isLoading;
  LatLng? get currentMapCenter => _currentMapCenter; // 新增：getter
  ChargingStation? get selectedStationDetail => _selectedStationDetail; // 新增：getter
  bool get isFetchingDetail => _isFetchingDetail; // 新增：getter

  // Filter states
  bool _filterOnlyAvailable = false;
  String _searchQuery = '';
  String? _selectedCity;
  List<String> _availableCities = []; // 將在 initialize 中填充

  bool get filterOnlyAvailable => _filterOnlyAvailable;
  String get searchQuery => _searchQuery;
  String? get selectedCity => _selectedCity;
  List<String> get availableCities => _availableCities;

  Future<void> initialize() async {
    if (_isInitialized) return;
    // 初始化可用城市列表 (固定列表)
    _availableCities = _getFixedAvailableCities();
    await fetchAndSetStationMarkers(); // 首次加載數據
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
    // 如果已選擇特定城市，則不應執行基於地理邊界的概覽獲取
    if (_selectedCity != null && _selectedCity!.isNotEmpty) {
      _logger.i('fetchAndSetStationMarkers skipped because a city is selected: $_selectedCity');
      // 可能需要確保在這種情況下 _isLoading 被正確處理，
      // 但通常選擇城市後會調用 fetchStationsByCity，它會管理 isLoading。
      // 如果直接調用此方法而城市已選中，則 markers 可能不會更新。
      // 或者，如果 selectedCity 不為空，此方法應轉為獲取該城市的數據（但這與 fetchStationsByCity 重複）。
      // 最好的做法是，如果 selectedCity 有值，UI 層面就不應該觸發這個概覽獲取。
      // 這裡加個 return，並確保 isLoading 在其他地方被重置。
      // 但如果 setSelectedCity(null) 後調用此方法，則應繼續。
      // 所以這個檢查應該放在 setSelectedCity(null) 的邏輯之後。
      // 目前的 setSelectedCity(null) 會直接調用 fetchAndSetStationMarkers()，這是對的。
      // 這個方法主要是給 onMapPositionChanged 和 initialize 用的。
      // 如果 selectedCity 有值，onMapPositionChanged 就不應該調用它。
      // initialize 時 selectedCity 應為 null。
      // 所以這裡的檢查主要是防止意外調用。
      // 但更合理的做法是在調用方 (onMapPositionChanged) 進行檢查。
      // 我將在 onMapPositionChanged 中加入檢查。
      // 此處暫不修改，讓 onMapPositionChanged 控制。
    }

    _isLoading = true;
    notifyListeners();

    // 根據縮放級別動態計算 limit
    // 如果 currentZoom 未提供，則嘗試從 mapController 獲取
    final zoomLevel = currentZoom ?? mapController.camera.zoom;
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
    _logger.i('Fetching stations with dynamic limit: $dynamicLimit based on zoom: $zoomLevel');

    try {
      _stations = await _stationService.getStationsOverview(
        minLat: minLat,
        minLon: minLon,
        maxLat: maxLat,
        maxLon: maxLon,
        limit: dynamicLimit, // 使用動態計算的 limit
      );

      _markers = _stations.map((station) {
        return Marker(
          width: 40.0, // 調整標記大小
          height: 40.0, // 調整標記大小
          point: LatLng(station.latitude, station.longitude),
          child: GestureDetector( // 使用 GestureDetector 保持點擊區域
            onTap: () {
              _logger.i('Tapped on station: ${station.stationName}, ID: ${station.stationID}');
              selectStation(station.stationID);
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
      // 如果已選擇特定城市，則地圖移動不應觸發基於邊界的重新獲取
      if (_selectedCity != null && _selectedCity!.isNotEmpty) {
        _logger.i('Map position changed but city filter is active ($_selectedCity), skipping overview fetch.');
        // 如果中心點改變，還是需要通知 UI 更新中心座標顯示
        if (center != null && _currentMapCenter == center) {
           notifyListeners();
        } else if (center == null) {
           notifyListeners();
        }
        return;
      }
      _logger.i('Debounced map position change. New bounds: ${bounds.southWest} to ${bounds.northEast}');
      final currentZoom = mapController.camera.zoom; // 從 mapController 獲取當前縮放級別
      fetchAndSetStationMarkers( // 只有在沒有選擇城市時才執行
        minLat: bounds.southWest.latitude,
        minLon: bounds.southWest.longitude,
        maxLat: bounds.northEast.latitude,
        maxLon: bounds.northEast.longitude,
        currentZoom: currentZoom, // 傳遞當前縮放級別
      );
      // 在獲取數據後，使用 mapController 的中心點更新 _currentMapCenter
      // 這可以確保我們使用的是地圖最終穩定後的中心點
      _currentMapCenter = mapController.camera.center;
      _logger.i('Map center updated after debounce: $_currentMapCenter');
      notifyListeners(); // 通知 UI 更新，包括中心座標和可能的標記
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
            _logger.i('Tapped on station: ${station.stationName}, ID: ${station.stationID}');
            selectStation(station.stationID);
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

  Future<void> selectStation(String stationId) async {
    if (_isFetchingDetail) return; // 如果正在獲取，則不重複執行

    _isFetchingDetail = true;
    _selectedStationDetail = null; // 先清除舊的詳細資訊
    notifyListeners();

    try {
      _logger.i('Fetching details for station ID: $stationId');
      final stationDetail = await _stationService.getStationById(stationId);
      if (stationDetail != null) {
        _selectedStationDetail = stationDetail;
        _logger.i('Successfully fetched details for station: ${stationDetail.stationName}');
      } else {
        _logger.w('Could not fetch details for station ID: $stationId or station not found.');
        // 可以在這裡設置一個錯誤狀態或保持 _selectedStationDetail 為 null
      }
    } catch (e) {
      _logger.e('Error in selectStation for ID $stationId: $e');
      _selectedStationDetail = null; // 出錯時確保清除
    } finally {
      _isFetchingDetail = false;
      notifyListeners();
    }
  }

  void clearSelectedStation() {
    _selectedStationDetail = null;
    _isFetchingDetail = false; // 確保也重置這個狀態
    notifyListeners();
    _logger.i('Selected station cleared.');
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

  // --- City Filter Methods ---
  List<String> _getFixedAvailableCities() {
    // 提供一個固定的台灣主要城市列表作為範例
    // 後續可以考慮從 API 或其他來源動態獲取
    return [
      '台北市', '新北市', '桃園市', '臺中市', '臺南市', '高雄市',
      '基隆市', '新竹市', '嘉義市', '新竹縣', '苗栗縣', '彰化縣',
      '南投縣', '雲林縣', '嘉義縣', '屏東縣', '宜蘭縣', '花蓮縣', '臺東縣',
      // '澎湖縣', '金門縣', '連江縣' // 離島視情況加入
    ];
  }

  Future<void> setSelectedCity(String? city) async {
    _selectedCity = city;
    _logger.i('Selected city set to: $_selectedCity');

    if (_selectedCity != null && _selectedCity!.isNotEmpty) {
      await fetchStationsByCity(_selectedCity!);
    } else {
      // 如果清除城市選擇，則重新加載概覽數據 (不按地理邊界，顯示預設概覽)
      await fetchAndSetStationMarkers(); 
    }
    // fetchStationsByCity 和 fetchAndSetStationMarkers 內部會 notifyListeners
  }

  Future<void> fetchStationsByCity(String city) async {
    _isLoading = true;
    _stations = []; // 清空舊站點，因為我們要獲取特定城市的站點
    _markers = [];  // 同時清空標記
    notifyListeners();

    try {
      _stations = await _stationService.getStationsByCity(city);
      _logger.i('Fetched ${_stations.length} stations for city: $city');
    } catch (e) {
      _logger.e('Error fetching stations for city $city: $e');
      _stations = []; // 出錯時確保清空
    }
    
    applyFilters(); // 根據新獲取的 _stations (已按城市篩選) 應用其他篩選並更新 markers
    // applyFilters 內部會設置 _isLoading = false 和 notifyListeners()
  }
}
