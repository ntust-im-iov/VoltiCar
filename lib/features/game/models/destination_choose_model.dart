class DestinationChooseModel {
  final String destinationId;
  final String name;
  final String region;
  final String? message;

  DestinationChooseModel({
    required this.destinationId,
    required this.name,
    required this.region,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'destination_id': destinationId,
    };
  }

  factory DestinationChooseModel.fromJson(Map<String, dynamic> json) {
    // 檢查是否有 selected_destination 欄位
    if (json.containsKey('selected_destination')) {
      final selectedDestination =
          json['selected_destination'] as Map<String, dynamic>;
      return DestinationChooseModel(
        destinationId: selectedDestination['destination_id'] as String? ?? '',
        name: selectedDestination['name'] as String? ?? '',
        region: selectedDestination['region'] as String? ?? '',
        message: json['message'] as String?,
      );
    } else {
      // 向後兼容舊格式
      return DestinationChooseModel(
        destinationId: json['destination_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        region: json['region'] as String? ?? '',
        message: json['message'] as String?,
      );
    }
  }
}
