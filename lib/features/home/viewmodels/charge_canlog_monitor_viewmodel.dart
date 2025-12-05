import 'dart:async';
import 'package:flutter/material.dart';
import '../models/charge_canlog_monitor_model.dart';
import '../repositories/charge_canlog_monitor_repository.dart';

class ChargeCanlogMonitorViewModel extends ChangeNotifier {
  final ChargeCanlogMonitorRepository _repository;
  StreamSubscription<ChargeCanlogMonitor>? _subscription;

  ChargeCanlogMonitor? _latestData;
  ChargeCanlogMonitor? _lastData; // 暫存最後一筆資料
  bool _isLoading = false;
  String? _error;
  bool _isFinished = false;

  ChargeCanlogMonitor? get latestData => _latestData;
  ChargeCanlogMonitor? get lastData => _lastData; // 提供外部存取
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isFinished => _isFinished;

  ChargeCanlogMonitorViewModel({ChargeCanlogMonitorRepository? repository})
      : _repository = repository ?? ChargeCanlogMonitorRepository();

  void startListening({
    required String log,
    bool skipIdle = false,
    int duration = 2000,
  }) {
    _isLoading = true;
    _error = null;
    _isFinished = false;
    notifyListeners();
    _subscription = _repository
        .getChargeCanlogMonitorStream(
      log: log,
      skipIdle: skipIdle,
      duration: duration,
    )
        .listen(
      (data) {
        _latestData = data;
        _lastData = data; // 每次收到新資料都暫存
        if (data.isFinished) {
          _isFinished = true;
          _isLoading = false;
          _subscription?.cancel();
        }
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
      onDone: () {
        _isLoading = false;
        notifyListeners();
      },
      cancelOnError: false,
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
