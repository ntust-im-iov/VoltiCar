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

  // Getter for human-readable type
  String get typeDescription {
    switch (type) {
      case 1:
        return 'J1772 (Type 1)';
      case 2:
        return 'Mennekes (Type 2)';
      case 3:
        return 'CHAdeMO';
      case 4:
        return 'CCS1 (Combo 1)';
      case 5:
        return 'CCS2 (Combo 2)';
      case 6:
        return 'TPC (Tesla)';
      default:
        return '未知類型 ($type)';
    }
  }

  // Getter for human-readable power
  String get powerDescription {
    // 假設 power 直接是 kW 值，如果不是，需要調整此邏輯
    // 例如，如果 power 是功率等級的代碼，則需要類似 typeDescription 的 switch
    if (power > 0) {
      return '$power kW';
    }
    // 根據 API 文件，Power: 1 (慢充), 2 (快充), 3 (超充)
    // 但使用者提供的 JSON 是 "Power": 1，而描述是 "充電樁2支"，這似乎不直接對應 kW
    // 我將暫時保留 switch，如果 API 的 Power 值是枚舉而不是直接的 kW
    switch (power) {
      case 1:
        return '慢充'; // 假設 1 代表慢充
      case 2:
        return '快充'; // 假設 2 代表快充
      case 3:
        return '超充'; // 假設 3 代表超充
      default:
        return '未知功率 ($power)';
    }
    // 如果 API 的 power 欄位確實是 kW，則應改為:
    // return '$power kW';
  }
}
