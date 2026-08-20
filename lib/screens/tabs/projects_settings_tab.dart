import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hour_tracker/common_widgets/app_text.dart';
import 'package:hour_tracker/common_widgets/custom_opacity.dart';
import 'package:hour_tracker/controllers/project_controller.dart';
import 'package:hour_tracker/controllers/settings_controller.dart';
import 'package:hour_tracker/screens/add_edit_project_screen.dart';
import 'package:hour_tracker/utils/app_colors.dart';
import 'package:hour_tracker/utils/app_strings.dart';


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

  @override
  void initState() {
    super.initState();
    final settings = Get.find<SettingsController>().settings;
    _dailyTargetCtrl.text = settings.dailyTargetHours.toStringAsFixed(0);
    _overtimeThreshCtrl.text = settings.overtimeThresholdDaily.toStringAsFixed(0);
    _overtimeMultCtrl.text = settings.overtimeMultiplier.toStringAsFixed(1);
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
    final mult = double.tryParse(_overtimeMultCtrl.text.trim()) ?? 1.5;

    final newSettings = settingsCtrl.settings.copyWith(
      dailyTargetHours: daily,
      overtimeThresholdDaily: thresh,
      overtimeMultiplier: mult,
    );

    settingsCtrl.updateSettings(newSettings);
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
                onTap: () => Get.to(() => const AddEditProjectScreen()),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_rounded, color: white, size: 16.sp),
                      SizedBox(width: 4.w),
                      CustomAppText(text: "New Project", fontSize: 12.sp, fontWeight: FontWeight.bold, color: white),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

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
                      Icon(Icons.folder_open_rounded, size: 40.sp, color: textMuted),
                      SizedBox(height: 8.h),
                      CustomAppText(text: "No projects created yet", fontSize: 14.sp, color: textSecondary),
                    ],
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: projCtrl.projects.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final p = projCtrl.projects[index];
                  final tasks = projCtrl.projectTasks[p.id] ?? [];

                  return Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(color: shadowColor, blurRadius: 8.r, offset: const Offset(0, 3)),
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
                                color: Color(int.parse(p.colorHex)),
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
                              onTap: () => Get.to(() => AddEditProjectScreen(existingProject: p)),
                              child: Icon(Icons.edit_outlined, size: 18.sp, color: primaryColor),
                            ),
                            SizedBox(width: 8.w),
                            CustomOpacityWidget(
                              onTap: () => projCtrl.deleteProject(p.id!),
                              child: Icon(Icons.delete_outline_rounded, size: 18.sp, color: dangerColor),
                            ),
                          ],
                        ),

                        // Sub-tasks section
                        if (tasks.isNotEmpty) ...[
                          Divider(height: 20.h, color: dividerColor),
                          CustomAppText(text: "Tasks / Items:", fontSize: 12.sp, fontWeight: FontWeight.bold, color: textSecondary),
                          SizedBox(height: 6.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 6.h,
                            children: tasks.map((t) {
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomAppText(text: t.name, fontSize: 11.sp, color: textPrimary),
                                    SizedBox(width: 4.w),
                                    CustomOpacityWidget(
                                      onTap: () => projCtrl.deleteTask(t.id!, p.id!),
                                      child: Icon(Icons.close_rounded, size: 14.sp, color: textMuted),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
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
                    BoxShadow(color: shadowColor, blurRadius: 10.r, offset: const Offset(0, 4)),
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
                        CustomAppText(text: AppStrings.dailyTarget, fontSize: 13.sp, color: textSecondary),
                        SizedBox(
                          width: 80.w,
                          child: TextField(
                            controller: _dailyTargetCtrl,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: textPrimary),
                            decoration: InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
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
                        CustomAppText(text: AppStrings.overtimeThreshold, fontSize: 13.sp, color: textSecondary),
                        SizedBox(
                          width: 80.w,
                          child: TextField(
                            controller: _overtimeThreshCtrl,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: textPrimary),
                            decoration: InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    // Overtime Multiplier
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomAppText(text: AppStrings.overtimeMultiplier, fontSize: 13.sp, color: textSecondary),
                        SizedBox(
                          width: 80.w,
                          child: TextField(
                            controller: _overtimeMultCtrl,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: textPrimary),
                            decoration: InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                            ),
                          ),
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
                          child: CustomAppText(text: "Save Preferences", fontSize: 14.sp, fontWeight: FontWeight.bold, color: white),
                        ),

                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
