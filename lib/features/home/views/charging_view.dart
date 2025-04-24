import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:volticar_app/core/constants/app_colors.dart';

class ChargingView extends StatefulWidget {
  const ChargingView({super.key});

  @override
  State<ChargingView> createState() => _ChargingViewState();
}

class _ChargingViewState extends State<ChargingView> {
  final _logger = Logger();

  // 充電狀態變量
  double _batteryLevel = 0.45; // 初始電池電量
  bool _isCharging = false; // 充電狀態
  int _chargingSpeed = 0; // 充電速度 (kW)
  int _estimatedTimeRemaining = 0; // 剩餘充電時間 (分鐘)

  @override
  void initState() {
    super.initState();
    _logger.i('ChargingView initialized');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '充電站',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2A1E47),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: const Color(0xFF2A1E47),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 充電站信息卡
                _buildChargingStationCard(),

                const SizedBox(height: 24),

                // 電池顯示
                _buildBatteryDisplay(),

                const SizedBox(height: 24),

                // 充電控制
                _buildChargingControls(),

                const SizedBox(height: 24),

                // 充電詳細信息
                _buildChargingDetails(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChargingStationCard() {
    return Card(
      color: const Color(0xFF3A2D5B),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF63588A), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.ev_station,
                  color: Color(0xFFFF6B6B),
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Text(
                  'VoltiCar私人充電站',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('充電功率', style: TextStyle(color: Colors.white70)),
                Text('最高150 kW', style: TextStyle(color: Colors.white)),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('充電接口', style: TextStyle(color: Colors.white70)),
                Text('Type 2 / CCS', style: TextStyle(color: Colors.white)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('狀態', style: TextStyle(color: Colors.white70)),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _isCharging
                            ? const Color(0xFF4CAF50).withOpacity(0.2)
                            : const Color(0xFFFF6B6B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color:
                          _isCharging
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFF6B6B),
                    ),
                  ),
                  child: Text(
                    _isCharging ? '充電中' : '待機中',
                    style: TextStyle(
                      color:
                          _isCharging
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFF6B6B),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryDisplay() {
    return Card(
      color: const Color(0xFF3A2D5B),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF63588A), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 電池電量百分比
            Text(
              '${(_batteryLevel * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // 電池圖示
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: _batteryLevelColor(), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width:
                        MediaQuery.of(context).size.width * 0.8 * _batteryLevel,
                    decoration: BoxDecoration(
                      color: _batteryLevelColor(),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        bottomLeft: Radius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (_isCharging) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt, color: Color(0xFFFFD166)),
                  const SizedBox(width: 4),
                  Text(
                    '充電速度: $_chargingSpeed kW',
                    style: const TextStyle(color: Color(0xFFFFD166)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '預計剩餘時間: $_estimatedTimeRemaining 分鐘',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChargingControls() {
    return Card(
      color: const Color(0xFF3A2D5B),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF63588A), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 充電按鈕
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isCharging = !_isCharging;
                  _chargingSpeed = _isCharging ? 50 : 0;
                  _estimatedTimeRemaining =
                      _isCharging
                          ? (((1.0 - _batteryLevel) * 100 * 60) /
                                  _chargingSpeed)
                              .round()
                          : 0;

                  // 如果開始充電，模擬充電過程
                  if (_isCharging) {
                    Future.delayed(const Duration(seconds: 1), () {
                      _simulateCharging();
                    });
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isCharging
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                _isCharging ? '停止充電' : '開始充電',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 充電速度選擇器（只在未充電時可調整）
            if (!_isCharging) ...[
              const Text(
                '選擇充電功率',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildChargingRateButton(50, '標準'),
                  _buildChargingRateButton(75, '快速'),
                  _buildChargingRateButton(120, '超快'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChargingRateButton(int rate, String label) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _chargingSpeed = rate;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _chargingSpeed == rate
                ? const Color(0xFF63588A)
                : const Color(0xFF2A1E47),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color:
                _chargingSpeed == rate
                    ? const Color(0xFFFFD166)
                    : const Color(0xFF63588A),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            '$rate kW',
            style: TextStyle(
              fontWeight:
                  _chargingSpeed == rate ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color:
                  _chargingSpeed == rate
                      ? const Color(0xFFFFD166)
                      : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargingDetails() {
    return Card(
      color: const Color(0xFF3A2D5B),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF63588A), width: 2),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '充電統計',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('本次充電', style: TextStyle(color: Colors.white70)),
                Text('0.0 kWh', style: TextStyle(color: Colors.white)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('本月充電', style: TextStyle(color: Colors.white70)),
                Text('120.5 kWh', style: TextStyle(color: Colors.white)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('總充電次數', style: TextStyle(color: Colors.white70)),
                Text('42 次', style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 根據電池電量返回顏色
  Color _batteryLevelColor() {
    if (_batteryLevel < 0.2) {
      return const Color(0xFFFF6B6B); // 紅色
    } else if (_batteryLevel < 0.5) {
      return const Color(0xFFFFD166); // 黃色
    } else {
      return const Color(0xFF4CAF50); // 綠色
    }
  }

  // 模擬充電過程
  void _simulateCharging() {
    if (_isCharging && _batteryLevel < 1.0) {
      setState(() {
        // 每秒增加電量
        _batteryLevel += (_chargingSpeed / 10000);
        if (_batteryLevel > 1.0) _batteryLevel = 1.0;

        // 更新剩餘時間
        _estimatedTimeRemaining =
            (((1.0 - _batteryLevel) * 100 * 60) / _chargingSpeed).round();

        // 如果電池已滿，停止充電
        if (_batteryLevel >= 1.0) {
          _isCharging = false;
          _chargingSpeed = 0;
          _estimatedTimeRemaining = 0;
        } else {
          // 否則繼續模擬
          Future.delayed(const Duration(seconds: 1), () {
            _simulateCharging();
          });
        }
      });
    }
  }
}
