class TaskModel {
  final int? id;
  final int projectId;
  final String name;
  final String createdAt;

  TaskModel({
    this.id,
    required this.projectId,
    required this.name,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'project_id': projectId,
      'name': name,
      'created_at': createdAt,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      projectId: map['project_id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
