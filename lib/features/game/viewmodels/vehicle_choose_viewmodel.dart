import 'package:flutter/material.dart';
import 'package:volticar_app/features/game/models/vehicle_choose_model.dart';
import 'package:volticar_app/features/game/repositories/vehicle_choose_repository.dart';

class VehicleChooseViewModel extends ChangeNotifier {
  final VehicleChooseRepository _vehicleChooseRepository;

  // 選擇車輛相關狀態
  VehicleChooseModel? _chosenVehicle;
  String? _chosenVehicleId;

  // 載入狀態
  bool _isChoosing = false;
  String? _error;
  bool _isChooseSuccess = false;

  VehicleChooseViewModel({
    VehicleChooseRepository? vehicleChooseRepository,
  }) : _vehicleChooseRepository =
            vehicleChooseRepository ?? VehicleChooseRepository();

  // 狀態 getter
  bool get isChoosing => _isChoosing;
  String? get error => _error;
  bool get isChooseSuccess => _isChooseSuccess;
  VehicleChooseModel? get chosenVehicle => _chosenVehicle;
  String? get chosenVehicleId => _chosenVehicleId;

  // 檢查車輛是否已被選擇
  bool isVehicleChosen(String vehicleId) {
    return _chosenVehicleId == vehicleId && _isChooseSuccess;
  }

  // 選擇車輛
  Future<void> chooseVehicle(String vehicleId) async {
    print('ViewModel: Starting to choose vehicle: $vehicleId');
    _updateState(isChoosing: true, error: null, isChooseSuccess: false);

    try {
      final result = await _vehicleChooseRepository.chooseVehicle(vehicleId);

      print('ViewModel: Received result: ${result.selectedVehicle.vehicleId}');
      print('ViewModel: Result name: ${result.selectedVehicle.name}');
      print('ViewModel: Message: ${result.message}');
      print('ViewModel: Cleared cargo: ${result.clearedCargo}');

      if (result.selectedVehicle.vehicleId.isNotEmpty) {
        _chosenVehicle = result;
        _chosenVehicleId = vehicleId;
        print('ViewModel: Setting success state for vehicle: $vehicleId');
        _updateState(isChoosing: false, isChooseSuccess: true);
      } else {
        print('ViewModel: Result has empty vehicleId');
        _updateState(
          isChoosing: false,
          error: '選擇車輛失敗，請稍後重試',
          isChooseSuccess: false,
        );
      }
    } catch (e) {
      print('ViewModel: Exception occurred: $e');
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.split('Exception:').last.trim();
      }
      _updateState(
        isChoosing: false,
        error: errorMessage,
        isChooseSuccess: false,
      );
    }
  }

  // 清除選擇狀態
  void clearChosenVehicle() {
    _chosenVehicle = null;
    _chosenVehicleId = null;
    _isChooseSuccess = false;
    notifyListeners();
  }

  // 清除錯誤狀態
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 更新狀態的輔助方法
  void _updateState({
    bool? isChoosing,
    String? error,
    bool? isChooseSuccess,
  }) {
    print(
        'ViewModel: Updating state - isChoosing: $isChoosing, error: $error, isChooseSuccess: $isChooseSuccess');
    if (isChoosing != null) _isChoosing = isChoosing;
    if (error != null) _error = error;
    if (isChooseSuccess != null) _isChooseSuccess = isChooseSuccess;
    print(
        'ViewModel: State after update - isChoosing: $_isChoosing, isChooseSuccess: $_isChooseSuccess, chosenVehicleId: $_chosenVehicleId');
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
