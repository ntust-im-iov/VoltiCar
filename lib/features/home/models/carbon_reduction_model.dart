class CarbonReductionModel {
  double totalCarbonReductionKg;

  CarbonReductionModel({required this.totalCarbonReductionKg});

  factory CarbonReductionModel.fromJson(Map<String, dynamic> json) {
    final raw = json['total_carbon_reduction_kg'];
    double value;
    if (raw is num) {
      value = raw.toDouble();
    } else if (raw is String) {
      value = double.tryParse(raw) ?? 0.0;
    } else {
      value = 0.0;
    }

    return CarbonReductionModel(
      totalCarbonReductionKg: value,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_carbon_reduction_kg': totalCarbonReductionKg,
    };
  }
}
