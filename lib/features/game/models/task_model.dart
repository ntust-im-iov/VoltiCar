class Task {
  String taskId;
  String title;
  String description;
  String type;
  String mode;
  Map<String, dynamic> requirements;
  Map<String, dynamic> rewards;
  bool isRepeatable;
  bool isActive;
  DateTime? availabilityStartDate;
  DateTime? availabilityEndDate;
  List<String> prerequisiteTaskIds;

  Task({
    required this.taskId,
    required this.title,
    required this.description,
    required this.type,
    required this.mode,
    required this.requirements,
    required this.rewards,
    required this.isRepeatable,
    required this.isActive,
    this.availabilityStartDate,
    this.availabilityEndDate,
    required this.prerequisiteTaskIds,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['task_id'] ?? '',
      title: json['title'] ?? 'Unknown Task',
      description: json['description'] ?? 'No description available',
      type: json['type'] ?? 'general',
      mode: json['mode'] ?? 'story',
      requirements: json['requirements'] ?? {},
      rewards: json['rewards'] ?? {},
      isRepeatable: json['is_repeatable'] ?? false,
      isActive: json['is_active'] ?? true,
      availabilityStartDate: json['availability_start_date'] != null
          ? DateTime.parse(json['availability_start_date'])
          : null,
      availabilityEndDate: json['availability_end_date'] != null
          ? DateTime.parse(json['availability_end_date'])
          : null,
      prerequisiteTaskIds: json['prerequisite_task_ids'] != null 
          ? List<String>.from(json['prerequisite_task_ids'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'title': title,
      'description': description,
      'type': type,
      'mode': mode,
      'requirements': requirements,
      'rewards': rewards,
      'is_repeatable': isRepeatable,
      'is_active': isActive,
      'availability_start_date': availabilityStartDate?.toIso8601String(),
      'availability_end_date': availabilityEndDate?.toIso8601String(),
      'prerequisite_task_ids': prerequisiteTaskIds,
    };
  }
}
