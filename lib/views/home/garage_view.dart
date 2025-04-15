import 'package:flutter/material.dart';
import 'package:flame/game.dart' hide Route; // Flame import - Hide Route
import 'package:flame/components.dart'; // Flame import
import 'package:flame/events.dart'; // Flame import
import 'package:flame/palette.dart'; // Flame import
import '../../features/auth/viewmodels/auth_viewmodel.dart'; // 導入身份驗證視圖模型
import '../../core/constants/app_colors.dart'; // Import AppColors
import '../../shared/widgets/map_overlay.dart'; // Import the new map overlay widget

class GarageView extends StatefulWidget {
  const GarageView({super.key});

  @override
  State<GarageView> createState() => _GarageViewState();
}

class _GarageViewState extends State<GarageView> {
  int selectedCarIndex = 0;
  bool _isMapVisible = false; // State variable to control map visibility
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
          /*暫時停用
          // Background image aligned to top (Re-added and made adaptive)
          Align(
            alignment: Alignment.topCenter,
            child: _buildPixelGarageBackground(),
          ),
          */
          // Flame Game Widget (Now on top of the background image)
          // Pass callbacks for info, map, and gas station buttons
          GameWidget(
              game: VoltiCarGame(
            onInfoButtonPressed: () {
              // Ensure we have the correct car details based on the current index
              _showCarDetailsDialog(carDetails[selectedCarIndex]);
            },
            onMapButtonPressed:
                _toggleMapVisibility, // Pass map toggle callback
            onGasStationPressed: () {
              // Pass navigation logic to the game
              Navigator.pushNamed(context, '/charging');
            },
          )),

          // Status bar - REMOVED
          // _buildStatusBar(),

          // Add Positioned Logout Button
          // Positioned(
          //   top: 10, // Adjust top padding as needed
          //   right: 10, // Adjust right padding as needed
          //   child: IconButton(
          //     icon: const Icon(Icons.logout,
          //         color: AppColors
          //             .textPrimary), // Use AppColors if available or Colors.white
          //     onPressed: _handleLogout,
          //     tooltip: '登出', // Optional: Add tooltip
          //   ),
          // ),

          // Car display - Adjust position slightly higher

          // Gas station image - REMOVED (Now handled by Flame game)

          // New Bottom Car Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomCarPanel(), // Add the new panel
          ),

          // Conditionally display the map overlay
          if (_isMapVisible)
            MapOverlay(
              onClose:
                  _toggleMapVisibility, // Pass the toggle callback to close
            ),
        ],
      ),
    );
  }

  // Method to toggle map visibility
  void _toggleMapVisibility() {
    setState(() {
      _isMapVisible = !_isMapVisible;
    });
  }

  /*暫時藤用 使用精靈代替
  Re-added _buildPixelGarageBackground method (Made Adaptive)
  Widget _buildPixelGarageBackground() {
    // Get screen width for adaptive sizing
    final screenWidth = MediaQuery.of(context).size.width;

    // Wrap Image in a Container constrained by screen width
    return Container(
      width: screenWidth, // Set container width to screen width
      alignment: Alignment.topCenter, // Keep alignment
      child: Image.asset(
        'assets/images/garage_bg.png',
        fit: BoxFit.fill, // Fit the width of the container
        // alignment: Alignment.topCenter, // Alignment is handled by the Container now
      ),
    );
  }
  */
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
  /*暫時停用 
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
  */
  /*暫時停用
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
  */
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

  /*暫時停用
  // Re-add the logout handler method
  Future<void> _handleLogout() async {
    await _authViewModel.logout();
    if (mounted) {
      // Navigate back to login and remove all previous routes
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    }
  }
  */
}

// Removed unused PixelFloorPainter class

// --- Flame Game Code ---

class VoltiCarGame extends FlameGame with HasGameRef {
  // Add HasGameRef
  final VoidCallback? onInfoButtonPressed; // Callback for info button
  final VoidCallback? onMapButtonPressed; // Callback for map button
  final VoidCallback? onGasStationPressed; // Callback for gas station

  VoltiCarGame({
    this.onInfoButtonPressed,
    this.onMapButtonPressed,
    this.onGasStationPressed, // Add gas station callback
  });

  // Override backgroundColor to make it transparent
  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad(); // Ensure FlameGame onLoad completes

    // Ensure game size is available before proceeding
    await Future.delayed(Duration.zero); // Allow layout to settle

    // --- Add Background Sprite ---
    final backgroundSprite =
        await loadSprite('garage_bg.png'); // Load the background
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

    // Button size
    final buttonSize = Vector2(150, 50);
    const verticalSpacing = 20.0; // Spacing between buttons

    // Button positions (grid layout) - Adjusted for potential smaller game area
    // Note: These positions might need further tweaking depending on how GameWidget is sized
    final buttonPositions = [
      Vector2(size.x / 2 - buttonSize.x / 2, size.y / 3 - buttonSize.y / 2),
      Vector2(size.x * 3 / 4 - buttonSize.x / 2, size.y / 3 - buttonSize.y / 2),
    ];

    // Button texts and associated actions/styles
    final buttonData = [
      {
        'text': '地圖',
        'action': onMapButtonPressed, // Use the new map callback
        'style': 'default'
      },
      {
        'text': '資訊頁面',
        'action': onInfoButtonPressed, // Keep info callback
        'style': 'computer'
      },
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
        // Apply computer button style
        backgroundColor = const Color(0xFF1F1638).withOpacity(0.7);
        borderColor = const Color(0xFF5DE8EB);
        borderWidth = 2;
        textColor = Colors.white;
      } else if (buttonText == '資訊頁面') {
        // Position below the map button
        currentPosition = Vector2(mapButtonPosition.x,
            mapButtonPosition.y + buttonSize.y + verticalSpacing);
        // Apply computer button style
        backgroundColor = const Color(0xFF1F1638).withOpacity(0.7);
        borderColor = const Color(0xFF5DE8EB);
        borderWidth = 2;
        textColor = Colors.white;
      } else {
        currentPosition = Vector2(0, 0);
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
      )..priority = 2; // Layer 2: Interactive Buttons
      add(button);
    }

    // --- Add Gas Station Component ---
    final gasStation = GasStationComponent(
      onPressed: onGasStationPressed,
    )..priority = 2; // Layer 2: Interactive Elements
    add(gasStation); // Add the gas station to the game

    // --- Add Car Component ---
    final carComponent = CarComponent()
      ..priority = 2; // Layer 2: Interactive Elements
    add(carComponent); // Add the car to the game
  }
}

// --- New Car Component ---
class CarComponent extends SpriteComponent with HasGameRef<VoltiCarGame> {
  CarComponent() : super(anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite('car.png');

    // Get screen size
    final screenSize = gameRef.size;

    // Calculate adaptive size and position
    final carWidth = screenSize.x * 0.55; // Car width as 55% of screen width
    final carHeight = carWidth * (230 / 250); // Maintain aspect ratio
    size = Vector2(carWidth, carHeight);

    // Position the car at the horizontal center and a dynamic position from the bottom
    position = Vector2(
      screenSize.x * 0.5,
      screenSize.y * 0.68,
    );
  }
}

// --- New Gas Station Component ---
class GasStationComponent extends SpriteComponent
    with TapCallbacks, HasGameRef<VoltiCarGame> {
  final VoidCallback? onPressed;

  GasStationComponent({this.onPressed})
      : super(anchor: Anchor.bottomRight); // Set size and anchor

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite('gas.png'); // Correct the sprite path

    // Get screen size
    final screenSize = gameRef.size;

    // Calculate adaptive size and position
    final gasStationWidth =
        screenSize.x * 0.35; // Gas station width as 20% of screen width
    final gasStationHeight =
        gasStationWidth * (260 / 180); // Maintain aspect ratio
    size = Vector2(gasStationWidth, gasStationHeight);

    // Position the gas station at 10% from the right and a dynamic position from the bottom
    position = Vector2(
      screenSize.x * 1.02,
      screenSize.y * 0.6,
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPressed?.call(); // Execute the callback on tap
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

// Removed MapPopup Flame component
