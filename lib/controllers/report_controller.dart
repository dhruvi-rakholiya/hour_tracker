import 'dart:io';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'package:hour_tracker/controllers/time_entry_controller.dart';
import 'package:hour_tracker/models/time_entry_model.dart';
import 'package:hour_tracker/utils/app_show_toast.dart';

enum ReportFilterType { today, thisWeek, thisMonth, custom }

class ReportController extends GetxController {
  ReportFilterType filterType = ReportFilterType.thisWeek;
  DateTime customStartDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime customEndDate = DateTime.now();

  List<TimeEntryModel> filteredReportEntries = [];

  @override
  void onInit() {
    super.onInit();
    generateReportData();
  }

  void setFilterType(ReportFilterType type) {
    filterType = type;
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
    final all = entryCtrl.allEntries;

    final now = DateTime.now();

    if (filterType == ReportFilterType.today) {
      filteredReportEntries = all.where((e) {
        return e.startTime.year == now.year &&
            e.startTime.month == now.month &&
            e.startTime.day == now.day;
      }).toList();
    } else if (filterType == ReportFilterType.thisWeek) {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      filteredReportEntries = all.where((e) => e.startTime.isAfter(start.subtract(const Duration(seconds: 1)))).toList();
    } else if (filterType == ReportFilterType.thisMonth) {
      filteredReportEntries = all.where((e) => e.startTime.year == now.year && e.startTime.month == now.month).toList();
    } else {
      final start = DateTime(customStartDate.year, customStartDate.month, customStartDate.day);
      final end = DateTime(customEndDate.year, customEndDate.month, customEndDate.day, 23, 59, 59);
      filteredReportEntries = all.where((e) => e.startTime.isAfter(start.subtract(const Duration(seconds: 1))) && e.startTime.isBefore(end)).toList();
    }

    update();
  }

  double get reportTotalHours => filteredReportEntries.fold(0.0, (sum, e) => sum + e.netWorkHours);
  double get reportTotalEarnings => filteredReportEntries.fold(0.0, (sum, e) => sum + e.totalEarnings);
  double get reportBillableHours => filteredReportEntries.where((e) => e.isBillable).fold(0.0, (sum, e) => sum + e.netWorkHours);
  double get reportNonBillableHours => filteredReportEntries.where((e) => !e.isBillable).fold(0.0, (sum, e) => sum + e.netWorkHours);

  // --- CHART DATA PREPARATION ---
  List<Map<String, dynamic>> getDailyChartData() {
    final Map<String, double> hoursPerDay = {};
    final DateFormat formatter = DateFormat('EEE');

    // Default last 7 days keys
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key = formatter.format(d);
      hoursPerDay[key] = 0.0;
    }

    for (var entry in filteredReportEntries) {
      final key = formatter.format(entry.startTime);
      if (hoursPerDay.containsKey(key)) {
        hoursPerDay[key] = (hoursPerDay[key] ?? 0.0) + entry.netWorkHours;
      }
    }

    return hoursPerDay.entries.map((e) => {'day': e.key, 'hours': e.value}).toList();
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
                    pw.Text("Hour Tracker Work Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text(DateFormat('MMM dd, yyyy').format(DateTime.now()), style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),

              // Summary Stats Box
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Column(children: [
                      pw.Text("Total Hours", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      pw.Text("${reportTotalHours.toStringAsFixed(1)} hrs", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    ]),
                    pw.Column(children: [
                      pw.Text("Total Earnings", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      pw.Text("\$${reportTotalEarnings.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green700)),
                    ]),
                    pw.Column(children: [
                      pw.Text("Billable Hours", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      pw.Text("${reportBillableHours.toStringAsFixed(1)} hrs", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    ]),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              pw.Text("Detailed Work Logs", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),

              // Entries Table
              pw.TableHelper.fromTextArray(
                headers: ['Date & Time', 'Project', 'Task / Note', 'Duration', 'Rate', 'Earnings'],
                data: filteredReportEntries.map((e) {
                  return [
                    df.format(e.startTime),
                    e.projectName,
                    e.taskName.isNotEmpty ? e.taskName : (e.notes.isNotEmpty ? e.notes : '-'),
                    '${(e.netWorkMinutes / 60.0).toStringAsFixed(1)}h',
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

      await Share.shareXFiles([XFile(file.path)], text: "Hour Tracker Work Report PDF");
    } catch (e) {
      showToast("Error generating PDF report");
    }
  }
}
