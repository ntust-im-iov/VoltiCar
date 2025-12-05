class ChargeCanlogMonitor {
  // 共用欄位
  final String? status;
  final double? instantAcPowerKw;
  final double? socUiPercent;
  final double? socMinPercent;
  final double? socMaxPercent;
  final double? initialKwh;
  final double? currentKwh;
  final double? energyToChargeCompleteKwh;
  final int? messagesProcessed;

  // 結束資料專屬欄位
  final String? logFile;
  final double? finalKwh;
  final double? totalKwhCharged;
  final double? initialSocPercent;
  final double? finalSocUiPercent;
  final double? finalSocMinPercent;
  final double? finalSocMaxPercent;
  final double? batteryBalancePercent;
  final double? carbonReductionKg;
  final double? rewardPoints;
  final int? totalMessages;
  final double? durationLimitSeconds;
  final bool? durationExceeded;
  final double? actualDurationSeconds;

  ChargeCanlogMonitor({
    this.status,
    this.instantAcPowerKw,
    this.socUiPercent,
    this.socMinPercent,
    this.socMaxPercent,
    this.initialKwh,
    this.currentKwh,
    this.energyToChargeCompleteKwh,
    this.messagesProcessed,
    this.logFile,
    this.finalKwh,
    this.totalKwhCharged,
    this.initialSocPercent,
    this.finalSocUiPercent,
    this.finalSocMinPercent,
    this.finalSocMaxPercent,
    this.batteryBalancePercent,
    this.carbonReductionKg,
    this.rewardPoints,
    this.totalMessages,
    this.durationLimitSeconds,
    this.durationExceeded,
    this.actualDurationSeconds,
  });

  factory ChargeCanlogMonitor.fromJson(Map<String, dynamic> json) {
    return ChargeCanlogMonitor(
      status: json['status'] as String?,
      instantAcPowerKw: (json['instant_ac_power_kw'] as num?)?.toDouble(),
      socUiPercent: (json['soc_ui_percent'] as num?)?.toDouble(),
      socMinPercent: (json['soc_min_percent'] as num?)?.toDouble(),
      socMaxPercent: (json['soc_max_percent'] as num?)?.toDouble(),
      initialKwh: (json['initial_kwh'] as num?)?.toDouble(),
      currentKwh: (json['current_kwh'] as num?)?.toDouble(),
      energyToChargeCompleteKwh:
          (json['energy_to_charge_complete_kwh'] as num?)?.toDouble(),
      messagesProcessed: json['messages_processed'] as int?,
      logFile: json['log_file'] as String?,
      finalKwh: (json['final_kwh'] as num?)?.toDouble(),
      totalKwhCharged: (json['total_kwh_charged'] as num?)?.toDouble(),
      initialSocPercent: (json['initial_soc_percent'] as num?)?.toDouble(),
      finalSocUiPercent: (json['final_soc_ui_percent'] as num?)?.toDouble(),
      finalSocMinPercent: (json['final_soc_min_percent'] as num?)?.toDouble(),
      finalSocMaxPercent: (json['final_soc_max_percent'] as num?)?.toDouble(),
      batteryBalancePercent:
          (json['battery_balance_percent'] as num?)?.toDouble(),
      carbonReductionKg: (json['carbon_reduction_kg'] as num?)?.toDouble(),
      rewardPoints: (json['reward_points'] as num?)?.toDouble(),
      totalMessages: json['total_messages'] as int?,
      durationLimitSeconds:
          (json['duration_limit_seconds'] as num?)?.toDouble(),
      durationExceeded: json['duration_exceeded'] as bool?,
      actualDurationSeconds:
          (json['actual_duration_seconds'] as num?)?.toDouble(),
    );
  }

  bool get isFinished => status == 'finished';

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'instant_ac_power_kw': instantAcPowerKw,
      'soc_ui_percent': socUiPercent,
      'soc_min_percent': socMinPercent,
      'soc_max_percent': socMaxPercent,
      'initial_kwh': initialKwh,
      'current_kwh': currentKwh,
      'energy_to_charge_complete_kwh': energyToChargeCompleteKwh,
      'messages_processed': messagesProcessed,
      'log_file': logFile,
      'final_kwh': finalKwh,
      'total_kwh_charged': totalKwhCharged,
      'initial_soc_percent': initialSocPercent,
      'final_soc_ui_percent': finalSocUiPercent,
      'final_soc_min_percent': finalSocMinPercent,
      'final_soc_max_percent': finalSocMaxPercent,
      'battery_balance_percent': batteryBalancePercent,
      'carbon_reduction_kg': carbonReductionKg,
      'reward_points': rewardPoints,
      'total_messages': totalMessages,
      'duration_limit_seconds': durationLimitSeconds,
      'duration_exceeded': durationExceeded,
      'actual_duration_seconds': actualDurationSeconds,
    };
  }
}
