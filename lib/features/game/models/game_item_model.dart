class GameItem {
  final String id;
  final String itemId;
  final String name;
  final String description;
  final String category;
  final int weightPerUnit;
  final double volumePerUnit;
  final int baseValuePerUnit;
  final bool isFragile;
  final bool isPerishable;
  final String iconUrl;

  const GameItem({
    required this.id,
    required this.itemId,
    required this.name,
    required this.description,
    required this.category,
    required this.weightPerUnit,
    required this.volumePerUnit,
    required this.baseValuePerUnit,
    required this.isFragile,
    required this.isPerishable,
    required this.iconUrl,
  });

  factory GameItem.fromJson(Map<String, dynamic> json) {
    return GameItem(
      id: json['_id'] as String,
      itemId: json['item_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      weightPerUnit: json['weight_per_unit'] as int,
      volumePerUnit: (json['volume_per_unit'] as num).toDouble(),
      baseValuePerUnit: json['base_value_per_unit'] as int,
      isFragile: json['is_fragile'] as bool,
      isPerishable: json['is_perishable'] as bool,
      iconUrl: json['icon_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'item_id': itemId,
      'name': name,
      'description': description,
      'category': category,
      'weight_per_unit': weightPerUnit,
      'volume_per_unit': volumePerUnit,
      'base_value_per_unit': baseValuePerUnit,
      'is_fragile': isFragile,
      'is_perishable': isPerishable,
      'icon_url': iconUrl,
    };
  }
}
