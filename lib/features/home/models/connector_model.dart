class Connector {
  final int type;
  final int power;
  final int quantity;
  final String? description;

  Connector({
    required this.type,
    required this.power,
    required this.quantity,
    this.description,
  });

  factory Connector.fromJson(Map<String, dynamic> json) {
    return Connector(
      type: json['Type'] as int,
      power: json['Power'] as int,
      quantity: json['Quantity'] as int,
      description: json['Description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Type': type,
      'Power': power,
      'Quantity': quantity,
      'Description': description,
    };
  }

  // 根據用戶提供的對照表獲取充電接口類型描述
  String get typeDescription {
    switch (type) {
      case 1:
        return 'CCS1';
      case 2:
        return 'CCS2';
      case 3:
        return 'CHAdeMO';
      case 4:
        return 'Tesla TPC';
      case 5:
        return 'J1772(Type1)';
      case 6:
        return 'Mennekes(Type2)';
      case 254:
        return 'Others';
      case 255:
        return 'Unknown';
      default:
        return '未知類型 ($type)';
    }
  }

  // 根據用戶提供的對照表獲取功率類型描述
  String get powerDescription {
    switch (power) {
      case 1:
        return 'AC';
      case 2:
        return 'DC';
      default:
        return '未知功率 ($power)';
    }
  }
}
