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
  final String? city; // 新增：城市名稱

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
    this.city,
  });

  factory ChargingStation.fromOverviewJson(Map<String, dynamic> json) {
    var connectorsJson = json['Connectors'] as List<dynamic>? ?? [];
    connectorsJson
        .map((cJson) => Connector.fromJson(cJson as Map<String, dynamic>))
        .toList();

    String name = '';
    if (json['StationName'] is String) {
      name = json['StationName'] as String;
    } else if (json['StationName'] is Map) {
      // 假設 StationName 在 overview API 中也可能是 {"Zh_tw": "Name"} 的形式
      name =
          (json['StationName'] as Map<String, dynamic>)['Zh_tw'] as String? ??
              '未知站點';
    } else {
      name = '未知站點';
    }

    // 嘗試從 overview JSON 中提取城市資訊
    // 假設 overview API 的 JSON 中可能直接有 City 欄位，或者在某個嵌套結構中
    // 這裡需要根據實際 overview API 的回傳格式來調整
    // 以下為一個假設性的提取，如果 overview API 的 StationName 旁邊有 Address 或 Location -> Address -> City
    String? overviewCity;
    if (json['Location'] is Map &&
        (json['Location'] as Map)['Address'] is Map) {
      final addressMap =
          (json['Location'] as Map)['Address'] as Map<String, dynamic>;
      overviewCity = addressMap['City'] as String?;
    } else if (json['City'] is String) {
      // 或者直接有 City 欄位
      overviewCity = json['City'] as String;
    }
    // 如果 overview API 的 StationName 是一個 Map，且裡面有城市資訊，也需要處理
    // 例如: json['StationName']['City']，但這不常見
    // API 更新：overview 現在也提供地址資訊。 StationID, StationName, PositionLat, PositionLon, 和地址。

    // String? overviewCity; // 移除此處的重複定義，使用上面已定義的 overviewCity
    String? overviewFullAddress;

    if (json['Location'] is Map &&
        (json['Location'] as Map)['Address'] is Map) {
      final addressMap =
          (json['Location'] as Map)['Address'] as Map<String, dynamic>;
      overviewCity = addressMap['City'] as String?;
      final town = addressMap['Town'] as String? ?? '';
      final road = addressMap['Road'] as String? ?? '';
      final no = addressMap['No'] as String? ?? '';
      if (overviewCity != null && overviewCity.isNotEmpty) {
        overviewFullAddress = '$overviewCity$town$road$no'.trim();
        if (overviewFullAddress.isEmpty) overviewFullAddress = null;
      }
    } else if (json['Address'] is String &&
        (json['Address'] as String).isNotEmpty) {
      // 如果直接提供 Address 字串
      overviewFullAddress = json['Address'] as String;
      // 嘗試從 Address 字串中提取 City (這比較困難且不可靠，暫時不處理，除非有明確格式)
      // overviewCity = ... ;
    }

    return ChargingStation(
        stationID: json['StationID'] as String,
        stationName: name, // Name 仍然從 StationName 解析
        latitude: (json['PositionLat'] as num).toDouble(),
        longitude: (json['PositionLon'] as num).toDouble(),
        city: overviewCity, // 使用上面第一次定義並賦值的 overviewCity
        fullAddress: overviewFullAddress,
        // 根據 API 更新，以下欄位在 overview API 中不再提供，使用確定的預設值
        chargingPoints: 0,
        connectors: [], // connectorsList 在此 scope 未被賦值，應直接用空列表
        parkingRate: '未知',
        chargingRate: '未知',
        serviceTime: '未知',
        // description, photoURLs, telephone 這些本來就是 optional，在 overview 中應為 null
        description: null,
        photoURLs: null,
        telephone: null);
  }

  // 可以選擇性地添加一個從詳細 JSON 轉換的工廠構造函數或更新方法
  factory ChargingStation.fromDetailJson(Map<String, dynamic> json) {
    var connectorsJson = json['Connectors'] as List<dynamic>? ?? [];
    List<Connector> connectorsList = connectorsJson
        .map((cJson) => Connector.fromJson(cJson as Map<String, dynamic>))
        .toList();

    String name = '未知站點';
    if (json['StationName'] is String) {
      name = json['StationName'] as String;
    } else if (json['StationName'] is Map) {
      name =
          (json['StationName'] as Map<String, dynamic>)['Zh_tw'] as String? ??
              '未知站點';
    }

    String extractedCity = '未知城市';
    String fullAddressStr = '未知地址';
    if (json['Location'] is Map &&
        (json['Location'] as Map)['Address'] is Map) {
      final addressMap =
          (json['Location'] as Map)['Address'] as Map<String, dynamic>;
      extractedCity = addressMap['City'] as String? ?? '未知城市';
      final town = addressMap['Town'] as String? ?? ''; // 注意是 Town 不是 District
      final road = addressMap['Road'] as String? ?? '';
      final no = addressMap['No'] as String? ?? '';
      // 使用 extractedCity 而不是 city
      fullAddressStr = '$extractedCity$town$road$no'.trim().isNotEmpty
          ? '$extractedCity$town$road$no'.trim()
          : '未知地址';
    } else if (json['Address'] is String) {
      // 向下相容舊的 Address 欄位 (如果有的話)
      fullAddressStr = json['Address'] as String;
    }

    List<String>? photos;
    if (json['PhotoURLs'] is List) {
      // API 回傳的是 PhotoURLs (複數)
      photos = (json['PhotoURLs'] as List<dynamic>)
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList();
      if (photos.isEmpty) photos = null;
    } else if (json['PhotoURLs'] is String &&
        (json['PhotoURLs'] as String).isNotEmpty) {
      // 也處理單一 URL 的情況
      photos = [json['PhotoURLs'] as String];
    }

    return ChargingStation(
      stationID: json['StationID'] as String,
      stationName: name,
      city: extractedCity, // 新增
      latitude: (json['PositionLat'] as num).toDouble(),
      longitude: (json['PositionLon'] as num).toDouble(),
      chargingPoints: json['ChargingPoints'] as int? ?? 0,
      connectors: connectorsList,
      parkingRate: json['ParkingRate'] as String? ?? '未知',
      chargingRate: json['ChargingRate'] as String? ?? '未知',
      serviceTime: json['ServiceTime'] as String? ?? '未知',
      description: json['Description'] as String?,
      fullAddress: fullAddressStr,
      photoURLs: photos,
      telephone: json['Telephone'] as String?,
    );
  }
}
