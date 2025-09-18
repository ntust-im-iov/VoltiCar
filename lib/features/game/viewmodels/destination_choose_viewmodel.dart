import 'package:flutter/material.dart';
import 'package:volticar_app/features/game/models/destination_choose_model.dart';
import 'package:volticar_app/features/game/repositories/destination_choose_repository.dart';

class DestinationChooseViewModel extends ChangeNotifier {
  final DestinationChooseRepository _destinationChooseRepository;

  // 選擇目的地相關狀態
  DestinationChooseModel? _chosenDestination;
  String? _chosenDestinationId;

  // 載入狀態
  bool _isChoosing = false;
  String? _error;
  bool _isChooseSuccess = false;

  DestinationChooseViewModel({
    DestinationChooseRepository? destinationChooseRepository,
  }) : _destinationChooseRepository =
            destinationChooseRepository ?? DestinationChooseRepository();

  // 狀態 getter
  bool get isChoosing => _isChoosing;
  String? get error => _error;
  bool get isChooseSuccess => _isChooseSuccess;
  DestinationChooseModel? get chosenDestination => _chosenDestination;
  String? get chosenDestinationId => _chosenDestinationId;

  // 檢查目的地是否已被選擇
  bool isDestinationChosen(String destinationId) {
    return _chosenDestinationId == destinationId && _isChooseSuccess;
  }

  // 選擇目的地
  Future<void> chooseDestination(String destinationId) async {
    print('ViewModel: Starting to choose destination: $destinationId');
    _updateState(isChoosing: true, error: null, isChooseSuccess: false);

    try {
      final result =
          await _destinationChooseRepository.chooseDestination(destinationId);

      print('ViewModel: Received result: ${result.destinationId}');
      print('ViewModel: Result name: ${result.name}');
      print('ViewModel: Result region: ${result.region}');

      if (result.destinationId.isNotEmpty) {
        _chosenDestination = result;
        _chosenDestinationId = destinationId;
        print(
            'ViewModel: Setting success state for destination: $destinationId');
        _updateState(isChoosing: false, isChooseSuccess: true);
      } else {
        print('ViewModel: Result has empty destinationId');
        _updateState(
          isChoosing: false,
          error: '選擇目的地失敗，請稍後重試',
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
  void clearChosenDestination() {
    _chosenDestination = null;
    _chosenDestinationId = null;
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
        'ViewModel: State after update - isChoosing: $_isChoosing, isChooseSuccess: $_isChooseSuccess, chosenDestinationId: $_chosenDestinationId');
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
