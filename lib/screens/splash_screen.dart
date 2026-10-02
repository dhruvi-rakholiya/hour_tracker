import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:hour_tracker/for_ads/ads/ads_variable.dart';
import 'package:hour_tracker/screens/intro_screen.dart';
import 'package:hour_tracker/screens/main_dashboard_screen.dart';
import 'package:hour_tracker/services/shared_preference_service.dart';
import 'package:hour_tracker/utils/app_colors.dart';
import 'package:hour_tracker/utils/app_strings.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../for_ads/utils/app_constants.dart';

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
          showLog('navigate screen');
          fetchData();
          // Initialize GetX Controllers (without Rx/Obx)
          Get.put(SettingsController());
          Get.put(ProjectController());
          Get.put(TimeEntryController());
          Get.put(TimerController());
          Get.put(ReportController());
          navigatingToNextActivity();
        },
      );
    });
  }

  void navigatingToNextActivity() async {
    bool isFirstLaunch = SharedPrefService.getIsFirsTime();
    if (isFirstLaunch) {
      Get.offAll(() => const IntroScreen());
    } else {
      Get.offAll(() => MainDashboardScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Centered App Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(22.r),
              child: Image.asset(
                'assets/images/appLogo.png',
                width: 88.r,
                height: 88.r,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20.h),
            // App Name
            CustomAppText(
              text: AppStrings.appName,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: textPrimary,
              letterSpacing: 0.4,
            ),
            SizedBox(height: 36.h),
            // Cupertino Loader
            CupertinoActivityIndicator(
              radius: 13.r,
              color: primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchData() async {
    showLog("get price");
    Offerings? offerings;
    try {
      offerings = await Purchases.getOfferings();
      if (kDebugMode) {
        log('offerings=======>$offerings');
      }
      AdsVariable.availablePackages = {
        for (var package in offerings.current?.availablePackages ?? [])
          package.identifier: package,
      };

      log("availablePackages ********** ${AdsVariable.availablePackages}");
      log(
        '----------------------------------------------------------------------------',
      );
      log(
        AdsVariable.availablePackages!.entries
            .elementAt(0)
            .value
            .storeProduct
            .identifier
            .toString(),
      );
      log(
        AdsVariable.availablePackages!.entries
            .elementAt(1)
            .value
            .storeProduct
            .identifier
            .toString(),
      );
      if ((AdsVariable.availablePackages?.entries ?? []).length >= 2) {}
    } on PlatformException catch (e) {
      if (kDebugMode) {
        showLog("get error -->$e");
      }
    }
  }

}
