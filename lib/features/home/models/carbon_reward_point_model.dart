class CarbonRewardPoint {
  final int carbonRewardPoints;

  CarbonRewardPoint({required this.carbonRewardPoints});

  factory CarbonRewardPoint.fromJson(Map<String, dynamic> json) {
    return CarbonRewardPoint(
      carbonRewardPoints: json['carbon_reward_points'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carbon_reward_points': carbonRewardPoints,
    };
  }
}
