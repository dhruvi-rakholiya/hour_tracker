import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hour_tracker/common_widgets/app_text.dart';
import 'package:hour_tracker/common_widgets/custom_opacity.dart';
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

    return Scaffold(
      backgroundColor: appBgColor,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: tabs,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardBgColor,
          boxShadow: [
            BoxShadow(color: shadowColor, blurRadius: 16.r, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.grid_view_rounded, "Home"),
                _buildNavItem(1, Icons.timer_rounded, "Timer"),
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
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22.sp,
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
}
