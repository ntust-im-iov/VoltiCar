import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ToolsView extends StatefulWidget {
  const ToolsView({super.key});

  @override
  State<ToolsView> createState() => _ToolsViewState();
}

class _ToolsViewState extends State<ToolsView> {
  final _logger = Logger();

  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['輪胎', '引擎', '外觀', '內裝', '性能', '電子件'];

  // 示例改裝項目
  final List<Map<String, dynamic>> _items = [
    {
      'name': 'Sport輪胎',
      'image': 'tire_1.png',
      'description': '提高抓地力和性能的運動型輪胎',
      'price': 2500,
      'category': 0,
      'level': 1,
    },
    {
      'name': 'Race Racing輪胎',
      'image': 'tire_2.png',
      'description': '專為賽道設計的極高性能輪胎',
      'price': 4500,
      'category': 0,
      'level': 2,
    },
    {
      'name': '性能提升模組',
      'image': 'engine_1.png',
      'description': '提升電動馬達性能的控制模組',
      'price': 12000,
      'category': 1,
      'level': 1,
    },
    {
      'name': '碳纖維車身套件',
      'image': 'body_1.png',
      'description': '輕量化碳纖維車身配件，提供更好的空氣動力學',
      'price': 35000,
      'category': 2,
      'level': 2,
    },
    {
      'name': '冷卻系統升級',
      'image': 'perf_1.png',
      'description': '高效能冷卻系統，提供更好的散熱效能',
      'price': 8000,
      'category': 4,
      'level': 1,
    },
    {
      'name': '座艙娛樂系統',
      'image': 'interior_1.png',
      'description': '高品質聲音系統和先進娛樂功能',
      'price': 15000,
      'category': 3,
      'level': 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    _logger.i('ToolsView initialized');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '改裝工具間',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2A1E47),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: const Color(0xFF2A1E47),
        child: Column(
          children: [
            // 類別選擇列
            _buildCategorySelector(),

            // 改裝項目列表
            Expanded(child: _buildItemsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1426),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF63588A).withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? const Color(0xFF3A2D5B)
                        : const Color(0xFF2A1E47),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color:
                      isSelected
                          ? const Color(0xFFFFD166)
                          : const Color(0xFF63588A),
                  width: 2,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: const Color(0xFFFFD166).withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                ],
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFFFD166) : Colors.white,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemsList() {
    // 依據選擇的類別過濾項目
    final filteredItems =
        _items
            .where((item) => item['category'] == _selectedCategoryIndex)
            .toList();

    if (filteredItems.isEmpty) {
      return const Center(
        child: Text(
          '該類別尚無改裝項目',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF3A2D5B),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF63588A), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 改裝項目圖示（使用佔位符，實際應用中使用實際圖像）
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF2A1E47),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF63588A)),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(item['category']),
                  color: const Color(0xFFFFD166),
                  size: 40,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 項目信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildLevelIndicator(item['level']),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['description'],
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item['price']} 元',
                        style: const TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showInstallDialog(item);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('安裝'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelIndicator(int level) {
    return Row(
      children: List.generate(3, (index) {
        return Container(
          width: 18,
          height: 8,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color:
                index < level
                    ? const Color(0xFFFFD166)
                    : const Color(0xFF63588A).withOpacity(0.3),
          ),
        );
      }),
    );
  }

  // 根據類別返回圖標
  IconData _getCategoryIcon(int category) {
    switch (category) {
      case 0:
        return Icons.tire_repair;
      case 1:
        return Icons.electric_car;
      case 2:
        return Icons.color_lens;
      case 3:
        return Icons.airline_seat_recline_normal;
      case 4:
        return Icons.speed;
      case 5:
        return Icons.memory;
      default:
        return Icons.build;
    }
  }

  // 顯示安裝改裝項目的對話框
  void _showInstallDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF3A2D5B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF63588A), width: 2),
            ),
            title: const Text(
              '確認安裝',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '您確定要安裝 ${item['name']} 嗎？',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '價格: ${item['price']} 元',
                  style: const TextStyle(color: Color(0xFFFF6B6B)),
                ),
                const SizedBox(height: 16),
                const Text(
                  '注意: 安裝後將無法退款。',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  // 這裡模擬安裝過程
                  Navigator.pop(context);
                  _showInstallSuccessDialog(item);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
                child: const Text('確認安裝'),
              ),
            ],
          ),
    );
  }

  // 顯示安裝成功的對話框
  void _showInstallSuccessDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF3A2D5B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                SizedBox(width: 8),
                Text(
                  '安裝成功',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              '${item['name']} 已成功安裝到您的車輛上！',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
                child: const Text('確定'),
              ),
            ],
          ),
    );
  }
}
