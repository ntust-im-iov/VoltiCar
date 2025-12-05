import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/game_session_viewmodel.dart';
import '../views/main_game_view.dart';
import '../../../shared/widgets/adaptive_button.dart';

class GameStartConfirmDialogView extends StatefulWidget {
  const GameStartConfirmDialogView({Key? key}) : super(key: key);

  @override
  State<GameStartConfirmDialogView> createState() =>
      _GameStartConfirmDialogViewState();
}

class _GameStartConfirmDialogViewState
    extends State<GameStartConfirmDialogView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel =
          Provider.of<GameSessionViewModel>(context, listen: false);
      viewModel.fetchGameSessionSummary();
    });
  }

  void _startGame() {
    Navigator.of(context).pop(); // 關閉對話框
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MainGameView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 38, 36, 36),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFF42A5F5), width: 2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Consumer<GameSessionViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (viewModel.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '錯誤: ${viewModel.error}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.fetchGameSessionSummary(),
                      child: const Text('重試'),
                    ),
                  ],
                ),
              );
            }

            final summary = viewModel.summary;
            if (summary == null) {
              return const Center(
                child: Text('無法取得遊戲資料', style: TextStyle(color: Colors.white)),
              );
            }

            return Column(
              children: [
                // 頂部標題列
                Container(
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF42A5F5), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 16),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 2),
                      const Text(
                        '遊戲開始確認',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // 主要內容區域（可滾動）
                Expanded(
                  child: Container(
                    color: const Color(0xFF1A1A1A),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 第一行：車輛 + 貨物
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildVehicleCard(
                                    summary.sessionSummary.selectedVehicle),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildCargoCard(
                                    summary.sessionSummary.selectedCargo),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // 第二行：目的地 + 相關任務
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildDestinationCard(
                                    summary.sessionSummary.selectedDestination),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTasksCard(summary.relatedTasks),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // 警告訊息（條件顯示，單獨一列）
                          if (summary.startGameWarnings.isNotEmpty)
                            _buildWarningsCard(summary.startGameWarnings),
                        ],
                      ),
                    ),
                  ),
                ),
                // 底部按鈕區域
                Container(
                  height: 50,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    border: Border(
                      top: BorderSide(color: Color(0xFF42A5F5), width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 取消按鈕
                      AdaptiveButton(
                        widthGain: 0.08,
                        heightGain: 0.08,
                        backgroundColor: const Color(0xFF5F1E1E),
                        borderColor: const Color(0xFFE24A4A),
                        highlightColor: const Color(0xFFF57C7C),
                        shadowColor: const Color(0xFF3A0D0D),
                        imagePath: "",
                        iconPath: null,
                        text: '取消',
                        textColor: Colors.white,
                        fixedFontSize: 10.0,
                        onTap: () => Navigator.of(context).pop(),
                        showImage: false,
                      ),
                      const SizedBox(width: 8),
                      // 開始遊戲按鈕
                      AdaptiveButton(
                        widthGain: 0.12,
                        heightGain: 0.08,
                        backgroundColor: viewModel.canStartGame
                            ? const Color(0xFF1E5F3A)
                            : const Color(0xFF3A3A3A),
                        borderColor: viewModel.canStartGame
                            ? const Color(0xFF4AE290)
                            : const Color(0xFF666666),
                        highlightColor: viewModel.canStartGame
                            ? const Color(0xFF7CF5B3)
                            : const Color(0xFF888888),
                        shadowColor: viewModel.canStartGame
                            ? const Color(0xFF0D3A1F)
                            : const Color(0xFF1A1A1A),
                        imagePath: "",
                        iconPath: null,
                        text: viewModel.canStartGame ? '開始遊戲' : '無法開始',
                        textColor: Colors.white,
                        fixedFontSize: 10.0,
                        onTap: viewModel.canStartGame ? _startGame : () {},
                        showImage: false,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildVehicleCard(selectedVehicle) {
    return Card(
      color: const Color(0xFF232323),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_car,
                  color: selectedVehicle != null ? Colors.blue : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  '選擇的車輛',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(color: Color(0xFF42A5F5)),
            if (selectedVehicle != null) ...[
              Text(
                '車輛名稱：${selectedVehicle.name}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                '最大載重：${selectedVehicle.maxLoadWeight.toStringAsFixed(0)} kg',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                '最大容積：${selectedVehicle.maxLoadVolume.toStringAsFixed(1)} m³',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ] else
              const Text(
                '❌ 尚未選擇車輛',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCargoCard(selectedCargo) {
    return Card(
      color: const Color(0xFF232323),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory_2,
                  color: selectedCargo != null ? Colors.blue : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  '選擇的貨物',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(color: Color(0xFF42A5F5)),
            if (selectedCargo != null) ...[
              Text(
                '貨物 ID：${selectedCargo.itemId}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                '數量：${selectedCargo.quantity}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ] else
              const Text(
                '尚未選取貨物',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCard(selectedDestination) {
    return Card(
      color: const Color(0xFF232323),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: selectedDestination != null ? Colors.blue : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  '目的地',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(color: Color(0xFF42A5F5)),
            if (selectedDestination != null) ...[
              Text(
                '名稱：${selectedDestination.name}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                '地區：${selectedDestination.region}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ] else
              const Text(
                '❌ 尚未選擇目的地',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksCard(List relatedTasks) {
    return Card(
      color: const Color(0xFF232323),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment,
                  color: relatedTasks.isNotEmpty ? Colors.blue : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  '相關任務',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(color: Color(0xFF42A5F5)),
            if (relatedTasks.isNotEmpty) ...[
              ...relatedTasks.map((task) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• 任務 ID：${task.taskId}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  )),
            ] else
              const Text(
                '尚無相關任務',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningsCard(List<String> warnings) {
    return Card(
      color: Colors.orange.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.orange,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  '⚠️ 警告',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.orange),
            ...warnings.map((warning) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $warning',
                    style: const TextStyle(color: Colors.orange, fontSize: 14),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
