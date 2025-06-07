import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:volticar_app/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:volticar_app/features/home/models/charging_station_model.dart'; // 新增匯入
import '../viewmodels/map_provider.dart';
import '../viewmodels/map_overlay.dart';

class ChargingView extends StatefulWidget {
  const ChargingView({super.key});

  @override
  State<ChargingView> createState() => _ChargingViewState();
}

class _ChargingViewState extends State<ChargingView> {
  final _logger = Logger();

  // 充電狀態變量
  double _batteryLevel = 0.45; // 初始電池電量
  bool _isCharging = false; // 充電狀態
  int _chargingSpeed = 0; // 充電速度 (kW)
  int _estimatedTimeRemaining = 0; // 剩餘充電時間 (分鐘)
  bool _isMapVisible = false; // 地圖顯示狀態
  bool _isStationDetailSheetVisible = false; // 新增：追蹤詳細資訊表單是否可見

  @override
  void initState() {
    super.initState();
    _logger.i('ChargingView initialized');

    // 確保MapProvider已初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mapProvider = Provider.of<MapProvider>(context, listen: false);
      if (!mapProvider.isInitialized) {
        mapProvider.initialize();
      }
    });
  }

  // 切換地圖顯示
  void _toggleMap() {
    setState(() {
      _isMapVisible = !_isMapVisible;
    });
  }

  // 關閉地圖
  void _closeMap() {
    setState(() {
      _isMapVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);

    // 使用 addPostFrameCallback 確保在 build 完成後執行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mapProvider.selectedStationDetail != null && !_isStationDetailSheetVisible) {
        _isStationDetailSheetVisible = true; // 標記為已顯示
        _showStationDetailBottomSheet(context, mapProvider.selectedStationDetail!)
            .then((_) {
          // 當 BottomSheet 關閉時
          _isStationDetailSheetVisible = false; // 重置標記
          // 檢查 mapProvider 是否仍然認為有選中的站點，
          // 如果使用者是透過手勢關閉 BottomSheet 而不是透過按鈕，
          // 我們需要通知 mapProvider 清除選中狀態。
          if (mapProvider.selectedStationDetail != null) {
            mapProvider.clearSelectedStation();
          }
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '充電站',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2A1E47),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 添加地圖按鈕
          IconButton(
            icon: const Icon(Icons.map, color: Colors.white),
            onPressed: _toggleMap,
            tooltip: '查看充電站地圖',
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
        color: const Color(0xFF2A1E47),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 充電站信息卡
                _buildChargingStationCard(),

                const SizedBox(height: 24),

                // 電池顯示
                _buildBatteryDisplay(),

                const SizedBox(height: 24),

                // 充電控制
                _buildChargingControls(),

                const SizedBox(height: 24),

                // 充電詳細信息
                _buildChargingDetails(),

                    const SizedBox(height: 24),

                    // 查找充電站按鈕
                    _buildFindChargingStationButton(),
              ],
            ),
          ),
            ),
          ),

          // 地圖覆蓋層
          if (_isMapVisible) _buildMapOverlay(),
        ],
      ),
    );
  }

  // 新增查找充電站按鈕
  Widget _buildFindChargingStationButton() {
    return ElevatedButton.icon(
      onPressed: _toggleMap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5C4EB4),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
      icon: const Icon(Icons.search_outlined),
      label: const Text(
        '查找附近充電站',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 構建地圖覆蓋層
  Widget _buildMapOverlay() {
    // final mapProvider = Provider.of<MapProvider>(context); // MapProvider 可能需要在 Widget Tree 更高層級提供
    // final stationService = Provider.of(context); // 如果 MapOverlay 不再需要 stationService，此行可能也需要移除或修改

    return MapOverlay(
      onClose: _closeMap,
      // stationService: stationService, // stationService 參數已從 MapOverlay 移除
    );
  }

  Widget _buildChargingStationCard() {
    return Card(
      color: const Color(0xFF3A2D5B),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF63588A), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.ev_station,
                  color: Color(0xFFFF6B6B),
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Text(
                  'VoltiCar私人充電站',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('充電功率', style: TextStyle(color: Colors.white70)),
                Text('最高150 kW', style: TextStyle(color: Colors.white)),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('充電接口', style: TextStyle(color: Colors.white70)),
                Text('Type 2 / CCS', style: TextStyle(color: Colors.white)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('狀態', style: TextStyle(color: Colors.white70)),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _isCharging
                            ? const Color(0xFF4CAF50).withOpacity(0.2)
                            : const Color(0xFFFF6B6B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color:
                          _isCharging
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFF6B6B),
                    ),
                  ),
                  child: Text(
                    _isCharging ? '充電中' : '待機中',
                    style: TextStyle(
                      color:
                          _isCharging
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFF6B6B),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryDisplay() {
    return Card(
      color: const Color(0xFF3A2D5B),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF63588A), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 電池電量百分比
            Text(
              '${(_batteryLevel * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // 電池圖示
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: _batteryLevelColor(), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width:
                        MediaQuery.of(context).size.width * 0.8 * _batteryLevel,
                    decoration: BoxDecoration(
                      color: _batteryLevelColor(),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        bottomLeft: Radius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (_isCharging) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt, color: Color(0xFFFFD166)),
                  const SizedBox(width: 4),
                  Text(
                    '充電速度: $_chargingSpeed kW',
                    style: const TextStyle(color: Color(0xFFFFD166)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '預計剩餘時間: $_estimatedTimeRemaining 分鐘',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChargingControls() {
    return Card(
      color: const Color(0xFF3A2D5B),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF63588A), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 充電按鈕
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isCharging = !_isCharging;
                  _chargingSpeed = _isCharging ? 50 : 0;
                  _estimatedTimeRemaining =
                      _isCharging
                          ? (((1.0 - _batteryLevel) * 100 * 60) /
                                  _chargingSpeed)
                              .round()
                          : 0;

                  // 如果開始充電，模擬充電過程
                  if (_isCharging) {
                    Future.delayed(const Duration(seconds: 1), () {
                      _simulateCharging();
                    });
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isCharging
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                _isCharging ? '停止充電' : '開始充電',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 充電速度選擇器（只在未充電時可調整）
            if (!_isCharging) ...[
              const Text(
                '選擇充電功率',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildChargingRateButton(50, '標準'),
                  _buildChargingRateButton(75, '快速'),
                  _buildChargingRateButton(120, '超快'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChargingRateButton(int rate, String label) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _chargingSpeed = rate;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _chargingSpeed == rate
                ? const Color(0xFF63588A)
                : const Color(0xFF2A1E47),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color:
                _chargingSpeed == rate
                    ? const Color(0xFFFFD166)
                    : const Color(0xFF63588A),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            '$rate kW',
            style: TextStyle(
              fontWeight:
                  _chargingSpeed == rate ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color:
                  _chargingSpeed == rate
                      ? const Color(0xFFFFD166)
                      : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargingDetails() {
    return Card(
      color: const Color(0xFF3A2D5B),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF63588A), width: 2),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '充電統計',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('本次充電', style: TextStyle(color: Colors.white70)),
                Text('0.0 kWh', style: TextStyle(color: Colors.white)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('本月充電', style: TextStyle(color: Colors.white70)),
                Text('120.5 kWh', style: TextStyle(color: Colors.white)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('總充電次數', style: TextStyle(color: Colors.white70)),
                Text('42 次', style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 根據電池電量返回顏色
  Color _batteryLevelColor() {
    if (_batteryLevel < 0.2) {
      return const Color(0xFFFF6B6B); // 紅色
    } else if (_batteryLevel < 0.5) {
      return const Color(0xFFFFD166); // 黃色
    } else {
      return const Color(0xFF4CAF50); // 綠色
    }
  }

  // 模擬充電過程
  void _simulateCharging() {
    if (_isCharging && _batteryLevel < 1.0) {
      setState(() {
        // 每秒增加電量
        _batteryLevel += (_chargingSpeed / 10000);
        if (_batteryLevel > 1.0) _batteryLevel = 1.0;

        // 更新剩餘時間
        _estimatedTimeRemaining =
            (((1.0 - _batteryLevel) * 100 * 60) / _chargingSpeed).round();

        // 如果電池已滿，停止充電
        if (_batteryLevel >= 1.0) {
          _isCharging = false;
          _chargingSpeed = 0;
          _estimatedTimeRemaining = 0;
        } else {
          // 否則繼續模擬
          Future.delayed(const Duration(seconds: 1), () {
            _simulateCharging();
          });
        }
      });
    }
  }

  // 顯示充電站詳細資訊的 BottomSheet
  Future<void> _showStationDetailBottomSheet(BuildContext context, ChargingStation station) {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true, // 允許內容滾動且高度可以較大
      backgroundColor: const Color(0xFF3A2D5B), // 背景色與卡片一致
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false, // 不完全展開，允許部分高度
          initialChildSize: 0.6, // 初始高度佔屏幕的60%
          minChildSize: 0.3,   // 最小高度
          maxChildSize: 0.9,   // 最大高度
          builder: (_, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 頂部拖動指示器
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: _buildStationDetailSheetContent(station),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text('關閉'),
                    onPressed: () {
                      Navigator.pop(context); // 關閉 BottomSheet
                      mapProvider.clearSelectedStation(); // 清除選中的站點
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      // 確保在 BottomSheet 關閉時（無論如何關閉）都清除狀態
      _isStationDetailSheetVisible = false;
      if (mapProvider.selectedStationDetail != null) {
         mapProvider.clearSelectedStation();
      }
    });
  }

  // 充電站詳細資訊 BottomSheet 的內容
  Widget _buildStationDetailSheetContent(ChargingStation station) {
    final textStyle = const TextStyle(color: Colors.white, fontSize: 16);
    final labelStyle = TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // 讓 Column 包裹內容
      children: <Widget>[
        Text(
          station.stationName,
          style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (station.fullAddress != null && station.fullAddress!.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(station.fullAddress!, style: textStyle)),
            ],
          ),
          const SizedBox(height: 8),
        ],

        _buildDetailRow(label: 'ID', value: station.stationID, icon: Icons.perm_identity),
        _buildDetailRow(label: '充電樁數量', value: station.chargingPoints.toString(), icon: Icons.power_settings_new),
        _buildDetailRow(label: '停車費率', value: station.parkingRate, icon: Icons.local_parking),
        _buildDetailRow(label: '充電費率', value: station.chargingRate, icon: Icons.attach_money),
        _buildDetailRow(label: '服務時間', value: station.serviceTime, icon: Icons.access_time),

        if (station.telephone != null && station.telephone!.isNotEmpty)
          _buildDetailRow(label: '電話', value: station.telephone!, icon: Icons.phone),
        
        if (station.description != null && station.description!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('描述:', style: labelStyle.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(station.description!, style: textStyle),
        ],

        const SizedBox(height: 12),
        Text('充電接口:', style: labelStyle.copyWith(fontWeight: FontWeight.bold)),
        if (station.connectors.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text('未提供接口資訊', style: textStyle.copyWith(fontStyle: FontStyle.italic)),
          )
        else
          ...station.connectors.map((connector) {
            return Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 8.0),
              child: Text(
                '- ${connector.typeDescription} (功率: ${connector.powerDescription}, 數量: ${connector.quantity})',
                style: textStyle,
              ),
            );
          }).toList(),
        
        if (station.photoURLs != null && station.photoURLs!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('照片:', style: labelStyle.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 150, // 設定一個固定高度給圖片輪播
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: station.photoURLs!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        station.photoURLs![index],
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 150,
                            height: 150,
                            color: Colors.grey[800],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                                color: AppColors.accentColor,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 150,
                          height: 150,
                          color: Colors.grey[800],
                          child: Icon(Icons.broken_image, color: Colors.white54, size: 50),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
        const SizedBox(height: 20), // 底部留白
      ],
    );
  }

  Widget _buildDetailRow({required String label, required String value, IconData? icon}) {
    final textStyle = const TextStyle(color: Colors.white, fontSize: 16);
    final labelStyle = TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
          ],
          Expanded(
            flex: 2,
            child: Text('$label:', style: labelStyle),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(value.isNotEmpty ? value : '未提供', style: textStyle),
          ),
        ],
      ),
    );
  }
}
