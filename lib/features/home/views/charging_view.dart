import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../viewmodels/carbon_reduction_viewmodel.dart';
import '../viewmodels/carbon_reward_point_viewmodel.dart';
import '../viewmodels/charge_canlog_monitor_viewmodel.dart';
// 已移除未使用的 import

class ChargingView extends StatefulWidget {
  const ChargingView({super.key});

  @override
  State<ChargingView> createState() => _ChargingViewState();
}

class _ChargingViewState extends State<ChargingView> {
  final _logger = Logger();
  ChargeCanlogMonitorViewModel? _canlogMonitorVM;
  // 參數控制
  String _chargeMode = "TYPE1"; // 預設 TYPE1
  bool _skipIdle = false;
  int _duration = 2000;
  bool _isCharging = false;
  late VoidCallback _vmListener;

  // 啟動模擬充電（按下按鈕才啟動流式監聽）
  void _startSimulation() {
    setState(() {
      _isCharging = true;
    });
    final vm = context.read<ChargeCanlogMonitorViewModel>();
    _logger.i(
        '[startSimulation] mode=$_chargeMode, skipIdle=$_skipIdle, duration=$_duration');
    try {
      vm.startListening(
        log: _chargeMode == 'TYPE1' ? 'supercharge' : 'supercharge_end',
        skipIdle: _skipIdle,
        duration: _duration,
      );
      _logger.i('[startSimulation] Called vm.startListening');
    } catch (e) {
      _logger.e('API error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API 取得資料失敗: $e')),
      );
      setState(() {
        _isCharging = false;
      });
    }
  }

  /// 充電結束時呼叫，依據最後一筆流式資料進行減碳量與點數 API 流程
  Future<void> handleChargingFinishAndCarbon() async {
    final canlogVM = context.read<ChargeCanlogMonitorViewModel>();
    final crVM = context.read<CarbonReductionViewModel>();
    final crpVM = context.read<CarbonRewardPointViewModel>();

    final lastData = canlogVM.lastData;
    _logger.i('[handleChargingFinishAndCarbon] lastData: '
        '${lastData != null ? lastData.toString() : 'null'}');
    if (lastData == null) {
      _logger.w('[handleChargingFinishAndCarbon] lastData is null, abort.');
      return;
    }

    final double totalKwh = lastData.totalKwhCharged ?? 0.0;
    final double oldReduction =
        crVM.carbonReduction?.totalCarbonReductionKg ?? 0.0;
    _logger.i(
        '[handleChargingFinishAndCarbon] totalKwh=$totalKwh, oldReduction=$oldReduction');

    _logger.i(
        '[handleChargingFinishAndCarbon] call saveCarbonReduction($totalKwh)');
    await crVM.saveCarbonReduction(totalKwh);
    _logger.i(
        '[handleChargingFinishAndCarbon] saveCarbonReduction done, new carbonReduction=${crVM.carbonReduction?.totalCarbonReductionKg}');

    final double updatedReduction =
        crVM.carbonReduction?.totalCarbonReductionKg ?? oldReduction;
    _logger.i(
        '[handleChargingFinishAndCarbon] updatedReduction=$updatedReduction');

    final double carbonKg = updatedReduction - oldReduction;
    _logger.i('[handleChargingFinishAndCarbon] carbonKg=$carbonKg');
    if (carbonKg > 0) {
      _logger.i(
          '[handleChargingFinishAndCarbon] call saveCarbonRewardPoint($carbonKg)');
      await crpVM.saveCarbonRewardPoint(carbonKg);
      _logger.i('[handleChargingFinishAndCarbon] saveCarbonRewardPoint done');
    } else {
      _logger.i(
          '[handleChargingFinishAndCarbon] carbonKg <= 0, skip saveCarbonRewardPoint');
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _logger.i('ChargingView initialized');
    // 設定監聽 ViewModel 狀態
    _vmListener = () async {
      final vm = context.read<ChargeCanlogMonitorViewModel>();
      if (_isCharging && vm.isFinished) {
        setState(() {
          _isCharging = false;
        });
        _logger.i(
            '[vmListener] isFinished, trigger handleChargingFinishAndCarbon');
        await handleChargingFinishAndCarbon();
      }
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 只註冊一次監聽器
    final vm =
        Provider.of<ChargeCanlogMonitorViewModel>(context, listen: false);
    if (_canlogMonitorVM != vm) {
      _canlogMonitorVM?.removeListener(_vmListener);
      _canlogMonitorVM = vm;
      _canlogMonitorVM?.addListener(_vmListener);
    }
  }

  @override
  void dispose() {
    // 只移除 State 儲存的 ViewModel 監聽
    _canlogMonitorVM?.removeListener(_vmListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A1E47),
      appBar: AppBar(
        title: const Text(
          '充電模擬',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2A1E47),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildChargingStationCard(),
              const SizedBox(height: 20),
              _buildModeSelector(),
              const SizedBox(height: 20),
              _buildSkipIdleSwitch(),
              const SizedBox(height: 12),
              _buildDurationSlider(),
              const SizedBox(height: 20),
              _buildSimulateButton(),
              const SizedBox(height: 20),
              _buildDataStreamRow(),
              const SizedBox(height: 20),
              _buildChargingStats(),
            ],
          ),
        ),
      ),
    );
  }

  // 跳過 idle 資料的開關
  Widget _buildSkipIdleSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Switch(
          value: _skipIdle,
          onChanged: (val) {
            setState(() {
              _skipIdle = val;
            });
            _logger.i('skipIdle 切換: $_skipIdle');
          },
        ),
        const Text('跳過 idle 資料', style: TextStyle(color: Colors.white)),
      ],
    );
  }

  // duration 參數滑桿
  Widget _buildDurationSlider() {
    return Row(
      children: [
        const Text('模擬時長(ms): ', style: TextStyle(color: Colors.white)),
        Expanded(
          child: Slider(
            value: _duration.toDouble(),
            min: 500,
            max: 5000,
            divisions: 19,
            label: _duration.toString(),
            onChanged: (val) {
              setState(() {
                _duration = val.round();
              });
              _logger.i('duration 調整: $_duration');
            },
          ),
        ),
        SizedBox(
          width: 60,
          child:
              Text('$_duration', style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildModeSelector() {
    final modes = ['TYPE1', 'TYPE2'];
    return Card(
      color: const Color(0xFF3A2D5B),
      elevation: 8,
      shadowColor: const Color(0xFF63588A).withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF63588A), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: modes.map((mode) {
            final isSelected = _chargeMode == mode;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _chargeMode = mode;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? const Color(0xFFFFD166)
                      : const Color(0xFF2A1E47),
                  foregroundColor:
                      isSelected ? const Color(0xFF3A2D5B) : Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFFFFD166)
                          : const Color(0xFF63588A),
                      width: 2,
                    ),
                  ),
                  elevation: isSelected ? 8 : 2,
                ),
                child: Text('超充$mode',
                    style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 18)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSimulateButton() {
    return Card(
      color: const Color(0xFF3A2D5B),
      elevation: 8,
      shadowColor: const Color(0xFF63588A).withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF63588A), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: ElevatedButton.icon(
            icon: Icon(_isCharging ? Icons.bolt : Icons.play_arrow,
                size: 28, color: Colors.white),
            onPressed: _startSimulation,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isCharging
                  ? const Color(0xFF63588A)
                  : const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: const Size(double.infinity, 60),
              elevation: _isCharging ? 2 : 8,
            ),
            label: Text(
              _isCharging ? '充電中...' : '開始充電模擬',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataStreamRow() {
    return Consumer<ChargeCanlogMonitorViewModel>(
      builder: (context, vm, _) {
        final data = vm.latestData;
        final isLoading = vm.isLoading;
        final isFinished = vm.isFinished;
        _logger.i(
            'DataStreamRow: isLoading=$isLoading, isFinished=$isFinished, data=${data != null ? data.toString() : 'null'}');
        return Card(
          color: const Color(0xFF3A2D5B),
          elevation: 8,
          shadowColor: const Color(0xFF63588A).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF63588A), width: 2),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
            child: isLoading && data == null
                ? const Center(child: CircularProgressIndicator())
                : data == null
                    ? const Text('尚無資料',
                        style: TextStyle(color: Colors.white70))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                                begin: 0, end: (data.socUiPercent ?? 0.0)),
                            duration: const Duration(milliseconds: 800),
                            builder: (context, value, child) => Text(
                              '電池電量：${value.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bolt,
                                  color: Color(0xFFFFD166), size: 28),
                              const SizedBox(width: 8),
                              Text(
                                  '充電速度：${data.instantAcPowerKw?.toStringAsFixed(1) ?? '--'} kW',
                                  style: const TextStyle(
                                      color: Color(0xFFFFD166),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                              '預計剩餘時間：${data.energyToChargeCompleteKwh?.toStringAsFixed(1) ?? '--'} 分鐘',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 18)),
                          const SizedBox(height: 14),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Text(
                              '狀態：${data.status ?? '--'}',
                              key: ValueKey(data.status),
                              style: TextStyle(
                                color: (data.status == '充電中' ||
                                        data.status == 'charging')
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFFF6B6B),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isFinished)
                            const Padding(
                              padding: EdgeInsets.only(top: 16.0),
                              child: Text('充電已結束',
                                  style: TextStyle(
                                      color: Colors.amber, fontSize: 18)),
                            ),
                        ],
                      ),
          ),
        );
      },
    );
  }

  Widget _buildChargingStats() {
    return Consumer2<CarbonReductionViewModel, CarbonRewardPointViewModel>(
      builder: (context, crVM, crpVM, _) {
        final reduction = crVM.carbonReduction?.totalCarbonReductionKg ?? 0.0;
        final points = crpVM.carbonRewardPoint?.carbonRewardPoints ?? 0;
        // points 以 int 顯示
        final isLoading = crVM.isLoading || crpVM.isLoading;
        _logger.i(
            '[buildChargingStats] reduction=$reduction, points=$points, isLoading=$isLoading');
        return Card(
          color: const Color(0xFF3A2D5B),
          elevation: 14,
          shadowColor: const Color(0xFF63588A).withOpacity(0.18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: Color(0xFF63588A), width: 2),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '充電統計',
                  style: TextStyle(
                    color: Color(0xFFFFD166),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('本次充電',
                        style: TextStyle(color: Colors.white70, fontSize: 16)),
                    Text('0.0 kWh',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                // 減碳量
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('減碳量',
                        style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    isLoading
                        ? const SizedBox(
                            width: 32,
                            height: 20,
                            child: Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Color(0xFF4CAF50))),
                          )
                        : Text('${reduction.toStringAsFixed(2)} kg',
                            style: const TextStyle(
                                color: Color(0xFF4CAF50),
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                // 減碳點數
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('減碳點數',
                        style: TextStyle(
                            color: Color(0xFF00B8D9),
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    isLoading
                        ? const SizedBox(
                            width: 32,
                            height: 20,
                            child: Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Color(0xFF00B8D9))),
                          )
                        : Text('${points.toString()}',
                            style: const TextStyle(
                                color: Color(0xFF00B8D9),
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChargingStationCard() {
    return Card(
      color: const Color(0xFF3A2D5B),
      elevation: 10,
      shadowColor: const Color(0xFF63588A).withOpacity(0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFF63588A), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.ev_station,
                  color: Color(0xFFFF6B6B),
                  size: 36,
                ),
                const SizedBox(width: 16),
                const Text(
                  'VoltiCar 模擬充電站',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('充電功率',
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                Text('最高 150 kW',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('充電接口',
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                Text('Type 2 / CCS',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('狀態',
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isCharging
                        ? const Color(0xFF4CAF50).withOpacity(0.18)
                        : const Color(0xFFFF6B6B).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isCharging
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF6B6B),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    _isCharging ? '充電中' : '待機中',
                    style: TextStyle(
                      color: _isCharging
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF6B6B),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
}
