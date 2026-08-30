import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hour_tracker/common_widgets/app_text.dart';
import 'package:hour_tracker/common_widgets/custom_opacity.dart';
import 'package:hour_tracker/common_widgets/delete_confirmation_dialog.dart';
import 'package:hour_tracker/controllers/time_entry_controller.dart';

import 'package:hour_tracker/screens/add_edit_entry_screen.dart';
import 'package:hour_tracker/utils/app_colors.dart';
import 'package:hour_tracker/utils/app_formatters.dart';
import 'package:hour_tracker/utils/app_strings.dart';

class LogsCalendarTab extends StatefulWidget {
  const LogsCalendarTab({super.key});

  @override
  State<LogsCalendarTab> createState() => _LogsCalendarTabState();
}

class _LogsCalendarTabState extends State<LogsCalendarTab> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TimeEntryController>(
      builder: (entryCtrl) {
        final selectedEntries = entryCtrl.filteredEntries;
        final dayHours = selectedEntries.fold(0.0, (sum, e) => sum + e.netWorkHours);
        final dayEarnings = selectedEntries.fold(0.0, (sum, e) => sum + e.totalEarnings);

        return Scaffold(
          backgroundColor: appBgColor,
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              children: [
                // Calendar Card
                Container(
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(color: shadowColor, blurRadius: 10.r, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: TableCalendar(
                    firstDay: DateTime(2020),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(entryCtrl.selectedDate, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() => _focusedDay = focusedDay);
                      entryCtrl.filterEntriesForSelectedDate(selectedDay);
                    },
                    onFormatChanged: (format) {
                      setState(() => _calendarFormat = format);
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: const TextStyle(color: white, fontWeight: FontWeight.bold),
                      todayTextStyle: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonDecoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      formatButtonTextStyle: TextStyle(color: primaryColor, fontSize: 12.sp, fontWeight: FontWeight.bold),
                      titleTextStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: textPrimary),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Selected Day Summary Card
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    gradient: primaryGradient,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(color: primaryColor.withValues(alpha: 0.25), blurRadius: 10.r, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomAppText(
                            text: DateFormat('EEEE, MMM dd').format(entryCtrl.selectedDate),
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: white,
                          ),
                          SizedBox(height: 4.h),
                          CustomAppText(
                            text: "${selectedEntries.length} Work Shift Logs",
                            fontSize: 12.sp,
                            color: white.withValues(alpha: 0.8),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CustomAppText(
                            text: "\$${dayEarnings.toStringAsFixed(2)}",
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                          SizedBox(height: 4.h),
                          CustomAppText(
                            text: "${formatHoursToDuration(dayHours, short: false)} worked",
                            fontSize: 12.sp,
                            color: white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Work Logs List
                if (selectedEntries.isEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(30.r),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.event_available_rounded, size: 48.sp, color: textMuted),
                        SizedBox(height: 10.h),
                        CustomAppText(text: "No work logs recorded for this day", fontSize: 14.sp, color: textSecondary),
                        SizedBox(height: 16.h),
                        CustomOpacityWidget(
                          onTap: () => Get.to(() => const AddEditEntryScreen()),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: const CustomAppText(text: AppStrings.addTimeEntry, color: white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: selectedEntries.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final entry = selectedEntries[index];
                      final DateFormat tf = DateFormat('hh:mm a');

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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 12.w,
                                      height: 12.w,
                                      decoration: BoxDecoration(
                                        color: parseColorHex(entry.projectColor),
                                        shape: BoxShape.circle,
                                      ),
                                    ),

                                    SizedBox(width: 8.w),
                                    CustomAppText(
                                      text: entry.projectName,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    // Edit Action
                                    CustomOpacityWidget(
                                      onTap: () => Get.to(() => AddEditEntryScreen(existingEntry: entry)),
                                      child: Icon(Icons.edit_outlined, size: 18.sp, color: primaryColor),
                                    ),
                                    SizedBox(width: 12.w),
                                    // Delete Action
                                    CustomOpacityWidget(
                                      onTap: () {
                                        showDeleteConfirmationDialog(
                                          context: context,
                                          title: "Delete Shift Log",
                                          message: "Are you sure you want to delete this shift log for ${entry.projectName}? This action cannot be undone.",
                                          onDelete: () => entryCtrl.deleteTimeEntry(entry.id!),
                                        );
                                      },
                                      child: Icon(Icons.delete_outline_rounded, size: 18.sp, color: dangerColor),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: 10.h),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomAppText(
                                  text: "${tf.format(entry.startTime)} - ${tf.format(entry.endTime)}",
                                  fontSize: 13.sp,
                                  color: textSecondary,
                                ),
                                Row(
                                  children: [
                                    if (entry.isOvertime) ...[
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6.r),
                                          border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.bolt_rounded, size: 12.sp, color: Colors.amber[800]),
                                            SizedBox(width: 2.w),
                                            CustomAppText(
                                              text: "Overtime (${entry.overtimeMultiplier}x)",
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber[900] ?? Colors.amber,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                    ],
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: (entry.isBillable ? billableColor : nonBillableColor).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                      child: CustomAppText(
                                        text: entry.isBillable ? "Billable" : "Non-Billable",
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.bold,
                                        color: entry.isBillable ? billableColor : nonBillableColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            if (entry.notes.isNotEmpty) ...[
                              SizedBox(height: 8.h),
                              CustomAppText(
                                text: entry.notes,
                                fontSize: 12.sp,
                                color: textMuted,
                                maxLines: 2,
                              ),
                            ],

                            Divider(height: 20.h, color: dividerColor),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomAppText(
                                  text: "Duration: ${entry.formattedDuration} (Break: ${entry.breakMinutes}m)",
                                  fontSize: 12.sp,
                                  color: textSecondary,
                                ),
                                CustomAppText(
                                  text: "\$${entry.totalEarnings.toStringAsFixed(2)}",
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: entry.isBillable ? billableColor : textPrimary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],

                SizedBox(height: 130.h),
              ],
            ),
          ),
        );
      },
    );
  }
}
