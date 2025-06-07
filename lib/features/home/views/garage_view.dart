import 'package:flutter/foundation.dart';
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

class GarageView extends StatefulWidget {
  const GarageView({super.key});

  @override
  State<GarageView> createState() => _GarageViewState();
}

class _GarageViewState extends State<GarageView> {
  int selectedCarIndex = 0;
  final ValueNotifier<bool> _isMapVisible =
      ValueNotifier<bool>(false); // State variable to control map visibility
  bool _isStationDetailSheetVisible = false; // 新增：追蹤詳細資訊表單是否可見

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
    final mapProvider = Provider.of<MapProvider>(context);

    // 使用 addPostFrameCallback 確保在 build 完成後執行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mapProvider.selectedStationDetail != null &&
          !_isStationDetailSheetVisible) {
        _isStationDetailSheetVisible = true; // 標記為已顯示
        _showStationDetailBottomSheet(
                context, mapProvider.selectedStationDetail!)
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

          // Conditionally display the map overlay
          ValueListenableBuilder<bool>(
            valueListenable: _isMapVisible,
            builder: (context, isMapVisible, child) {
              return isMapVisible
                  ? MapOverlay(
                      onClose: _closeMap, // Pass the toggle callback to close
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

  // 顯示充電站詳細資訊的 BottomSheet
  Future<void> _showStationDetailBottomSheet(
      BuildContext context, ChargingStation station) {
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
          minChildSize: 0.3, // 最小高度
          maxChildSize: 0.9, // 最大高度
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
    final labelStyle =
        TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14);

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

        _buildDetailRow(
            label: 'ID', value: station.stationID, icon: Icons.perm_identity),
        _buildDetailRow(
            label: '充電樁數量',
            value: station.chargingPoints.toString(),
            icon: Icons.power_settings_new),
        _buildDetailRow(
            label: '停車費率',
            value: station.parkingRate,
            icon: Icons.local_parking),
        _buildDetailRow(
            label: '充電費率',
            value: station.chargingRate,
            icon: Icons.attach_money),
        _buildDetailRow(
            label: '服務時間', value: station.serviceTime, icon: Icons.access_time),

        if (station.telephone != null && station.telephone!.isNotEmpty)
          _buildDetailRow(
              label: '電話', value: station.telephone!, icon: Icons.phone),

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
            child: Text('未提供接口資訊',
                style: textStyle.copyWith(fontStyle: FontStyle.italic)),
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
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 150,
                          height: 150,
                          color: Colors.grey[800],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
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
                        child: Icon(Icons.broken_image,
                            color: Colors.white54, size: 50),
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

  // 充電站詳細資訊 BottomSheet 填充
  Widget _buildDetailRow(
      {required String label, required String value, IconData? icon}) {
    final textStyle = const TextStyle(color: Colors.white, fontSize: 16);
    final labelStyle =
        TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14);
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
