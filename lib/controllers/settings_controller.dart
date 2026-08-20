import 'package:get/get.dart';
import 'package:hour_tracker/models/user_settings_model.dart';
import 'package:hour_tracker/services/database_service.dart';
import 'package:hour_tracker/utils/app_show_toast.dart';

class SettingsController extends GetxController {
  UserSettingsModel settings = UserSettingsModel();
  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    isLoading = true;
    update();

    try {
      settings = await DatabaseService.instance.getUserSettings();
    } catch (e) {
      showToast("Failed to load settings");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<bool> updateSettings(UserSettingsModel newSettings) async {
    try {
      await DatabaseService.instance.updateUserSettings(newSettings);
      settings = newSettings;
      update();
      showToast("Settings saved successfully");
      return true;
    } catch (e) {
      showToast("Error saving settings");
      return false;
    }
  }
}
