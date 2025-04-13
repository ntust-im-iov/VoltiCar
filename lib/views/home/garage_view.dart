import 'package:flutter/material.dart';
import 'package:flame/game.dart' hide Route; // Flame import - Hide Route
import 'package:flame/components.dart'; // Flame import
import 'package:flame/events.dart'; // Flame import
import 'package:flame/palette.dart'; // Flame import
import '../../features/auth/viewmodels/auth_viewmodel.dart'; // 導入身份驗證視圖模型
import '../../core/constants/app_colors.dart'; // Import AppColors

class GarageView extends StatefulWidget {
  const GarageView({super.key});

  @override
  State<GarageView> createState() => _GarageViewState();
}

class _GarageViewState extends State<GarageView> {
  int selectedCarIndex = 0;
  // 替換自訂用戶名變數為身份驗證視圖模型
  final AuthViewModel _authViewModel =
      AuthViewModel(); // Re-add AuthViewModel instance

  final List<String> cars = [
    'Tesla Model 3',
    'Nissan Leaf',
    'BMW i3',
    'Porsche Taycan',
  ];

  // 車輛數據（簡單示例）
  final List<Map<String, dynamic>> carDetails = [
    {
      'name': 'Tesla Model 3',
      'image': 'assets/images/tesla_model_3.png', // Added prefix
      'icon':
          'assets/images/tesla_model_3.png', // Added prefix, TODO: Replace with actual icon path
      'range': 450,
      'power': 283,
      'charging': 250,
      'acceleration': 5.6,
    },
    {
      'name': 'Nissan Leaf',
      'image': 'assets/images/nissan_leaf.png', // Added prefix
      'icon':
          'assets/images/nissan_leaf.png', // Added prefix, TODO: Replace with actual icon path
      'range': 270,
      'power': 160,
      'charging': 100,
      'acceleration': 7.9,
    },
    {
      'name': 'BMW i3',
      'image': 'assets/images/bmw_i3.png', // Added prefix
      'icon':
          'assets/images/bmw_i3.png', // Added prefix, TODO: Replace with actual icon path
      'range': 260,
      'power': 170,
      'charging': 50,
      'acceleration': 7.2,
    },
    {
      'name': 'Porsche Taycan',
      'image': 'assets/images/porsche_taycan.png', // Added prefix
      'icon':
          'assets/images/porsche_taycan.png', // Added prefix, TODO: Replace with actual icon path
      'range': 400,
      'power': 560,
      'charging': 270,
      'acceleration': 3.2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove the entire AppBar
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image aligned to top (Re-added)
          Align(
            alignment: Alignment.topCenter,
            child: _buildPixelGarageBackground(),
          ),

          // Flame Game Widget (Now on top of the background image)
          // Pass the callback to show car details dialog
          GameWidget(game: VoltiCarGame(
            onInfoButtonPressed: () {
              // Ensure we have the correct car details based on the current index
              _showCarDetailsDialog(carDetails[selectedCarIndex]);
            },
          )),

          // Status bar - REMOVED
          // _buildStatusBar(),

          // Add Positioned Logout Button
          Positioned(
            top: 10, // Adjust top padding as needed
            right: 10, // Adjust right padding as needed
            child: IconButton(
              icon: const Icon(Icons.logout,
                  color: AppColors
                      .textPrimary), // Use AppColors if available or Colors.white
              onPressed: _handleLogout,
              tooltip: '登出', // Optional: Add tooltip
            ),
          ),

          // Car display - Adjust position slightly higher
          Positioned(
            bottom: 480, // Move car display slightly up
            left: 0,
            right: 0,
            child:
                _buildCarDisplay(), // Call the existing method, but its parent Positioned is adjusted
          ),

          // Gas station image - Adjust position slightly higher
          Positioned(
            right: 0,
            bottom: 520, // Move gas station slightly up
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/charging');
              },
              child: Image.asset(
                'assets/images/gas.png',
                width: 120,
                height: 150,
              ),
            ),
          ),

          // New Bottom Car Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomCarPanel(), // Add the new panel
          ),
        ],
      ),
    );
  }

  // Re-added _buildPixelGarageBackground method
  Widget _buildPixelGarageBackground() {
    // Return only the configured Image widget for the background
    return Image.asset(
      'assets/images/garage_bg.png',
      fit: BoxFit.contain, // Use contain to ensure the whole image is visible
      alignment: Alignment.topCenter, // Align the image to the top
    );
  }

  // Remove _buildStatusBar method
  /*
  Widget _buildStatusBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.black.withOpacity(0.6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "9:30",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: const [
                Icon(Icons.signal_cellular_alt, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Icon(Icons.wifi, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Icon(Icons.battery_full, color: Colors.white, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
  */

  Widget _buildCarDisplay() {
    // 車輛顯示在車庫中央，靠近地板位置
    // Removed inner Positioned widget
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 車輛圖片
        Container(
          width: 250, // 縮小車子寬度以符合參考圖比例
          height: 200, // 維持合適的高度
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 車輛像素圖 - 使用新的圖片
              Image.asset(
                'assets/images/car.png',
                width: 170, // 確保圖片寬度與容器一致
                fit: BoxFit.fitWidth,
              ),

              // 車輛數據標籤 (調整位置)
              Positioned(
                bottom: -25, // 將標籤稍微移到車子下方
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMiniStat(
                      icon: Icons.battery_full,
                      value: "${carDetails[selectedCarIndex]['range']}km",
                    ),
                    const SizedBox(width: 12),
                    _buildMiniStat(
                      icon: Icons.speed,
                      value: "${carDetails[selectedCarIndex]['power']}kW",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
      // Removed closing parenthesis for Positioned
    );
  }

  Widget _buildMiniStat({required IconData icon, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1638).withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF5C4EB4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF5DE8EB), size: 12),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveElements() {
    // Keep only the computer button and adjust its position
    // Removed inner Positioned widget
    return _buildInteractiveElement(
      icon: Icons.computer,
      color: const Color(0xFF5DE8EB),
      label: '電腦',
      onTap: () {
        _showCarDetailsDialog(carDetails[selectedCarIndex]);
      },
      // Removed closing parenthesis for Positioned
    );
  }

  Widget _buildInteractiveElement({
    required IconData icon,
    required Color color,
    required String label,
    double scale = 1.0,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50 * scale,
            height: 50 * scale,
            decoration: BoxDecoration(
              color: const Color(0xFF1F1638).withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 24 * scale),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12 * scale,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Removed unused _buildCarSelector method

  // 新增底部車輛選擇面板
  Widget _buildBottomCarPanel() {
    // TODO: Replace with actual pixel art arrow icons
    const pixelArrowLeft = Icons.arrow_left;
    const pixelArrowRight = Icons.arrow_right;

    return Container(
      height: 100, // 面板高度，可以調整
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
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF5C4EB4), width: 2),
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

  // Re-add the logout handler method
  Future<void> _handleLogout() async {
    await _authViewModel.logout();
    if (mounted) {
      // Navigate back to login and remove all previous routes
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    }
  }
}

// Removed unused PixelFloorPainter class

// --- Flame Game Code Copied from HomeView ---

class VoltiCarGame extends FlameGame {
  final VoidCallback? onInfoButtonPressed; // Callback for info button
  MapPopup? _currentMapPopup;

  VoltiCarGame(
      {this.onInfoButtonPressed}); // Constructor to accept the callback

  // Override backgroundColor to make it transparent
  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await super.onLoad(); // Ensure FlameGame onLoad completes

    // Ensure game size is available
    await Future.delayed(Duration.zero); // Allow layout to settle

    // Button size
    final buttonSize = Vector2(150, 50);
    const verticalSpacing = 20.0; // Spacing between buttons

    // Button positions (grid layout) - Adjusted for potential smaller game area
    // Note: These positions might need further tweaking depending on how GameWidget is sized
    final buttonPositions = [
      Vector2(size.x / 4 - buttonSize.x / 2, size.y / 3 - buttonSize.y / 2),
      Vector2(size.x * 3 / 4 - buttonSize.x / 2, size.y / 3 - buttonSize.y / 2),
      Vector2(size.x / 4 - buttonSize.x / 2, size.y * 2 / 3 - buttonSize.y / 2),
      Vector2(
          size.x * 3 / 4 - buttonSize.x / 2, size.y * 2 / 3 - buttonSize.y / 2),
    ];

    // Button texts and associated actions/styles
    final buttonData = [
      {'text': '地圖', 'action': _showMapPopup, 'style': 'default'},
      {
        'text': '資訊頁面',
        'action': onInfoButtonPressed,
        'style': 'computer'
      }, // Use callback, specify style
      {
        'text': '遊戲配置',
        'action': () {},
        'style': 'default'
      }, // Placeholder action
      {
        'text': '系統設定',
        'action': () {},
        'style': 'default'
      }, // Placeholder action
      {
        'text': '遊戲入口',
        'action': () {},
        'style': 'default'
      }, // Placeholder action
    ];

    // --- Create Buttons ---
    Vector2 mapButtonPosition = Vector2.zero(); // To store map button position

    for (int i = 0; i < buttonData.length; i++) {
      final data = buttonData[i];
      final buttonText = data['text'] as String;
      final onPressed = data['action'] as VoidCallback?;
      final style = data['style'] as String;

      Vector2 currentPosition;
      Color backgroundColor;
      Color borderColor;
      double borderWidth;
      Color textColor;

      // Determine position and style
      if (buttonText == '地圖') {
        currentPosition = buttonPositions[0];
        mapButtonPosition = currentPosition; // Store map button position
        backgroundColor = BasicPalette.lightGray.withAlpha(200).color;
        borderColor = Colors.transparent; // Default: no border
        borderWidth = 0;
        textColor = BasicPalette.black.color;
      } else if (buttonText == '資訊頁面') {
        // Position below the map button
        currentPosition = Vector2(mapButtonPosition.x,
            mapButtonPosition.y + buttonSize.y + verticalSpacing);
        // Apply computer button style
        backgroundColor = const Color(0xFF1F1638).withOpacity(0.7);
        borderColor = const Color(0xFF5DE8EB);
        borderWidth = 2;
        textColor = Colors.white;
      } else if (i < 4) {
        // Other top/middle buttons
        currentPosition = buttonPositions[i];
        backgroundColor = BasicPalette.lightGray.withAlpha(200).color;
        borderColor = Colors.transparent;
        borderWidth = 0;
        textColor = BasicPalette.black.color;
      } else {
        // Bottom button ('遊戲入口')
        currentPosition = Vector2(
            size.x / 2 - buttonSize.x / 2, size.y * 5 / 6 - buttonSize.y / 2);
        backgroundColor = BasicPalette.lightGray.withAlpha(200).color;
        borderColor = Colors.transparent;
        borderWidth = 0;
        textColor = BasicPalette.black.color;
      }

      final button = ButtonComponent(
        buttonSize: buttonSize,
        buttonPosition: currentPosition,
        buttonText: buttonText,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        borderWidth: borderWidth,
        textColor: textColor,
        onPressed: onPressed, // Use the action from buttonData
      );
      add(button);
    }
  }

  // Helper function for map popup action
  void _showMapPopup() {
    if (_currentMapPopup == null || _currentMapPopup?.isMounted == false) {
      final newPopup = MapPopup(
          // Adjust popup size and position relative to game size
          popupSize: Vector2(size.x * 0.8, size.y * 0.6),
          popupPosition: Vector2(size.x * 0.1, size.y * 0.2),
          onClose: () {
            _currentMapPopup = null; // Clear the reference when closed
          }); // Correctly close the MapPopup constructor call
      _currentMapPopup = newPopup;
      add(newPopup);
    }
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

class MapPopup extends PositionComponent with TapCallbacks, DragCallbacks {
  // Added DragCallbacks
  // Added TapCallbacks
  final VoidCallback onClose;
  final Vector2 popupSize;
  final Vector2 popupPosition;

  MapPopup(
      {required this.onClose,
      required this.popupSize,
      required this.popupPosition})
      : super(
          size: popupSize,
          position: popupPosition,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Semi-transparent background for the popup
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = Colors.blueGrey.withOpacity(0.85), // Changed color slightly
        // borderRadius: BorderRadius.circular(10), // Example rounded corners
        // renderShape: true,
      ),
    );

    // Add a title to the popup
    final titlePaint = TextPaint(
        style: TextStyle(
            color: BasicPalette.white.color,
            fontSize: 24,
            fontWeight: FontWeight.bold));
    add(TextComponent(
      text: '地圖視窗',
      textRenderer: titlePaint,
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 15),
    ));

    // Close button (using ButtonComponent for consistency)
    final closeButtonSize = Vector2(40, 40);
    add(
      ButtonComponent(
        buttonSize: closeButtonSize,
        // Position top-right corner
        buttonPosition: Vector2(size.x - closeButtonSize.x - 10, 10),
        buttonText: 'X',
        onPressed: () {
          onClose(); // Notify the game it's closing
          removeFromParent(); // Remove the popup itself
        },
      ),
    );

    // Add some placeholder content to the map popup
    final contentPaint = TextPaint(
        style: TextStyle(color: BasicPalette.white.color, fontSize: 16));
    add(TextComponent(
      text: '這裡是地圖內容...',
      textRenderer: contentPaint,
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
    ));
  }

  // Make the popup draggable (optional)
  Vector2? dragStart;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    dragStart = event.localPosition;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (dragStart != null) {
      position += event.localDelta;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    dragStart = null;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    dragStart = null;
  }
}
