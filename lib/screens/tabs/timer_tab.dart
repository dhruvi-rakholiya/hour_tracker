import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hour_tracker/common_widgets/app_text.dart';
import 'package:hour_tracker/common_widgets/custom_opacity.dart';
import 'package:hour_tracker/controllers/project_controller.dart';
import 'package:hour_tracker/controllers/timer_controller.dart';
import 'package:hour_tracker/models/project_model.dart';
import 'package:hour_tracker/screens/add_edit_project_screen.dart';
import 'package:hour_tracker/screens/focus_mode_screen.dart';
import 'package:hour_tracker/utils/app_colors.dart';
import 'package:hour_tracker/utils/app_strings.dart';

class TimerTab extends StatefulWidget {
  const TimerTab({super.key});

  @override
  State<TimerTab> createState() => _TimerTabState();
}

class _TimerTabState extends State<TimerTab> {
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: GetBuilder<TimerController>(
        builder: (timerCtrl) {
          return Column(
            children: [
              // Header
              CustomAppText(
                text: AppStrings.activeTimer,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
              SizedBox(height: 16.h),

              // Project Selector Dropdown & Add Button
              GetBuilder<ProjectController>(
                builder: (projCtrl) {
                  if (projCtrl.projects.isEmpty) {
                    return Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(color: shadowColor, blurRadius: 10.r, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.folder_open_rounded, color: primaryColor, size: 24.sp),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: CustomAppText(
                              text: "No project selected. Create a project to log time.",
                              fontSize: 13.sp,
                              color: textSecondary,
                            ),
                          ),
                          CustomOpacityWidget(
                            onTap: () => Get.to(() => const AddEditProjectScreen()),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: CustomAppText(
                                text: "+ Create",
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(color: shadowColor, blurRadius: 10.r, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<ProjectModel>(
                              isExpanded: true,
                              value: timerCtrl.selectedProject ?? projCtrl.selectedProject,
                              hint: const CustomAppText(text: AppStrings.noProjectSelected, color: textMuted),
                              items: projCtrl.projects.map((p) {
                                return DropdownMenuItem<ProjectModel>(
                                  value: p,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12.w,
                                        height: 12.w,
                                        decoration: BoxDecoration(
                                          color: parseColorHex(p.colorHex),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      CustomAppText(
                                        text: p.name,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: textPrimary,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: timerCtrl.isRunning
                                  ? null
                                  : (p) {
                                      if (p != null) {
                                        timerCtrl.setProject(p);
                                      }
                                    },
                            ),
                          ),
                        ),
                        if (!timerCtrl.isRunning)
                          IconButton(
                            icon: Icon(Icons.add_circle_outline_rounded, color: primaryColor, size: 22.sp),
                            onPressed: () => Get.to(() => const AddEditProjectScreen()),
                            tooltip: "Add New Project",
                          ),
                      ],
                    ),
                  );
                },
              ),

              SizedBox(height: 16.h),

              // Focus Mode Launch Card & Switch
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
                  boxShadow: [
                    BoxShadow(color: shadowColor, blurRadius: 8.r, offset: const Offset(0, 3)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.center_focus_strong_rounded, color: primaryColor, size: 22.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomAppText(
                            text: "Focus Mode",
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                          SizedBox(height: 2.h),
                          CustomAppText(
                            text: "Full-screen timer view",
                            fontSize: 11.sp,
                            color: textMuted,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    CustomOpacityWidget(
                      onTap: () {
                        timerCtrl.toggleFocusMode(true);
                        Get.to(() => const FocusModeScreen());
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          gradient: primaryGradient,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fullscreen_rounded, color: white, size: 16.sp),
                            SizedBox(width: 4.w),
                            CustomAppText(
                              text: "Focus",
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Transform.scale(
                      scale: 0.85,
                      child: Switch.adaptive(
                        value: timerCtrl.isFocusMode,
                        activeColor: primaryColor,
                        onChanged: (val) {
                          timerCtrl.toggleFocusMode(val);
                          if (val) {
                            Get.to(() => const FocusModeScreen());
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Large Circular Timer Display
              Container(
                width: 230.w,
                height: 230.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: timerCtrl.isPaused
                      ? const LinearGradient(colors: [nonBillableColor, Colors.orangeAccent])
                      : (timerCtrl.isRunning ? timerGradient : primaryGradient),
                  boxShadow: [
                    BoxShadow(
                      color: (timerCtrl.isPaused ? nonBillableColor : primaryColor).withValues(alpha: 0.35),
                      blurRadius: 20.r,
                      spreadRadius: 2.r,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: cardBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomAppText(
                          text: timerCtrl.isPaused ? "BREAK" : (timerCtrl.isRunning ? "WORKING" : "READY"),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: timerCtrl.isPaused ? nonBillableColor : (timerCtrl.isRunning ? primaryColor : textMuted),
                        ),
                        SizedBox(height: 8.h),
                        CustomAppText(
                          text: timerCtrl.formattedElapsedTime,
                          fontSize: 34.sp,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                        SizedBox(height: 8.h),
                        CustomAppText(
                          text: "Earnings: \$${timerCtrl.liveEarnings.toStringAsFixed(2)}",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: billableColor,
                        ),
                        if (timerCtrl.breakSeconds > 0) ...[
                          SizedBox(height: 4.h),
                          CustomAppText(
                            text: "Break: ${timerCtrl.formattedBreakTime}",
                            fontSize: 11.sp,
                            color: textMuted,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Control Action Buttons (Start, Pause/Resume, Stop)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!timerCtrl.isRunning) ...[
                    // START BUTTON
                    CustomOpacityWidget(
                      onTap: timerCtrl.startTimer,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 16.h),
                        decoration: BoxDecoration(
                          gradient: primaryGradient,
                          borderRadius: BorderRadius.circular(30.r),
                          boxShadow: [
                            BoxShadow(color: primaryColor.withValues(alpha: 0.35), blurRadius: 12.r, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.play_arrow_rounded, color: white, size: 28.sp),
                            SizedBox(width: 8.w),
                            CustomAppText(text: AppStrings.startWork, fontSize: 16.sp, fontWeight: FontWeight.bold, color: white),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // PAUSE / RESUME BUTTON
                    CustomOpacityWidget(
                      onTap: timerCtrl.isPaused ? timerCtrl.startTimer : timerCtrl.pauseTimer,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: timerCtrl.isPaused ? billableColor : nonBillableColor,
                          borderRadius: BorderRadius.circular(30.r),
                          boxShadow: [
                            BoxShadow(
                              color: (timerCtrl.isPaused ? billableColor : nonBillableColor).withValues(alpha: 0.3),
                              blurRadius: 10.r,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              timerCtrl.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                              color: white,
                              size: 22.sp,
                            ),
                            SizedBox(width: 6.w),
                            CustomAppText(
                              text: timerCtrl.isPaused ? "Resume" : "Pause",
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: white,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: 16.w),

                    // STOP & SAVE BUTTON
                    CustomOpacityWidget(
                      onTap: timerCtrl.stopAndSaveTimer,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: dangerColor,
                          borderRadius: BorderRadius.circular(30.r),
                          boxShadow: [
                            BoxShadow(color: dangerColor.withValues(alpha: 0.3), blurRadius: 10.r, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.stop_rounded, color: white, size: 22.sp),
                            SizedBox(width: 6.w),
                            CustomAppText(
                              text: "Finish Shift",
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: 32.h),

              // Additional Settings Card (Hourly rate, billable toggle, notes)
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(color: shadowColor, blurRadius: 10.r, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomAppText(text: AppStrings.currentRate, fontSize: 14.sp, color: textSecondary),
                        CustomAppText(
                          text: "\$${timerCtrl.currentHourlyRate.toStringAsFixed(0)} / hr",
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ],
                    ),
                    Divider(height: 24.h, color: dividerColor),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomAppText(text: AppStrings.billableStatus, fontSize: 14.sp, color: textSecondary),
                        Switch.adaptive(
                          value: timerCtrl.isBillable,
                          activeTrackColor: billableColor,
                          onChanged: timerCtrl.toggleBillable,
                        ),
                      ],
                    ),
                    Divider(height: 24.h, color: dividerColor),
                    TextField(
                      controller: _notesCtrl,
                      onChanged: timerCtrl.setNotes,
                      style: TextStyle(fontSize: 14.sp, color: textPrimary),
                      decoration: InputDecoration(
                        hintText: "Add notes for this timer shift...",
                        hintStyle: TextStyle(fontSize: 13.sp, color: textMuted),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),
            ],
          );
        },
      ),
    );
  }
}
