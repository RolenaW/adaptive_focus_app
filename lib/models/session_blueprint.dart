class SessionBlueprint {
  final int? id;
  final String name;
  final String mood;
  final String taskType;
  final int energyLevel;
  final int workDuration;
  final int breakDuration;
  final int? presetId;
  final String createdAt;

  SessionBlueprint({
    this.id,
    required this.name,
    required this.mood,
    required this.taskType,
    required this.energyLevel,
    required this.workDuration,
    required this.breakDuration,
    this.presetId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'blueprint_name': name,
      'mood': mood,
      'task_type': taskType,
      'energy_level': energyLevel,
      'work_duration_minutes': workDuration,
      'break_duration_minutes': breakDuration,
      'preset_id': presetId,
      'created_at': createdAt,
    };
  }

  factory SessionBlueprint.fromMap(Map<String, dynamic> map) {
    return SessionBlueprint(
      id: map['id'],
      name: map['blueprint_name'],
      mood: map['mood'],
      taskType: map['task_type'],
      energyLevel: map['energy_level'],
      workDuration: map['work_duration_minutes'],
      breakDuration: map['break_duration_minutes'],
      presetId: map['preset_id'],
      createdAt: map['created_at'],
    );
  }
}