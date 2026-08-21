import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hour_tracker/common_widgets/app_text.dart';
import 'package:hour_tracker/common_widgets/custom_opacity.dart';
import 'package:hour_tracker/controllers/timer_controller.dart';
import 'package:hour_tracker/utils/app_colors.dart';

class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({super.key});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  @override
  void dispose() {
    // Reset orientation on exit
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _applyOrientation(bool isHorizontal) {
    if (isHorizontal) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return GetBuilder<TimerController>(
      builder: (timerCtrl) {
        final projectColor = parseColorHex(timerCtrl.selectedProject?.colorHex ?? '0xFF6C5CE7');

        // Parse formatted time "HH:MM:SS"
        final timeParts = timerCtrl.formattedElapsedTime.split(':');
        final hoursStr = timeParts.isNotEmpty ? timeParts[0] : "00";
        final minsStr = timeParts.length > 1 ? timeParts[1] : "00";
        final secsStr = timeParts.length > 2 ? timeParts[2] : "00";

        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              timerCtrl.toggleFocusMode(false);
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]);
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFF0A0B10), // OLED Night Black
            body: GestureDetector(
              onTap: timerCtrl.toggleFocusControls,
              behavior: HitTestBehavior.opaque,
              child: SafeArea(
                child: Stack(
                  children: [
                    // Center Flip-Clock View
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.all(isLandscape ? 12.0 : 16.r),
                        child: isLandscape
                            ? _buildLandscapeFlipClock(
                                timerCtrl: timerCtrl,
                                hoursStr: hoursStr,
                                minsStr: minsStr,
                                secsStr: secsStr,
                                projectColor: projectColor,
                              )
                            : _buildPortraitFlipClock(
                                timerCtrl: timerCtrl,
                                hoursStr: hoursStr,
                                minsStr: minsStr,
                                secsStr: secsStr,
                                projectColor: projectColor,
                              ),
                      ),
                    ),

                    // Top Action Bar (Exit & Orientation Switcher) - Fixed Compact Scaling in Landscape
                    Positioned(
                      top: isLandscape ? 12.0 : 16.h,
                      left: isLandscape ? 16.0 : 16.w,
                      right: isLandscape ? 16.0 : 16.w,
                      child: AnimatedOpacity(
                        opacity: timerCtrl.showFocusControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: IgnorePointer(
                          ignoring: !timerCtrl.showFocusControls,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Exit Button
                              CustomOpacityWidget(
                                onTap: () {
                                  timerCtrl.toggleFocusMode(false);
                                  SystemChrome.setPreferredOrientations([
                                    DeviceOrientation.portraitUp,
                                    DeviceOrientation.portraitDown,
                                    DeviceOrientation.landscapeLeft,
                                    DeviceOrientation.landscapeRight,
                                  ]);
                                  Get.back();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isLandscape ? 14.0 : 14.w,
                                    vertical: isLandscape ? 8.0 : 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1F2E).withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(color: white.withValues(alpha: 0.15)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.arrow_back_rounded, color: white, size: isLandscape ? 16.0 : 18.sp),
                                      SizedBox(width: isLandscape ? 6.0 : 6.w),
                                      Text(
                                        "Exit",
                                        style: TextStyle(
                                          fontSize: isLandscape ? 12.0 : 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Focus Badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isLandscape ? 12.0 : 12.w,
                                  vertical: isLandscape ? 6.0 : 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: isLandscape ? 6.0 : 8.w,
                                      height: isLandscape ? 6.0 : 8.w,
                                      decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                                    ),
                                    SizedBox(width: isLandscape ? 6.0 : 6.w),
                                    Text(
                                      "FOCUS MODE",
                                      style: TextStyle(
                                        fontSize: isLandscape ? 11.0 : 11.sp,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Orientation Switcher
                              CustomOpacityWidget(
                                onTap: () {
                                  timerCtrl.toggleFocusOrientation();
                                  _applyOrientation(timerCtrl.isHorizontalOrientation);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isLandscape ? 14.0 : 14.w,
                                    vertical: isLandscape ? 8.0 : 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1F2E).withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(color: white.withValues(alpha: 0.15)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        timerCtrl.isHorizontalOrientation
                                            ? Icons.crop_portrait_rounded
                                            : Icons.crop_landscape_rounded,
                                        color: primaryColor,
                                        size: isLandscape ? 16.0 : 18.sp,
                                      ),
                                      SizedBox(width: isLandscape ? 6.0 : 6.w),
                                      Text(
                                        timerCtrl.isHorizontalOrientation ? "Portrait" : "Landscape",
                                        style: TextStyle(
                                          fontSize: isLandscape ? 12.0 : 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bottom Floating Control Bar (Pause & Finish Buttons)
                    Positioned(
                      bottom: isLandscape ? 14.0 : 24.h,
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                        opacity: timerCtrl.showFocusControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: IgnorePointer(
                          ignoring: !timerCtrl.showFocusControls,
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isLandscape ? 14.0 : 16.w,
                                vertical: isLandscape ? 8.0 : 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF161824).withValues(alpha: 0.94),
                                borderRadius: BorderRadius.circular(30.r),
                                border: Border.all(color: white.withValues(alpha: 0.15)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Pause / Resume Button
                                  CustomOpacityWidget(
                                    onTap: timerCtrl.isPaused ? timerCtrl.startTimer : timerCtrl.pauseTimer,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isLandscape ? 18.0 : 20.w,
                                        vertical: isLandscape ? 8.0 : 10.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: timerCtrl.isPaused ? billableColor : nonBillableColor,
                                        borderRadius: BorderRadius.circular(20.r),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            timerCtrl.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                            color: white,
                                            size: isLandscape ? 18.0 : 20.sp,
                                          ),
                                          SizedBox(width: isLandscape ? 6.0 : 6.w),
                                          Text(
                                            timerCtrl.isPaused ? "Resume" : "Pause",
                                            style: TextStyle(
                                              fontSize: isLandscape ? 13.0 : 13.sp,
                                              fontWeight: FontWeight.bold,
                                              color: white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: isLandscape ? 12.0 : 12.w),

                                  // Finish / Stop Button
                                  CustomOpacityWidget(
                                    onTap: () async {
                                      await timerCtrl.stopAndSaveTimer();
                                      SystemChrome.setPreferredOrientations([
                                        DeviceOrientation.portraitUp,
                                        DeviceOrientation.portraitDown,
                                        DeviceOrientation.landscapeLeft,
                                        DeviceOrientation.landscapeRight,
                                      ]);
                                      Get.back();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isLandscape ? 18.0 : 20.w,
                                        vertical: isLandscape ? 8.0 : 10.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: dangerColor,
                                        borderRadius: BorderRadius.circular(20.r),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.stop_rounded, color: white, size: isLandscape ? 18.0 : 20.sp),
                                          SizedBox(width: isLandscape ? 6.0 : 6.w),
                                          Text(
                                            "Stop",
                                            style: TextStyle(
                                              fontSize: isLandscape ? 13.0 : 13.sp,
                                              fontWeight: FontWeight.bold,
                                              color: white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Tap Instruction Hint when Controls are Hidden
                    if (!timerCtrl.showFocusControls)
                      Positioned(
                        bottom: isLandscape ? 12.0 : 20.h,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isLandscape ? 12.0 : 14.w,
                              vertical: isLandscape ? 4.0 : 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              "Tap anywhere for controls",
                              style: TextStyle(
                                fontSize: isLandscape ? 11.0 : 11.sp,
                                color: textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Portrait Flip Clock Layout (3 Equal Parts: Hours, Minutes, Seconds)
  Widget _buildPortraitFlipClock({
    required TimerController timerCtrl,
    required String hoursStr,
    required String minsStr,
    required String secsStr,
    required Color projectColor,
  }) {
    return Column(
      children: [
        SizedBox(height: 48.h),

        // 1. HOURS CARD
        Expanded(
          child: _buildFlipCard(
            headerLabel: timerCtrl.selectedProject?.name ?? "General Work",
            headerColor: projectColor,
            digitsText: hoursStr,
            footerText: "HOURS",
            isLandscape: false,
          ),
        ),

        SizedBox(height: 8.h),

        // 2. MINUTES CARD
        Expanded(
          child: _buildFlipCard(
            headerLabel: "\$${timerCtrl.liveEarnings.toStringAsFixed(2)}",
            headerColor: billableColor,
            digitsText: minsStr,
            footerText: "MINUTES",
            isLandscape: false,
          ),
        ),

        SizedBox(height: 8.h),

        // 3. SECONDS CARD
        Expanded(
          child: _buildFlipCard(
            headerLabel: timerCtrl.isPaused ? "PAUSED" : "WORKING",
            headerColor: timerCtrl.isPaused ? nonBillableColor : primaryColor,
            digitsText: secsStr,
            footerText: "SECONDS",
            isLandscape: false,
          ),
        ),

        SizedBox(height: 48.h),
      ],
    );
  }

  // Landscape Flip Clock Layout (3 Equal Parts: Hours, Minutes, Seconds)
  Widget _buildLandscapeFlipClock({
    required TimerController timerCtrl,
    required String hoursStr,
    required String minsStr,
    required String secsStr,
    required Color projectColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36.0),
      child: Row(
        children: [
          // 1. HOURS CARD
          Expanded(
            child: _buildFlipCard(
              headerLabel: timerCtrl.selectedProject?.name ?? "General Work",
              headerColor: projectColor,
              digitsText: hoursStr,
              footerText: "HOURS",
              isLandscape: true,
            ),
          ),

          const SizedBox(width: 8.0),

          // 2. MINUTES CARD
          Expanded(
            child: _buildFlipCard(
              headerLabel: "\$${timerCtrl.liveEarnings.toStringAsFixed(2)}",
              headerColor: billableColor,
              digitsText: minsStr,
              footerText: "MINUTES",
              isLandscape: true,
            ),
          ),

          const SizedBox(width: 8.0),

          // 3. SECONDS CARD
          Expanded(
            child: _buildFlipCard(
              headerLabel: timerCtrl.isPaused ? "PAUSED" : "WORKING",
              headerColor: timerCtrl.isPaused ? nonBillableColor : primaryColor,
              digitsText: secsStr,
              footerText: "SECONDS",
              isLandscape: true,
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Premium Flip Clock Card
  Widget _buildFlipCard({
    required String headerLabel,
    required Color headerColor,
    required String digitsText,
    required String footerText,
    required bool isLandscape,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141622),
        borderRadius: BorderRadius.circular(isLandscape ? 20.0 : 24.r),
        border: Border.all(color: white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Horizontal Split Line across Card Center (Flip aesthetic)
          Center(
            child: Container(
              height: 1.5,
              color: Colors.black.withValues(alpha: 0.65),
            ),
          ),

          // Card Layout Content
          Padding(
            padding: EdgeInsets.all(isLandscape ? 10.0 : 10.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header Pill inside Flip Card
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLandscape ? 10.0 : 10.w,
                      vertical: isLandscape ? 3.0 : 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: headerColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: headerColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: isLandscape ? 6.0 : 6.w,
                          height: isLandscape ? 6.0 : 6.w,
                          decoration: BoxDecoration(color: headerColor, shape: BoxShape.circle),
                        ),
                        SizedBox(width: isLandscape ? 5.0 : 5.w),
                        Text(
                          headerLabel,
                          style: TextStyle(
                            fontSize: isLandscape ? 11.0 : 11.sp,
                            fontWeight: FontWeight.bold,
                            color: white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Center Digits
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        digitsText,
                        style: TextStyle(
                          fontSize: isLandscape ? 90.0 : 90.sp,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: white,
                          letterSpacing: -1.5,
                          shadows: [
                            Shadow(
                              color: Colors.white.withValues(alpha: 0.15),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Footer Text (Seconds / Status)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    footerText,
                    style: TextStyle(
                      fontSize: isLandscape ? 12.0 : 13.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
