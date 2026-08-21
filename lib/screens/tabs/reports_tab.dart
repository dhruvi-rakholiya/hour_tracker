import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hour_tracker/common_widgets/app_text.dart';
import 'package:hour_tracker/common_widgets/custom_opacity.dart';
import 'package:hour_tracker/controllers/project_controller.dart';
import 'package:hour_tracker/controllers/report_controller.dart';
import 'package:hour_tracker/utils/app_colors.dart';
import 'package:hour_tracker/utils/app_formatters.dart';
import 'package:hour_tracker/utils/app_strings.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  Future<void> _selectCustomRange(BuildContext context, ReportController reportCtrl) async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: reportCtrl.customStartDate, end: reportCtrl.customEndDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      reportCtrl.setCustomRange(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReportController>(
      builder: (reportCtrl) {
        final chartData = reportCtrl.getDailyChartData();
        final maxY = reportCtrl.maxChartY;
        final breakdown = reportCtrl.getProjectBreakdown();

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title & Export Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomAppText(
                    text: "Analytics & Reports",
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                  CustomOpacityWidget(
                    onTap: reportCtrl.exportAndSharePdf,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf_rounded, color: primaryColor, size: 18.sp),
                          SizedBox(width: 6.w),
                          CustomAppText(
                            text: "PDF Report",
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip("Today", ReportFilterType.today, reportCtrl),
                    SizedBox(width: 8.w),
                    _buildFilterChip("This Week", ReportFilterType.thisWeek, reportCtrl),
                    SizedBox(width: 8.w),
                    _buildFilterChip("This Month", ReportFilterType.thisMonth, reportCtrl),
                    SizedBox(width: 8.w),
                    _buildFilterChip("Custom Range", ReportFilterType.custom, reportCtrl, onTapCustom: () => _selectCustomRange(context, reportCtrl)),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Date Period Banner with Previous & Next Navigation Buttons
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(color: shadowColor, blurRadius: 6.r, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_rounded, color: primaryColor, size: 18.sp),
                      onPressed: () => reportCtrl.navigatePeriod(-1),
                      tooltip: "Previous Period",
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: reportCtrl.filterType == ReportFilterType.custom ? () => _selectCustomRange(context, reportCtrl) : null,
                        child: Column(
                          children: [
                            CustomAppText(
                              text: reportCtrl.getPeriodDisplayTitle(),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                              textAlign: TextAlign.center,
                            ),
                            if (reportCtrl.filterType == ReportFilterType.custom)
                              CustomAppText(text: "Tap to change dates", fontSize: 11.sp, color: primaryColor),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios_rounded, color: primaryColor, size: 18.sp),
                      onPressed: () => reportCtrl.navigatePeriod(1),
                      tooltip: "Next Period",
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Project Filter Selector
              GetBuilder<ProjectController>(
                builder: (projCtrl) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(color: shadowColor, blurRadius: 6.r, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        isExpanded: true,
                        value: reportCtrl.selectedProjectId,
                        items: [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: CustomAppText(text: "All Projects", fontSize: 14.sp, fontWeight: FontWeight.bold, color: textPrimary),
                          ),
                          ...projCtrl.projects.map((p) {
                            return DropdownMenuItem<int?>(
                              value: p.id,
                              child: Row(
                                children: [
                                  Container(
                                    width: 10.w,
                                    height: 10.w,
                                    decoration: BoxDecoration(
                                      color: parseColorHex(p.colorHex),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  CustomAppText(text: p.name, fontSize: 14.sp, color: textPrimary),
                                ],
                              ),
                            );
                          }),
                        ],
                        onChanged: (id) => reportCtrl.setSelectedProjectId(id),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 20.h),

              // Bar Chart Card
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(20.r),
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
                          text: AppStrings.hoursChart,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                        Icon(Icons.bar_chart_rounded, color: primaryColor, size: 20.sp),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      height: 210.h,
                      child: chartData.isEmpty
                          ? Center(
                              child: CustomAppText(text: "No data recorded for this period", fontSize: 13.sp, color: textMuted),
                            )
                          : BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: maxY,
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      final day = chartData[group.x.toInt()]['day'];
                                      return BarTooltipItem(
                                        '$day\n${formatHoursToDuration(rod.toY)}',
                                        TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 12.sp),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (double value, TitleMeta meta) {
                                        final index = value.toInt();
                                        if (index >= 0 && index < chartData.length) {
                                          return Padding(
                                            padding: EdgeInsets.only(top: 6.h),
                                            child: CustomAppText(
                                              text: chartData[index]['day'] as String,
                                              fontSize: 10.sp,
                                              color: textSecondary,
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 32.w,
                                      getTitlesWidget: (value, meta) {
                                        return CustomAppText(
                                          text: '${value.toInt()}h',
                                          fontSize: 10.sp,
                                          color: textMuted,
                                        );
                                      },
                                    ),
                                  ),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) => FlLine(color: dividerColor, strokeWidth: 1),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: chartData.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final hours = (entry.value['hours'] as double).clamp(0.0, maxY);
                                  return BarChartGroupData(
                                    x: idx,
                                    barRods: [
                                      BarChartRodData(
                                        toY: hours,
                                        gradient: primaryGradient,
                                        width: 14.w,
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Overview Stats Grid (4 Cards)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard("Total Hours", formatHoursToDuration(reportCtrl.reportTotalHours), Icons.schedule_rounded, primaryColor),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildStatCard("Total Earnings", "\$${reportCtrl.reportTotalEarnings.toStringAsFixed(2)}", Icons.attach_money_rounded, billableColor),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard("Billable Hours", formatHoursToDuration(reportCtrl.reportBillableHours), Icons.check_circle_rounded, billableColor),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildStatCard("Avg Daily", formatHoursToDuration(reportCtrl.avgDailyHours), Icons.trending_up_rounded, accentColor),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Project Distribution Breakdown
              if (breakdown.isNotEmpty) ...[
                CustomAppText(
                  text: "Project Breakdown",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
                SizedBox(height: 12.h),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: breakdown.length,
                  separatorBuilder: (context, index) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    final item = breakdown[index];
                    final color = parseColorHex(item.projectColor);

                    return Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(color: shadowColor, blurRadius: 6.r, offset: const Offset(0, 2)),
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
                                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                  ),
                                  SizedBox(width: 8.w),
                                  CustomAppText(text: item.projectName, fontSize: 14.sp, fontWeight: FontWeight.bold, color: textPrimary),
                                ],
                              ),
                              CustomAppText(
                                text: "${formatHoursToDuration(item.totalHours)} (${item.percentage.toStringAsFixed(0)}%)",
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6.r),
                            child: LinearProgressIndicator(
                              value: item.percentage / 100.0,
                              minHeight: 6.h,
                              backgroundColor: surfaceColor,
                              color: color,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomAppText(text: "Earnings", fontSize: 11.sp, color: textMuted),
                              CustomAppText(text: "\$${item.totalEarnings.toStringAsFixed(2)}", fontSize: 12.sp, fontWeight: FontWeight.w600, color: billableColor),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 24.h),
              ],

              // Large Export PDF Button
              CustomOpacityWidget(
                onTap: reportCtrl.exportAndSharePdf,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    gradient: primaryGradient,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 10.r, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf_rounded, color: white, size: 22.sp),
                      SizedBox(width: 8.w),
                      CustomAppText(
                        text: AppStrings.exportPdf,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: white,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(14.r),
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
              Icon(icon, color: color, size: 18.sp),
              SizedBox(width: 6.w),
              CustomAppText(text: title, fontSize: 12.sp, color: textSecondary),
            ],
          ),
          SizedBox(height: 8.h),
          CustomAppText(
            text: value,
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ReportFilterType type, ReportController ctrl, {VoidCallback? onTapCustom}) {
    final isSelected = ctrl.filterType == type;

    return CustomOpacityWidget(
      onTap: () {
        if (type == ReportFilterType.custom && onTapCustom != null) {
          onTapCustom();
        } else {
          ctrl.setFilterType(type);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : cardBgColor,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            if (!isSelected) BoxShadow(color: shadowColor, blurRadius: 4.r, offset: const Offset(0, 2)),
          ],
        ),
        child: CustomAppText(
          text: label,
          fontSize: 13.sp,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? white : textSecondary,
        ),
      ),
    );
  }
}
