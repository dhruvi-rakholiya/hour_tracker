import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hour_tracker/common_widgets/app_text.dart';
import 'package:hour_tracker/common_widgets/custom_opacity.dart';
import 'package:hour_tracker/common_widgets/delete_confirmation_dialog.dart';
import 'package:hour_tracker/controllers/project_controller.dart';
import 'package:hour_tracker/controllers/settings_controller.dart';
import 'package:hour_tracker/screens/add_edit_project_screen.dart';
import 'package:hour_tracker/utils/app_colors.dart';
import 'package:hour_tracker/utils/app_strings.dart';
import 'package:hour_tracker/utils/app_premium_helper.dart';
import 'package:hour_tracker/for_ads/ads/ads_variable.dart';

class ProjectsSettingsTab extends StatefulWidget {
  const ProjectsSettingsTab({super.key});

  @override
  State<ProjectsSettingsTab> createState() => _ProjectsSettingsTabState();
}

class _ProjectsSettingsTabState extends State<ProjectsSettingsTab> {
  final TextEditingController _dailyTargetCtrl = TextEditingController();
  final TextEditingController _overtimeThreshCtrl = TextEditingController();
  final TextEditingController _overtimeMultCtrl = TextEditingController();
  final TextEditingController _taskInputCtrl = TextEditingController();
  bool _enableNotifications = true;

  @override
  void initState() {
    super.initState();
    final settings = Get.find<SettingsController>().settings;
    _dailyTargetCtrl.text = settings.dailyTargetHours.toStringAsFixed(0);
    _overtimeThreshCtrl.text = settings.overtimeThresholdDaily.toStringAsFixed(
      0,
    );
    _overtimeMultCtrl.text = settings.overtimeMultiplier.toStringAsFixed(1);
    _enableNotifications = settings.enableNotifications;
  }

  @override
  void dispose() {
    _dailyTargetCtrl.dispose();
    _overtimeThreshCtrl.dispose();
    _overtimeMultCtrl.dispose();
    _taskInputCtrl.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final settingsCtrl = Get.find<SettingsController>();
    final daily = double.tryParse(_dailyTargetCtrl.text.trim()) ?? 8.0;
    final thresh = double.tryParse(_overtimeThreshCtrl.text.trim()) ?? 8.0;
    final mult = AdsVariable.isPurchase
        ? (double.tryParse(_overtimeMultCtrl.text.trim()) ?? 1.5)
        : 1.0;

    final newSettings = settingsCtrl.settings.copyWith(
      dailyTargetHours: daily,
      overtimeThresholdDaily: thresh,
      overtimeMultiplier: mult,
      enableNotifications: _enableNotifications,
    );

    settingsCtrl.updateSettings(newSettings);
  }

  void _showAddTaskDialog(
    BuildContext context,
    ProjectController projCtrl,
    int projectId,
  ) {
    _taskInputCtrl.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: const CustomAppText(
            text: "Add Task / Sub-item",
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          content: TextField(
            controller: _taskInputCtrl,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Task name (e.g., Code Review)",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const CustomAppText(text: "Cancel", color: textSecondary),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _taskInputCtrl.text.trim();
                if (name.isNotEmpty) {
                  projCtrl.addTask(projectId, name);
                  Get.back();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const CustomAppText(
                text: "Add",
                color: white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Add Project Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomAppText(
                text: "Projects & Options",
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
              CustomOpacityWidget(
                onTap: () {
                  if (AppPremiumHelper.checkProjectLimitAndPrompt(context)) {
                    Get.to(() => const AddEditProjectScreen());
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_rounded, color: white, size: 16.sp),
                      SizedBox(width: 4.w),
                      CustomAppText(
                        text: "New Project",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // // PRO Highlight Banner Card
          // CustomOpacityWidget(
          //   onTap: () => Get.to(() => const PremiumScreen()),
          //   child: Container(
          //     padding: EdgeInsets.all(16.r),
          //     decoration: BoxDecoration(
          //       gradient: goldGradient,
          //       borderRadius: BorderRadius.circular(20.r),
          //       boxShadow: [
          //         BoxShadow(
          //           color: const Color(0xFFFB8500).withValues(alpha: 0.35),
          //           blurRadius: 14.r,
          //           offset: const Offset(0, 4),
          //         ),
          //       ],
          //     ),
          //     child: Row(
          //       children: [
          //         Container(
          //           padding: EdgeInsets.all(10.r),
          //           decoration: BoxDecoration(
          //             color: white.withValues(alpha: 0.2),
          //             shape: BoxShape.circle,
          //           ),
          //           child: Icon(
          //             Icons.workspace_premium_rounded,
          //             color: white,
          //             size: 26.sp,
          //           ),
          //         ),
          //         SizedBox(width: 12.w),
          //         Expanded(
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               CustomAppText(
          //                 text: "Upgrade to Hour Tracker PRO",
          //                 fontSize: 14.sp,
          //                 fontWeight: FontWeight.bold,
          //                 color: white,
          //               ),
          //               SizedBox(height: 2.h),
          //               CustomAppText(
          //                 text: "Ad-Free, Unlimited Projects & PDF Exports",
          //                 fontSize: 11.sp,
          //                 color: white.withValues(alpha: 0.9),
          //               ),
          //             ],
          //           ),
          //         ),
          //         Icon(
          //           Icons.arrow_forward_ios_rounded,
          //           color: white,
          //           size: 14.sp,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          //
          // SizedBox(height: 16.h),

          // Projects List Section
          GetBuilder<ProjectController>(
            builder: (projCtrl) {
              if (projCtrl.projects.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_open_rounded,
                        size: 40.sp,
                        color: textMuted,
                      ),
                      SizedBox(height: 8.h),
                      CustomAppText(
                        text: "No projects created yet",
                        fontSize: 14.sp,
                        color: textSecondary,
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: projCtrl.projects.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final p = projCtrl.projects[index];
                  final tasks = projCtrl.projectTasks[p.id] ?? [];

                  return Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: 8.r,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 14.w,
                              height: 14.w,
                              decoration: BoxDecoration(
                                color: parseColorHex(p.colorHex),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomAppText(
                                    text: p.name,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                  if (p.clientName.isNotEmpty) ...[
                                    SizedBox(height: 2.h),
                                    CustomAppText(
                                      text: "Client: ${p.clientName}",
                                      fontSize: 12.sp,
                                      color: textSecondary,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            CustomAppText(
                              text: "\$${p.hourlyRate.toStringAsFixed(0)}/hr",
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: billableColor,
                            ),
                            SizedBox(width: 8.w),
                            CustomOpacityWidget(
                              onTap: () => Get.to(
                                () => AddEditProjectScreen(existingProject: p),
                              ),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 18.sp,
                                color: primaryColor,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            CustomOpacityWidget(
                              onTap: () {
                                showDeleteConfirmationDialog(
                                  context: context,
                                  title: "Delete Project",
                                  message: "Are you sure you want to delete project '${p.name}'? All tasks associated with this project will also be removed.",
                                  onDelete: () => projCtrl.deleteProject(p.id!),
                                );
                              },
                              child: Icon(
                                Icons.delete_outline_rounded,
                                size: 18.sp,
                                color: dangerColor,
                              ),
                            ),
                          ],
                        ),

                        // Sub-tasks section with Add Task Action
                        Divider(height: 20.h, color: dividerColor),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomAppText(
                              text: "Tasks / Scope Items:",
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: textSecondary,
                            ),
                            CustomOpacityWidget(
                              onTap: () =>
                                  _showAddTaskDialog(context, projCtrl, p.id!),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add_circle_outline_rounded,
                                    size: 14.sp,
                                    color: primaryColor,
                                  ),
                                  SizedBox(width: 4.w),
                                  CustomAppText(
                                    text: "Add Task",
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        if (tasks.isEmpty)
                          CustomAppText(
                            text: "No tasks added yet",
                            fontSize: 11.sp,
                            color: textMuted,
                          )
                        else
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 6.h,
                            children: tasks.map((t) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomAppText(
                                      text: t.name,
                                      fontSize: 11.sp,
                                      color: textPrimary,
                                    ),
                                    SizedBox(width: 4.w),
                                    CustomOpacityWidget(
                                      onTap: () {
                                        showDeleteConfirmationDialog(
                                          context: context,
                                          title: "Remove Task",
                                          message: "Are you sure you want to remove task '${t.name}' from project '${p.name}'?",
                                          onDelete: () => projCtrl.deleteTask(t.id!, p.id!),
                                        );
                                      },
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 14.sp,
                                        color: textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          SizedBox(height: 24.h),

          // User Preferences & Targets Card
          GetBuilder<SettingsController>(
            builder: (settingsCtrl) {
              return Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 10.r,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppText(
                      text: "Target & Overtime Configuration",
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                    SizedBox(height: 16.h),

                    // Daily Target
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomAppText(
                          text: AppStrings.dailyTarget,
                          fontSize: 13.sp,
                          color: textSecondary,
                        ),
                        SizedBox(
                          width: 80.w,
                          child: TextField(
                            controller: _dailyTargetCtrl,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    // Overtime Threshold
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomAppText(
                          text: AppStrings.overtimeThreshold,
                          fontSize: 13.sp,
                          color: textSecondary,
                        ),
                        SizedBox(
                          width: 80.w,
                          child: TextField(
                            controller: _overtimeThreshCtrl,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    // Overtime Multiplier
                    CustomOpacityWidget(
                      onTap: () {
                        if (!AdsVariable.isPurchase) {
                          AppPremiumHelper.showOvertimeLockedBottomSheet(context);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CustomAppText(
                                text: AppStrings.overtimeMultiplier,
                                fontSize: 13.sp,
                                color: textSecondary,
                              ),
                              if (!AdsVariable.isPurchase) ...[
                                SizedBox(width: 6.w),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    gradient: primaryGradient,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.lock_rounded, size: 10.sp, color: white),
                                      SizedBox(width: 2.w),
                                      CustomAppText(
                                        text: "PRO",
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.bold,
                                        color: white,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(
                            width: 80.w,
                            child: TextField(
                              controller: _overtimeMultCtrl,
                              enabled: AdsVariable.isPurchase,
                              readOnly: !AdsVariable.isPurchase,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AdsVariable.isPurchase ? textPrimary : textMuted,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                suffixIcon: !AdsVariable.isPurchase
                                    ? Icon(Icons.lock_outline_rounded, size: 14.sp, color: primaryColor)
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Active Timer Notification Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomAppText(
                                text: "Active Timer Notifications",
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                              SizedBox(height: 2.h),
                              CustomAppText(
                                text:
                                    "Show status bar notification when timer is running",
                                fontSize: 11.sp,
                                color: textMuted,
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _enableNotifications,
                          activeColor: primaryColor,
                          onChanged: (val) {
                            setState(() {
                              _enableNotifications = val;
                            });
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    CustomOpacityWidget(
                      onTap: _saveSettings,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: CustomAppText(
                            text: "Save Preferences",
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: 130.h),
        ],
      ),
    );
  }
}
