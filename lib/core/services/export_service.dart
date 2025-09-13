import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/data/services/local_storage_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// خدمة تصدير البيانات والتقارير
class ExportService {
  // منع إنشاء instance من الكلاس
  ExportService._();

  // ===== تصدير البيانات =====

  /// تصدير جميع البيانات كملف JSON
  static Future<String?> exportAllDataAsJson() async {
    try {
      // جمع جميع البيانات
      final customers = await LocalStorageService.getAllCustomers();
      final debts = await LocalStorageService.getAllDebts();
      final payments = await LocalStorageService.getAllPayments();

      // إنشاء هيكل البيانات
      final exportData = {
        'app_info': {
          'name': AppConstants.appName,
          'version': AppConstants.appVersion,
          'export_date': DateTime.now().toIso8601String(),
        },
        'data': {
          'customers': customers.map((c) => c.toJson()).toList(),
          'debts': debts.map((d) => d.toJson()).toList(),
          'payments': payments.map((p) => p.toJson()).toList(),
        },
        'statistics': {
          'total_customers': customers.length,
          'total_debts': debts.length,
          'total_payments': payments.length,
          'total_debt_amount':
              debts.fold(0.0, (sum, debt) => sum + debt.amount),
          'total_payment_amount':
              payments.fold(0.0, (sum, payment) => sum + payment.amount),
        },
      };

      // تحويل إلى JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // حفظ الملف
      final fileName = 'backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final filePath = await _saveToFile(jsonString, fileName);

      return filePath;
    } catch (e) {
      debugPrint('Error exporting data as JSON: $e');
      return null;
    }
  }

  /// تصدير البيانات كملف CSV
  static Future<String?> exportDataAsCSV({
    required String dataType, // 'customers', 'debts', 'payments'
  }) async {
    try {
      String csvContent = '';
      String fileName = '';

      switch (dataType) {
        case 'customers':
          csvContent = await _exportCustomersAsCSV();
          fileName = 'customers_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
        case 'debts':
          csvContent = await _exportDebtsAsCSV();
          fileName = 'debts_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
        case 'payments':
          csvContent = await _exportPaymentsAsCSV();
          fileName = 'payments_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
        default:
          throw Exception('نوع البيانات غير مدعوم');
      }

      // حفظ الملف
      final filePath = await _saveToFile(csvContent, fileName);
      return filePath;
    } catch (e) {
      debugPrint('Error exporting data as CSV: $e');
      return null;
    }
  }

  // ===== تصدير التقارير =====

  /// تصدير تقرير شامل كملف نصي
  static Future<String?> exportComprehensiveReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start =
          startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();

      // جمع البيانات
      final customers = await LocalStorageService.getAllCustomers();
      final debts = await LocalStorageService.getAllDebts();
      final payments = await LocalStorageService.getAllPayments();

      // فلترة البيانات حسب التاريخ
      final filteredDebts = debts
          .where((debt) =>
              debt.createdAt.isAfter(start) && debt.createdAt.isBefore(end))
          .toList();
      final filteredPayments = payments
          .where((payment) =>
              payment.paymentDate.isAfter(start) &&
              payment.paymentDate.isBefore(end))
          .toList();

      // إنشاء التقرير
      final report = StringBuffer();

      // رأس التقرير
      report.writeln('=' * 50);
      report.writeln('تقرير شامل - ${AppConstants.appName}');
      report.writeln('=' * 50);
      report
          .writeln('تاريخ التقرير: ${AppConstants.formatDate(DateTime.now())}');
      report.writeln(
          'الفترة: ${AppConstants.formatDate(start)} - ${AppConstants.formatDate(end)}');
      report.writeln('');

      // الإحصائيات العامة
      report.writeln('الإحصائيات العامة:');
      report.writeln('-' * 20);
      report.writeln('إجمالي العملاء: ${customers.length}');
      report.writeln('إجمالي الديون: ${filteredDebts.length}');
      report.writeln('إجمالي المدفوعات: ${filteredPayments.length}');
      report.writeln('');

      // إحصائيات مالية
      final totalDebtAmount =
          filteredDebts.fold(0.0, (sum, debt) => sum + debt.amount);
      final totalPaymentAmount =
          filteredPayments.fold(0.0, (sum, payment) => sum + payment.amount);
      final netAmount = totalPaymentAmount - totalDebtAmount;

      report.writeln('الإحصائيات المالية:');
      report.writeln('-' * 20);
      report
          .writeln('إجمالي الديون: ${totalDebtAmount.toStringAsFixed(2)} ر.س');
      report.writeln(
          'إجمالي المدفوعات: ${totalPaymentAmount.toStringAsFixed(2)} ر.س');
      report.writeln('الصافي: ${netAmount.toStringAsFixed(2)} ر.س');
      report.writeln('');

      // تفاصيل العملاء
      report.writeln('تفاصيل العملاء:');
      report.writeln('-' * 20);
      for (final customer in customers) {
        final customerDebts =
            filteredDebts.where((d) => d.customerId == customer.id).toList();
        final customerPayments =
            filteredPayments.where((p) => p.customerId == customer.id).toList();

        if (customerDebts.isNotEmpty || customerPayments.isNotEmpty) {
          report.writeln('العميل: ${customer.name}');
          report.writeln('  الديون: ${customerDebts.length}');
          report.writeln('  المدفوعات: ${customerPayments.length}');
          report.writeln(
              '  إجمالي الديون: ${customerDebts.fold(0.0, (sum, debt) => sum + debt.amount).toStringAsFixed(2)} ر.س');
          report.writeln(
              '  إجمالي المدفوعات: ${customerPayments.fold(0.0, (sum, payment) => sum + payment.amount).toStringAsFixed(2)} ر.س');
          report.writeln('');
        }
      }

      // حفظ التقرير
      final fileName = 'report_${DateTime.now().millisecondsSinceEpoch}.txt';
      final filePath = await _saveToFile(report.toString(), fileName);

      return filePath;
    } catch (e) {
      debugPrint('Error exporting comprehensive report: $e');
      return null;
    }
  }

  // ===== الدوال المساعدة =====

  /// تصدير العملاء كـ CSV
  static Future<String> _exportCustomersAsCSV() async {
    final customers = await LocalStorageService.getAllCustomers();

    final csv = StringBuffer();

    // رأس الجدول
    csv.writeln('الاسم,الهاتف,البريد الإلكتروني,العنوان,تاريخ الإنشاء');

    // البيانات
    for (final customer in customers) {
      csv.writeln([
        _escapeCsvField(customer.name),
        _escapeCsvField(''),
        _escapeCsvField(customer.email ?? ''),
        _escapeCsvField(customer.address ?? ''),
        AppConstants.formatDate(customer.createdAt),
      ].join(','));
    }

    return csv.toString();
  }

  /// تصدير الديون كـ CSV
  static Future<String> _exportDebtsAsCSV() async {
    final debts = await LocalStorageService.getAllDebts();
    final customers = await LocalStorageService.getAllCustomers();

    final csv = StringBuffer();

    // رأس الجدول
    csv.writeln('العميل,المبلغ,الوصف,الحالة,تاريخ الاستحقاق,تاريخ الإنشاء');

    // البيانات
    for (final debt in debts) {
      final customer =
          customers.firstWhereOrNull((c) => c.id == debt.customerId);

      csv.writeln([
        _escapeCsvField(customer?.name ?? 'غير معروف'),
        debt.amount.toStringAsFixed(2),
        _escapeCsvField(debt.description ?? ''),
        _getDebtStatusText(debt.status),
        debt.dueDate != null ? AppConstants.formatDate(debt.dueDate!) : '',
        AppConstants.formatDate(debt.createdAt),
      ].join(','));
    }

    return csv.toString();
  }

  /// تصدير المدفوعات كـ CSV
  static Future<String> _exportPaymentsAsCSV() async {
    final payments = await LocalStorageService.getAllPayments();
    final customers = await LocalStorageService.getAllCustomers();

    final csv = StringBuffer();

    // رأس الجدول
    csv.writeln('العميل,المبلغ,طريقة الدفع,الملاحظات,تاريخ الدفع');

    // البيانات
    for (final payment in payments) {
      final customer =
          customers.firstWhereOrNull((c) => c.id == payment.customerId);

      csv.writeln([
        _escapeCsvField(customer?.name ?? 'غير معروف'),
        payment.amount.toStringAsFixed(2),
        _escapeCsvField(payment.paymentMethod),
        _escapeCsvField(payment.notes ?? ''),
        AppConstants.formatDate(payment.paymentDate),
      ].join(','));
    }

    return csv.toString();
  }

  /// حفظ المحتوى في ملف
  static Future<String> _saveToFile(String content, String fileName) async {
    try {
      // الحصول على مجلد التنزيلات أو المجلد المؤقت
      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = Directory('/storage/emulated/0/Documents');
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      // إنشاء مجلد التطبيق إذا لم يكن موجوداً
      final appDirectory =
          Directory('${directory!.path}/${AppConstants.appName}');
      if (!await appDirectory.exists()) {
        await appDirectory.create(recursive: true);
      }

      // إنشاء الملف
      final file = File('${appDirectory.path}/$fileName');
      await file.writeAsString(content, encoding: utf8);

      return file.path;
    } catch (e) {
      debugPrint('Error saving file: $e');
      rethrow;
    }
  }

  /// تنظيف حقل CSV
  static String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  /// الحصول على نص حالة الدين
  static String _getDebtStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'معلق';
      case 'paid':
        return 'مدفوع';
      case 'partially_paid':
        return 'مدفوع جزئياً';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  // ===== واجهة المستخدم =====

  /// عرض خيارات التصدير
  static void showExportOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'تصدير البيانات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildExportOption(
              'تصدير جميع البيانات (JSON)',
              'نسخة احتياطية كاملة',
              Icons.backup,
              () => _handleExport('all_json'),
            ),
            _buildExportOption(
              'تصدير العملاء (CSV)',
              'قائمة العملاء كجدول',
              Icons.people,
              () => _handleExport('customers_csv'),
            ),
            _buildExportOption(
              'تصدير الديون (CSV)',
              'قائمة الديون كجدول',
              Icons.receipt_long,
              () => _handleExport('debts_csv'),
            ),
            _buildExportOption(
              'تصدير المدفوعات (CSV)',
              'قائمة المدفوعات كجدول',
              Icons.payment,
              () => _handleExport('payments_csv'),
            ),
            _buildExportOption(
              'تقرير شامل (TXT)',
              'تقرير مفصل نصي',
              Icons.description,
              () => _handleExport('report_txt'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _buildExportOption(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {
        Get.back();
        onTap();
      },
    );
  }

  static Future<void> _handleExport(String type) async {
    try {
      Get.dialog(
        const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('جاري التصدير...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      String? filePath;

      switch (type) {
        case 'all_json':
          filePath = await exportAllDataAsJson();
          break;
        case 'customers_csv':
          filePath = await exportDataAsCSV(dataType: 'customers');
          break;
        case 'debts_csv':
          filePath = await exportDataAsCSV(dataType: 'debts');
          break;
        case 'payments_csv':
          filePath = await exportDataAsCSV(dataType: 'payments');
          break;
        case 'report_txt':
          filePath = await exportComprehensiveReport();
          break;
      }

      Get.back(); // إغلاق dialog التحميل

      if (filePath != null) {
        Get.snackbar(
          'تم التصدير',
          'تم حفظ الملف في: $filePath',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          'فشل التصدير',
          'حدث خطأ أثناء تصدير البيانات',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.back(); // إغلاق dialog التحميل
      Get.snackbar(
        'خطأ',
        'فشل في تصدير البيانات: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}

// استيراد مكتبة path_provider للحصول على مجلد المستندات
Future<Directory> getApplicationDocumentsDirectory() async {
  // هذه دالة مؤقتة - يجب إضافة مكتبة path_provider
  return Directory.systemTemp;
}
