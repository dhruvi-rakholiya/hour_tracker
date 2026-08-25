import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hour_tracker/common_widgets/app_text.dart';
import 'package:hour_tracker/controllers/project_controller.dart';
import 'package:hour_tracker/controllers/report_controller.dart';
import 'package:hour_tracker/controllers/settings_controller.dart';
import 'package:hour_tracker/controllers/time_entry_controller.dart';
import 'package:hour_tracker/controllers/timer_controller.dart';
import 'package:hour_tracker/firebase_analysis.dart';
import 'package:hour_tracker/for_ads/ads/ads_splash_utils.dart';
import 'package:hour_tracker/screens/intro_screen.dart';
import 'package:hour_tracker/screens/main_dashboard_screen.dart';
import 'package:hour_tracker/utils/app_colors.dart';
import 'package:hour_tracker/utils/app_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    WidgetsBinding.instance.addPostFrameCallback((callback) async {
      FirebaseAnalyticsService.logEvent(eventName: 'SPLASH_SCREEN');
      await AdsSplashUtils().getOnlineIds(
        navigateScreen: () async {
          print('navigate screen');
          // Initialize GetX Controllers (without Rx/Obx)
          Get.put(SettingsController());
          Get.put(ProjectController());
          Get.put(TimeEntryController());
          Get.put(TimerController());
          Get.put(ReportController());
          // Direct Navigation to IntroScreen
          Get.off(() => const IntroScreen());
        },
      );
    });
  }

  // void navigatingToNextActivity() async {
  //   bool isFirstLaunch = SharedPrefService.getIsFirsTime();
  //   if (isFirstLaunch) {
  //     Get.offAll(() => const SurveyScreen());
  //   } else {
  //     if (AdsVariable.isPurchase) {
  //       Get.offAll(() => BottomBarScreen());
  //     } else {
  //       Get.offAll(() => PremiumScreen(isFromIntroAndSplash: true));
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.access_time_filled_rounded,
                size: 72.sp,
                color: white,
              ),
            ),
            SizedBox(height: 24.h),
            CustomAppText(
              text: AppStrings.appName,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: white,
            ),
            SizedBox(height: 8.h),
            CustomAppText(
              text: "Professional Work & Earnings Tracker",
              fontSize: 14.sp,
              color: white.withValues(alpha: 0.8),
            ),
            SizedBox(height: 48.h),
            CircularProgressIndicator(color: white, strokeWidth: 3.w),
          ],
        ),
      ),
    );
  }
}
