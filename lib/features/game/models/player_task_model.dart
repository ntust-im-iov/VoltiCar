class TaskProgress {
  int? itemsDeliveredCount;
  double? distanceTraveledForTask;

  TaskProgress({
    this.itemsDeliveredCount,
    this.distanceTraveledForTask,
  });

  factory TaskProgress.fromJson(Map<String, dynamic> json) {
    return TaskProgress(
      itemsDeliveredCount: json['items_delivered_count'],
      distanceTraveledForTask: json['distance_traveled_for_task']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items_delivered_count': itemsDeliveredCount,
      'distance_traveled_for_task': distanceTraveledForTask,
    };
  }
}

class PlayerTask {
  String id;
  String playerTaskId;
  String userId;
  String taskId;
  String status;
  DateTime acceptedAt;
  String? linkedGameSessionId;
  TaskProgress progress;
  DateTime? completedAt;
  DateTime? failedAt;
  DateTime? abandonedAt;
  DateTime lastUpdatedAt;

  PlayerTask({
    required this.id,
    required this.playerTaskId,
    required this.userId,
    required this.taskId,
    required this.status,
    required this.acceptedAt,
    this.linkedGameSessionId,
    required this.progress,
    this.completedAt,
    this.failedAt,
    this.abandonedAt,
    required this.lastUpdatedAt,
  });

  factory PlayerTask.fromJson(Map<String, dynamic> json) {
    return PlayerTask(
      id: json['_id'],
      playerTaskId: json['player_task_id'],
      userId: json['user_id'],
      taskId: json['task_id'],
      status: json['status'],
      acceptedAt: DateTime.parse(json['accepted_at']),
      linkedGameSessionId: json['linked_game_session_id'],
      progress: TaskProgress.fromJson(json['progress']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      failedAt: json['failed_at'] != null 
          ? DateTime.parse(json['failed_at']) 
          : null,
      abandonedAt: json['abandoned_at'] != null 
          ? DateTime.parse(json['abandoned_at']) 
          : null,
      lastUpdatedAt: DateTime.parse(json['last_updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'player_task_id': playerTaskId,
      'user_id': userId,
      'task_id': taskId,
      'status': status,
      'accepted_at': acceptedAt.toIso8601String(),
      'linked_game_session_id': linkedGameSessionId,
      'progress': progress.toJson(),
      'completed_at': completedAt?.toIso8601String(),
      'failed_at': failedAt?.toIso8601String(),
      'abandoned_at': abandonedAt?.toIso8601String(),
      'last_updated_at': lastUpdatedAt.toIso8601String(),
    };
  }

  // 任務狀態檢查方法
  bool get isAccepted => status == 'accepted';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isAbandoned => status == 'abandoned';
}
