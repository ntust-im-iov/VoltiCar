class GameItem {
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
  final int quantityInWarehouse;

  const GameItem({
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
    required this.quantityInWarehouse,
  });

  factory GameItem.fromJson(Map<String, dynamic> json) {
    return GameItem(
      itemId: json['item_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      weightPerUnit: (json['weight_per_unit'] as num).toInt(),
      volumePerUnit: (json['volume_per_unit'] as num).toDouble(),
      baseValuePerUnit: (json['base_value_per_unit'] as num).toInt(),
      isFragile: json['is_fragile'] as bool,
      isPerishable: json['is_perishable'] as bool,
      iconUrl: (json['icon_url'] is String && json['icon_url'] != null)
          ? json['icon_url'] as String
          : 'assets/images/volticar_logo.png',
      quantityInWarehouse: json['quantity_in_warehouse'] != null
          ? (json['quantity_in_warehouse'] as num).toInt()
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      'quantity_in_warehouse': quantityInWarehouse,
    };
  }
}
