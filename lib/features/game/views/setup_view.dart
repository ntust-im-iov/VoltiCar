import 'package:flutter/material.dart'; // 引入 Flutter Material UI 库
import 'package:flutter/services.dart'; // 引入 Flutter Services 库，用于控制设备方向
import 'package:provider/provider.dart'; // 引入 Provider
import '../../../shared/widgets/adaptive_button.dart'; // 引入 AdaptiveButton
import '../views/task_assignment_view.dart';
import '../views/destination_fetch_view.dart'; // 引入 DestinationFetchView
import '../viewmodels/destination_fetch_viewmodel.dart'; // 引入 DestinationFetchViewModel
import '../views/player_data_display_view.dart';

class SetupView extends StatefulWidget {
  // 设置页面，用于设置游戏参数
  const SetupView({super.key});

  @override
  State<SetupView> createState() => _SetupViewState(); // 创建 SetupView 的状态
}

class _SetupViewState extends State<SetupView> {
  // SetupView 的状态
  // List<Cargo> warehouseCargo = [
  //   // 仓库货物列表
  //   Cargo(
  //     itemId: '708d1d5c-bd49-495e-916a-5ef219b315a6',
  //     name: '鐵礦石 (v4)',
  //     description: '未加工的鐵礦石，用於工業生產。',
  //     category: '原材料',
  //     weightPerUnit: 100,
  //     volumePerUnit: 0.05,
  //     baseValuePerUnit: 20,
  //     isFragile: false,
  //     isPerishable: false,
  //     iconUrl: '/icons/iron_ore_v4.png',
  //   ),
  //   Cargo(
  //     itemId: '708d1d5c-bd49-495e-916a-5ef219b315a7',
  //     name: '鐵礦石 (v5)',
  //     description: '未加工的鐵礦石，用於工業生產。',
  //     category: '原材料',
  //     weightPerUnit: 100,
  //     volumePerUnit: 0.05,
  //     baseValuePerUnit: 20,
  //     isFragile: false,
  //     isPerishable: false,
  //     iconUrl: '/icons/iron_ore_v4.png',
  //   ),
  // ];

  // List<Cargo> trunkCargo = [
  //   // 后备箱货物列表
  //   Cargo(
  //     itemId: '708d1d5c-bd49-495e-916a-5ef219b315a8',
  //     name: '鐵礦石 (v6)',
  //     description: '未加工的鐵礦石，用於工業生產。',
  //     category: '原材料',
  //     weightPerUnit: 100,
  //     volumePerUnit: 0.05,
  //     baseValuePerUnit: 20,
  //     isFragile: false,
  //     isPerishable: false,
  //     iconUrl: '/icons/iron_ore_v4.png',
  //   ),
  //   Cargo(
  //     itemId: '708d1d5c-bd49-495e-916a-5ef219b315a9',
  //     name: '鐵礦石 (v7)',
  //     description: '未加工的鐵礦石，用於工業生產。',
  //     category: '原材料',
  //     weightPerUnit: 100,
  //     volumePerUnit: 0.05,
  //     baseValuePerUnit: 20,
  //     isFragile: false,
  //     isPerishable: false,
  //     iconUrl: '/icons/iron_ore_v4.png',
  //   ),
  // ];

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

  void _onTaskAssigned() {
    print('委託任務按鈕被點擊');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TaskAssignmentView();
      },
    );
  }

  void _onRouteSelected() {
    print('路線選擇按鈕被點擊');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (context) => DestinationFetchViewModel(),
          child: const DestinationFetchView(),
        );
      },
    );
  }

  void _onCargoChecked() {
    print('貨物檢查按鈕被點擊');
  }

  void _onPlayerAvatarTapped() {
    PlayerDataDisplayView().showPlayerDataDialog(context);
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
            Positioned(
              top: MediaQuery.of(context).size.height * 0.07,
              right: MediaQuery.of(context).size.width * 0.04,
              child: SafeArea(
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.07,
              left: MediaQuery.of(context).size.width * 0.04,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _onPlayerAvatarTapped,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(
                              'assets/images/volticar_logo.png'), // 使用預設圖片
                          radius: 30,
                        ),
                        Text(
                          'Lv.1',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '玩家名稱',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      SizedBox(height: 5),
                      Container(
                        width: 100,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.7,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.lightGreenAccent,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
