import 'package:volticar_app/features/game/models/player_data_model.dart';
import 'package:volticar_app/features/game/services/player_data_display_service.dart';

class PlayerDataRepository {
  static final PlayerDataRepository _instance =
      PlayerDataRepository._internal();
  final PlayerDataDisplayService _service = PlayerDataDisplayService();

  factory PlayerDataRepository() {
    return _instance;
  }

  PlayerDataRepository._internal();

  /// 取得玩家資料
  Future<PlayerData> fetchPlayerData() async {
    return await _service.getPlayerData();
  }
}
