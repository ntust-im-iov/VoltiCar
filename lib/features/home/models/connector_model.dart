import 'package:logger/logger.dart';

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
    final Logger logger = Logger();
    // 移除詳細的解析日誌
    
    // 嘗試多種可能的字段名稱格式
    int? type;
    int? power;
    int? quantity;
    String? description;
    
    // 解析 Type 字段
    if (json.containsKey('Type')) {
      type = json['Type'] as int?;
    } else if (json.containsKey('type')) {
      type = json['type'] as int?;
    } else if (json.containsKey('ConnectorType')) {
      type = json['ConnectorType'] as int?;
    } else if (json.containsKey('connector_type')) {
      type = json['connector_type'] as int?;
    }
    
    // 解析 Power 字段
    if (json.containsKey('Power')) {
      power = json['Power'] as int?;
    } else if (json.containsKey('power')) {
      power = json['power'] as int?;
    } else if (json.containsKey('PowerType')) {
      power = json['PowerType'] as int?;
    } else if (json.containsKey('power_type')) {
      power = json['power_type'] as int?;
    }
    
    // 解析 Quantity 字段
    if (json.containsKey('Quantity')) {
      quantity = json['Quantity'] as int?;
    } else if (json.containsKey('quantity')) {
      quantity = json['quantity'] as int?;
    } else if (json.containsKey('Count')) {
      quantity = json['Count'] as int?;
    } else if (json.containsKey('count')) {
      quantity = json['count'] as int?;
    }
    
    // 解析 Description 字段
    if (json.containsKey('Description')) {
      description = json['Description'] as String?;
    } else if (json.containsKey('description')) {
      description = json['description'] as String?;
    }
    
    // 如果找不到必要字段，嘗試從其他可能的結構中提取
    if (type == null || power == null || quantity == null) {
      // 移除詳細的字段檢查日誌
      
      // 如果數據結構不同，可能需要根據實際 API 響應調整
      // 例如，某些 API 可能返回字符串而不是整數
      if (type == null && json.containsKey('Type') && json['Type'] is String) {
        try {
          type = int.parse(json['Type'] as String);
        } catch (e) {
          // 解析失敗，使用默認值
        }
      }
      
      if (power == null && json.containsKey('Power') && json['Power'] is String) {
        try {
          power = int.parse(json['Power'] as String);
        } catch (e) {
          // 解析失敗，使用默認值
        }
      }
      
      if (quantity == null && json.containsKey('Quantity') && json['Quantity'] is String) {
        try {
          quantity = int.parse(json['Quantity'] as String);
        } catch (e) {
          // 解析失敗，使用默認值
        }
      }
    }
    
    // 設置默認值
    type ??= 255; // Unknown
    power ??= 2; // DC
    quantity ??= 1;
    
    // 移除解析結果日誌
    
    return Connector(
      type: type,
      power: power,
      quantity: quantity,
      description: description,
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

  // 根據實際充電站數據修正的充電接口類型描述
  String get typeDescription {
    final Logger logger = Logger();
    String result;
    
    switch (type) {
      case 1:
        result = 'CCS1';  // 根據標準應該是 CCS1
        break;
      case 2:
        result = 'CCS2';  // 根據標準應該是 CCS2
        break;
      case 3:
        result = 'CHAdeMO';
        break;
      case 4:
        result = 'Tesla TPC';
        break;
      case 5:
        result = 'J1772(Type1)';
        break;
      case 6:
        result = 'Mennekes(Type2)';
        break;
      case 254:
        result = 'Others';
        break;
      case 255:
        result = 'Unknown';
        break;
      default:
        result = '未知類型 ($type)';
        break;
    }
    
    // 移除類型轉換日誌
    return result;
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
