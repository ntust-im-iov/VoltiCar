import 'package:flutter/material.dart';
import 'package:volticar_app/features/game/models/destination_model.dart';
import 'package:volticar_app/features/game/repositories/destination_fetch_repository.dart';

class DestinationFetchViewModel extends ChangeNotifier {
  final DestinationFetchRepository _destinationFetchRepository;

  // 目的地相關狀態
  List<Destination> _destinations = [];
  Destination? _selectedDestination;

  // 載入狀態
  bool _isLoading = false;
  String? _error;
  bool _isSuccess = false;

  DestinationFetchViewModel({
    DestinationFetchRepository? destinationFetchRepository,
  }) : _destinationFetchRepository =
            destinationFetchRepository ?? DestinationFetchRepository();

  // 狀態 getter
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSuccess => _isSuccess;
  List<Destination> get destinations => List.unmodifiable(_destinations);
  Destination? get selectedDestination => _selectedDestination;

  // 根據地區篩選目的地
  List<Destination> getDestinationsByRegion(String region) {
    return _destinations
        .where((destination) =>
            destination.region.toLowerCase() == region.toLowerCase())
        .toList();
  }

  // 獲取所有可用的地區
  List<String> get availableRegions {
    final regions =
        _destinations.map((destination) => destination.region).toSet().toList();
    regions.sort();
    return regions;
  }

  // 獲取已解鎖的目的地
  List<Destination> get unlockedDestinations {
    return _destinations
        .where((destination) => destination.isUnlockedByDefault)
        .toList();
  }

  // 設置選中的目的地
  void selectDestination(Destination? destination) {
    _selectedDestination = destination;
    notifyListeners();
  }

  // 獲取目的地列表
  Future<void> fetchDestinations() async {
    _updateState(isLoading: true, error: null, isSuccess: false);

    try {
      final destinations =
          await _destinationFetchRepository.fetchDestinations();
      _destinations = destinations;
      _updateState(isLoading: false, isSuccess: true);
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.split('Exception:').last.trim();
      }
      _updateState(
        isLoading: false,
        error: errorMessage,
        isSuccess: false,
      );
    }
  }

  // 重新載入目的地
  Future<void> refreshDestinations() async {
    await fetchDestinations();
  }

  // 清除錯誤狀態
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 更新狀態的輔助方法
  void _updateState({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    if (isLoading != null) _isLoading = isLoading;
    if (error != null) _error = error;
    if (isSuccess != null) _isSuccess = isSuccess;
    notifyListeners();
  }

  // 檢查目的地是否可用（基於服務類型）
  bool isServiceAvailable(Destination destination, String serviceType) {
    return destination.availableServices.contains(serviceType);
  }

  // 獲取特定服務的目的地
  List<Destination> getDestinationsWithService(String serviceType) {
    return _destinations
        .where((destination) =>
            destination.availableServices.contains(serviceType))
        .toList();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
