class FocusSession {
  final int? id;
  final String sessionName;
  final String mood;
  final String taskType;
  final int energyLevel;
  final int workDuration;
  final int breakDuration;
  final String sessionDate;
  final bool completed;
  final String createdAt;

  FocusSession({
    this.id,
    required this.sessionName,
    required this.mood,
    required this.taskType,
    required this.energyLevel,
    required this.workDuration,
    required this.breakDuration,
    required this.sessionDate,
    required this.completed,
    required this.createdAt,
  });

  // Convert object → database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_name': sessionName,
      'mood': mood,
      'task_type': taskType,
      'energy_level': energyLevel,
      'work_duration_minutes': workDuration,
      'break_duration_minutes': breakDuration,
      'session_date': sessionDate,
      'completed': completed ? 1 : 0,
      'created_at': createdAt,
    };
  }

  // Convert database → object
  factory FocusSession.fromMap(Map<String, dynamic> map) {
    return FocusSession(
      id: map['id'],
      sessionName: map['session_name'],
      mood: map['mood'],
      taskType: map['task_type'],
      energyLevel: map['energy_level'],
      workDuration: map['work_duration_minutes'],
      breakDuration: map['break_duration_minutes'],
      sessionDate: map['session_date'],
      completed: map['completed'] == 1,
      createdAt: map['created_at'],
    );
  }
}