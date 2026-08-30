import 'dart:async';
import 'package:get/get.dart';
import 'package:hour_tracker/controllers/project_controller.dart';
import 'package:hour_tracker/controllers/settings_controller.dart';
import 'package:hour_tracker/controllers/time_entry_controller.dart';
import 'package:hour_tracker/models/project_model.dart';
import 'package:hour_tracker/models/time_entry_model.dart';
import 'package:hour_tracker/services/notification_service.dart';
import 'package:hour_tracker/services/shared_preference_service.dart';
import 'package:hour_tracker/utils/app_show_toast.dart';
import 'package:hour_tracker/for_ads/ads/ads_variable.dart';

class TimerController extends GetxController {
  Timer? _timer;
  
  bool isRunning = false;
  bool isPaused = false;

  // Focus Mode state
  bool isFocusMode = false;
  bool isHorizontalOrientation = false;
  bool showFocusControls = true;
  Timer? _autoHideControlsTimer;

  DateTime? startTime;
  DateTime? pauseStartTime;
  int elapsedSeconds = 0;
  int breakSeconds = 0;

  ProjectModel? selectedProject;
  String selectedTaskName = '';
  double currentHourlyRate = 0.0;
  bool isBillable = true;
  String notes = '';

  static const String keyStartTime = 'timer_start_time';
  static const String keyIsRunning = 'timer_is_running';
  static const String keyIsPaused = 'timer_is_paused';
  static const String keyBreakSeconds = 'timer_break_seconds';
  static const String keyProjectName = 'timer_project_name';
  static const String keyProjectColor = 'timer_project_color';
  static const String keyRate = 'timer_hourly_rate';

  @override
  void onInit() {
    super.onInit();
    restoreTimerState();
  }

  void restoreTimerState() {
    final running = SharedPrefService.sharedPreferences.getBool(keyIsRunning) ?? false;
    if (running) {
      final startStr = SharedPrefService.sharedPreferences.getString(keyStartTime);
      if (startStr != null) {
        startTime = DateTime.tryParse(startStr);
        isPaused = SharedPrefService.sharedPreferences.getBool(keyIsPaused) ?? false;
        breakSeconds = SharedPrefService.sharedPreferences.getInt(keyBreakSeconds) ?? 0;
        currentHourlyRate = SharedPrefService.sharedPreferences.getDouble(keyRate) ?? 0.0;

        if (startTime != null) {
          isRunning = true;
          _recalculateElapsedTime();
          _startTicker();
          updateTimerNotification();
        }
      }
    }
  }

  void updateTimerNotification() {
    bool enableNotifications = true;
    if (Get.isRegistered<SettingsController>()) {
      enableNotifications = Get.find<SettingsController>().settings.enableNotifications;
    }

    if (!enableNotifications || !isRunning) {
      NotificationService.instance.cancelTimerNotification();
      return;
    }

    if (isPaused) {
      NotificationService.instance.showTimerNotification(
        title: "Work Timer Paused",
        body: "Session paused for break",
      );
    } else {
      NotificationService.instance.showTimerNotification(
        title: "Work Timer Running",
        body: "Tracking session for ${selectedProject?.name ?? 'General Work'}",
      );
    }
  }

  void _recalculateElapsedTime() {
    if (startTime == null) return;
    final now = DateTime.now();
    final totalDiff = now.difference(startTime!).inSeconds;
    elapsedSeconds = totalDiff > breakSeconds ? totalDiff - breakSeconds : 0;
  }

  void setProject(ProjectModel? project) {
    selectedProject = project;
    if (project != null) {
      currentHourlyRate = project.hourlyRate;
    } else {
      currentHourlyRate = 35.0;
    }
    update();
  }

  void setHourlyRate(double rate) {
    currentHourlyRate = rate;
    update();
  }

  void setTaskName(String task) {
    selectedTaskName = task;
    update();
  }

  void toggleBillable(bool val) {
    isBillable = val;
    update();
  }

  void setNotes(String val) {
    notes = val;
    update();
  }

  void startTimer() {
    if (isRunning && !isPaused) return;

    if (isPaused) {
      // Resume from break
      if (pauseStartTime != null) {
        final breakDiff = DateTime.now().difference(pauseStartTime!).inSeconds;
        breakSeconds += breakDiff;
        pauseStartTime = null;
      }
      isPaused = false;
      SharedPrefService.sharedPreferences.setBool(keyIsPaused, false);
      SharedPrefService.sharedPreferences.setInt(keyBreakSeconds, breakSeconds);
      _startTicker();
      updateTimerNotification();
      showToast("Timer Resumed");
    } else {
      // Fresh Start
      startTime = DateTime.now();
      elapsedSeconds = 0;
      breakSeconds = 0;
      isRunning = true;
      isPaused = false;

      // Default rate if not set
      if (currentHourlyRate == 0.0) {
        currentHourlyRate = selectedProject?.hourlyRate ?? 35.0;
      }

      SharedPrefService.sharedPreferences.setBool(keyIsRunning, true);
      SharedPrefService.sharedPreferences.setBool(keyIsPaused, false);
      SharedPrefService.sharedPreferences.setString(keyStartTime, startTime!.toIso8601String());
      SharedPrefService.sharedPreferences.setInt(keyBreakSeconds, 0);
      SharedPrefService.sharedPreferences.setDouble(keyRate, currentHourlyRate);

      _startTicker();
      updateTimerNotification();
      showToast("Timer Started");
    }
    update();
  }

  void pauseTimer() {
    if (!isRunning || isPaused) return;

    isPaused = true;
    pauseStartTime = DateTime.now();
    _timer?.cancel();

    SharedPrefService.sharedPreferences.setBool(keyIsPaused, true);
    updateTimerNotification();
    showToast("Timer Paused / On Break");
    update();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused) {
        elapsedSeconds++;
        update();
      }
    });
  }

  Future<void> stopAndSaveTimer() async {
    if (!isRunning) return;

    _timer?.cancel();
    final endTime = DateTime.now();

    final totalDurationMinutes = (elapsedSeconds + breakSeconds) ~/ 60;
    final netBreakMinutes = breakSeconds ~/ 60;

    final settingsCtrl = Get.find<SettingsController>();
    final settings = settingsCtrl.settings;

    final entry = TimeEntryModel(
      projectId: selectedProject?.id,
      projectName: selectedProject?.name ?? 'General Work',
      projectColor: selectedProject?.colorHex ?? '0xFF6C5CE7',
      taskName: selectedTaskName,
      startTime: startTime ?? endTime.subtract(Duration(seconds: elapsedSeconds)),
      endTime: endTime,
      durationMinutes: totalDurationMinutes > 0 ? totalDurationMinutes : 1,
      breakMinutes: netBreakMinutes,
      hourlyRate: currentHourlyRate,
      isBillable: isBillable,
      isOvertime: false,
      overtimeMultiplier: AdsVariable.isPurchase ? settings.overtimeMultiplier : 1.0,
      notes: notes,
    );

    final entryCtrl = Get.find<TimeEntryController>();
    await entryCtrl.addTimeEntry(entry);

    _resetState();
    await NotificationService.instance.cancelTimerNotification();
    showToast("Timer Saved!");
  }

  void resetTimerWithoutSaving() {
    _timer?.cancel();
    _resetState();
    NotificationService.instance.cancelTimerNotification();
    showToast("Timer Reset");
  }

  void toggleFocusMode(bool val) {
    isFocusMode = val;
    if (isFocusMode) {
      showFocusControls = true;
      _scheduleAutoHideControls();
    }
    update();
  }

  void toggleFocusOrientation() {
    isHorizontalOrientation = !isHorizontalOrientation;
    showFocusControls = true;
    _scheduleAutoHideControls();
    update();
  }

  void toggleFocusControls() {
    showFocusControls = !showFocusControls;
    if (showFocusControls) {
      _scheduleAutoHideControls();
    } else {
      _autoHideControlsTimer?.cancel();
    }
    update();
  }

  void _scheduleAutoHideControls() {
    _autoHideControlsTimer?.cancel();
    _autoHideControlsTimer = Timer(const Duration(seconds: 4), () {
      showFocusControls = false;
      update();
    });
  }

  void _resetState() {
    isRunning = false;
    isPaused = false;
    isFocusMode = false;
    _autoHideControlsTimer?.cancel();
    startTime = null;
    pauseStartTime = null;
    elapsedSeconds = 0;
    breakSeconds = 0;
    notes = '';

    SharedPrefService.sharedPreferences.remove(keyIsRunning);
    SharedPrefService.sharedPreferences.remove(keyIsPaused);
    SharedPrefService.sharedPreferences.remove(keyStartTime);
    SharedPrefService.sharedPreferences.remove(keyBreakSeconds);
    SharedPrefService.sharedPreferences.remove(keyRate);
    update();
  }

  bool get isOvertimeActive {
    if (!AdsVariable.isPurchase) return false;
    if (!isRunning) return false;
    double dailyGoal = 8.0;
    if (Get.isRegistered<SettingsController>()) {
      dailyGoal = Get.find<SettingsController>().settings.dailyTargetHours;
    }
    final dailyGoalMinutes = (dailyGoal * 60).round();

    int existingRegularMinutes = 0;
    if (Get.isRegistered<TimeEntryController>()) {
      final entryCtrl = Get.find<TimeEntryController>();
      existingRegularMinutes = entryCtrl
          .getEntriesForDay(DateTime.now())
          .where((e) => !e.isOvertime)
          .fold(0, (sum, e) => sum + e.netWorkMinutes);
    }

    final currentNetMinutes = elapsedSeconds ~/ 60;
    return (existingRegularMinutes + currentNetMinutes) > dailyGoalMinutes;
  }

  double get liveEarnings {
    if (!isBillable) return 0.0;

    double dailyGoal = 8.0;
    double multiplier = AdsVariable.isPurchase
        ? (Get.isRegistered<SettingsController>()
            ? Get.find<SettingsController>().settings.overtimeMultiplier
            : 1.5)
        : 1.0;
    if (Get.isRegistered<SettingsController>()) {
      final s = Get.find<SettingsController>().settings;
      dailyGoal = s.dailyTargetHours;
      multiplier = s.overtimeMultiplier;
    }
    final dailyGoalMinutes = (dailyGoal * 60).round();

    int existingRegularMinutes = 0;
    if (Get.isRegistered<TimeEntryController>()) {
      final entryCtrl = Get.find<TimeEntryController>();
      existingRegularMinutes = entryCtrl
          .getEntriesForDay(DateTime.now())
          .where((e) => !e.isOvertime)
          .fold(0, (sum, e) => sum + e.netWorkMinutes);
    }

    final remainingRegularMinutes = (dailyGoalMinutes - existingRegularMinutes).clamp(0, dailyGoalMinutes);
    final remainingRegularSeconds = remainingRegularMinutes * 60;

    if (elapsedSeconds <= remainingRegularSeconds) {
      final hours = elapsedSeconds / 3600.0;
      return hours * currentHourlyRate;
    } else {
      final regularHours = remainingRegularSeconds / 3600.0;
      final overtimeSeconds = elapsedSeconds - remainingRegularSeconds;
      final overtimeHours = overtimeSeconds / 3600.0;
      return (regularHours * currentHourlyRate) + (overtimeHours * currentHourlyRate * multiplier);
    }
  }

  String get formattedElapsedTime {
    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedBreakTime {
    final minutes = breakSeconds ~/ 60;
    final seconds = breakSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    _timer?.cancel();
    _autoHideControlsTimer?.cancel();
    super.onClose();
  }
}
