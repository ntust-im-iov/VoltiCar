import "package:volticar_app/features/game/models/vehicle_choose_model.dart";
import "package:volticar_app/features/game/services/vehicle_choose_service.dart";

class VehicleChooseRepository {
  final VehicleChooseService _vehicleChooseService = VehicleChooseService();

  Future<VehicleChooseModel> chooseVehicle(String vehicleId) async {
    final result = await _vehicleChooseService.chooseVehicle(vehicleId);
    return result;
  }
}
