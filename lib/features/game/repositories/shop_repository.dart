import '../models/shop_item_model.dart';
import '../services/shop_service.dart';

class ShopRepository {
  final ShopService service = ShopService();

  /// 取得商店商品列表
  Future<List<ShopItem>> getShopItems() async {
    return await service.fetchShopItems();
  }
}
