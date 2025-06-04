class Connector {
  final int type;
  final int power;
  final int quantity;
  final String? description;

  Connector({
    required this.type,
    required this.power,
    required this.quantity,
    this.description,
  });

  factory Connector.fromJson(Map<String, dynamic> json) {
    return Connector(
      type: json['Type'] as int,
      power: json['Power'] as int,
      quantity: json['Quantity'] as int,
      description: json['Description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Type': type,
      'Power': power,
      'Quantity': quantity,
      'Description': description,
    };
  }
}
