import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';

class VehicleRepository {
  final VehicleService service = VehicleService();

  /// 取得使用者車輛列表
  Future<List<Vehicle>> getUserVehicles() async {
    return await service.fetchUserVehicles();
  }
}
