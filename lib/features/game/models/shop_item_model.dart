class ShopItem {
  final String id;
  final String itemId;
  final String name;
  final String description;
  final int price;
  final String category;
  final String iconUrl;

  ShopItem({
    required this.id,
    required this.itemId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.iconUrl,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['_id'] as String? ?? '',
      itemId: json['item_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Item',
      description: json['description'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      category: json['category'] as String? ?? 'unknown',
      iconUrl: json['icon_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'item_id': itemId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'icon_url': iconUrl,
    };
  }
}
