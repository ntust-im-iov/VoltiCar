class GameSessionSummary {
  final SessionSummary sessionSummary;
  final List<RelatedTask> relatedTasks;
  final bool canStartGame;
  final List<String> startGameWarnings;

  GameSessionSummary({
    required this.sessionSummary,
    required this.relatedTasks,
    required this.canStartGame,
    required this.startGameWarnings,
  });

  factory GameSessionSummary.fromJson(Map<String, dynamic> json) {
    return GameSessionSummary(
      sessionSummary: json['session_summary'] != null
          ? SessionSummary.fromJson(json['session_summary'])
          : SessionSummary(
              selectedVehicle: null,
              selectedCargo: null,
              selectedDestination: null,
            ),
      relatedTasks: json['related_tasks'] != null
          ? (json['related_tasks'] as List)
              .map((task) => RelatedTask.fromJson(task))
              .toList()
          : [],
      canStartGame: json['can_start_game'] as bool? ?? false,
      startGameWarnings: json['start_game_warnings'] != null
          ? List<String>.from(json['start_game_warnings'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_summary': sessionSummary.toJson(),
      'related_tasks': relatedTasks.map((task) => task.toJson()).toList(),
      'can_start_game': canStartGame,
      'start_game_warnings': startGameWarnings,
    };
  }
}

class SessionSummary {
  final SelectedVehicleSummary? selectedVehicle;
  final SelectedCargo? selectedCargo;
  final SelectedDestinationSummary? selectedDestination;

  SessionSummary({
    this.selectedVehicle,
    this.selectedCargo,
    this.selectedDestination,
  });

  factory SessionSummary.fromJson(Map<String, dynamic> json) {
    return SessionSummary(
      selectedVehicle: json['selected_vehicle'] != null
          ? SelectedVehicleSummary.fromJson(json['selected_vehicle'])
          : null,
      selectedCargo: json['selected_cargo'] != null
          ? SelectedCargo.fromJson(json['selected_cargo'])
          : null,
      selectedDestination: json['selected_destination'] != null
          ? SelectedDestinationSummary.fromJson(json['selected_destination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selected_vehicle': selectedVehicle?.toJson(),
      'selected_cargo': selectedCargo?.toJson(),
      'selected_destination': selectedDestination?.toJson(),
    };
  }
}

class SelectedVehicleSummary {
  final String vehicleId;
  final String name;
  final double maxLoadWeight;
  final double maxLoadVolume;

  SelectedVehicleSummary({
    required this.vehicleId,
    required this.name,
    required this.maxLoadWeight,
    required this.maxLoadVolume,
  });

  factory SelectedVehicleSummary.fromJson(Map<String, dynamic> json) {
    return SelectedVehicleSummary(
      vehicleId: json['vehicle_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      maxLoadWeight: (json['max_load_weight'] ?? 0).toDouble(),
      maxLoadVolume: (json['max_load_volume'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'name': name,
      'max_load_weight': maxLoadWeight,
      'max_load_volume': maxLoadVolume,
    };
  }
}

class SelectedCargo {
  final String itemId;
  final int quantity;

  SelectedCargo({
    required this.itemId,
    required this.quantity,
  });

  factory SelectedCargo.fromJson(Map<String, dynamic> json) {
    return SelectedCargo(
      itemId: json['item_id'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'quantity': quantity,
    };
  }
}

class SelectedDestinationSummary {
  final String destinationId;
  final String name;
  final String region;

  SelectedDestinationSummary({
    required this.destinationId,
    required this.name,
    required this.region,
  });

  factory SelectedDestinationSummary.fromJson(Map<String, dynamic> json) {
    return SelectedDestinationSummary(
      destinationId: json['destination_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      region: json['region'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destination_id': destinationId,
      'name': name,
      'region': region,
    };
  }
}

class RelatedTask {
  final String taskId;

  RelatedTask({
    required this.taskId,
  });

  factory RelatedTask.fromJson(Map<String, dynamic> json) {
    return RelatedTask(
      taskId: json['task_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
    };
  }
}
