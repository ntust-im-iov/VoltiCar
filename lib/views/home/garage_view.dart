import 'package:flutter/material.dart';
import '../../viewmodels/auth_viewmodel.dart'; // 導入身份驗證視圖模型

class GarageView extends StatefulWidget {
  const GarageView({super.key});

  @override
  State<GarageView> createState() => _GarageViewState();
}

class _GarageViewState extends State<GarageView> {
  int selectedCarIndex = 0;
  // 替換自訂用戶名變數為身份驗證視圖模型
  final AuthViewModel _authViewModel = AuthViewModel();

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
      'image': 'tesla_model_3.png',
      'icon': 'tesla_model_3.png', // TODO: Replace with actual icon path
      'range': 450,
      'power': 283,
      'charging': 250,
      'acceleration': 5.6,
    },
    {
      'name': 'Nissan Leaf',
      'image': 'nissan_leaf.png',
      'icon': 'nissan_leaf.png', // TODO: Replace with actual icon path
      'range': 270,
      'power': 160,
      'charging': 100,
      'acceleration': 7.9,
    },
    {
      'name': 'BMW i3',
      'image': 'bmw_i3.png',
      'icon': 'bmw_i3.png', // TODO: Replace with actual icon path
      'range': 260,
      'power': 170,
      'charging': 50,
      'acceleration': 7.2,
    },
    {
      'name': 'Porsche Taycan',
      'image': 'porsche_taycan.png',
      'icon': 'porsche_taycan.png', // TODO: Replace with actual icon path
      'range': 400,
      'power': 560,
      'charging': 270,
      'acceleration': 3.2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Dark background color
          Container(color: const Color(0xFF0F0A1F)),

          // Background image aligned to top
          Align(
            alignment: Alignment.topCenter,
            child: _buildPixelGarageBackground(),
          ),

          // Status bar
          _buildStatusBar(),

          // Car display - Adjust position slightly higher
          Positioned(
            bottom: 480, // Move car display slightly up
            left: 0,
            right: 0,
            child:
                _buildCarDisplay(), // Call the existing method, but its parent Positioned is adjusted
          ),

          // Interactive elements (computer) - Adjust position slightly higher
          Positioned(
            left: 40,
            bottom: 220, // Move computer button slightly up
            child:
                _buildInteractiveElements(), // This now returns just the computer button Positioned
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

  Widget _buildPixelGarageBackground() {
    // Return only the configured Image widget for the background
    return Image.asset(
      'assets/images/garage_bg.png',
      fit: BoxFit.contain, // Use contain to ensure the whole image is visible
      alignment: Alignment.topCenter, // Align the image to the top
    );
  }

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

  Widget _buildCarDisplay() {
    // 車輛顯示在車庫中央，靠近地板位置
    return Positioned(
      bottom: 450, // 根據參考圖調整車輛位置
      left: 0,
      right: 0,
      child: Column(
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
      ),
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
    return Positioned(
      left: 40, // Adjust position to align with the workbench in the background
      bottom: 180,
      child: _buildInteractiveElement(
        icon: Icons.computer,
        color: const Color(0xFF5DE8EB),
        label: '電腦',
        onTap: () {
          _showCarDetailsDialog(carDetails[selectedCarIndex]);
        },
      ),
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

  Widget _buildCarSelector() {
    // (_buildCarSelector method from line 369 to 430 deleted)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 車輛選擇指示器
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(cars.length, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      selectedCarIndex == index
                          ? const Color(0xFFFF5E5B)
                          : Colors.white54,
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          // 左右按鈕與當前車輛指示
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 上一輛車按鈕
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (selectedCarIndex > 0) {
                      selectedCarIndex--;
                    } else {
                      selectedCarIndex = cars.length - 1;
                    }
                  });
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1638).withOpacity(0.7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF5C4EB4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // 下一輛車按鈕
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (selectedCarIndex < cars.length - 1) {
                      selectedCarIndex++;
                    } else {
                      selectedCarIndex = 0;
                    }
                  });
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1638).withOpacity(0.7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF5C4EB4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
      builder:
          (context) => Dialog(
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
}

// 像素風格地板繪製器
class PixelFloorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 繪製像素風格地板格線
    final paint =
        Paint()
          ..color = const Color(0xFF5C4EB4).withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    // 水平線
    for (int i = 0; i < size.height; i += 10) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }

    // 垂直線
    for (int i = 0; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }

    // 反光效果
    final reflectionPaint =
        Paint()
          ..color = const Color(0xFF5DE8EB).withOpacity(0.2)
          ..style = PaintingStyle.fill;

    // 中央反光效果
    final reflectionRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 100,
      height: 20,
    );
    canvas.drawRect(reflectionRect, reflectionPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
