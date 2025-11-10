class CarbonReduction {
  final double totalCarbonReductionKg;

  CarbonReduction({required this.totalCarbonReductionKg});

  factory CarbonReduction.fromJson(Map<String, dynamic> json) {
    return CarbonReduction(
      totalCarbonReductionKg:
          (json['total_carbon_reduction_kg'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_carbon_reduction_kg': totalCarbonReductionKg,
    };
  }
}
