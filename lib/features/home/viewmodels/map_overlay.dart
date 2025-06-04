import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // Required for LatLng
import 'package:provider/provider.dart';
import 'map_provider.dart'; // Import MapProvider

class MapOverlay extends StatelessWidget {
  final VoidCallback onClose;

  const MapOverlay({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        return Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.5), // Semi-transparent background
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1638),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF5C4EB4), width: 4.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
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
                        mapController: mapProvider.mapController, // 使用 MapProvider 中的 MapController
                        options: MapOptions(
                          initialCenter: const LatLng(25.0340, 121.5645), // 初始中心點 (例如台北市)
                          initialZoom: 10.0, // 初始縮放級別，可以調整以便看到更多標記
                          onPositionChanged: (position, hasGesture) { // 移除了 MapPosition 類型聲明
                            if (hasGesture) {
                              // 用戶手動改變地圖視角時，獲取新的邊界並請求更新充電站
                              final bounds = position.visibleBounds; // 使用 visibleBounds
                              final center = position.center;
                              if (bounds != null) {
                                mapProvider.onMapPositionChanged(bounds, center); // 調用新的 debounce 方法並傳遞中心點
                              }
                            }
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.volticar', // 替換為您的應用包名
                          ),
                          if (mapProvider.markers.isNotEmpty)
                            MarkerLayer(markers: mapProvider.markers),
                        ],
                      ),
                    ),
                    if (mapProvider.isLoading)
                      const Center(child: CircularProgressIndicator()),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(Icons.close,
                            color: Color(0xFF5C4EB4), size: 30),
                        onPressed: onClose,
                        tooltip: '關閉地圖',
                      ),
                    ),
                    _buildSearchAndFilterUI(context, mapProvider), // 添加搜索和篩選 UI
                    _buildMapInfoFooter(context, mapProvider), // 添加左下角地圖資訊
                    _buildMapControlsUI(context, mapProvider), // 添加右下角地圖控制按鈕
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
  Widget _buildSearchAndFilterUI(BuildContext context, MapProvider mapProvider) {
    return Positioned(
      top: 10,
      left: 10,
      right: 60, // 為關閉按鈕留出空間
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
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
                decoration: const InputDecoration(
                  hintText: '搜尋充電站名稱或地址...',
                  hintStyle: TextStyle(color: Colors.grey),
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
              tooltip: '篩選充電站',
            ),
          ],
        ),
      ),
    );
  }

  // 顯示篩選器對話框 (示例)
  void _showFilterDialog(BuildContext context, MapProvider mapProvider) {
    // TODO: 實現更完整的篩選器 UI 和邏輯
    // 為了讓 CheckboxListTile 能夠在對話框內更新其狀態，
    // AlertDialog 的 content 通常需要是一個 StatefulWidget，或者使用 StatefulBuilder。
    // 這裡我們先用一個簡單的結構，實際應用中可能需要調整。
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // 使用 StatefulBuilder 來管理對話框內的局部狀態
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('篩選充電站'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CheckboxListTile(
                    title: const Text('僅顯示可用'),
                    value: mapProvider.filterOnlyAvailable, // 假設 MapProvider 有此狀態
                    onChanged: (bool? value) {
                      setState(() { // 更新對話框內的狀態
                        mapProvider.setFilterOnlyAvailable(value ?? false); // 假設 MapProvider 有此方法
                      });
                    },
                  ),
                  // 可以添加更多篩選條件
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('取消'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child: const Text('套用'),
                  onPressed: () {
                    mapProvider.applyFilters(); // 假設 MapProvider 有此方法來觸發過濾
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
    final stationCount = mapProvider.markers.length;
    final centerLat = mapProvider.currentMapCenter?.latitude.toStringAsFixed(4) ?? 'N/A';
    final centerLon = mapProvider.currentMapCenter?.longitude.toStringAsFixed(4) ?? 'N/A';

    return Positioned(
      bottom: 10,
      left: 10,
      // 移除了 right: 10，讓寬度由內容決定或設置一個 max/min width
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF5C4EB4).withOpacity(0.75), // 紫色半透明背景
          borderRadius: BorderRadius.circular(8),
          boxShadow: [ // 可以添加一點陰影使其更突出
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
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
              '充電站: $stationCount',
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
          FloatingActionButton(
            heroTag: 'zoomInBtn', // 確保 heroTag 唯一
            mini: true,
            onPressed: mapProvider.zoomIn,
            backgroundColor: const Color(0xFF5C4EB4).withOpacity(0.8),
            child: const Icon(Icons.add, color: Colors.white),
            tooltip: '放大',
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoomOutBtn', // 確保 heroTag 唯一
            mini: true,
            onPressed: mapProvider.zoomOut,
            backgroundColor: const Color(0xFF5C4EB4).withOpacity(0.8),
            child: const Icon(Icons.remove, color: Colors.white),
            tooltip: '縮小',
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'gpsBtn', // 確保 heroTag 唯一
            mini: true,
            onPressed: mapProvider.moveToCurrentUserLocation,
            backgroundColor: const Color(0xFF5C4EB4).withOpacity(0.8),
            child: const Icon(Icons.my_location, color: Colors.white),
            tooltip: '定位到當前位置',
          ),
        ],
      ),
    );
  }
}
