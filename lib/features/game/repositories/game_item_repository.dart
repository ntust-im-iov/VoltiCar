import '../models/game_item_model.dart';
import '../services/game_item_service.dart';

class GameItemRepository {
  final GameItemService service = GameItemService();

  /// 取得使用者倉庫物品
  Future<List<GameItem>> getUserWarehouseItems() async {
    return await service.fetchUserWarehouseItems();
  }

  /// 取得單一遊戲物品（顯示用）
  Future<GameItem> getGameItemById(String itemId) async {
    return await service.fetchGameItemById(itemId);
  }
}
