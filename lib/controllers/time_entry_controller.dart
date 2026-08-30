import 'package:get/get.dart';
import 'package:hour_tracker/controllers/report_controller.dart';
import 'package:hour_tracker/controllers/settings_controller.dart';
import 'package:hour_tracker/models/time_entry_model.dart';
import 'package:hour_tracker/services/database_service.dart';
import 'package:hour_tracker/utils/app_show_toast.dart';
import 'package:hour_tracker/for_ads/ads/ads_variable.dart';

class TimeEntryController extends GetxController {
  List<TimeEntryModel> allEntries = [];
  List<TimeEntryModel> filteredEntries = [];
  bool isLoading = false;

  DateTime selectedDate = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    loadTimeEntries();
  }

  Future<void> loadTimeEntries() async {
    isLoading = true;
    update();

    try {
      allEntries = await DatabaseService.instance.getAllTimeEntries();
      filterEntriesForSelectedDate(selectedDate);
      if (Get.isRegistered<ReportController>()) {
        Get.find<ReportController>().generateReportData();
      }
    } catch (e) {
      showToast("Error loading time entries");
    } finally {
      isLoading = false;
      update();
    }
  }

  void filterEntriesForSelectedDate(DateTime date) {
    selectedDate = date;
    filteredEntries = allEntries.where((e) {
      return e.startTime.year == date.year &&
          e.startTime.month == date.month &&
          e.startTime.day == date.day;
    }).toList();
    update();
  }

  List<TimeEntryModel> getEntriesForDay(DateTime date) {
    return allEntries.where((e) {
      return e.startTime.year == date.year &&
          e.startTime.month == date.month &&
          e.startTime.day == date.day;
    }).toList();
  }

  double getDailyTargetHours() {
    if (Get.isRegistered<SettingsController>()) {
      return Get.find<SettingsController>().settings.dailyTargetHours;
    }
    return 8.0;
  }

  double getOvertimeMultiplier() {
    if (!AdsVariable.isPurchase) {
      return 1.0;
    }
    if (Get.isRegistered<SettingsController>()) {
      return Get.find<SettingsController>().settings.overtimeMultiplier;
    }
    return 1.5;
  }

  // --- STATS COMPUTATIONS ---
  double get todayTotalHours {
    final today = DateTime.now();
    return getEntriesForDay(today).fold(0.0, (sum, entry) => sum + entry.netWorkHours);
  }

  double get todayEarnings {
    final today = DateTime.now();
    return getEntriesForDay(today).fold(0.0, (sum, entry) => sum + entry.totalEarnings);
  }

  double get weeklyTotalHours {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    return allEntries.where((e) => e.startTime.isAfter(start.subtract(const Duration(seconds: 1)))).fold(0.0, (sum, entry) => sum + entry.netWorkHours);
  }

  double get weeklyEarnings {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    return allEntries.where((e) => e.startTime.isAfter(start.subtract(const Duration(seconds: 1)))).fold(0.0, (sum, entry) => sum + entry.totalEarnings);
  }

  double get monthlyTotalHours {
    final now = DateTime.now();
    return allEntries.where((e) => e.startTime.year == now.year && e.startTime.month == now.month).fold(0.0, (sum, entry) => sum + entry.netWorkHours);
  }

  double get monthlyEarnings {
    final now = DateTime.now();
    return allEntries.where((e) => e.startTime.year == now.year && e.startTime.month == now.month).fold(0.0, (sum, entry) => sum + entry.totalEarnings);
  }

  double get totalBillableHours {
    return allEntries.where((e) => e.isBillable).fold(0.0, (sum, entry) => sum + entry.netWorkHours);
  }

  double get totalNonBillableHours {
    return allEntries.where((e) => !e.isBillable).fold(0.0, (sum, entry) => sum + entry.netWorkHours);
  }

  Future<bool> addTimeEntry(TimeEntryModel entry) async {
    try {
      final dailyTargetHours = getDailyTargetHours();
      final overtimeMultiplier = getOvertimeMultiplier();
      final dailyGoalMinutes = (dailyTargetHours * 60).round();

      // Existing regular net minutes worked on entry date
      final dayEntries = getEntriesForDay(entry.startTime);
      final existingRegularMinutes = dayEntries
          .where((e) => !e.isOvertime)
          .fold<int>(0, (sum, e) => sum + e.netWorkMinutes);

      final remainingRegularMinutes = dailyGoalMinutes - existingRegularMinutes;
      final newNetMinutes = entry.netWorkMinutes;

      if (remainingRegularMinutes <= 0) {
        // Entire new entry is overtime
        final overtimeEntry = entry.copyWith(
          isOvertime: true,
          overtimeMultiplier: overtimeMultiplier,
        );
        await DatabaseService.instance.insertTimeEntry(overtimeEntry);
      } else if (newNetMinutes <= remainingRegularMinutes) {
        // Entire entry fits in regular hours
        final regularEntry = entry.copyWith(
          isOvertime: false,
          overtimeMultiplier: overtimeMultiplier,
        );
        await DatabaseService.instance.insertTimeEntry(regularEntry);
      } else {
        // Shift crosses daily goal threshold! Split into 2 separate log events.
        final regularNetMins = remainingRegularMinutes;
        final overtimeNetMins = newNetMinutes - regularNetMins;

        final regularDurationMins = regularNetMins + entry.breakMinutes;
        final regularEndTime = entry.startTime.add(Duration(minutes: regularDurationMins));

        final regularEntry = entry.copyWith(
          endTime: regularEndTime,
          durationMinutes: regularDurationMins,
          breakMinutes: entry.breakMinutes,
          isOvertime: false,
          overtimeMultiplier: overtimeMultiplier,
        );

        final overtimeEntry = entry.copyWith(
          startTime: regularEndTime,
          endTime: entry.endTime,
          durationMinutes: overtimeNetMins,
          breakMinutes: 0,
          isOvertime: true,
          overtimeMultiplier: overtimeMultiplier,
        );

        await DatabaseService.instance.insertTimeEntry(regularEntry);
        await DatabaseService.instance.insertTimeEntry(overtimeEntry);
      }

      await loadTimeEntries();
      showToast("Time log saved successfully");
      return true;
    } catch (e) {
      showToast("Failed to save time log");
      return false;
    }
  }

  Future<bool> updateTimeEntry(TimeEntryModel entry) async {
    try {
      final dailyTargetHours = getDailyTargetHours();
      final overtimeMultiplier = getOvertimeMultiplier();
      final dailyGoalMinutes = (dailyTargetHours * 60).round();

      // Existing regular minutes on this date, excluding this entry
      final dayEntries = getEntriesForDay(entry.startTime).where((e) => e.id != entry.id).toList();
      final existingRegularMinutes = dayEntries
          .where((e) => !e.isOvertime)
          .fold<int>(0, (sum, e) => sum + e.netWorkMinutes);

      final remainingRegularMinutes = dailyGoalMinutes - existingRegularMinutes;
      final newNetMinutes = entry.netWorkMinutes;

      if (remainingRegularMinutes <= 0) {
        final overtimeEntry = entry.copyWith(
          isOvertime: true,
          overtimeMultiplier: overtimeMultiplier,
        );
        await DatabaseService.instance.updateTimeEntry(overtimeEntry);
      } else if (newNetMinutes <= remainingRegularMinutes) {
        final regularEntry = entry.copyWith(
          isOvertime: false,
          overtimeMultiplier: overtimeMultiplier,
        );
        await DatabaseService.instance.updateTimeEntry(regularEntry);
      } else {
        // Split
        final regularNetMins = remainingRegularMinutes;
        final overtimeNetMins = newNetMinutes - regularNetMins;

        final regularDurationMins = regularNetMins + entry.breakMinutes;
        final regularEndTime = entry.startTime.add(Duration(minutes: regularDurationMins));

        final regularEntry = entry.copyWith(
          endTime: regularEndTime,
          durationMinutes: regularDurationMins,
          breakMinutes: entry.breakMinutes,
          isOvertime: false,
          overtimeMultiplier: overtimeMultiplier,
        );

        final overtimeEntry = TimeEntryModel(
          projectId: entry.projectId,
          projectName: entry.projectName,
          projectColor: entry.projectColor,
          taskId: entry.taskId,
          taskName: entry.taskName,
          startTime: regularEndTime,
          endTime: entry.endTime,
          durationMinutes: overtimeNetMins,
          breakMinutes: 0,
          hourlyRate: entry.hourlyRate,
          isBillable: entry.isBillable,
          isOvertime: true,
          overtimeMultiplier: overtimeMultiplier,
          notes: entry.notes,
        );

        await DatabaseService.instance.updateTimeEntry(regularEntry);
        await DatabaseService.instance.insertTimeEntry(overtimeEntry);
      }

      await loadTimeEntries();
      showToast("Time log updated");
      return true;
    } catch (e) {
      showToast("Failed to update time log");
      return false;
    }
  }

  Future<void> deleteTimeEntry(int id) async {
    try {
      await DatabaseService.instance.deleteTimeEntry(id);
      await loadTimeEntries();
      showToast("Time log deleted");
    } catch (e) {
      showToast("Failed to delete time log");
    }
  }
}

