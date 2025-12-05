class Destination {
  final String id;
  final String destinationId;
  final String name;
  final String description;
  final String region;
  final Coordinates coordinates;
  final bool isUnlockedByDefault;
  final UnlockRequirements unlockRequirements;
  final List<String> availableServices;
  final String iconUrl;

  Destination({
    required this.id,
    required this.destinationId,
    required this.name,
    required this.description,
    required this.region,
    required this.coordinates,
    required this.isUnlockedByDefault,
    required this.unlockRequirements,
    required this.availableServices,
    required this.iconUrl,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['_id'] as String,
      destinationId: json['destination_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      region: json['region'] as String,
      coordinates:
          Coordinates.fromJson(json['coordinates'] as Map<String, dynamic>),
      isUnlockedByDefault: json['is_unlocked_by_default'] as bool,
      unlockRequirements: json['unlock_requirements'] == null
          ? UnlockRequirements(
              requiredPlayerLevel: 0, requiredCompletedTaskId: '')
          : UnlockRequirements.fromJson(
              json['unlock_requirements'] as Map<String, dynamic>),
      availableServices: List<String>.from(json['available_services'] as List),
      iconUrl: json['icon_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'destination_id': destinationId,
      'name': name,
      'description': description,
      'region': region,
      'coordinates': coordinates.toJson(),
      'is_unlocked_by_default': isUnlockedByDefault,
      'unlock_requirements': unlockRequirements.toJson(),
      'available_services': availableServices,
      'icon_url': iconUrl,
    };
  }
}

class Coordinates {
  final String type;
  final List<double> coordinates;

  Coordinates({
    required this.type,
    required this.coordinates,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      type: json['type'] as String,
      coordinates: (json['coordinates'] as List)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}

class UnlockRequirements {
  final int requiredPlayerLevel;
  final String requiredCompletedTaskId;

  UnlockRequirements({
    required this.requiredPlayerLevel,
    required this.requiredCompletedTaskId,
  });

  factory UnlockRequirements.fromJson(Map<String, dynamic> json) {
    return UnlockRequirements(
      requiredPlayerLevel: json['required_player_level'] as int,
      requiredCompletedTaskId:
          json['required_completed_task_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'required_player_level': requiredPlayerLevel,
      'required_completed_task_id': requiredCompletedTaskId,
    };
  }
}
