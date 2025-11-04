import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/warehouse_viewmodel.dart';
import '../models/game_item_model.dart';

class WarehouseDialogView extends StatefulWidget {
  const WarehouseDialogView({Key? key}) : super(key: key);

  @override
  State<WarehouseDialogView> createState() => _WarehouseDialogViewState();
}

class _WarehouseDialogViewState extends State<WarehouseDialogView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<WarehouseViewModel>(context, listen: false);
      viewModel.fetchWarehouseItems();
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
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Consumer<WarehouseViewModel>(
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
                      onPressed: () => viewModel.fetchWarehouseItems(),
                      child: const Text('重試'),
                    ),
                  ],
                ),
              );
            }
            if (viewModel.items.isEmpty) {
              return const Center(
                child: Text('倉庫目前沒有貨物', style: TextStyle(color: Colors.white)),
              );
            }
            return Column(
              children: [
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
                        '倉庫貨物',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh,
                            color: Colors.white, size: 16),
                        onPressed: () => viewModel.fetchWarehouseItems(),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFF1A1A1A),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: viewModel.items.length,
                      itemBuilder: (context, index) {
                        final GameItem item = viewModel.items[index];
                        Widget leadingWidget;
                        if (item.iconUrl.isNotEmpty &&
                            (item.iconUrl.startsWith('http://') ||
                                item.iconUrl.startsWith('https://'))) {
                          leadingWidget = Image.network(
                            item.iconUrl,
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.inventory,
                                    color: Colors.white),
                          );
                        } else {
                          leadingWidget = Image.asset(
                            item.iconUrl.isNotEmpty
                                ? item.iconUrl
                                : 'assets/images/volticar_logo.png',
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.inventory,
                                    color: Colors.white),
                          );
                        }
                        return Card(
                          color: const Color(0xFF232323),
                          child: ListTile(
                            leading: leadingWidget,
                            title: Text(item.name,
                                style: const TextStyle(color: Colors.white)),
                            subtitle: Text(item.description,
                                style: const TextStyle(color: Colors.white70)),
                            trailing: Text('x${item.quantityInWarehouse}',
                                style: const TextStyle(color: Colors.white)),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
