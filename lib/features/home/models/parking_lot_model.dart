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
      
      // 解析位置信息 - 兼容多種可能的數據結構
      double latitude = 0.0;
      double longitude = 0.0;

      try {
        dynamic positionData;
        if (json['CarParkPosition'] != null && json['CarParkPosition'] is Map) {
          positionData = json['CarParkPosition'];
        } else if (json['Position'] != null && json['Position'] is Map) {
          positionData = json['Position'];
        } else {
          positionData = json; // 嘗試從頂層解析
        }

        latitude = _parseDouble(positionData['PositionLat']) ??
                   _parseDouble(positionData['lat']) ??
                   0.0;
        longitude = _parseDouble(positionData['PositionLon']) ??
                    _parseDouble(positionData['lon']) ??
                    0.0;
        
        if (latitude == 0.0 && longitude == 0.0) {
          logger.w('無法從數據中解析有效的經緯度: $json');
        }
      } catch (e) {
        logger.e('解析經緯度時出錯: $e, 數據: $json');
        latitude = 0.0;
        longitude = 0.0;
      }
      
      // 解析其他信息 - 使用實際的 API 字段名
      final String? address = _parseAddress(json['Address']);
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

  // 輔助方法：解析地址
  static String? _parseAddress(dynamic addressData) {
    if (addressData == null) return null;
    if (addressData is String) return addressData;
    if (addressData is Map) {
      final city = addressData['City'] ?? '';
      final town = addressData['Town'] ?? '';
      final road = addressData['Road'] ?? '';
      final no = addressData['No'] ?? '';
      
      final parts = [city, town, road, no];
      final fullAddress = parts.where((part) => part != null && part.toString().isNotEmpty).join('');
      
      return fullAddress.isNotEmpty ? fullAddress : null;
    }
    return addressData.toString();
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