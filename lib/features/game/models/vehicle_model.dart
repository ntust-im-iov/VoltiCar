class Vehicle {
  final String vehicleId;
  final String? playerVehicleId;
  final String name;
  final String type;
  final double maxLoadWeight;
  final double maxLoadVolume;
  final String status;

  Vehicle({
    required this.vehicleId,
    this.playerVehicleId,
    required this.name,
    required this.type,
    required this.maxLoadWeight,
    required this.maxLoadVolume,
    required this.status,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleId: json['vehicle_id'] ?? '',
      playerVehicleId: json['player_vehicle_id'],
      name: json['name'] ?? 'Unknown Vehicle',
      type: json['type'] ?? 'unknown',
      maxLoadWeight: (json['max_load_weight'] ?? 0).toDouble(),
      maxLoadVolume: (json['max_load_volume'] ?? 0).toDouble(),
      status: json['status'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'player_vehicle_id': playerVehicleId,
      'name': name,
      'type': type,
      'max_load_weight': maxLoadWeight,
      'max_load_volume': maxLoadVolume,
      'status': status,
    };
  }
}
