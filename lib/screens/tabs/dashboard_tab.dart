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
import 'package:hour_tracker/utils/app_colors.dart';
import 'package:hour_tracker/utils/app_formatters.dart';
import 'package:hour_tracker/utils/app_strings.dart';

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
          // Header Row: App  Title & Add Log Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppText(
                      text: AppStrings.appName,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                    SizedBox(height: 2.h),
                    CustomAppText(
                      text: "Track hours, calculate earnings & export reports",
                      fontSize: 12.sp,
                      color: textSecondary,
                    ),
                  ],
                ),
              ),
              CustomOpacityWidget(
                onTap: () => Get.to(() => const AddEditEntryScreen()),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    gradient: primaryGradient,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 8.r, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_rounded, color: white, size: 18.sp),
                      SizedBox(width: 4.w),
                      CustomAppText(
                        text: "Add Log",
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

          SizedBox(height: 16.h),

          // Getting Started Onboarding Hero Banner (When 0 Projects exist)
          GetBuilder<ProjectController>(
            builder: (projCtrl) {
              if (projCtrl.projects.isNotEmpty) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 20.h),
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF4834DF), const Color(0xFF6C5CE7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(color: primaryColor.withValues(alpha: 0.35), blurRadius: 14.r, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.rocket_launch_rounded, color: accentColor, size: 24.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomAppText(
                                text: "Welcome to Hour Tracker! 👋",
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: white,
                              ),
                              SizedBox(height: 2.h),
                              CustomAppText(
                                text: "Let's set up your first project to get started",
                                fontSize: 12.sp,
                                color: white.withValues(alpha: 0.85),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    CustomAppText(
                      text: "• Step 1: Create a Project & set hourly rate\n• Step 2: Track hours using Live Timer or manual entries\n• Step 3: View analytics & export PDF reports",
                      fontSize: 12.sp,
                      color: white.withValues(alpha: 0.9),
                    ),

                    SizedBox(height: 16.h),
                    CustomOpacityWidget(
                      onTap: () => Get.to(() => const AddEditProjectScreen()),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_circle_outline_rounded, color: primaryColor, size: 18.sp),
                            SizedBox(width: 8.w),
                            CustomAppText(
                              text: "Create First Project",
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
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
                      boxShadow: [
                        BoxShadow(color: primaryColor.withValues(alpha: 0.25), blurRadius: 10.r, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                timerCtrl.isPaused ? Icons.pause_rounded : Icons.timer_rounded,
                                color: white,
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomAppText(
                                  text: timerCtrl.isPaused ? "Timer Paused" : "Live Timer Active",
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: white,
                                ),
                                CustomAppText(
                                  text: timerCtrl.selectedProject?.name ?? "General Shift",
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

          // Quick Action Shortcuts Bar
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(color: shadowColor, blurRadius: 10.r, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomOpacityWidget(
                  onTap: () => onNavigateToTab(1), // Go to Timer tab
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.play_arrow_rounded, color: primaryColor, size: 22.sp),
                      ),
                      SizedBox(height: 4.h),
                      CustomAppText(text: "Start Timer", fontSize: 11.sp, fontWeight: FontWeight.w600, color: textPrimary),
                    ],
                  ),
                ),
                Container(height: 30.h, width: 1.w, color: dividerColor),
                CustomOpacityWidget(
                  onTap: () => Get.to(() => const AddEditEntryScreen()),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: billableColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.edit_note_rounded, color: billableColor, size: 22.sp),
                      ),
                      SizedBox(height: 4.h),
                      CustomAppText(text: "Log Hours", fontSize: 11.sp, fontWeight: FontWeight.w600, color: textPrimary),
                    ],
                  ),
                ),
                Container(height: 30.h, width: 1.w, color: dividerColor),
                CustomOpacityWidget(
                  onTap: () => Get.to(() => const AddEditProjectScreen()),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.create_new_folder_rounded, color: primaryDark, size: 22.sp),
                      ),
                      SizedBox(height: 4.h),
                      CustomAppText(text: "New Project", fontSize: 11.sp, fontWeight: FontWeight.w600, color: textPrimary),
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
                  // Weekly Earnings Hero Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      gradient: primaryGradient,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 14.r, offset: const Offset(0, 6)),
                      ],
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
                            Icon(Icons.trending_up_rounded, color: accentColor, size: 22.sp),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        CustomAppText(
                          text: "\$${entryCtrl.weeklyEarnings.toStringAsFixed(2)}",
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
                                CustomAppText(text: "Today", fontSize: 11.sp, color: white.withValues(alpha: 0.7)),
                                CustomAppText(
                                  text: "\$${entryCtrl.todayEarnings.toStringAsFixed(2)}",
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: white,
                                ),
                              ],
                            ),
                            Container(height: 24.h, width: 1.w, color: white.withValues(alpha: 0.2)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomAppText(text: "Monthly", fontSize: 11.sp, color: white.withValues(alpha: 0.7)),
                                CustomAppText(
                                  text: "\$${entryCtrl.monthlyEarnings.toStringAsFixed(2)}",
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: white,
                                ),
                              ],
                            ),
                            Container(height: 24.h, width: 1.w, color: white.withValues(alpha: 0.2)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomAppText(text: "Billable Ratio", fontSize: 11.sp, color: white.withValues(alpha: 0.7)),
                                CustomAppText(
                                  text: "${(entryCtrl.totalBillableHours + entryCtrl.totalNonBillableHours) > 0 ? ((entryCtrl.totalBillableHours / (entryCtrl.totalBillableHours + entryCtrl.totalNonBillableHours)) * 100).toStringAsFixed(0) : 100}%",
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

                  // Today & Weekly Hours Grid
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(color: shadowColor, blurRadius: 10.r, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.schedule_rounded, color: primaryColor, size: 18.sp),
                                  SizedBox(width: 6.w),
                                  CustomAppText(text: "Today Hours", fontSize: 12.sp, color: textSecondary),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              CustomAppText(
                                text: formatHoursToDuration(entryCtrl.todayTotalHours),
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
                            boxShadow: [
                              BoxShadow(color: shadowColor, blurRadius: 10.r, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.check_circle_outline_rounded, color: billableColor, size: 18.sp),
                                  SizedBox(width: 6.w),
                                  CustomAppText(text: "Weekly Hours", fontSize: 12.sp, color: textSecondary),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              CustomAppText(
                                text: formatHoursToDuration(entryCtrl.weeklyTotalHours),
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

          // Work Target Progress Section
          GetBuilder<SettingsController>(
            builder: (settingsCtrl) {
              final entryCtrl = Get.find<TimeEntryController>();
              final dailyTarget = settingsCtrl.settings.dailyTargetHours;
              final workedToday = entryCtrl.todayTotalHours;
              final progress = dailyTarget > 0 ? (workedToday / dailyTarget).clamp(0.0, 1.0) : 0.0;

              return Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(color: shadowColor, blurRadius: 10.r, offset: const Offset(0, 4)),
                  ],
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
                          text: "${formatHoursToDuration(workedToday)} / ${formatHoursToDuration(dailyTarget)}",
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

          // Recent Entries List
          GetBuilder<TimeEntryController>(
            builder: (entryCtrl) {
              if (entryCtrl.allEntries.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(24.r),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.history_rounded, size: 40.sp, color: textMuted),
                      SizedBox(height: 8.h),
                      CustomAppText(text: "No work logs recorded yet", fontSize: 14.sp, color: textSecondary),
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
                      boxShadow: [
                        BoxShadow(color: shadowColor, blurRadius: 6.r, offset: const Offset(0, 2)),
                      ],
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
                              text: "\$${entry.totalEarnings.toStringAsFixed(2)}",
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: entry.isBillable ? billableColor : textSecondary,
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
          SizedBox(height: 80.h),
        ],
      ),
    );
  }
}
