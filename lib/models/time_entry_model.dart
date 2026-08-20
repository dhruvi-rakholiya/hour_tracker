class TimeEntryModel {
  final int? id;
  final int? projectId;
  final String projectName;
  final String projectColor;
  final int? taskId;
  final String taskName;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final int breakMinutes;
  final double hourlyRate;
  final bool isBillable;
  final bool isOvertime;
  final double overtimeMultiplier;
  final String notes;
  final String createdAt;

  TimeEntryModel({
    this.id,
    this.projectId,
    this.projectName = 'General Work',
    this.projectColor = '0xFF6C5CE7',
    this.taskId,
    this.taskName = '',
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    this.breakMinutes = 0,
    this.hourlyRate = 0.0,
    this.isBillable = true,
    this.isOvertime = false,
    this.overtimeMultiplier = 1.5,
    this.notes = '',
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  int get netWorkMinutes {
    final net = durationMinutes - breakMinutes;
    return net > 0 ? net : 0;
  }

  double get netWorkHours => netWorkMinutes / 60.0;

  double get totalEarnings {
    if (!isBillable) return 0.0;
    final rateMultiplier = isOvertime ? overtimeMultiplier : 1.0;
    return netWorkHours * hourlyRate * rateMultiplier;
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'project_id': projectId,
      'project_name': projectName,
      'project_color': projectColor,
      'task_id': taskId,
      'task_name': taskName,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'duration_minutes': durationMinutes,
      'break_minutes': breakMinutes,
      'hourly_rate': hourlyRate,
      'is_billable': isBillable ? 1 : 0,
      'is_overtime': isOvertime ? 1 : 0,
      'overtime_multiplier': overtimeMultiplier,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory TimeEntryModel.fromMap(Map<String, dynamic> map) {
    return TimeEntryModel(
      id: map['id'] as int?,
      projectId: map['project_id'] as int?,
      projectName: map['project_name'] as String? ?? 'General Work',
      projectColor: map['project_color'] as String? ?? '0xFF6C5CE7',
      taskId: map['task_id'] as int?,
      taskName: map['task_name'] as String? ?? '',
      startTime: DateTime.tryParse(map['start_time'] as String? ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(map['end_time'] as String? ?? '') ?? DateTime.now(),
      durationMinutes: map['duration_minutes'] as int? ?? 0,
      breakMinutes: map['break_minutes'] as int? ?? 0,
      hourlyRate: (map['hourly_rate'] as num?)?.toDouble() ?? 0.0,
      isBillable: (map['is_billable'] as int? ?? 1) == 1,
      isOvertime: (map['is_overtime'] as int? ?? 0) == 1,
      overtimeMultiplier: (map['overtime_multiplier'] as num?)?.toDouble() ?? 1.5,
      notes: map['notes'] as String? ?? '',
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  TimeEntryModel copyWith({
    int? id,
    int? projectId,
    String? projectName,
    String? projectColor,
    int? taskId,
    String? taskName,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    int? breakMinutes,
    double? hourlyRate,
    bool? isBillable,
    bool? isOvertime,
    double? overtimeMultiplier,
    String? notes,
    String? createdAt,
  }) {
    return TimeEntryModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      projectColor: projectColor ?? this.projectColor,
      taskId: taskId ?? this.taskId,
      taskName: taskName ?? this.taskName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      isBillable: isBillable ?? this.isBillable,
      isOvertime: isOvertime ?? this.isOvertime,
      overtimeMultiplier: overtimeMultiplier ?? this.overtimeMultiplier,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
