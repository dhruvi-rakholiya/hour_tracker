import 'dart:io';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'package:hour_tracker/controllers/time_entry_controller.dart';
import 'package:hour_tracker/models/time_entry_model.dart';
import 'package:hour_tracker/utils/app_formatters.dart';
import 'package:hour_tracker/utils/app_show_toast.dart';

enum ReportFilterType { today, thisWeek, thisMonth, custom }

class ProjectBreakdownItem {
  final int? projectId;
  final String projectName;
  final String projectColor;
  final double totalHours;
  final double totalEarnings;
  final double percentage;

  ProjectBreakdownItem({
    required this.projectId,
    required this.projectName,
    required this.projectColor,
    required this.totalHours,
    required this.totalEarnings,
    required this.percentage,
  });
}

class ReportController extends GetxController {
  ReportFilterType filterType = ReportFilterType.thisWeek;
  DateTime anchorDate = DateTime.now();

  DateTime customStartDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime customEndDate = DateTime.now();

  int? selectedProjectId; // null = All Projects

  List<TimeEntryModel> filteredReportEntries = [];

  @override
  void onInit() {
    super.onInit();
    generateReportData();
  }

  void setFilterType(ReportFilterType type) {
    filterType = type;
    anchorDate = DateTime.now();
    generateReportData();
  }

  void setSelectedProjectId(int? id) {
    selectedProjectId = id;
    generateReportData();
  }

  void navigatePeriod(int delta) {
    if (filterType == ReportFilterType.today) {
      anchorDate = anchorDate.add(Duration(days: delta));
    } else if (filterType == ReportFilterType.thisWeek) {
      anchorDate = anchorDate.add(Duration(days: delta * 7));
    } else if (filterType == ReportFilterType.thisMonth) {
      anchorDate = DateTime(anchorDate.year, anchorDate.month + delta, 1);
    }
    generateReportData();
  }

  void setCustomRange(DateTime start, DateTime end) {
    customStartDate = start;
    customEndDate = end;
    filterType = ReportFilterType.custom;
    generateReportData();
  }

  void generateReportData() {
    final entryCtrl = Get.find<TimeEntryController>();
    List<TimeEntryModel> all = entryCtrl.allEntries;

    if (selectedProjectId != null) {
      all = all.where((e) => e.projectId == selectedProjectId).toList();
    }

    DateTime start;
    DateTime end;

    if (filterType == ReportFilterType.today) {
      start = DateTime(anchorDate.year, anchorDate.month, anchorDate.day, 0, 0, 0);
      end = DateTime(anchorDate.year, anchorDate.month, anchorDate.day, 23, 59, 59, 999);
    } else if (filterType == ReportFilterType.thisWeek) {
      final startOfWeek = anchorDate.subtract(Duration(days: anchorDate.weekday - 1));
      start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day, 0, 0, 0);
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      end = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59, 999);
    } else if (filterType == ReportFilterType.thisMonth) {
      start = DateTime(anchorDate.year, anchorDate.month, 1, 0, 0, 0);
      final lastDay = DateTime(anchorDate.year, anchorDate.month + 1, 0).day;
      end = DateTime(anchorDate.year, anchorDate.month, lastDay, 23, 59, 59, 999);
    } else {
      start = DateTime(customStartDate.year, customStartDate.month, customStartDate.day, 0, 0, 0);
      end = DateTime(customEndDate.year, customEndDate.month, customEndDate.day, 23, 59, 59, 999);
    }

    filteredReportEntries = all.where((e) {
      return !e.startTime.isBefore(start) && !e.startTime.isAfter(end);
    }).toList();

    update();
  }

  String getPeriodDisplayTitle() {
    if (filterType == ReportFilterType.today) {
      final isToday = anchorDate.year == DateTime.now().year &&
          anchorDate.month == DateTime.now().month &&
          anchorDate.day == DateTime.now().day;
      return isToday ? "Today (${DateFormat('MMM dd').format(anchorDate)})" : DateFormat('EEEE, MMM dd, yyyy').format(anchorDate);
    } else if (filterType == ReportFilterType.thisWeek) {
      final startOfWeek = anchorDate.subtract(Duration(days: anchorDate.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      return "${DateFormat('MMM dd').format(startOfWeek)} - ${DateFormat('MMM dd, yyyy').format(endOfWeek)}";
    } else if (filterType == ReportFilterType.thisMonth) {
      return DateFormat('MMMM yyyy').format(anchorDate);
    } else {
      return "${DateFormat('MMM dd, yyyy').format(customStartDate)} - ${DateFormat('MMM dd, yyyy').format(customEndDate)}";
    }
  }

  double get reportTotalHours => filteredReportEntries.fold(0.0, (sum, e) => sum + e.netWorkHours);
  double get reportTotalEarnings => filteredReportEntries.fold(0.0, (sum, e) => sum + e.totalEarnings);
  double get reportBillableHours => filteredReportEntries.where((e) => e.isBillable).fold(0.0, (sum, e) => sum + e.netWorkHours);
  double get reportNonBillableHours => filteredReportEntries.where((e) => !e.isBillable).fold(0.0, (sum, e) => sum + e.netWorkHours);

  double get avgDailyHours {
    if (filteredReportEntries.isEmpty) return 0.0;
    final dates = filteredReportEntries.map((e) => DateTime(e.startTime.year, e.startTime.month, e.startTime.day)).toSet();
    final activeDays = dates.isNotEmpty ? dates.length : 1;

    return reportTotalHours / activeDays;
  }

  // --- CHART DATA PREPARATION ---
  List<Map<String, dynamic>> getDailyChartData() {
    final List<Map<String, dynamic>> chartList = [];

    if (filterType == ReportFilterType.today) {
      // Breakdown by 3-hour slots for today
      for (int hour = 0; hour < 24; hour += 4) {
        final label = '${hour.toString().padLeft(2, '0')}:00';
        double hours = 0.0;
        for (var e in filteredReportEntries) {
          if (e.startTime.hour >= hour && e.startTime.hour < hour + 4) {
            hours += e.netWorkHours;
          }
        }
        chartList.add({'day': label, 'hours': hours});
      }
    } else if (filterType == ReportFilterType.thisWeek) {
      // 7 days Mon-Sun
      final startOfWeek = anchorDate.subtract(Duration(days: anchorDate.weekday - 1));
      for (int i = 0; i < 7; i++) {
        final d = startOfWeek.add(Duration(days: i));
        final label = DateFormat('EEE').format(d);
        final dayHours = filteredReportEntries.where((e) {
          return e.startTime.year == d.year && e.startTime.month == d.month && e.startTime.day == d.day;
        }).fold(0.0, (sum, e) => sum + e.netWorkHours);
        chartList.add({'day': label, 'hours': dayHours});
      }
    } else if (filterType == ReportFilterType.thisMonth) {
      // 4 Weeks chunking or daily
      final lastDay = DateTime(anchorDate.year, anchorDate.month + 1, 0).day;
      for (int day = 1; day <= lastDay; day += 5) {
        final endRange = (day + 4 > lastDay) ? lastDay : day + 4;
        final label = '$day-$endRange';
        final rangeHours = filteredReportEntries.where((e) {
          return e.startTime.year == anchorDate.year &&
              e.startTime.month == anchorDate.month &&
              e.startTime.day >= day &&
              e.startTime.day <= endRange;
        }).fold(0.0, (sum, e) => sum + e.netWorkHours);
        chartList.add({'day': label, 'hours': rangeHours});
      }
    } else {
      // Custom range daily breakdown
      final totalDays = customEndDate.difference(customStartDate).inDays + 1;
      final step = (totalDays / 7).ceil();
      for (int i = 0; i < totalDays; i += step) {
        final d = customStartDate.add(Duration(days: i));
        final label = DateFormat('MM/dd').format(d);
        final dayHours = filteredReportEntries.where((e) {
          return e.startTime.year == d.year && e.startTime.month == d.month && e.startTime.day == d.day;
        }).fold(0.0, (sum, e) => sum + e.netWorkHours);
        chartList.add({'day': label, 'hours': dayHours});
      }
    }

    return chartList;
  }

  double get maxChartY {
    final data = getDailyChartData();
    double maxH = 0.0;
    for (var d in data) {
      final val = d['hours'] as double;
      if (val > maxH) maxH = val;
    }
    if (maxH <= 0) return 8.0;
    return (maxH * 1.25).ceilToDouble();
  }

  List<ProjectBreakdownItem> getProjectBreakdown() {
    final Map<String, List<TimeEntryModel>> grouped = {};
    for (var entry in filteredReportEntries) {
      grouped.putIfAbsent(entry.projectName, () => []).add(entry);
    }

    final totalH = reportTotalHours;
    final List<ProjectBreakdownItem> list = [];

    grouped.forEach((name, entries) {
      final hours = entries.fold(0.0, (sum, e) => sum + e.netWorkHours);
      final earnings = entries.fold(0.0, (sum, e) => sum + e.totalEarnings);
      final pct = totalH > 0 ? (hours / totalH) * 100 : 0.0;
      final colorHex = entries.first.projectColor;
      list.add(ProjectBreakdownItem(
        projectId: entries.first.projectId,
        projectName: name,
        projectColor: colorHex,
        totalHours: hours,
        totalEarnings: earnings,
        percentage: pct,
      ));
    });

    list.sort((a, b) => b.totalHours.compareTo(a.totalHours));
    return list;
  }

  // --- PDF REPORT GENERATION & EXPORT ---
  Future<void> exportAndSharePdf() async {
    if (filteredReportEntries.isEmpty) {
      showToast("No time entries to export for this period");
      return;
    }

    try {
      final pdf = pw.Document();
      final DateFormat df = DateFormat('yyyy-MM-dd HH:mm');
      final periodTitle = getPeriodDisplayTitle();
      final breakdown = getProjectBreakdown();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Hour Tracker Work Report", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                        pw.SizedBox(height: 2),
                        pw.Text("Period: $periodTitle", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo600)),
                      ],
                    ),
                    pw.Text("Generated: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),

              // Summary Stats Box
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  border: pw.Border.all(color: PdfColors.indigo200),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Column(children: [
                      pw.Text("Total Hours", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text(formatHoursToDuration(reportTotalHours), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    ]),
                    pw.Column(children: [
                      pw.Text("Total Earnings", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text("\$${reportTotalEarnings.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green700)),
                    ]),
                    pw.Column(children: [
                      pw.Text("Billable Hours", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text(formatHoursToDuration(reportBillableHours), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    ]),
                    pw.Column(children: [
                      pw.Text("Avg Daily", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text(formatHoursToDuration(avgDailyHours), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    ]),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Project Breakdown Section
              pw.Text("Project Breakdown", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headers: ['Project Name', 'Hours Worked', 'Earnings', 'Share'],
                data: breakdown.map((b) {
                  return [
                    b.projectName,
                    formatHoursToDuration(b.totalHours),
                    '\$${b.totalEarnings.toStringAsFixed(2)}',
                    '${b.percentage.toStringAsFixed(1)}%',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo800),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.all(6),
              ),

              pw.SizedBox(height: 20),

              pw.Text("Detailed Work Logs", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),

              // Entries Table
              pw.TableHelper.fromTextArray(
                headers: ['Date & Time', 'Project', 'Task / Note', 'Duration', 'Rate', 'Earnings'],
                data: filteredReportEntries.map((e) {
                  return [
                    df.format(e.startTime),
                    e.projectName,
                    e.taskName.isNotEmpty ? e.taskName : (e.notes.isNotEmpty ? e.notes : '-'),
                    e.formattedDuration,
                    '\$${e.hourlyRate.toStringAsFixed(0)}',
                    '\$${e.totalEarnings.toStringAsFixed(2)}',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo600),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.all(6),
              ),
            ];
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File("${output.path}/hour_tracker_report.pdf");
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles([XFile(file.path)], text: "Hour Tracker Work Report ($periodTitle)");
    } catch (e) {
      showToast("Error generating PDF report");
    }
  }
}
