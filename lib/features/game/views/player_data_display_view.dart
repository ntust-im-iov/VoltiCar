import 'package:flutter/material.dart';
import '../viewmodels/player_data_viewmodel.dart';
import 'package:provider/provider.dart';

class PlayerDataDisplayView extends StatelessWidget {
  const PlayerDataDisplayView({Key? key}) : super(key: key);

  void showPlayerDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (_) => PlayerDataViewModel()..fetchPlayerData(),
          child: Consumer<PlayerDataViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (viewModel.error != null) {
                return AlertDialog(
                  title: const Text('錯誤'),
                  content: Text(viewModel.error!),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('關閉'),
                    ),
                  ],
                );
              } else if (viewModel.playerData != null) {
                final playerData = viewModel.playerData!;
                return Dialog(
                  backgroundColor:
                      const Color.fromARGB(255, 38, 36, 36).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Color(0xFF42A5F5), width: 2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.8,
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              '玩家資料',
                              style: const TextStyle(
                                color: Color(0xFF42A5F5),
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text('玩家ID：${playerData.userId}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18)),
                          const SizedBox(height: 12),
                          Text('玩家名稱：${playerData.displayName}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18)),
                          const SizedBox(height: 12),
                          Text('等級：${playerData.level}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18)),
                          const SizedBox(height: 12),
                          Text('經驗值：${playerData.experience}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18)),
                          const SizedBox(height: 12),
                          Text(
                              '成就：${playerData.achievements.isNotEmpty ? playerData.achievements.join(", ") : "無"}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18)),
                          const SizedBox(height: 12),
                          Text(
                              '遊戲進行中：${playerData.gameSession.active ? "是" : "否"}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18)),
                          const SizedBox(height: 12),
                          Text('車輛ID：${playerData.gameSession.vehicleId}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18)),
                          const SizedBox(height: 12),
                          Text('目的地ID：${playerData.gameSession.destinationId}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18)),
                          const SizedBox(height: 12),
                          Text(
                              '貨物：${playerData.gameSession.cargo.isNotEmpty ? playerData.gameSession.cargo.toString() : "無"}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18)),
                          const SizedBox(height: 12),
                          Text(
                              '倉庫：${playerData.warehouse.isNotEmpty ? playerData.warehouse.toString() : "無"}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18)),
                          const SizedBox(height: 12),
                          Text(
                              '任務：${playerData.tasks.isNotEmpty ? playerData.tasks.toString() : "無"}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => showPlayerDataDialog(context),
        child: const Text('顯示玩家資料'),
      ),
    );
  }
}
