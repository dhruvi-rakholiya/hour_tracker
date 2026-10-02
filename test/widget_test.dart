import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hour_tracker/common_widgets/screen_app_bar_title.dart';
import 'package:hour_tracker/controllers/timer_controller.dart';
import 'package:hour_tracker/screens/focus_mode_screen.dart';
import 'package:hour_tracker/screens/intro_screen.dart';
import 'package:hour_tracker/services/shared_preference_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('ScreenAppBarTitle renders properly with horizontal padding', (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(56),
              child: ScreenAppBarTitle(text: 'Settings'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('IntroScreen renders properly without layout errors', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => const GetMaterialApp(
          home: IntroScreen(),
        ),
      ),
    );

    expect(find.text('Hour Metric'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('STEP 01 / 03'), findsOneWidget);
  });

  testWidgets('FocusModeScreen Top Action Bar renders properly without overflow on narrow device', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefService.init();
    Get.put(TimerController());

    // Narrow screen (320px width)
    tester.view.physicalSize = const Size(320 * 2, 640 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      Get.reset();
    });

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => const GetMaterialApp(
          home: FocusModeScreen(),
        ),
      ),
    );

    expect(find.text('Exit'), findsOneWidget);
    expect(find.text('FOCUS MODE'), findsOneWidget);
    expect(find.text('Landscape'), findsOneWidget);
  });

  testWidgets('FocusModeScreen Top Action Bar renders properly in Landscape', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefService.init();
    Get.put(TimerController());

    // Landscape screen (640x360)
    tester.view.physicalSize = const Size(640 * 2, 360 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      Get.reset();
    });

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => const GetMaterialApp(
          home: FocusModeScreen(),
        ),
      ),
    );

    expect(find.text('Exit'), findsOneWidget);
    expect(find.text('FOCUS MODE'), findsOneWidget);
    expect(find.text('Landscape'), findsOneWidget);
  });
}


