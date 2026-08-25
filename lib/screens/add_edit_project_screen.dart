import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hour_tracker/common_widgets/app_text.dart';
import 'package:hour_tracker/common_widgets/custom_opacity.dart';
import 'package:hour_tracker/controllers/project_controller.dart';
import 'package:hour_tracker/for_ads/ads/ads_variable.dart';
import 'package:hour_tracker/models/project_model.dart';
import 'package:hour_tracker/utils/app_colors.dart';
import 'package:hour_tracker/utils/app_strings.dart';
import 'package:hour_tracker/utils/app_show_toast.dart';

class AddEditProjectScreen extends StatefulWidget {
  final ProjectModel? existingProject;

  const AddEditProjectScreen({super.key, this.existingProject});

  @override
  State<AddEditProjectScreen> createState() => _AddEditProjectScreenState();
}

class _AddEditProjectScreenState extends State<AddEditProjectScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _clientCtrl = TextEditingController();
  final TextEditingController _rateCtrl = TextEditingController();
  final TextEditingController _targetCtrl = TextEditingController();

  Color _selectedColor = primaryColor;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProject;
    if (p != null) {
      _nameCtrl.text = p.name;
      _clientCtrl.text = p.clientName;
      _rateCtrl.text = p.hourlyRate.toStringAsFixed(0);
      _targetCtrl.text = p.targetHours.toStringAsFixed(0);
      try {
        _selectedColor = Color(int.parse(p.colorHex));
      } catch (_) {
        _selectedColor = primaryColor;
      }
    } else {
      _rateCtrl.text = '40';
      _targetCtrl.text = '40';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _clientCtrl.dispose();
    _rateCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) {
        Color tempColor = _selectedColor;
        return AlertDialog(
          title: const CustomAppText(text: "Select Project Color", color: textPrimary),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: tempColor,
              onColorChanged: (color) => tempColor = color,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const CustomAppText(text: "Cancel", color: textSecondary),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _selectedColor = tempColor);
                Get.back();
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const CustomAppText(text: "Select", color: white),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProject() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      showToast("Please enter project name");
      return;
    }

    final rate = double.tryParse(_rateCtrl.text.trim()) ?? 0.0;
    final target = double.tryParse(_targetCtrl.text.trim()) ?? 0.0;
    final colorHex = '0x${_selectedColor.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';

    final project = ProjectModel(
      id: widget.existingProject?.id,
      name: name,
      clientName: _clientCtrl.text.trim(),
      hourlyRate: rate,
      colorHex: colorHex,
      targetHours: target,
    );

    final projCtrl = Get.find<ProjectController>();
    bool success;
    if (widget.existingProject == null) {
      success = await projCtrl.addProject(project);
    } else {
      success = await projCtrl.updateProject(project);
    }

    if (success) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingProject != null;

    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        backgroundColor: cardBgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20.sp),
          onPressed: () {
            AdsVariable.onShowAds(
              context,
              onComplete: () {
                Get.back();
              },
            );
          },
        ),
        title: CustomAppText(
          text: isEditing ? AppStrings.editProject : AppStrings.addProject,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
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
                  CustomAppText(text: AppStrings.projectName, fontSize: 13.sp, color: textSecondary),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _nameCtrl,
                    style: TextStyle(fontSize: 15.sp, color: textPrimary),
                    decoration: InputDecoration(
                      hintText: "e.g. Mobile App Redesign",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  CustomAppText(text: AppStrings.clientName, fontSize: 13.sp, color: textSecondary),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _clientCtrl,
                    style: TextStyle(fontSize: 15.sp, color: textPrimary),
                    decoration: InputDecoration(
                      hintText: "e.g. Acme Corp",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomAppText(text: AppStrings.hourlyRate, fontSize: 13.sp, color: textSecondary),
                            SizedBox(height: 8.h),
                            TextField(
                              controller: _rateCtrl,
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 15.sp, color: textPrimary),
                              decoration: InputDecoration(
                                prefixText: "\$ ",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomAppText(text: "Target Hours", fontSize: 13.sp, color: textSecondary),
                            SizedBox(height: 8.h),
                            TextField(
                              controller: _targetCtrl,
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 15.sp, color: textPrimary),
                              decoration: InputDecoration(
                                suffixText: "hrs",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Color Picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomAppText(text: "Project Color Badge", fontSize: 14.sp, color: textPrimary, fontWeight: FontWeight.w600),
                      CustomOpacityWidget(
                        onTap: _pickColor,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: _selectedColor,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.palette_rounded, color: white, size: 16.sp),
                              SizedBox(width: 6.w),
                              CustomAppText(text: "Color", fontSize: 13.sp, color: white, fontWeight: FontWeight.bold),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            CustomOpacityWidget(
              onTap: _saveProject,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  gradient: primaryGradient,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 12.r, offset: const Offset(0, 6)),
                  ],
                ),
                child: Center(
                  child: CustomAppText(
                    text: isEditing ? "Update Project" : "Create Project",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
