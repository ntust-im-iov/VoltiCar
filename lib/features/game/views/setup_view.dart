import 'package:flutter/material.dart'; // 引入 Flutter Material UI 库
import 'package:flutter/services.dart'; // 引入 Flutter Services 库，用于控制设备方向
import '../models/cargo_model.dart'; // 引入货物模型
import '../../../shared/widgets/adaptive_button.dart'; // 引入 AdaptiveButton

class SetupView extends StatefulWidget {
  // 设置页面，用于设置游戏参数
  const SetupView({super.key});

  @override
  State<SetupView> createState() => _SetupViewState(); // 创建 SetupView 的状态
}

class _SetupViewState extends State<SetupView> {
  // SetupView 的状态
  List<Cargo> warehouseCargo = [
    // 仓库货物列表
    Cargo(name: 'Box 1', description: 'Fragile items', weight: 10),
    Cargo(name: 'Box 2', description: 'Electronics', weight: 15),
  ];

  List<Cargo> trunkCargo = [
    // 后备箱货物列表
    Cargo(name: 'Spare Tire', description: 'For emergencies', weight: 20),
    Cargo(name: 'Toolkit', description: 'Essential tools', weight: 5),
  ];

  @override
  void initState() {
    // 初始化状态
    super.initState();
    SystemChrome.setPreferredOrientations([
      // 设置屏幕方向为横向
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // 销毁状态
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp]); // 设置屏幕方向为纵向
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 构建 Widget
    return Container(
      // 使用 Container 作为背景
      decoration: BoxDecoration(
        // 设置背景图片
        image: DecorationImage(
          image: AssetImage(
              "assets/images/ready_pg_bg.png"), // 使用 assets/images/ready_pg_bg.png 作为背景图片
          fit: BoxFit.cover, // 覆盖整个屏幕
        ),
      ),
      child: Scaffold(
        // 使用 Scaffold 作为页面的基本结构
        backgroundColor: Colors.transparent, // 设置背景颜色为透明
        body: Stack(
          // 使用 Stack 布局，允许 Widget 重叠
          children: [
            SafeArea(
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Container(), // 空 Container，用于占位
            Positioned(
              // 使用 Positioned Widget 定位
              left: MediaQuery.of(context).size.width * 0.5 -
                  (MediaQuery.of(context).size.width *
                      0.2 /
                      2), // 距离左边 50% 屏幕宽度
              top: MediaQuery.of(context).size.height * 0.5 -
                  ((MediaQuery.of(context).size.height * 0.15 * 3) +
                          (MediaQuery.of(context).size.height * 0.05 * 2)) /
                      2, // 距离顶部 50% 屏幕高度
              child: Column(
                // 使用 Column 垂直排列 Widget
                mainAxisAlignment: MainAxisAlignment.start, // 顶部对齐
                children: [
                  AdaptiveButton(
                    widthGain: 0.2,
                    heightGain: 0.15,
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                    borderColor: Colors.blue.withValues(alpha: 0.3),
                    imagePath: "assets/images/volticar_logo.png",
                    text: '委託任務',
                    textColor: Colors.white,
                    onTap: _onTaskAssigned,
                    showImage: false,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  AdaptiveButton(
                    widthGain: 0.2,
                    heightGain: 0.15,
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                    borderColor: Colors.blue.withValues(alpha: 0.3),
                    imagePath: "assets/images/volticar_logo.png",
                    text: '路線選擇',
                    textColor: Colors.white,
                    onTap: _onRouteSelected,
                    showImage: false,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  AdaptiveButton(
                    widthGain: 0.2,
                    heightGain: 0.15,
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                    borderColor: Colors.blue.withValues(alpha: 0.3),
                    imagePath: "assets/images/volticar_logo.png",
                    text: '貨物檢查',
                    textColor: Colors.white,
                    onTap: _onCargoChecked,
                    showImage: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _onTaskAssigned() {}

void _onRouteSelected() {}

void _onCargoChecked() {}
