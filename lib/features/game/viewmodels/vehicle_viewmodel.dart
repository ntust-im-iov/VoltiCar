import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../repositories/vehicle_repository.dart';

class VehicleViewModel extends ChangeNotifier {
  final VehicleRepository _vehicleRepository;

  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  String? _error;

  VehicleViewModel({VehicleRepository? vehicleRepository})
      : _vehicleRepository = vehicleRepository ?? VehicleRepository();

  List<Vehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchVehicles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _vehicles = await _vehicleRepository.getUserVehicles();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
