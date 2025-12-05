class CarbonRewardPointModel {
  int carbonRewardPoints;

  CarbonRewardPointModel({required this.carbonRewardPoints});

  factory CarbonRewardPointModel.fromJson(Map<String, dynamic> json) {
    final raw = json['carbon_reward_points'];
    int value;
    if (raw is int) {
      value = raw;
    } else if (raw is double) {
      value = raw.toInt();
    } else if (raw is String) {
      // Try parsing as int first, then as double and convert to int.
      value = int.tryParse(raw) ?? (double.tryParse(raw)?.toInt() ?? 0);
    } else {
      value = 0;
    }

    return CarbonRewardPointModel(carbonRewardPoints: value);
  }

  Map<String, dynamic> toJson() {
    return {
      'carbon_reward_points': carbonRewardPoints,
    };
  }
}
