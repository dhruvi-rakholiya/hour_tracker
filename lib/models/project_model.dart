class ProjectModel {
  final int? id;
  final String name;
  final String clientName;
  final double hourlyRate;
  final String colorHex;
  final double targetHours;
  final String createdAt;

  ProjectModel({
    this.id,
    required this.name,
    this.clientName = '',
    this.hourlyRate = 0.0,
    this.colorHex = '0xFF6C5CE7',
    this.targetHours = 0.0,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'client_name': clientName,
      'hourly_rate': hourlyRate,
      'color_hex': colorHex,
      'target_hours': targetHours,
      'created_at': createdAt,
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] as int?,
      name: map['name'] as String? ?? 'Untitled Project',
      clientName: map['client_name'] as String? ?? '',
      hourlyRate: (map['hourly_rate'] as num?)?.toDouble() ?? 0.0,
      colorHex: map['color_hex'] as String? ?? '0xFF6C5CE7',
      targetHours: (map['target_hours'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  ProjectModel copyWith({
    int? id,
    String? name,
    String? clientName,
    double? hourlyRate,
    String? colorHex,
    double? targetHours,
    String? createdAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      clientName: clientName ?? this.clientName,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      colorHex: colorHex ?? this.colorHex,
      targetHours: targetHours ?? this.targetHours,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectModel &&
        (id != null && other.id != null ? id == other.id : name == other.name);
  }

  @override
  int get hashCode => id != null ? id.hashCode : name.hashCode;
}

