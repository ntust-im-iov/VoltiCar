import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // Required for LatLng
import 'package:provider/provider.dart';
import 'package:volticar_app/features/home/viewmodels/map_provider.dart';
import 'package:volticar_app/features/home/models/parking_lot_model.dart';

class MapOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const MapOverlay({super.key, required this.onClose});

  @override
  MapOverlayState createState() => MapOverlayState();
}

class MapOverlayState extends State<MapOverlay> {
  @override
  void initState() {
    super.initState();
    // 在下一個 frame 後執行，確保地圖已經初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialStations();
    });
  }

  // 載入初始充電站數據
  void _loadInitialStations() {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    // 如果還沒有載入任何數據，則載入初始區域的充電站
    if (mapProvider.markers.isEmpty) {
      // 計算初始地圖的邊界範圍（基於 initialCenter 和 initialZoom）
      const initialCenter = LatLng(25.0340, 121.5645); // 台北市
      const initialZoom = 10.0;

      // 根據縮放級別估算可視範圍（粗略計算）
      final latDelta = 1.0 / (initialZoom * 0.1); // 簡化的計算方式
      final lngDelta = 1.0 / (initialZoom * 0.1);

      mapProvider.fetchAndSetStationMarkers(
        minLat: initialCenter.latitude - latDelta,
        maxLat: initialCenter.latitude + latDelta,
        minLon: initialCenter.longitude - lngDelta,
        maxLon: initialCenter.longitude + lngDelta,
        currentZoom: initialZoom,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        return Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1638),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: const Color(0xFF5C4EB4), width: 4.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: FlutterMap(
                        mapController: mapProvider
                            .mapController, // 使用 MapProvider 中的 MapController
                        options: MapOptions(
                          initialCenter:
                              const LatLng(25.0340, 121.5645), // 初始中心點 (例如台北市)
                          initialZoom: 10.0, // 初始縮放級別，可以調整以便看到更多標記
                          onPositionChanged: (position, hasGesture) {
                            // 移除原本的 hasGesture 限制，讓初始載入也能觸發
                            final bounds = position.visibleBounds;
                            final center = position.center;
                            mapProvider.onMapPositionChanged(bounds, center);
                          },
                          onMapReady: () {
                            // 地圖準備完成後，再次確保載入充電站數據
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              if (mounted && mapProvider.markers.isEmpty) {
                                final bounds = mapProvider
                                    .mapController.camera.visibleBounds;
                                final center =
                                    mapProvider.mapController.camera.center;
                                mapProvider.onMapPositionChanged(
                                    bounds, center);
                              }
                            });
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'com.example.volticar', // 替換為您的應用包名
                          ),
                          if (mapProvider.markers.isNotEmpty)
                            MarkerLayer(markers: mapProvider.markers),
                        ],
                      ),
                    ),
                    // 優化的載入指示器，避免閃爍
                    if (mapProvider.isLoading)
                      Container(
                        color: Colors.black.withValues(alpha: 0.1),
                        child: const Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF5C4EB4)),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(Icons.close,
                            color: Color(0xFF5C4EB4), size: 30),
                        onPressed: widget.onClose,
                        tooltip: '關閉地圖',
                      ),
                    ),
                    _buildSearchAndFilterUI(context, mapProvider),
                    _buildMapInfoFooter(context, mapProvider), // 添加左下角地圖資訊
                    _buildMapControlsUI(context, mapProvider), // 添加右下角地圖控制按鈕
                    // 顯示停車場詳細資訊
                    if (mapProvider.selectedParkingDetail != null)
                      _buildParkingDetailSheet(context, mapProvider),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 構建搜索和篩選 UI 的輔助方法
  Widget _buildSearchAndFilterUI(
      BuildContext context, MapProvider mapProvider) {
    return Positioned(
      top: 10,
      left: 10,
      right: 60, // 為關閉按鈕留出空間
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                style: const TextStyle(color: Colors.black), // 確保文字顏色可見
                keyboardType: TextInputType.text, // 明確指定鍵盤類型
                decoration: InputDecoration(
                  hintText: mapProvider.isParkingMap
                      ? '搜尋停車場名稱或地址...'
                      : '搜尋充電站名稱或地址...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (value) {
                  mapProvider.updateSearchQuery(value); // 調用 MapProvider 更新搜索查詢
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.grey),
              onPressed: () {
                // TODO: 實現打開篩選器對話框或頁面的邏輯
                _showFilterDialog(context, mapProvider);
              },
              tooltip: mapProvider.isParkingMap ? '篩選停車場' : '篩選充電站',
            ),
          ],
        ),
      ),
    );
  }

  // 顯示篩選器對話框
  void _showFilterDialog(BuildContext context, MapProvider mapProvider) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // 使用 StatefulBuilder 來管理對話框內的局部狀態
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1F1638),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF5C4EB4), width: 2),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5C4EB4), Color(0xFF8976FF)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '篩選充電站',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                constraints: const BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // 充電槍規格篩選區塊
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F0A1F).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                const Color(0xFF5C4EB4).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF06D6A0)
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.electrical_services,
                                    color: Color(0xFF06D6A0),
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '充電槍規格',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '選擇您需要的充電槍類型',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // 充電槍類型選項
                            ...mapProvider.availableConnectorTypes
                                .map((connectorType) {
                              final isSelected = mapProvider
                                  .selectedConnectorTypes
                                  .contains(connectorType);
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF5C4EB4)
                                          .withValues(alpha: 0.2)
                                      : const Color(0xFF1F1638)
                                          .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF5C4EB4)
                                        : Colors.white.withValues(alpha: 0.1),
                                    width: 1,
                                  ),
                                ),
                                child: CheckboxListTile(
                                  title: Text(
                                    connectorType,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.8),
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        mapProvider.addConnectorTypeFilter(
                                            connectorType);
                                      } else {
                                        mapProvider.removeConnectorTypeFilter(
                                            connectorType);
                                      }
                                    });
                                  },
                                  activeColor: const Color(0xFF5C4EB4),
                                  checkColor: Colors.white,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  dense: true,
                                ),
                              );
                            }),
                            if (mapProvider.availableConnectorTypes.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color:
                                          Colors.orange.withValues(alpha: 0.8),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '暫無可用的充電槍類型',
                                        style: TextStyle(
                                          color: Colors.orange
                                              .withValues(alpha: 0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 其他篩選選項
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F0A1F).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                const Color(0xFF5C4EB4).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF5E5B)
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.settings,
                                    color: Color(0xFFFF5E5B),
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '其他條件',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: mapProvider.filterOnlyAvailable
                                    ? const Color(0xFF06D6A0)
                                        .withValues(alpha: 0.2)
                                    : const Color(0xFF1F1638)
                                        .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: mapProvider.filterOnlyAvailable
                                      ? const Color(0xFF06D6A0)
                                      : Colors.white.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                              child: CheckboxListTile(
                                title: const Text(
                                  '僅顯示可用充電站',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  '隱藏維修中或故障的充電站',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 12,
                                  ),
                                ),
                                value: mapProvider.filterOnlyAvailable,
                                onChanged: (bool? value) {
                                  setState(() {
                                    mapProvider
                                        .setFilterOnlyAvailable(value ?? false);
                                  });
                                },
                                activeColor: const Color(0xFF06D6A0),
                                checkColor: Colors.white,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withValues(alpha: 0.7),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: const Text('重置'),
                  onPressed: () {
                    setState(() {
                      mapProvider.clearAllFilters();
                    });
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withValues(alpha: 0.7),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: const Text('取消'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C4EB4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('套用'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMapInfoFooter(BuildContext context, MapProvider mapProvider) {
    // 根據地圖類型獲取當前視野範圍內的數量
    final int visibleCount = mapProvider.isParkingMap
        ? mapProvider.visibleParkingCount // 當前視野範圍內的停車場數量
        : mapProvider.visibleStationCount; // 當前視野範圍內的充電站數量

    // 獲取總載入數量（用於顯示比例）
    // final int totalCount = mapProvider.isParkingMap
    //     ? mapProvider.parkingLots.length
    //     : mapProvider.stations.length;

    final centerLat =
        mapProvider.currentMapCenter?.latitude.toStringAsFixed(4) ?? 'N/A';
    final centerLon =
        mapProvider.currentMapCenter?.longitude.toStringAsFixed(4) ?? 'N/A';

    // 根據地圖類型決定顯示文字和顏色
    final String markerType = mapProvider.isParkingMap ? '停車場' : '充電站';
    final Color backgroundColor = mapProvider.isParkingMap
        ? const Color(0xFF2196F3).withValues(alpha: 0.75) // 停車場：藍色
        : const Color(0xFF4CAF50).withValues(alpha: 0.75); // 充電站：綠色

    return Positioned(
      bottom: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$markerType: $visibleCount',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              '中心座標: $centerLat, $centerLon',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControlsUI(BuildContext context, MapProvider mapProvider) {
    return Positioned(
      bottom: 10,
      right: 10,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // P字型停車場切換按鈕
          FloatingActionButton(
            heroTag: 'mapTypeToggleBtn', // 確保 heroTag 唯一
            mini: true,
            onPressed: () {
              mapProvider.toggleMapType();
            },
            backgroundColor: mapProvider.isParkingMap
                ? const Color(0xFF2196F3).withValues(alpha: 0.9) // 停車場模式：藍色
                : const Color(0xFF4CAF50).withValues(alpha: 0.9), // 充電站模式：綠色
            tooltip: mapProvider.isParkingMap ? '切換到充電站地圖' : '切換到停車場地圖',
            child: Text(
              'P',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12), // 增加間距以區分功能區域
          FloatingActionButton(
            heroTag: 'zoomInBtn', // 確保 heroTag 唯一
            mini: true,
            onPressed: mapProvider.zoomIn,
            backgroundColor: const Color(0xFF5C4EB4).withValues(alpha: 0.8),
            tooltip: '放大',
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoomOutBtn', // 確保 heroTag 唯一
            mini: true,
            onPressed: mapProvider.zoomOut,
            backgroundColor: const Color(0xFF5C4EB4).withValues(alpha: 0.8),
            tooltip: '縮小',
            child: const Icon(Icons.remove, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'gpsBtn', // 確保 heroTag 唯一
            mini: true,
            onPressed: mapProvider.moveToCurrentUserLocation,
            backgroundColor: const Color(0xFF5C4EB4).withValues(alpha: 0.8),
            tooltip: '定位到當前位置',
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // 顯示停車場詳細資訊底部彈窗
  Widget _buildParkingDetailSheet(BuildContext context, MapProvider mapProvider) {
    final parking = mapProvider.selectedParkingDetail!;
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1638),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: const Color(0xFF5C4EB4), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 標題和狀態
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      parking.parkingName,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (parking.availableSpaces != null && parking.availableSpaces! > 0) 
                          ? Colors.green 
                          : Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      parking.availableSpaces != null 
                          ? '${parking.availableSpaces}/${parking.totalSpaces ?? 0} 可用'
                          : '停車場',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              
              // 地址資訊
              if (parking.address?.isNotEmpty == true)
                _buildInfoRow(Icons.location_on, '地址', parking.address!, Colors.orange),
              
              if (parking.address?.isNotEmpty == true) 
                Divider(color: Colors.white.withValues(alpha: 0.2)),
              
              // 停車位資訊
              if (parking.totalSpaces != null) ...[
                _buildInfoRow(Icons.local_parking, '總停車位', '${parking.totalSpaces} 個', Colors.orange),
                Divider(color: Colors.white.withValues(alpha: 0.2)),
              ],
              
              if (parking.availableSpaces != null) ...[
                _buildInfoRow(Icons.check_circle, '可用停車位', '${parking.availableSpaces} 個', Colors.orange),
                Divider(color: Colors.white.withValues(alpha: 0.2)),
              ],
              
              // 費率資訊
              if (parking.parkingRate?.isNotEmpty == true) ...[
                _buildInfoRow(Icons.attach_money, '停車費率', parking.parkingRate!, Colors.orange),
                Divider(color: Colors.white.withValues(alpha: 0.2)),
              ],
              
              // 營業時間
              if (parking.operatingHours?.isNotEmpty == true) ...[
                _buildInfoRow(Icons.access_time, '營業時間', parking.operatingHours!, Colors.orange),
                Divider(color: Colors.white.withValues(alpha: 0.2)),
              ],
              
              // 聯絡電話
              if (parking.telephone?.isNotEmpty == true) ...[
                _buildInfoRow(Icons.phone, '聯絡電話', parking.telephone!, Colors.orange),
                Divider(color: Colors.white.withValues(alpha: 0.2)),
              ],
              
              // 描述資訊
              if (parking.description?.isNotEmpty == true) ...[
                _buildInfoRow(Icons.info, '說明', parking.description!, Colors.orange),
                Divider(color: Colors.white.withValues(alpha: 0.2)),
              ],
              
              SizedBox(height: 20),
              // 按鈕區域
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => mapProvider.clearSelectedParkingDetail(),
                    child: Text('關閉', style: TextStyle(color: Colors.white70)),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      _navigateToParking(parking);
                    },
                    icon: Icon(Icons.directions),
                    label: Text('導航'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  // 資訊行建構器
  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 導航到停車場
  void _navigateToParking(ParkingLot parking) {
    // 暫時顯示提示訊息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('導航到 ${parking.parkingName}'),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: '確定',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

}
