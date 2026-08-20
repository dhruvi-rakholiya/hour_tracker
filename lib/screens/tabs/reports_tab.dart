import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hour_tracker/common_widgets/app_text.dart';
import 'package:hour_tracker/common_widgets/custom_opacity.dart';
import 'package:hour_tracker/controllers/report_controller.dart';
import 'package:hour_tracker/utils/app_colors.dart';
import 'package:hour_tracker/utils/app_strings.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReportController>(
      builder: (reportCtrl) {
        final chartData = reportCtrl.getDailyChartData();

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppText(
                text: "Analytics & Reports",
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: textPrimary,
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
                  ],
                ),
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
                    SizedBox(height: 24.h),
                    SizedBox(
                      height: 200.h,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 12,
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < chartData.length) {
                                    return CustomAppText(
                                      text: chartData[index]['day'] as String,
                                      fontSize: 11.sp,
                                      color: textSecondary,
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28.w,
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
                            final hours = (entry.value['hours'] as double).clamp(0.0, 12.0);
                            return BarChartGroupData(
                              x: idx,
                              barRods: [
                                BarChartRodData(
                                  toY: hours,
                                  color: primaryColor,
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

              // Overview Stat Grid
              Row(
                children: [
                  Expanded(
                    child: Container(
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
                          CustomAppText(text: "Total Hours", fontSize: 12.sp, color: textSecondary),
                          SizedBox(height: 6.h),
                          CustomAppText(
                            text: "${reportCtrl.reportTotalHours.toStringAsFixed(1)} hrs",
                            fontSize: 18.sp,
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
                          BoxShadow(color: shadowColor, blurRadius: 8.r, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomAppText(text: "Earnings", fontSize: 12.sp, color: textSecondary),
                          SizedBox(height: 6.h),
                          CustomAppText(
                            text: "\$${reportCtrl.reportTotalEarnings.toStringAsFixed(2)}",
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: billableColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Export PDF Button using CustomOpacityWidget
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

              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, ReportFilterType type, ReportController ctrl) {
    final isSelected = ctrl.filterType == type;

    return CustomOpacityWidget(
      onTap: () => ctrl.setFilterType(type),
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
