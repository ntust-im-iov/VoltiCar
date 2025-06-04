import 'connector_model.dart';

class ChargingStation {
  final String stationID;
  final String stationName;
  final double latitude;
  final double longitude;
  final int chargingPoints;
  final List<Connector> connectors;
  final String parkingRate;
  final String chargingRate;
  final String serviceTime;
  // 詳細資訊中的可選欄位
  final String? description; // 來自 /stations/id/{station_id}
  final String? fullAddress; // 組合後的完整地址，來自 /stations/id/{station_id}
  final List<String>? photoURLs; // 來自 /stations/id/{station_id}
  final String? telephone; // 來自 /stations/id/{station_id}

  ChargingStation({
    required this.stationID,
    required this.stationName,
    required this.latitude,
    required this.longitude,
    required this.chargingPoints,
    required this.connectors,
    required this.parkingRate,
    required this.chargingRate,
    required this.serviceTime,
    this.description,
    this.fullAddress,
    this.photoURLs,
    this.telephone,
  });

  factory ChargingStation.fromOverviewJson(Map<String, dynamic> json) {
    var connectorsJson = json['Connectors'] as List<dynamic>? ?? [];
    List<Connector> connectorsList = connectorsJson
        .map((cJson) => Connector.fromJson(cJson as Map<String, dynamic>))
        .toList();

    String name = '';
    if (json['StationName'] is String) {
      name = json['StationName'] as String;
    } else if (json['StationName'] is Map) {
      // 假設 StationName 在 overview API 中也可能是 {"Zh_tw": "Name"} 的形式
      name = (json['StationName'] as Map<String, dynamic>)['Zh_tw'] as String? ?? '未知站點';
    } else {
      name = '未知站點';
    }

    return ChargingStation(
      stationID: json['StationID'] as String,
      stationName: name,
      latitude: (json['PositionLat'] as num).toDouble(),
      longitude: (json['PositionLon'] as num).toDouble(),
      chargingPoints: json['ChargingPoints'] as int? ?? 0,
      connectors: connectorsList,
      parkingRate: json['ParkingRate'] as String? ?? '未知',
      chargingRate: json['ChargingRate'] as String? ?? '未知',
      serviceTime: json['ServiceTime'] as String? ?? '未知',
    );
  }

  // 可以選擇性地添加一個從詳細 JSON 轉換的工廠構造函數或更新方法
  // factory ChargingStation.fromDetailJson(Map<String, dynamic> json) { ... }
}
