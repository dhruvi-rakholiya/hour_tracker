import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hour_tracker/common_widgets/app_text.dart';
import 'package:hour_tracker/common_widgets/custom_opacity.dart';
import 'package:hour_tracker/controllers/timer_controller.dart';
import 'package:hour_tracker/for_ads/widgets/banner_ad_widget.dart';
import 'package:hour_tracker/screens/tabs/dashboard_tab.dart';
import 'package:hour_tracker/screens/tabs/logs_calendar_tab.dart';
import 'package:hour_tracker/screens/tabs/projects_settings_tab.dart';
import 'package:hour_tracker/screens/tabs/reports_tab.dart';
import 'package:hour_tracker/screens/tabs/timer_tab.dart';
import 'package:hour_tracker/utils/app_colors.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      DashboardTab(onNavigateToTab: _onTabSelected),
      const TimerTab(),
      const LogsCalendarTab(),
      const ReportsTab(),
      const ProjectsSettingsTab(),
    ];

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: appBgColor,
        extendBody: true,
        body: IndexedStack(
          index: _currentIndex,
          children: tabs,
        ).paddingOnly(top: 20.h),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBannerAdWidget(currentIndex: _currentIndex),
            _buildFloatingBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingBottomBar() {
    return Container(
      margin: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        bottom: 16.h,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: cardBgColor.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.18),
                  blurRadius: 24.r,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 16.r,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.grid_view_rounded, "Home"),
                _buildTimerHeroNavItem(1, "Timer"),
                _buildNavItem(2, Icons.calendar_today_rounded, "Logs"),
                _buildNavItem(3, Icons.insert_chart_outlined_rounded, "Reports"),
                _buildNavItem(4, Icons.folder_outlined, "Projects"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return CustomOpacityWidget(
      onTap: () => _onTabSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14.w : 10.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: isSelected
              ? Border.all(color: primaryColor.withValues(alpha: 0.3), width: 1)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.2),
                    blurRadius: 10.r,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: isSelected ? primaryColor : textMuted,
            ),
            if (isSelected) ...[
              SizedBox(width: 6.w),
              CustomAppText(
                text: label,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimerHeroNavItem(int index, String label) {
    final isSelected = _currentIndex == index;

    return GetBuilder<TimerController>(
      builder: (timerCtrl) {
        final isRunning = timerCtrl.isRunning;

        return CustomOpacityWidget(
          onTap: () => _onTabSelected(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 16.w : 12.w,
              vertical: 8.h,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? primaryGradient
                  : (isRunning
                      ? LinearGradient(
                          colors: [
                            primaryColor.withValues(alpha: 0.25),
                            primaryDark.withValues(alpha: 0.25),
                          ],
                        )
                      : null),
              color: isSelected ? null : (isRunning ? null : primaryColor.withValues(alpha: 0.08)),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.3)
                    : (isRunning ? primaryColor.withValues(alpha: 0.5) : primaryColor.withValues(alpha: 0.2)),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isSelected || isRunning)
                      ? primaryColor.withValues(alpha: 0.35)
                      : Colors.transparent,
                  blurRadius: 12.r,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.timer_rounded,
                      size: 20.sp,
                      color: isSelected ? white : (isRunning ? primaryColor : textMuted),
                    ),
                    if (isRunning && !isSelected)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: const BoxDecoration(
                            color: successColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                if (isSelected) ...[
                  SizedBox(width: 6.w),
                  CustomAppText(
                    text: label,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: white,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

