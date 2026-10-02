import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:hour_tracker/common_widgets/app_text.dart';
import 'package:hour_tracker/common_widgets/custom_opacity.dart';
import 'package:hour_tracker/controllers/project_controller.dart';
import 'package:hour_tracker/controllers/settings_controller.dart';
import 'package:hour_tracker/controllers/time_entry_controller.dart';
import 'package:hour_tracker/controllers/timer_controller.dart';
import 'package:hour_tracker/screens/add_edit_entry_screen.dart';
import 'package:hour_tracker/screens/add_edit_project_screen.dart';
import 'package:hour_tracker/screens/premium_screen.dart';
import 'package:hour_tracker/screens/settings_screen.dart';
import 'package:hour_tracker/utils/app_colors.dart';
import 'package:hour_tracker/utils/app_formatters.dart';
import 'package:hour_tracker/utils/app_strings.dart';
import 'package:hour_tracker/utils/app_premium_helper.dart';

class DashboardTab extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const DashboardTab({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: App Title, PRO Button & Settings Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: CustomAppText(
                          text: AppStrings.appName,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      CustomAppText(
                        text: "Track hours & calculate earnings",
                        fontSize: 12.sp,
                        color: textSecondary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  // Highlighted PRO Button (Shadow-Free)
                  CustomOpacityWidget(
                    onTap: () => Get.to(() => const PremiumScreen()),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 13.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: goldGradient,
                        borderRadius: BorderRadius.circular(7.r),
                      ),
                      child: Row(
                        children: [
                          CustomAppText(
                            text: "PRO",
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Settings Button in AppBar (Shadow-Free)
                  CustomOpacityWidget(
                    onTap: () => Get.to(() => const SettingsScreen()),
                    child: Container(
                      padding: EdgeInsets.all(9.r),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.settings_rounded,
                        color: textPrimary,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Getting Started Onboarding Hero Banner (When 0 Projects exist) - Subtle & Minimal
          GetBuilder<ProjectController>(
            builder: (projCtrl) {
              if (projCtrl.projects.isNotEmpty) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 16.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.rocket_launch_rounded,
                      color: primaryColor,
                      size: 27.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomAppText(
                            text: "Welcome to Hour Metric! 👋",
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                          SizedBox(height: 2.h),
                          CustomAppText(
                            text: "Create a project to start logging hours & earnings",
                            fontSize: 11.5.sp,
                            color: textSecondary,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    CustomOpacityWidget(
                      onTap: () {
                        if (AppPremiumHelper.checkProjectLimitAndPrompt(context)) {
                          Get.to(() => const AddEditProjectScreen());
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 4.h,
                          horizontal: 7.w,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              color: white,
                              size: 16.sp,
                            ),
                            SizedBox(width: 3.w),
                            CustomAppText(
                              text: "Add",
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Active Timer Quick Access Banner (if timer running)
          GetBuilder<TimerController>(
            builder: (timerCtrl) {
              if (!timerCtrl.isRunning) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: CustomOpacityWidget(
                  onTap: () => onNavigateToTab(1),
                  child: Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      gradient: timerGradient,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              timerCtrl.isPaused
                                  ? Icons.pause_rounded
                                  : Icons.timer_rounded,
                              color: white,
                              size: 27.sp,
                            ),
                            SizedBox(width: 12.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomAppText(
                                  text: timerCtrl.isPaused
                                      ? "Timer Paused"
                                      : "Live Timer Active",
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: white,
                                ),
                                CustomAppText(
                                  text: timerCtrl.selectedProject?.name ??
                                      "General Shift",
                                  fontSize: 12.sp,
                                  color: white.withValues(alpha: 0.85),
                                ),
                              ],
                            ),
                          ],
                        ),
                        CustomAppText(
                          text: timerCtrl.formattedElapsedTime,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: white,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),



          // Quick Action Shortcuts Bar (Shadow-Free)
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomOpacityWidget(
                  onTap: () => onNavigateToTab(1), // Go to Timer tab
                  child: Column(
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: primaryColor,
                        size: 30.sp,
                      ),
                      SizedBox(height: 4.h),
                      CustomAppText(
                        text: "Start Timer",
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ],
                  ),
                ),
                Container(height: 30.h, width: 1.w, color: dividerColor),
                CustomOpacityWidget(
                  onTap: () => Get.to(() => const AddEditEntryScreen()),
                  child: Column(
                    children: [
                      Icon(
                        Icons.edit_note_rounded,
                        color: billableColor,
                        size: 30.sp,
                      ),
                      SizedBox(height: 4.h),
                      CustomAppText(
                        text: "Log Hours",
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ],
                  ),
                ),
                Container(height: 30.h, width: 1.w, color: dividerColor),
                CustomOpacityWidget(
                  onTap: () {
                    if (AppPremiumHelper.checkProjectLimitAndPrompt(context)) {
                      Get.to(() => const AddEditProjectScreen());
                    }
                  },
                  child: Column(
                    children: [
                      Icon(
                        Icons.create_new_folder_rounded,
                        color: primaryDark,
                        size: 30.sp,
                      ),
                      SizedBox(height: 4.h),
                      CustomAppText(
                        text: "New Project",
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Financial Summary Cards
          GetBuilder<TimeEntryController>(
            builder: (entryCtrl) {
              return Column(
                children: [
                  // Weekly Earnings Hero Card (Shadow-Free)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      gradient: primaryGradient,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomAppText(
                              text: "THIS WEEK EARNINGS",
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: white.withValues(alpha: 0.8),
                            ),
                            Icon(
                              Icons.trending_up_rounded,
                              color: accentColor,
                              size: 22.sp,
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        CustomAppText(
                          text:
                              "\$${entryCtrl.weeklyEarnings.toStringAsFixed(2)}",
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          color: white,
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomAppText(
                                  text: "Today",
                                  fontSize: 11.sp,
                                  color: white.withValues(alpha: 0.7),
                                ),
                                CustomAppText(
                                  text:
                                      "\$${entryCtrl.todayEarnings.toStringAsFixed(2)}",
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: white,
                                ),
                              ],
                            ),
                            Container(
                              height: 24.h,
                              width: 1.w,
                              color: white.withValues(alpha: 0.2),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomAppText(
                                  text: "Monthly",
                                  fontSize: 11.sp,
                                  color: white.withValues(alpha: 0.7),
                                ),
                                CustomAppText(
                                  text:
                                      "\$${entryCtrl.monthlyEarnings.toStringAsFixed(2)}",
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: white,
                                ),
                              ],
                            ),
                            Container(
                              height: 24.h,
                              width: 1.w,
                              color: white.withValues(alpha: 0.2),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomAppText(
                                  text: "Billable Ratio",
                                  fontSize: 11.sp,
                                  color: white.withValues(alpha: 0.7),
                                ),
                                CustomAppText(
                                  text:
                                      "${(entryCtrl.totalBillableHours + entryCtrl.totalNonBillableHours) > 0 ? ((entryCtrl.totalBillableHours / (entryCtrl.totalBillableHours + entryCtrl.totalNonBillableHours)) * 100).toStringAsFixed(0) : 100}%",
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Today & Weekly Hours Grid (Shadow-Free)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    color: primaryColor,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 6.w),
                                  CustomAppText(
                                    text: "Today Hours",
                                    fontSize: 12.sp,
                                    color: textSecondary,
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              CustomAppText(
                                text: formatHoursToDuration(
                                  entryCtrl.todayTotalHours,
                                ),
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: billableColor,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 6.w),
                                  CustomAppText(
                                    text: "Weekly Hours",
                                    fontSize: 12.sp,
                                    color: textSecondary,
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              CustomAppText(
                                text: formatHoursToDuration(
                                  entryCtrl.weeklyTotalHours,
                                ),
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 20.h),

          // Work Target Progress Section (Shadow-Free)
          GetBuilder<SettingsController>(
            builder: (settingsCtrl) {
              final entryCtrl = Get.find<TimeEntryController>();
              final dailyTarget = settingsCtrl.settings.dailyTargetHours;
              final workedToday = entryCtrl.todayTotalHours;
              final progress = dailyTarget > 0
                  ? (workedToday / dailyTarget).clamp(0.0, 1.0)
                  : 0.0;

              return Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomAppText(
                          text: AppStrings.workTarget,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                        CustomAppText(
                          text:
                              "${formatHoursToDuration(workedToday)} / ${formatHoursToDuration(dailyTarget)}",
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10.h,
                        backgroundColor: surfaceColor,
                        color: progress >= 1.0 ? successColor : primaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    CustomAppText(
                      text: progress >= 1.0
                          ? "🎉 Great job! Daily goal achieved!"
                          : "${formatHoursToDuration((1 - progress) * dailyTarget, short: false)} remaining to reach today's target.",
                      fontSize: 12.sp,
                      color: progress >= 1.0 ? successColor : textSecondary,
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: 24.h),

          // Recent Activity Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomAppText(
                text: "Recent Work Logs",
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
              CustomOpacityWidget(
                onTap: () => onNavigateToTab(2),
                child: CustomAppText(
                  text: "View All",
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Recent Entries List (Shadow-Free)
          GetBuilder<TimeEntryController>(
            builder: (entryCtrl) {
              if (entryCtrl.allEntries.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(24.r),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 40.sp,
                        color: textMuted,
                      ),
                      SizedBox(height: 8.h),
                      CustomAppText(
                        text: "No work logs recorded yet",
                        fontSize: 14.sp,
                        color: textSecondary,
                      ),
                    ],
                  ),
                );
              }

              final recent = entryCtrl.allEntries.take(4).toList();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recent.length,
                separatorBuilder: (context, index) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final entry = recent[index];
                  final DateFormat df = DateFormat('MMM dd, hh:mm a');

                  return Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: parseColorHex(entry.projectColor),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomAppText(
                                text: entry.projectName,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                              SizedBox(height: 4.h),
                              CustomAppText(
                                text: df.format(entry.startTime),
                                fontSize: 11.sp,
                                color: textSecondary,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            CustomAppText(
                              text:
                                  "\$${entry.totalEarnings.toStringAsFixed(2)}",
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: entry.isBillable
                                  ? billableColor
                                  : textSecondary,
                            ),
                            SizedBox(height: 4.h),
                            CustomAppText(
                              text: entry.formattedDuration,
                              fontSize: 12.sp,
                              color: textMuted,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(height: 130.h),
        ],
      ),
    );
  }
}
