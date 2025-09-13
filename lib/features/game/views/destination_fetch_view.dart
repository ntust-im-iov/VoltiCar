import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volticar_app/features/game/viewmodels/destination_fetch_viewmodel.dart';

class DestinationFetchView extends StatefulWidget {
  const DestinationFetchView({super.key});

  @override
  State<DestinationFetchView> createState() => _DestinationFetchViewState();
}

class _DestinationFetchViewState extends State<DestinationFetchView> {
  String _selectedRegion = '全部';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel =
          Provider.of<DestinationFetchViewModel>(context, listen: false);
      viewModel.fetchDestinations();
    });
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
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.95,
        child: Consumer<DestinationFetchViewModel>(
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
                      onPressed: () => viewModel.refreshDestinations(),
                      child: const Text('重試'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // 頂部導覽列
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
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 10),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '目的地管理',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh,
                            color: Colors.white, size: 10),
                        onPressed: () => viewModel.refreshDestinations(),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),

                // 地區篩選標籤
                Container(
                  height: 40,
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2A2A2A),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF42A5F5), width: 1),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: _buildRegionTabs(viewModel),
                    ),
                  ),
                ),

                // 主要內容區域
                Expanded(
                  child: Row(
                    children: [
                      // 左側目的地列表
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            // 目的地列表標題
                            Container(
                              height: 30,
                              color: const Color(0xFF2A2A2A),
                              child: const Center(
                                child: Text(
                                  '目的地列表',
                                  style: TextStyle(
                                    color: Color(0xFF42A5F5),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                color: const Color(0xFF1A1A1A),
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(8),
                                  itemCount: _getFilteredDestinations(viewModel)
                                      .length,
                                  itemBuilder: (context, index) {
                                    final destination =
                                        _getFilteredDestinations(
                                            viewModel)[index];

                                    return _buildDestinationCard(
                                      destination,
                                      viewModel,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 分隔線
                      Container(
                        width: 1,
                        color: const Color(0xFF42A5F5),
                      ),

                      // 右側目的地詳情
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            // 詳情標題
                            Container(
                              height: 30,
                              color: const Color(0xFF2A2A2A),
                              child: const Center(
                                child: Text(
                                  '目的地詳情',
                                  style: TextStyle(
                                    color: Color(0xFF42A5F5),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            // 詳情內容
                            Expanded(
                              child: Container(
                                color: const Color(0xFF1A1A1A),
                                padding: const EdgeInsets.all(16),
                                child: viewModel.selectedDestination != null
                                    ? _buildDestinationDetails(
                                        viewModel.selectedDestination!)
                                    : const Center(
                                        child: Text(
                                          '請選擇一個目的地查看詳情',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
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

  List<Widget> _buildRegionTabs(DestinationFetchViewModel viewModel) {
    final regions = ['全部', ...viewModel.availableRegions];

    return regions.map((region) {
      final isSelected = _selectedRegion == region;

      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedRegion = region;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF42A5F5) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF42A5F5),
              width: 1,
            ),
          ),
          child: Text(
            region,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF42A5F5),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<dynamic> _getFilteredDestinations(DestinationFetchViewModel viewModel) {
    if (_selectedRegion == '全部') {
      return viewModel.destinations;
    }
    return viewModel.getDestinationsByRegion(_selectedRegion);
  }

  Widget _buildDestinationCard(
      destination, DestinationFetchViewModel viewModel) {
    final isSelected = viewModel.selectedDestination?.id == destination.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF42A5F5).withValues(alpha: 0.3)
            : const Color(0xFF2A2A2A),
        border: Border.all(
          color: isSelected ? const Color(0xFF42A5F5) : Colors.transparent,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => viewModel.selectDestination(destination),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 目的地圖標
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF42A5F5).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: destination.iconUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          destination.iconUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.location_on,
                            color: Color(0xFF42A5F5),
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.location_on,
                        color: Color(0xFF42A5F5),
                      ),
              ),

              const SizedBox(width: 12),

              // 左側目的地內容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 目的地名稱
                    Text(
                      destination.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // 地區
                    Text(
                      destination.region,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // 可用服務數量
                    Text(
                      '服務: ${destination.availableServices.length} 項',
                      style: const TextStyle(
                        color: Color(0xFF42A5F5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // 右側狀態標籤
              if (destination.isUnlockedByDefault)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: const Text(
                    '已解鎖',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: const Text(
                    '鎖定',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationDetails(destination) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 目的地標題和圖片
          Row(
            children: [
              // 目的地圖片
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF42A5F5).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: destination.iconUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          destination.iconUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.location_on,
                            color: Color(0xFF42A5F5),
                            size: 30,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.location_on,
                        color: Color(0xFF42A5F5),
                        size: 30,
                      ),
              ),

              const SizedBox(width: 16),

              // 目的地名稱和地區
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      destination.region,
                      style: const TextStyle(
                        color: Color(0xFF42A5F5),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 目的地描述
          const Text(
            '描述',
            style: TextStyle(
              color: Color(0xFF42A5F5),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            destination.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          // 座標資訊
          const Text(
            '位置座標',
            style: TextStyle(
              color: Color(0xFF42A5F5),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '類型: ${destination.coordinates.type}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            '座標: [${destination.coordinates.coordinates.join(', ')}]',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 16),

          // 解鎖條件
          const Text(
            '解鎖條件',
            style: TextStyle(
              color: Color(0xFF42A5F5),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (destination.isUnlockedByDefault)
            const Text(
              '• 預設解鎖',
              style: TextStyle(
                color: Colors.green,
                fontSize: 14,
              ),
            )
          else ...[
            Text(
              '• 需要等級: ${destination.unlockRequirements.requiredPlayerLevel}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            if (destination
                .unlockRequirements.requiredCompletedTaskId.isNotEmpty)
              Text(
                '• 需要完成任務: ${destination.unlockRequirements.requiredCompletedTaskId}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
          ],

          const SizedBox(height: 16),

          // 可用服務
          const Text(
            '可用服務',
            style: TextStyle(
              color: Color(0xFF42A5F5),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (destination.availableServices.isEmpty)
            const Text(
              '暫無可用服務',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: destination.availableServices
                  .map<Widget>(
                    (service) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF42A5F5).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFF42A5F5), width: 1),
                      ),
                      child: Text(
                        service,
                        style: const TextStyle(
                          color: Color(0xFF42A5F5),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}
