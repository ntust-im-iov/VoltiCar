class VehicleChooseModel {
  final String message;
  final SelectedVehicle selectedVehicle;
  final bool clearedCargo;

  VehicleChooseModel({
    required this.message,
    required this.selectedVehicle,
    required this.clearedCargo,
  });

  factory VehicleChooseModel.fromJson(Map<String, dynamic> json) {
    return VehicleChooseModel(
      message: json['message'] as String? ?? '',
      selectedVehicle: json['selected_vehicle'] != null
          ? SelectedVehicle.fromJson(
              json['selected_vehicle'] as Map<String, dynamic>)
          : SelectedVehicle(
              vehicleId: '',
              name: '',
              maxLoadWeight: 0.0,
              maxLoadVolume: 0.0,
            ),
      clearedCargo: json['cleared_cargo'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'selected_vehicle': selectedVehicle.toJson(),
      'cleared_cargo': clearedCargo,
    };
  }
}

class SelectedVehicle {
  final String vehicleId;
  final String name;
  final double maxLoadWeight;
  final double maxLoadVolume;

  SelectedVehicle({
    required this.vehicleId,
    required this.name,
    required this.maxLoadWeight,
    required this.maxLoadVolume,
  });

  factory SelectedVehicle.fromJson(Map<String, dynamic> json) {
    return SelectedVehicle(
      vehicleId: json['vehicle_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      maxLoadWeight: (json['max_load_weight'] ?? 0).toDouble(),
      maxLoadVolume: (json['max_load_volume'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'name': name,
      'max_load_weight': maxLoadWeight,
      'max_load_volume': maxLoadVolume,
    };
  }
}
