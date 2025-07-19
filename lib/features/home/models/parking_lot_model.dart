import 'package:logger/logger.dart';

// 輔助類用於位置信息
class ParkingLocation {
  final double latitude;
  final double longitude;
  
  ParkingLocation(this.latitude, this.longitude);
}

class ParkingLot {
  final String parkingID;
  final String parkingName;
  final double latitude;
  final double longitude;
  final String? address;
  final String? description;
  final int? totalSpaces;
  final int? availableSpaces;
  final String? operatingHours;
  final String? parkingRate;
  final String? telephone;
  final List<String> photoURLs;

  ParkingLot({
    required this.parkingID,
    required this.parkingName,
    required this.latitude,
    required this.longitude,
    this.address,
    this.description,
    this.totalSpaces,
    this.availableSpaces,
    this.operatingHours,
    this.parkingRate,
    this.telephone,
    this.photoURLs = const [],
  });

  factory ParkingLot.fromOverviewJson(Map<String, dynamic> json) {
    final Logger logger = Logger();
    
    try {
      // 解析基本信息 - 使用實際的 API 字段名
      final String parkingID = json['CarParkID']?.toString() ?? '';
      final String parkingName = json['CarParkName']?.toString() ?? '未知停車場';
      
      // 解析位置信息 - 從 CarParkPosition 對象中提取
      double latitude = 0.0;
      double longitude = 0.0;
      
      if (json['CarParkPosition'] != null) {
        final position = json['CarParkPosition'] as Map<String, dynamic>;
        latitude = _parseDouble(position['PositionLat']) ?? 0.0;
        longitude = _parseDouble(position['PositionLon']) ?? 0.0;
      }
      
      // 解析其他信息 - 使用實際的 API 字段名
      final String? address = json['Address']?.toString();
      final String? description = json['FareDescription']?.toString(); // 使用費率描述作為描述
      final int? totalSpaces = _parseInt(json['TotalSpaces']);
      final int? availableSpaces = _parseInt(json['AvailableSpaces']);
      final String? operatingHours = json['OperatingHours']?.toString();
      final String? parkingRate = json['FareDescription']?.toString(); // 費率信息
      final String? telephone = json['Telephone']?.toString();
      
      // 解析照片URLs
      final List<String> photoURLs = [];
      if (json['PhotoURLs'] is List) {
        for (var url in json['PhotoURLs']) {
          if (url != null && url.toString().isNotEmpty) {
            photoURLs.add(url.toString());
          }
        }
      }

      return ParkingLot(
        parkingID: parkingID,
        parkingName: parkingName,
        latitude: latitude,
        longitude: longitude,
        address: address,
        description: description,
        totalSpaces: totalSpaces,
        availableSpaces: availableSpaces,
        operatingHours: operatingHours,
        parkingRate: parkingRate,
        telephone: telephone,
        photoURLs: photoURLs,
      );
    } catch (e) {
      logger.e('停車場數據解析失敗: $e');
      rethrow;
    }
  }

  factory ParkingLot.fromDetailJson(Map<String, dynamic> json) {
    // 詳細信息解析與overview相同，但可能包含更多字段
    return ParkingLot.fromOverviewJson(json);
  }

  // 添加 fromJson 方法以兼容服務層調用
  factory ParkingLot.fromJson(Map<String, dynamic> json) {
    return ParkingLot.fromOverviewJson(json);
  }

  // 添加 location getter 以兼容服務層調用
  ParkingLocation get location => ParkingLocation(latitude, longitude);

  // 輔助方法：提取名稱
  static String _extractName(dynamic nameData) {
    if (nameData is Map) {
      return nameData['Zh_tw']?.toString() ?? 
             nameData['zh_tw']?.toString() ?? 
             nameData['name']?.toString() ?? 
             '未知停車場';
    }
    return nameData?.toString() ?? '未知停車場';
  }

  // 輔助方法：解析雙精度浮點數
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  // 輔助方法：解析整數
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  // 轉換為JSON
  Map<String, dynamic> toJson() {
    return {
      'parkingID': parkingID,
      'parkingName': parkingName,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'description': description,
      'totalSpaces': totalSpaces,
      'availableSpaces': availableSpaces,
      'operatingHours': operatingHours,
      'parkingRate': parkingRate,
      'telephone': telephone,
      'photoURLs': photoURLs,
    };
  }

  @override
  String toString() {
    return 'ParkingLot(id: $parkingID, name: $parkingName, lat: $latitude, lon: $longitude)';
  }
}