class PlayerData {
  final String userId;
  final String displayName;
  final int level;
  final int experience;
  final List<String> achievements;
  final GameSession gameSession;
  final List<dynamic> warehouse;
  final List<dynamic> tasks;

  PlayerData({
    required this.userId,
    required this.displayName,
    required this.level,
    required this.experience,
    required this.achievements,
    required this.gameSession,
    required this.warehouse,
    required this.tasks,
  });
  factory PlayerData.fromJson(Map<String, dynamic> json) {
    return PlayerData(
      userId: json['user_id'] ?? '',
      displayName: json['display_name'] ?? 'Unknown Player',
      level: json['level'] ?? 1,
      experience: json['experience'] ?? 0,
      achievements: json['achievements'] != null
          ? List<String>.from(json['achievements'])
          : [],
      gameSession: json['game_session'] != null
          ? GameSession(
              vehicleId: json['game_session']['vehicle_id'] ?? '',
              destinationId: json['game_session']['destination_id'] ?? '',
              cargo: json['game_session']['cargo'] != null
                  ? List<dynamic>.from(json['game_session']['cargo'])
                  : [],
              active: json['game_session']['active'] ?? false,
            )
          : GameSession(
              vehicleId: '',
              destinationId: '',
              cargo: [],
              active: false,
            ),
      warehouse: json['warehouse'] != null
          ? List<dynamic>.from(json['warehouse'])
          : [],
      tasks: json['tasks'] != null ? List<dynamic>.from(json['tasks']) : [],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'level': level,
      'experience': experience,
      'achievements': achievements,
      'game_session': {
        'vehicle_id': gameSession.vehicleId,
        'destination_id': gameSession.destinationId,
        'cargo': gameSession.cargo,
        'active': gameSession.active,
      },
      'warehouse': warehouse,
      'tasks': tasks,
    };
  }
}

class GameSession {
  final String vehicleId;
  final String destinationId;
  final List<dynamic> cargo;
  final bool active;

  GameSession({
    required this.vehicleId,
    required this.destinationId,
    required this.cargo,
    required this.active,
  });

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      vehicleId: json['vehicle_id'] ?? '',
      destinationId: json['destination_id'] ?? '',
      cargo: json['cargo'] != null ? List<dynamic>.from(json['cargo']) : [],
      active: json['active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'destination_id': destinationId,
      'cargo': cargo,
      'active': active,
    };
  }
}
