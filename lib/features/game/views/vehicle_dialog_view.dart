import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/vehicle_viewmodel.dart';
import '../models/vehicle_model.dart';

class VehicleDialogView extends StatefulWidget {
  const VehicleDialogView({Key? key}) : super(key: key);

  @override
  State<VehicleDialogView> createState() => _VehicleDialogViewState();
}

class _VehicleDialogViewState extends State<VehicleDialogView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<VehicleViewModel>(context, listen: false);
      viewModel.fetchVehicles();
    });
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'rentable':
        return '可租用';
      case 'owned':
        return '已擁有';
      case 'in_use':
        return '使用中';
      case 'unavailable':
        return '無法使用';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'rentable':
        return Colors.green;
      case 'owned':
        return Colors.blue;
      case 'in_use':
        return Colors.orange;
      case 'unavailable':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
        child: Consumer<VehicleViewModel>(
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
                      onPressed: () => viewModel.fetchVehicles(),
                      child: const Text('重試'),
                    ),
                  ],
                ),
              );
            }
            if (viewModel.vehicles.isEmpty) {
              return const Center(
                child: Text('目前沒有可用車輛', style: TextStyle(color: Colors.white)),
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
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 16),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '車輛列表',
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
                        onPressed: () => viewModel.fetchVehicles(),
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
                      itemCount: viewModel.vehicles.length,
                      itemBuilder: (context, index) {
                        final Vehicle vehicle = viewModel.vehicles[index];
                        return Card(
                          color: const Color(0xFF232323),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        vehicle.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(vehicle.status)
                                            .withOpacity(0.2),
                                        border: Border.all(
                                          color: _getStatusColor(vehicle.status),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _getStatusText(vehicle.status),
                                        style: TextStyle(
                                          color: _getStatusColor(vehicle.status),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.category,
                                        color: Colors.white70, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '類型: ${vehicle.type}',
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.fitness_center,
                                        color: Colors.white70, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '最大載重: ${vehicle.maxLoadWeight.toStringAsFixed(0)} kg',
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.inventory_2,
                                        color: Colors.white70, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '最大容積: ${vehicle.maxLoadVolume.toStringAsFixed(1)} m³',
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
