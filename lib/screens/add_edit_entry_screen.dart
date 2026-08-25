import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hour_tracker/for_ads/ads/ads_variable.dart';
import 'package:intl/intl.dart';
import 'package:hour_tracker/common_widgets/app_text.dart';
import 'package:hour_tracker/common_widgets/custom_opacity.dart';
import 'package:hour_tracker/controllers/project_controller.dart';
import 'package:hour_tracker/controllers/time_entry_controller.dart';
import 'package:hour_tracker/models/project_model.dart';
import 'package:hour_tracker/models/time_entry_model.dart';
import 'package:hour_tracker/utils/app_colors.dart';
import 'package:hour_tracker/utils/app_strings.dart';
import 'package:hour_tracker/utils/app_show_toast.dart';

class AddEditEntryScreen extends StatefulWidget {
  final TimeEntryModel? existingEntry;

  const AddEditEntryScreen({super.key, this.existingEntry});

  @override
  State<AddEditEntryScreen> createState() => _AddEditEntryScreenState();
}

class _AddEditEntryScreenState extends State<AddEditEntryScreen> {
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _breakMinutes;
  late double _hourlyRate;
  late bool _isBillable;

  ProjectModel? _selectedProject;
  final TextEditingController _taskCtrl = TextEditingController();
  final TextEditingController _rateCtrl = TextEditingController();
  final TextEditingController _breakCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final entry = widget.existingEntry;

    if (entry != null) {
      _selectedDate = entry.startTime;
      _startTime = TimeOfDay.fromDateTime(entry.startTime);
      _endTime = TimeOfDay.fromDateTime(entry.endTime);
      _breakMinutes = entry.breakMinutes;
      _hourlyRate = entry.hourlyRate;
      _isBillable = entry.isBillable;
      _taskCtrl.text = entry.taskName;
      _notesCtrl.text = entry.notes;
      _rateCtrl.text = _hourlyRate.toStringAsFixed(0);
      _breakCtrl.text = _breakMinutes.toString();
    } else {
      _selectedDate = DateTime.now();
      _startTime = TimeOfDay(
        hour: DateTime.now().hour - 1,
        minute: DateTime.now().minute,
      );
      _endTime = TimeOfDay.now();
      _breakMinutes = 0;
      _hourlyRate = 35.0;
      _isBillable = true;
      _rateCtrl.text = '35';
      _breakCtrl.text = '0';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final projCtrl = Get.find<ProjectController>();
      if (projCtrl.projects.isNotEmpty) {
        if (entry != null && entry.projectId != null) {
          _selectedProject = projCtrl.projects.firstWhereOrNull(
            (p) => p.id == entry.projectId,
          );
        }
        _selectedProject ??= projCtrl.projects.first;
        if (entry == null) {
          _hourlyRate = _selectedProject!.hourlyRate;
          _rateCtrl.text = _hourlyRate.toStringAsFixed(0);
        }
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _taskCtrl.dispose();
    _rateCtrl.dispose();
    _breakCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveEntry() async {
    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime) ||
        endDateTime.isAtSameMomentAs(startDateTime)) {
      showToast("End time must be after start time");
      return;
    }

    final durationMins = endDateTime.difference(startDateTime).inMinutes;
    final breakMins = int.tryParse(_breakCtrl.text.trim()) ?? 0;
    final rate = double.tryParse(_rateCtrl.text.trim()) ?? 0.0;

    if (breakMins >= durationMins) {
      showToast("Break time cannot exceed total shift duration");
      return;
    }

    final entry = TimeEntryModel(
      id: widget.existingEntry?.id,
      projectId: _selectedProject?.id,
      projectName: _selectedProject?.name ?? 'General Work',
      projectColor: _selectedProject?.colorHex ?? '0xFF6C5CE7',
      taskName: _taskCtrl.text.trim(),
      startTime: startDateTime,
      endTime: endDateTime,
      durationMinutes: durationMins,
      breakMinutes: breakMins,
      hourlyRate: rate,
      isBillable: _isBillable,
      notes: _notesCtrl.text.trim(),
    );

    final entryCtrl = Get.find<TimeEntryController>();
    bool success;
    if (widget.existingEntry == null) {
      success = await entryCtrl.addTimeEntry(entry);
    } else {
      success = await entryCtrl.updateTimeEntry(entry);
    }

    if (success) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingEntry != null;

    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        backgroundColor: cardBgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textPrimary,
            size: 20.sp,
          ),
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
          text: isEditing ? AppStrings.editTimeEntry : AppStrings.addTimeEntry,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Selector Card
            GetBuilder<ProjectController>(
              builder: (projCtrl) {
                if (projCtrl.projects.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 24.sp,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: CustomAppText(
                            text:
                                "No projects found. Please create a project first.",
                            fontSize: 13.sp,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

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
                        text: AppStrings.projectName,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                      SizedBox(height: 8.h),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<ProjectModel>(
                          isExpanded: true,
                          value: _selectedProject,
                          hint: const CustomAppText(
                            text: AppStrings.noProjectSelected,
                            color: textMuted,
                          ),
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
                          onChanged: (p) {
                            if (p != null) {
                              setState(() {
                                _selectedProject = p;
                                _rateCtrl.text = p.hourlyRate.toStringAsFixed(
                                  0,
                                );
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 16.h),

            // Date & Time Picker Card
            Container(
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
                children: [
                  // Date selection
                  CustomOpacityWidget(
                    onTap: _pickDate,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color: primaryColor,
                              size: 20.sp,
                            ),
                            SizedBox(width: 10.w),
                            CustomAppText(
                              text: AppStrings.date,
                              fontSize: 14.sp,
                              color: textSecondary,
                            ),
                          ],
                        ),
                        CustomAppText(
                          text: DateFormat(
                            'EEE, MMM dd, yyyy',
                          ).format(_selectedDate),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 24.h, color: dividerColor),

                  // Start and End Time Row
                  Row(
                    children: [
                      Expanded(
                        child: CustomOpacityWidget(
                          onTap: () => _pickTime(true),
                          child: Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomAppText(
                                  text: AppStrings.startTime,
                                  fontSize: 12.sp,
                                  color: textSecondary,
                                ),
                                SizedBox(height: 4.h),
                                CustomAppText(
                                  text: _startTime.format(context),
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 12.w),

                      Expanded(
                        child: CustomOpacityWidget(
                          onTap: () => _pickTime(false),
                          child: Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomAppText(
                                  text: AppStrings.endTime,
                                  fontSize: 12.sp,
                                  color: textSecondary,
                                ),
                                SizedBox(height: 4.h),
                                CustomAppText(
                                  text: _endTime.format(context),
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Overtime Indicator Info Card
            Builder(
              builder: (context) {
                final startDT = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _startTime.hour,
                  _startTime.minute,
                );
                final endDT = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _endTime.hour,
                  _endTime.minute,
                );
                final durMins = endDT.difference(startDT).inMinutes;
                final breakMins = int.tryParse(_breakCtrl.text.trim()) ?? 0;
                final netMins = durMins - breakMins;

                if (Get.isRegistered<TimeEntryController>() && netMins > 0) {
                  final entryCtrl = Get.find<TimeEntryController>();
                  final dailyGoal = entryCtrl.getDailyTargetHours();
                  final multiplier = entryCtrl.getOvertimeMultiplier();
                  final existingRegMins = entryCtrl
                      .getEntriesForDay(_selectedDate)
                      .where(
                        (e) =>
                            !e.isOvertime && e.id != widget.existingEntry?.id,
                      )
                      .fold<int>(0, (sum, e) => sum + e.netWorkMinutes);

                  final remainingRegMins = ((dailyGoal * 60) - existingRegMins)
                      .clamp(0, (dailyGoal * 60).toInt());

                  if (netMins > remainingRegMins) {
                    final overMins = netMins - remainingRegMins;
                    final overHoursStr = (overMins / 60.0).toStringAsFixed(1);
                    return Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            color: Colors.amber[800],
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: CustomAppText(
                              text: remainingRegMins <= 0
                                  ? "Entire shift will be logged as Overtime (${multiplier}x rate)."
                                  : "Shift exceeds daily goal (${dailyGoal.toStringAsFixed(0)}h). $overHoursStr hrs will auto-split into a separate Overtime log (${multiplier}x rate).",
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber[900] ?? Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),

            // Financial & Break Details
            Container(
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
                children: [
                  // Hourly rate
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomAppText(
                        text: AppStrings.hourlyRate,
                        fontSize: 14.sp,
                        color: textSecondary,
                      ),
                      SizedBox(
                        width: 100.w,
                        child: TextField(
                          controller: _rateCtrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 8.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 14.h),

                  // Break duration
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomAppText(
                        text: AppStrings.breakTime,
                        fontSize: 14.sp,
                        color: textSecondary,
                      ),
                      SizedBox(
                        width: 100.w,
                        child: TextField(
                          controller: _breakCtrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 8.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Divider(height: 24.h, color: dividerColor),

                  // Billable toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isBillable
                                ? Icons.monetization_on_rounded
                                : Icons.money_off_rounded,
                            color: _isBillable
                                ? billableColor
                                : nonBillableColor,
                            size: 22.sp,
                          ),
                          SizedBox(width: 8.w),
                          CustomAppText(
                            text: AppStrings.billableStatus,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: _isBillable,
                        activeTrackColor: billableColor,
                        onChanged: (val) => setState(() => _isBillable = val),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Notes Card
            Container(
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
                    text: AppStrings.notes,
                    fontSize: 13.sp,
                    color: textSecondary,
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _notesCtrl,
                    maxLines: 3,
                    style: TextStyle(fontSize: 14.sp, color: textPrimary),
                    decoration: InputDecoration(
                      hintText: "What did you work on?",
                      hintStyle: TextStyle(fontSize: 14.sp, color: textMuted),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Save Button using CustomOpacityWidget
            CustomOpacityWidget(
              onTap: _saveEntry,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  gradient: primaryGradient,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12.r,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: CustomAppText(
                    text: isEditing ? "Update Shift Log" : "Save Shift Log",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}
