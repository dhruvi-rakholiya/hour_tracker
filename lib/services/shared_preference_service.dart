import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static late SharedPreferences sharedPreferences;

  static Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static const String isFirstTimeLaunch = 'isFirstTimeLaunch';

  static Future<void> setIsFirstTime(bool value) async {
    await sharedPreferences.setBool(isFirstTimeLaunch, value);
  }

  static bool getIsFirsTime() {
    return sharedPreferences.getBool(isFirstTimeLaunch) ?? true;
  }
}
