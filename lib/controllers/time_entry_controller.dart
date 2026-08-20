import 'package:get/get.dart';
import 'package:hour_tracker/models/time_entry_model.dart';
import 'package:hour_tracker/services/database_service.dart';
import 'package:hour_tracker/utils/app_show_toast.dart';

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
      await DatabaseService.instance.insertTimeEntry(entry);
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
      await DatabaseService.instance.updateTimeEntry(entry);
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
