import 'package:flutter/material.dart';
import 'package:flame/game.dart' hide Route; // Flame import - Hide Route
import 'package:flame/components.dart'; // Flame import
import 'package:flame/events.dart'; // Flame import
import 'package:volticar_app/core/constants/app_colors.dart';
import 'package:volticar_app/features/home/models/charging_station_model.dart';
import 'package:volticar_app/features/home/viewmodels/map_overlay.dart';
import 'package:volticar_app/shared/maplist/carDetails.dart'; //導入車輛訊息MAP列表
import 'package:volticar_app/shared/widgets/adaptive_component.dart'; //導入自適應點擊元件原型
import 'package:volticar_app/features/auth/viewmodels/login_viewmodel.dart'; // 導入身份驗證視圖模型
import 'package:provider/provider.dart'; // 導入 Provider
import 'package:volticar_app/features/home/viewmodels/map_provider.dart';
import 'package:url_launcher/url_launcher.dart'; // 導入url_launcher

class GarageView extends StatefulWidget {
  const GarageView({super.key});

  @override
  State<GarageView> createState() => _GarageViewState();
}

class _GarageViewState extends State<GarageView> {
  int selectedCarIndex = 0;
  final ValueNotifier<bool> _isMapVisible =
      ValueNotifier<bool>(false); // State variable to control map visibility
  // bool _isStationDetailSheetVisible = false; // 已移至_MapOverlayWidget

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mapProvider = Provider.of<MapProvider>(context, listen: false);
      if (!mapProvider.isInitialized) {
        mapProvider.initialize();
      }
    });
  }

  final List<String> cars = [
    'Tesla Model 3',
    'Nissan Leaf',
    'BMW i3',
    'Porsche Taycan',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          GameWidget(
              game: VoltiCarGame(
                  onInfoButtonPressed: () {
                    // Ensure we have the correct car details based on the current index
                    _showCarDetailsDialog(carDetails[selectedCarIndex]);
                  },
                  onMapButtonPressed: _toggleMap, // Pass map toggle callback
                  onGasStationPressed: () {
                    // Pass navigation logic to the game
                    Navigator.pushNamed(context, '/charging');
                  },
                  onCarPressed: () {
                    Navigator.pushNamed(context, '/setup');
                  },
                  Function: () {})),

          //Logout Button
          Positioned(
            top: 50, // Adjust top padding as needed
            right: 10, // Adjust right padding as needed
            child: IconButton(
              icon: const Icon(
                Icons.logout,
                color:
                    Colors.white, // Use AppColors if available or Colors.white
              ), // Use AppColors if available or Colors.white
              onPressed: _handleLogout,
              tooltip: '登出', // Optional: Add tooltip
            ),
          ),

          // New Bottom Car Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomCarPanel(), // Add the new panel
          ),

          // Conditionally display the map overlay - 使用獨立的Widget避免重建
          ValueListenableBuilder<bool>(
            valueListenable: _isMapVisible,
            builder: (context, isMapVisible, child) {
              return isMapVisible
                  ? _MapOverlayWidget(
                      onClose: _closeMap,
                      onStationDetailSheetChanged: (isVisible) {
                        // 可以在這裡處理狀態變化，目前不需要
                      },
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  // 切換地圖顯示
  void _toggleMap() {
    _isMapVisible.value = !_isMapVisible.value;
  }

  // 關閉地圖
  void _closeMap() {
    _isMapVisible.value = false;
  }

  // 新增底部車輛選擇面板
  Widget _buildBottomCarPanel() {
    // TODO: Replace with actual pixel art arrow icons
    const pixelArrowLeft = Icons.arrow_left;
    const pixelArrowRight = Icons.arrow_right;

    return Container(
      height: 100, // 面板高度، 可以調整
      margin: const EdgeInsets.only(
        bottom: 20, // 調整底部邊距，由於移除了底部導覽列，減少底部空間
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1638).withOpacity(0.85), // 深紫色半透明背景
        borderRadius: BorderRadius.circular(16), // 圓角
        border: Border.all(color: const Color(0xFF5C4EB4), width: 2), // 邊框
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左箭頭按鈕
          IconButton(
            icon: Icon(
              pixelArrowLeft,
              color: Colors.white,
              size: 40,
            ), // 像素風格左箭頭
            onPressed: () {
              setState(() {
                if (selectedCarIndex > 0) {
                  selectedCarIndex--;
                } else {
                  selectedCarIndex = carDetails.length - 1; // 循環到最後一個
                }
              });
            },
          ),

          // 當前車輛小圖示 - 使用替代顯示方式
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 使用圖標替代圖片
                  Icon(
                    Icons.electric_car,
                    color: const Color(0xFFFFD166),
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  // 顯示車輛名稱
                  Text(
                    carDetails[selectedCarIndex]['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // 右箭頭按鈕
          IconButton(
            icon: Icon(
              pixelArrowRight,
              color: Colors.white,
              size: 40,
            ), // 像素風格右箭頭
            onPressed: () {
              setState(() {
                if (selectedCarIndex < carDetails.length - 1) {
                  selectedCarIndex++;
                } else {
                  selectedCarIndex = 0; // 循環到第一個
                }
              });
            },
          ),
        ],
      ),
    );
  }

  // 顯示車輛詳細信息對話框
  void _showCarDetailsDialog(Map<String, dynamic> car) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1F1638),
            borderRadius: BorderRadius.circular(16), // 圓角
            border: Border.all(color: const Color(0xFF5C4EB4), width: 2), // 邊框
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 標題
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.electric_car,
                        color: Color(0xFFFF5E5B),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        car['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 車輛模擬圖像（像素風格）
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0A1F),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF5C4EB4)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.directions_car,
                    color: Color(0xFFFFD166),
                    size: 60,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 車輛詳細數據 - 像素風格面板
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCarStatBox(
                    icon: Icons.battery_full,
                    value: '${car['range']} km',
                    label: '續航里程',
                    color: const Color(0xFF5DE8EB),
                  ),
                  _buildCarStatBox(
                    icon: Icons.flash_on,
                    value: '${car['power']} kW',
                    label: '最大功率',
                    color: const Color(0xFFFF5E5B),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCarStatBox(
                    icon: Icons.speed,
                    value: '${car['acceleration']} 秒',
                    label: '0-100 km/h',
                    color: const Color(0xFFFFD166),
                  ),
                  _buildCarStatBox(
                    icon: Icons.ev_station,
                    value: '${car['charging']} kW',
                    label: '最大充電功率',
                    color: const Color(0xFF06D6A0),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 按鈕 - 像素風格
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/mycar');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C4EB4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                          color: Color(0xFF8976FF),
                          width: 2,
                        ),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0xFF5C4EB4).withOpacity(0.5),
                    ),
                    child: const Text(
                      '查看詳細資料',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
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

  // 車輛數據顯示方塊 - 像素風格
  Widget _buildCarStatBox({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4 - 20,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0A1F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.8), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  //Logout Button method
  Future<void> _handleLogout() async {
    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
    await loginViewModel.logout();
    if (mounted) {
      // Navigate back to login and remove all previous routes
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    }
  }

  // 原本的_showStationDetailBottomSheet方法和_buildDetailRow方法已移至_MapOverlayWidget
}

// 獨立的地圖overlay widget，避免garage頁面重建
class _MapOverlayWidget extends StatefulWidget {
  final VoidCallback onClose;
  final Function(bool) onStationDetailSheetChanged;

  const _MapOverlayWidget({
    Key? key,
    required this.onClose,
    required this.onStationDetailSheetChanged,
  }) : super(key: key);

  @override
  State<_MapOverlayWidget> createState() => _MapOverlayWidgetState();
}

class _MapOverlayWidgetState extends State<_MapOverlayWidget> {
  bool _isStationDetailSheetVisible = false;

  @override
  void initState() {
    super.initState();
    // 重置地圖狀態，確保每次打開地圖overlay時都能正確載入充電站
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mapProvider = Provider.of<MapProvider>(context, listen: false);
      mapProvider.resetMapState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        // 使用 addPostFrameCallback 確保在 build 完成後執行
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mapProvider.selectedStationDetail != null &&
              !_isStationDetailSheetVisible) {
            _isStationDetailSheetVisible = true; // 標記為已顯示
            widget.onStationDetailSheetChanged(true);
            _showStationDetailBottomSheet(
                    context, mapProvider.selectedStationDetail!)
                .then((_) {
              // 當 BottomSheet 關閉時
              _isStationDetailSheetVisible = false; // 重置標記
              widget.onStationDetailSheetChanged(false);
              // 檢查 mapProvider 是否仍然認為有選中的站點，
              // 如果使用者是透過手勢關閉 BottomSheet 而不是透過按鈕，
              // 我們需要通知 mapProvider 清除選中狀態。
              if (mapProvider.selectedStationDetail != null) {
                mapProvider.clearSelectedStation();
              }
            });
          }
        });

        return MapOverlay(
          onClose: widget.onClose,
        );
      },
    );
  }

  // 移植從原本GarageView的方法
  Future<void> _showStationDetailBottomSheet(
      BuildContext context, ChargingStation station) async {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6, // 增加初始高度到 60%
          minChildSize: 0.4, // 增加最小高度到 40%
          maxChildSize: 0.95, // 增加最大高度到 95%
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                // 添加漸層背景
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2A1F3D), // 頂部稍微亮一點
                    Color(0xFF1F1638), // 底部較暗
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24), // 增加圓角
                  topRight: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(color: Color(0xFF5C4EB4), width: 3),
                  left: BorderSide(color: Color(0xFF5C4EB4), width: 3),
                  right: BorderSide(color: Color(0xFF5C4EB4), width: 3),
                ),
                // 添加陰影效果
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF5C4EB4).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 美化拖拽指示器
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5C4EB4), Color(0xFF8976FF)],
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF5C4EB4).withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                  // 美化標題欄
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 8, 16, 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF5C4EB4).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // 添加充電站圖標
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF06D6A0), Color(0xFF5DE8EB)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF06D6A0).withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.ev_station,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                station.stationName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '充電站詳細資訊',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF5C4EB4).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 20),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 內容區域 - 可滾動
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: _buildStationDetailContent(station),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 構建充電站詳細資訊內容
  Widget _buildStationDetailContent(ChargingStation station) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 基本資訊區塊 - 美化卡片樣式
        _buildInfoCard(
          title: '基本資訊',
          icon: Icons.info_outline,
          gradient: const LinearGradient(
            colors: [Color(0xFF5C4EB4), Color(0xFF8976FF)],
          ),
          children: [
            _buildDetailRow(
              label: '地址',
              value: station.fullAddress ?? '未提供',
              icon: Icons.location_on,
              iconColor: const Color(0xFFFF5E5B),
            ),
            _buildDetailRow(
              label: '電話',
              value: station.telephone ?? '未提供',
              icon: Icons.phone,
              iconColor: const Color(0xFF06D6A0),
            ),
            _buildDetailRow(
              label: '營業時間',
              value: station.serviceTime ?? '未提供',
              icon: Icons.access_time,
              iconColor: const Color(0xFFFFD166),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 收費資訊區塊
        _buildInfoCard(
          title: '收費資訊',
          icon: Icons.attach_money,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF5E5B), Color(0xFFFF8A80)],
          ),
          children: [
            _buildDetailRow(
              label: '充電費率',
              value: station.chargingRate ?? '未提供',
              icon: Icons.electric_bolt,
              iconColor: const Color(0xFFFFD166),
            ),
            _buildDetailRow(
              label: '停車費率',
              value: station.parkingRate ?? '未提供',
              icon: Icons.local_parking,
              iconColor: const Color(0xFF5DE8EB),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 充電接口區塊
        _buildInfoCard(
          title: '充電接口',
          icon: Icons.power,
          gradient: const LinearGradient(
            colors: [Color(0xFF06D6A0), Color(0xFF5DE8EB)],
          ),
          children: [
            if (station.connectors.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF0F0A1F).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white.withOpacity(0.6),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '未提供接口資訊',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...station.connectors.asMap().entries.map((entry) {
                final index = entry.key;
                final connector = entry.value;
                return Container(
                  margin: EdgeInsets.only(bottom: index < station.connectors.length - 1 ? 12 : 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF0F0A1F).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(0xFF06D6A0).withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF06D6A0).withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF06D6A0).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.electrical_services,
                          color: Color(0xFF06D6A0),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              connector.typeDescription,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '功率: ${connector.powerDescription} • 數量: ${connector.quantity}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),

        // 照片區塊
        if (station.photoURLs != null && station.photoURLs!.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildInfoCard(
            title: '充電站照片',
            icon: Icons.photo_library,
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD166), Color(0xFFF4A261)],
            ),
            children: [
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: station.photoURLs!.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(
                        right: index < station.photoURLs!.length - 1 ? 12 : 0,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 160,
                          height: 180,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Image.network(
                            station.photoURLs![index],
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Color(0xFF0F0A1F),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: Color(0xFFFFD166),
                                    strokeWidth: 3,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Color(0xFF0F0A1F),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.white54,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '圖片載入失敗',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],

        // 導航按鈕
        const SizedBox(height: 30),
        _buildNavigationButton(station),
        const SizedBox(height: 20), // 底部留白
      ],
    );
  }

  // 新增資訊卡片組件
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Gradient gradient,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF0F0A1F).withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片標題
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // 卡片內容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // 導航按鈕組件
  Widget _buildNavigationButton(ChargingStation station) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF06D6A0), Color(0xFF5DE8EB)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06D6A0).withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _navigateToStation(station),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.navigation,
            color: Colors.white,
            size: 22,
          ),
        ),
        label: const Text(
          '導航到此充電站',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  // 導航功能
  Future<void> _navigateToStation(ChargingStation station) async {
    try {
      // 顯示載入中的訊息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                                 Text('正在開啟Google Maps導航至 ${station.stationName}...'),
              ],
            ),
            backgroundColor: const Color(0xFF06D6A0),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // 構建不同地圖應用的URL
      final double lat = station.latitude;
      final double lng = station.longitude;
      final String stationName = Uri.encodeComponent(station.stationName);
      
      // Google Maps App URL (首選)
      final String googleMapsAppUrl = 'google.navigation:q=$lat,$lng&mode=d';
      
      // Apple Maps URL (備選，僅當Google Maps App不可用時)
      final String appleMapsUrl = 'https://maps.apple.com/?daddr=$lat,$lng&dirflg=d&q=$stationName';

      bool navigationOpened = false;

      // 直接調用原生地圖應用，不使用網頁版
      // 1. 首先嘗試Google Maps App
      if (!navigationOpened && await canLaunchUrl(Uri.parse(googleMapsAppUrl))) {
        await launchUrl(
          Uri.parse(googleMapsAppUrl),
          mode: LaunchMode.externalApplication,
        );
        navigationOpened = true;
      }
      
      // 2. 如果Google Maps App不可用，嘗試Apple Maps
      if (!navigationOpened && await canLaunchUrl(Uri.parse(appleMapsUrl))) {
        await launchUrl(
          Uri.parse(appleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
        navigationOpened = true;
      }

      // 如果都無法打開，顯示錯誤訊息
      if (!navigationOpened) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('無法打開地圖應用，請確認已安裝Google Maps或其他地圖應用'),
              backgroundColor: Color(0xFFFF5E5B),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // 處理錯誤
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('導航功能發生錯誤：${e.toString()}'),
            backgroundColor: const Color(0xFFFF5E5B),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // 充電站詳細資訊 BottomSheet 填充 - 美化版本
  Widget _buildDetailRow({
    required String label,
    required String value,
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color(0xFF1F1638).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.white70).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor ?? Colors.white70,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : '未提供',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Flame Game Code ---

class VoltiCarGame extends FlameGame with HasGameRef {
  // Add HasGameRef
  final VoidCallback? onInfoButtonPressed; // Callback for info button
  final VoidCallback? onMapButtonPressed; // Callback for map button
  final VoidCallback? onGasStationPressed; // Callback for gas station
  final VoidCallback? onCarPressed;

  VoltiCarGame({
    this.onInfoButtonPressed,
    this.onMapButtonPressed,
    this.onGasStationPressed,
    this.onCarPressed,
    required Null Function(), // Add gas station callback
  });

  // Override backgroundColor to make it transparent
  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Ensure game size is available before proceeding
    await Future.delayed(Duration.zero);

    // --- Add Background Sprite ---
    final image = await images.load('garage_bg.png');
    final backgroundSprite = Sprite(image);
    add(
      SpriteComponent(
        sprite: backgroundSprite,
        size:
            Vector2(size.x, size.y * 3 / 4), // Set size to cover the game area
        position: Vector2.zero(), // Position at top-left
      )..priority = 0, // Layer 0: Background
    );

    // --- Add Background Component ---
    final backgroundComponent = RectangleComponent(
      size: Vector2(size.x, size.y / 4),
      paint: Paint()
        ..color = const Color(0xFF2E3364), // AppColors.primaryColor,
      position: Vector2(0, size.y),
      anchor: Anchor.bottomLeft,
    )..priority = 0; // Layer 1: Background Component
    add(backgroundComponent);

    // --- Add PC Component ---
    final pcComponent = AdaptiveComponent(gameRef.size, 0.3, (160 / 100),
        'pc.png', 0.145, 0.625, onInfoButtonPressed)
      ..priority = 2;
    add(pcComponent);
    // --- Add Map Component ---
    final mapComponent = AdaptiveComponent(gameRef.size, 0.17, (230 / 100),
        'map.png', 0.087, 0.42, onMapButtonPressed)
      ..priority = 1;
    add(mapComponent);

    // --- Add Gas Station Component ---
    final gasStation = AdaptiveComponent(gameRef.size, 0.35, (160 / 100),
        'gas.png', 0.86, 0.65, onGasStationPressed)
      ..priority = 2; // Layer 2: Interactive Elements
    add(gasStation); // Add the gas station to the game

    // --- Add Car Component ---
    final carComponent = AdaptiveComponent(
        gameRef.size, 0.4, (230 / 250), 'car.png', 0.5, 0.61, onCarPressed)
      ..priority = 2; // Layer 2: Interactive Elements
    add(carComponent); // Add the car to the game
  }
}

class ButtonComponent extends PositionComponent with TapCallbacks {
  ButtonComponent({
    required this.buttonSize,
    required this.buttonPosition,
    required this.buttonText,
    this.backgroundColor = Colors.grey, // Default background
    this.borderColor = Colors.transparent, // Default no border
    this.borderWidth = 0, // Default no border width
    this.textColor = Colors.black, // Default text color
    this.onPressed,
  }) : super(size: buttonSize, position: buttonPosition);

  final Vector2 buttonSize;
  final Vector2 buttonPosition;
  final String buttonText;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final Color textColor;
  final VoidCallback? onPressed;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final backgroundPaint = Paint()..color = backgroundColor;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    final textPaint = TextPaint(
        style: TextStyle(color: textColor, fontSize: 20)); // Use textColor

    // Background Rectangle
    add(
      RectangleComponent(
        size: buttonSize,
        paint: backgroundPaint,
        // TODO: Add rounded corners if desired and feasible in Flame
      ),
    );

    // Border Rectangle (only if borderWidth > 0)
    if (borderWidth > 0) {
      add(
        RectangleComponent(
          size: buttonSize,
          paint: borderPaint,
          // TODO: Add rounded corners if desired and feasible in Flame
        ),
      );
    }

    // Text Label
    add(
      TextComponent(
        text: buttonText,
        textRenderer: textPaint, // Uses the configured textPaint
        anchor: Anchor.center,
        position: buttonSize / 2,
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPressed?.call();
  }
}
