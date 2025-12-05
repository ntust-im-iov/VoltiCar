import 'package:dio/dio.dart';
import '../models/charge_canlog_monitor_model.dart';
import 'package:volticar_app/core/constants/api_constants.dart';
import 'dart:convert';
import 'dart:async';
import 'package:logger/logger.dart';

class ChargeCanlogMonitorService {
  final Dio _dio = Dio();
  final Logger _logger = Logger();
  static final String _streamUrl =
      '${ApiConstants.baseUrl}${ApiConstants.chargeCanlogMonitorStream}';

  /// 取得充電 CAN log 監控流式資料
  Stream<ChargeCanlogMonitor> getChargeCanlogMonitorStream({
    required String log,
    bool skipIdle = false,
    int duration = 2000,
  }) async* {
    _logger.i(
        '[Service] getChargeCanlogMonitorStream called, params: log=$log, skipIdle=$skipIdle, duration=$duration');
    try {
      final response = await _dio.get(
        _streamUrl,
        queryParameters: {
          'log': log,
          'skip_idle': skipIdle.toString(),
          'duration': duration.toString(),
        },
        options: Options(responseType: ResponseType.stream),
      );
      _logger.i('[Service] API requested: $_streamUrl');
      final utf8Stream =
          response.data.stream.cast<List<int>>().transform(utf8.decoder);
      final lineStream = utf8Stream.transform(const LineSplitter());
      await for (final line in lineStream) {
        if (line.trim().isEmpty) continue;
        _logger.d('[Service] Received line: $line');
        try {
          // 若有 data: 前綴，去除
          final cleanLine =
              line.startsWith('data: ') ? line.substring(6) : line;
          final json = jsonDecode(cleanLine);
          final data = ChargeCanlogMonitor.fromJson(json);
          _logger.i('[Service] Parsed data: \\${data.toString()}');
          yield data;
        } catch (e) {
          _logger.e('[Service] JSON parse error: $e, line: $line');
        }
      }
      _logger.i('[Service] Stream finished');
    } catch (e) {
      _logger.e('[Service] API error: $e');
      rethrow;
    }
  }
}
