class UserSettingsModel {
  final double dailyTargetHours;
  final double weeklyTargetHours;
  final double monthlyTargetHours;
  final double overtimeThresholdDaily;
  final double overtimeMultiplier;
  final bool enableNotifications;

  UserSettingsModel({
    this.dailyTargetHours = 8.0,
    this.weeklyTargetHours = 40.0,
    this.monthlyTargetHours = 160.0,
    this.overtimeThresholdDaily = 8.0,
    this.overtimeMultiplier = 1.5,
    this.enableNotifications = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'daily_target': dailyTargetHours,
      'weekly_target': weeklyTargetHours,
      'monthly_target': monthlyTargetHours,
      'overtime_threshold': overtimeThresholdDaily,
      'overtime_multiplier': overtimeMultiplier,
      'enable_notifications': enableNotifications ? 1 : 0,
    };
  }

  factory UserSettingsModel.fromMap(Map<String, dynamic> map) {
    return UserSettingsModel(
      dailyTargetHours: (map['daily_target'] as num?)?.toDouble() ?? 8.0,
      weeklyTargetHours: (map['weekly_target'] as num?)?.toDouble() ?? 40.0,
      monthlyTargetHours: (map['monthly_target'] as num?)?.toDouble() ?? 160.0,
      overtimeThresholdDaily: (map['overtime_threshold'] as num?)?.toDouble() ?? 8.0,
      overtimeMultiplier: (map['overtime_multiplier'] as num?)?.toDouble() ?? 1.5,
      enableNotifications: (map['enable_notifications'] as int? ?? 1) == 1,
    );
  }

  UserSettingsModel copyWith({
    double? dailyTargetHours,
    double? weeklyTargetHours,
    double? monthlyTargetHours,
    double? overtimeThresholdDaily,
    double? overtimeMultiplier,
    bool? enableNotifications,
  }) {
    return UserSettingsModel(
      dailyTargetHours: dailyTargetHours ?? this.dailyTargetHours,
      weeklyTargetHours: weeklyTargetHours ?? this.weeklyTargetHours,
      monthlyTargetHours: monthlyTargetHours ?? this.monthlyTargetHours,
      overtimeThresholdDaily: overtimeThresholdDaily ?? this.overtimeThresholdDaily,
      overtimeMultiplier: overtimeMultiplier ?? this.overtimeMultiplier,
      enableNotifications: enableNotifications ?? this.enableNotifications,
    );
  }
}
