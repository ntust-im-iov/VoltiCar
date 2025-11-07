import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/adaptive_button.dart';
import '../views/task_assignment_view.dart';
import '../views/player_data_display_view.dart';
import '../views/destination_fetch_view.dart';
import '../viewmodels/destination_fetch_viewmodel.dart';
import '../views/warehouse_dialog_view.dart';
import '../viewmodels/warehouse_viewmodel.dart';
import '../viewmodels/destination_choose_viewmodel.dart';
import '../views/vehicle_dialog_view.dart';
import '../viewmodels/vehicle_viewmodel.dart';
import '../viewmodels/vehicle_choose_viewmodel.dart';
import '../views/shop_dialog_view.dart';
import '../viewmodels/shop_viewmodel.dart';
import '../views/game_start_confirm_dialog_view.dart';
import '../viewmodels/game_session_viewmodel.dart';
import '../viewmodels/player_data_viewmodel.dart';

class SetupView extends StatefulWidget {
  const SetupView({super.key});

  @override
  State<SetupView> createState() => _SetupViewState();
}

class _SetupViewState extends State<SetupView> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _onTaskAssigned() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TaskAssignmentView();
      },
    );
  }

  void _onRouteSelected() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => DestinationFetchViewModel(),
            ),
            ChangeNotifierProvider(
              create: (context) => DestinationChooseViewModel(),
            ),
          ],
          child: const DestinationFetchView(),
        );
      },
    );
  }

  void _onWarehouseCargoChecked() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (context) => WarehouseViewModel(),
          child: const WarehouseDialogView(),
        );
      },
    );
  }

  void _onShowVehicles() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => VehicleViewModel(),
            ),
            ChangeNotifierProvider(
              create: (context) => VehicleChooseViewModel(),
            ),
          ],
          child: const VehicleDialogView(),
        );
      },
    );
  }

  void _onShopOpened() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (context) => ShopViewModel(),
          child: const ShopDialogView(),
        );
      },
    );
  }

  void _onStartGame() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (context) => GameSessionViewModel(),
          child: const GameStartConfirmDialogView(),
        );
      },
    );
  }

  void _onPlayerAvatarTapped() {
    PlayerDataDisplayView().showPlayerDataDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    // 构建 Widget
    return ChangeNotifierProvider(
      create: (context) => PlayerDataViewModel()..fetchPlayerData(),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
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
                  Consumer<PlayerDataViewModel>(
                    builder: (context, viewModel, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            viewModel.isLoading
                                ? '載入中...'
                                : (viewModel.playerData?.displayName ?? '玩家名稱'),
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
                                  color: const Color.fromRGBO(178, 255, 89, 1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(), // 空 Container，用于占位
            Positioned(
              // 使用 Positioned Widget 定位按鈕區域
              left: MediaQuery.of(context).size.width * 0.4 -
                  (MediaQuery.of(context).size.width * 0.6 / 2), // 置中
              top: MediaQuery.of(context).size.height * 0.55 -
                  (MediaQuery.of(context).size.height * 0.5 / 2), // 垂直置中
              child: Row(
                // 使用 Row 水平排列
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 左側：3x2 網格
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          AdaptiveButton(
                            widthGain: 0.15,
                            heightGain: 0.18,
                            backgroundColor: const Color(0xFF1E3A5F),
                            borderColor: const Color(0xFF4A90E2),
                            highlightColor: const Color(0xFF7CB3F5),
                            shadowColor: const Color(0xFF0D1F3A),
                            imagePath: "assets/images/volticar_logo.png",
                            iconPath: "assets/icons/list.png",
                            text: '委託任務',
                            textColor: Colors.white,
                            onTap: _onTaskAssigned,
                            showImage: true,
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.02),
                          AdaptiveButton(
                            widthGain: 0.15,
                            heightGain: 0.18,
                            backgroundColor: const Color(0xFF1E3A5F),
                            borderColor: const Color(0xFF4A90E2),
                            highlightColor: const Color(0xFF7CB3F5),
                            shadowColor: const Color(0xFF0D1F3A),
                            imagePath: "assets/images/volticar_logo.png",
                            iconPath: "assets/icons/maps-and-flags.png",
                            text: '路線選擇',
                            textColor: Colors.white,
                            onTap: _onRouteSelected,
                            showImage: true,
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.02),
                          AdaptiveButton(
                            widthGain: 0.15,
                            heightGain: 0.18,
                            backgroundColor: const Color(0xFF1E3A5F),
                            borderColor: const Color(0xFF4A90E2),
                            highlightColor: const Color(0xFF7CB3F5),
                            shadowColor: const Color(0xFF0D1F3A),
                            imagePath: "assets/images/volticar_logo.png",
                            iconPath:
                                "assets/icons/closed-cardboard-box-with-packing-tape.png",
                            text: '倉儲貨物',
                            textColor: Colors.white,
                            onTap: _onWarehouseCargoChecked,
                            showImage: true,
                          ),
                        ],
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      Row(
                        children: [
                          AdaptiveButton(
                            widthGain: 0.15,
                            heightGain: 0.18,
                            backgroundColor: const Color(0xFF1E3A5F),
                            borderColor: const Color(0xFF4A90E2),
                            highlightColor: const Color(0xFF7CB3F5),
                            shadowColor: const Color(0xFF0D1F3A),
                            imagePath: "assets/images/volticar_logo.png",
                            iconPath: "assets/icons/car.png",
                            text: '顯示車輛',
                            textColor: Colors.white,
                            onTap: _onShowVehicles,
                            showImage: true,
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.02),
                          AdaptiveButton(
                            widthGain: 0.15,
                            heightGain: 0.18,
                            backgroundColor: const Color(0xFF5F3A1E),
                            borderColor: const Color(0xFFE2904A),
                            highlightColor: const Color(0xFFF5B37C),
                            shadowColor: const Color(0xFF3A1F0D),
                            imagePath: "assets/images/volticar_logo.png",
                            iconPath: "assets/icons/shopping-cart.png",
                            text: '商店',
                            textColor: Colors.white,
                            onTap: _onShopOpened,
                            showImage: true,
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.02),
                          AdaptiveButton(
                            widthGain: 0.15,
                            heightGain: 0.18,
                            backgroundColor: const Color(0xFF1E5F3A),
                            borderColor: const Color(0xFF4AE290),
                            highlightColor: const Color(0xFF7CF5B3),
                            shadowColor: const Color(0xFF0D3A1F),
                            imagePath: "assets/images/volticar_logo.png",
                            iconPath: "assets/icons/play.png",
                            text: '開始遊戲',
                            textColor: Colors.white,
                            onTap: _onStartGame,
                            showImage: true,
                          ),
                        ],
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
}
