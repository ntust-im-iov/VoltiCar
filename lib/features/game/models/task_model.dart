class Task {
  String taskId;
  String title;
  String description;
  String type;
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
      taskId: json['task_id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      requirements: json['requirements'],
      rewards: json['rewards'],
      isRepeatable: json['is_repeatable'],
      isActive: json['is_active'],
      availabilityStartDate: json['availability_start_date'] != null
          ? DateTime.parse(json['availability_start_date'])
          : null,
      availabilityEndDate: json['availability_end_date'] != null
          ? DateTime.parse(json['availability_end_date'])
          : null,
      prerequisiteTaskIds: List<String>.from(json['prerequisite_task_ids']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type};
  }
}
