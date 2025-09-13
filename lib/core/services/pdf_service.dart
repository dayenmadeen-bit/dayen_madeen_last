import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:get/get.dart';

import '../../app/modules/reports/controllers/reports_controller.dart';
import '../constants/app_constants.dart';

class PdfService {
  /// Generates a PDF for the daily report.
  static Future<Uint8List> generateDailyReportPdf(
      ReportsController controller) async {
    final pdf = pw.Document();

    // Load the Arabic font
    final fontData = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    // Get today's data
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final todayPayments = controller.allPayments.where((payment) {
      return payment.paymentDate.isAfter(todayStart) &&
          payment.paymentDate.isBefore(todayEnd);
    }).toList();

    final todayDebts = controller.allDebts.where((debt) {
      return debt.createdAt.isAfter(todayStart) &&
          debt.createdAt.isBefore(todayEnd);
    }).toList();

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(
          base: ttf,
          bold: ttf,
        ),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('التقرير اليومي',
                          style: pw.TextStyle(font: ttf, fontSize: 24)),
                      pw.Text(AppConstants.formatDate(today),
                          style: pw.TextStyle(font: ttf, fontSize: 16)),
                    ],
                  ),
                ),
                pw.Divider(),
                pw.SizedBox(height: 20),

                // Summary
                pw.Text('ملخص اليوم:',
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryCard(
                          'مدفوعات اليوم',
                          '${controller.todayPaymentsAmount.value.toStringAsFixed(2)} ر.س',
                          PdfColors.green,
                          ttf),
                      _buildSummaryCard(
                          'ديون اليوم',
                          '${controller.todayDebtsAmount.value.toStringAsFixed(2)} ر.س',
                          PdfColors.orange,
                          ttf),
                      _buildSummaryCard(
                          'الصافي',
                          '${(controller.todayPaymentsAmount.value - controller.todayDebtsAmount.value).toStringAsFixed(2)} ر.س',
                          PdfColors.blue,
                          ttf),
                    ]),
                pw.SizedBox(height: 20),

                // Payments
                pw.Text('تفاصيل المدفوعات:',
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold)),
                _buildPaymentsTable(todayPayments, controller, ttf),
                pw.SizedBox(height: 20),

                // Debts
                pw.Text('تفاصيل الديون:',
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold)),
                _buildDebtsTable(todayDebts, controller, ttf),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSummaryCard(
      String title, String value, PdfColor color, pw.Font ttf) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: color.shade(0.1),
        border: pw.Border.all(color: color, width: 1),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: pw.TextStyle(font: ttf, fontSize: 14)),
          pw.SizedBox(height: 5),
          pw.Text(value,
              style: pw.TextStyle(
                  font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _buildPaymentsTable(
      List<dynamic> payments, ReportsController controller, pw.Font ttf) {
    if (payments.isEmpty) {
      return pw.Text('لا توجد مدفوعات اليوم.', style: pw.TextStyle(font: ttf));
    }
    final headers = ['العميل', 'طريقة الدفع', 'المبلغ'];
    final data = payments.map((payment) {
      final customerName = controller.getCustomerName(payment.customerId);
      return [
        customerName,
        payment.paymentMethod,
        '${payment.amount.toStringAsFixed(2)} ر.س',
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
      cellStyle: pw.TextStyle(font: ttf),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.centerRight,
      headerAlignment: pw.Alignment.centerRight,
      border: pw.TableBorder.all(),
    );
  }

  static pw.Widget _buildDebtsTable(
      List<dynamic> debts, ReportsController controller, pw.Font ttf) {
    if (debts.isEmpty) {
      return pw.Text('لا توجد ديون اليوم.', style: pw.TextStyle(font: ttf));
    }
    final headers = ['العميل', 'الوصف', 'المبلغ'];
    final data = debts.map((debt) {
      final customerName = controller.getCustomerName(debt.customerId);
      return [
        customerName,
        debt.description,
        '${debt.amount.toStringAsFixed(2)} ر.س',
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
      cellStyle: pw.TextStyle(font: ttf),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.centerRight,
      headerAlignment: pw.Alignment.centerRight,
      border: pw.TableBorder.all(),
    );
  }

  /// Prints a PDF document.
  static Future<void> printPdf(Uint8List pdfData) async {
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfData);
  }

  /// Shares a PDF document.
  static Future<void> sharePdf(Uint8List pdfData, String fileName) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file =
          await File('${tempDir.path}/$fileName').writeAsBytes(pdfData);
      await Share.shareXFiles([XFile(file.path)], text: 'تقرير يومي');
    } catch (e) {
      Get.snackbar('خطأ', 'فشلت مشاركة الملف: ${e.toString()}');
    }
  }
}
