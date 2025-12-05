import '../models/charge_canlog_monitor_model.dart';
import '../services/charge_canlog_monitor_service.dart';

class ChargeCanlogMonitorRepository {
  final ChargeCanlogMonitorService _service;

  ChargeCanlogMonitorRepository({ChargeCanlogMonitorService? service})
      : _service = service ?? ChargeCanlogMonitorService();

  /// 取得充電 CAN log 監控流式資料
  Stream<ChargeCanlogMonitor> getChargeCanlogMonitorStream({
    required String log,
    bool skipIdle = false,
    int duration = 2000,
  }) {
    return _service.getChargeCanlogMonitorStream(
      log: log,
      skipIdle: skipIdle,
      duration: duration,
    );
  }
}
