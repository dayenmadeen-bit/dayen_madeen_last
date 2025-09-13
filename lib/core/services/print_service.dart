import 'dart:io';
// تم إزالة dart:typed_data غير المستخدم
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import '../../app/data/models/debt.dart';
import '../../app/data/models/payment.dart';
import '../../app/data/models/customer.dart';
// تم إزالة app_constants غير المستخدم

/// خدمة الطباعة والتصدير
class PrintService {
  /// طباعة فاتورة دين
  static Future<void> printDebtInvoice(Debt debt, Customer customer) async {
    try {
      final pdf = await _generateDebtInvoicePDF(debt, customer);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'فاتورة_دين_${debt.id}',
      );
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في طباعة الفاتورة: $e');
    }
  }

  /// طباعة إيصال دفعة
  static Future<void> printPaymentReceipt(
      Payment payment, Customer customer, Debt? debt) async {
    try {
      final pdf = await _generatePaymentReceiptPDF(payment, customer, debt);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'إيصال_دفعة_${payment.id}',
      );
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في طباعة الإيصال: $e');
    }
  }

  /// طباعة كشف حساب عميل
  static Future<void> printCustomerStatement(
    Customer customer,
    List<Debt> debts,
    List<Payment> payments,
    DateTime fromDate,
    DateTime toDate,
  ) async {
    try {
      final pdf = await _generateCustomerStatementPDF(
        customer,
        debts,
        payments,
        fromDate,
        toDate,
      );
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'كشف_حساب_${customer.name}',
      );
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في طباعة كشف الحساب: $e');
    }
  }

  /// تصدير فاتورة دين كـ PDF
  static Future<String?> exportDebtInvoicePDF(
      Debt debt, Customer customer) async {
    try {
      final pdf = await _generateDebtInvoicePDF(debt, customer);
      final output = await getApplicationDocumentsDirectory();
      final file = File('${output.path}/فاتورة_دين_${debt.id}.pdf');
      await file.writeAsBytes(await pdf.save());
      return file.path;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تصدير الفاتورة: $e');
      return null;
    }
  }

  /// تصدير إيصال دفعة كـ PDF
  static Future<String?> exportPaymentReceiptPDF(
      Payment payment, Customer customer, Debt? debt) async {
    try {
      final pdf = await _generatePaymentReceiptPDF(payment, customer, debt);
      final output = await getApplicationDocumentsDirectory();
      final file = File('${output.path}/إيصال_دفعة_${payment.id}.pdf');
      await file.writeAsBytes(await pdf.save());
      return file.path;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تصدير الإيصال: $e');
      return null;
    }
  }

  /// مشاركة فاتورة دين
  static Future<void> shareDebtInvoice(Debt debt, Customer customer) async {
    try {
      final filePath = await exportDebtInvoicePDF(debt, customer);
      if (filePath != null) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'فاتورة دين - ${customer.name}',
        );
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في مشاركة الفاتورة: $e');
    }
  }

  /// مشاركة إيصال دفعة
  static Future<void> sharePaymentReceipt(
      Payment payment, Customer customer, Debt? debt) async {
    try {
      final filePath = await exportPaymentReceiptPDF(payment, customer, debt);
      if (filePath != null) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'إيصال دفعة - ${customer.name}',
        );
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في مشاركة الإيصال: $e');
    }
  }

  /// إنشاء PDF فاتورة دين
  static Future<pw.Document> _generateDebtInvoicePDF(
      Debt debt, Customer customer) async {
    final pdf = pw.Document();
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBoldFont = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // رأس الفاتورة
              _buildInvoiceHeader(arabicBoldFont),
              pw.SizedBox(height: 20),

              // معلومات العميل
              _buildCustomerInfo(customer, arabicFont, arabicBoldFont),
              pw.SizedBox(height: 20),

              // تفاصيل الدين
              _buildDebtDetails(debt, arabicFont, arabicBoldFont),
              pw.SizedBox(height: 20),

              // المجموع
              _buildDebtTotal(debt, arabicFont, arabicBoldFont),

              pw.Spacer(),

              // التوقيع والتاريخ
              _buildSignatureSection(arabicFont),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// إنشاء PDF إيصال دفعة
  static Future<pw.Document> _generatePaymentReceiptPDF(
      Payment payment, Customer customer, Debt? debt) async {
    final pdf = pw.Document();
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBoldFont = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // رأس الإيصال
              _buildReceiptHeader(arabicBoldFont),
              pw.SizedBox(height: 20),

              // معلومات العميل
              _buildCustomerInfo(customer, arabicFont, arabicBoldFont),
              pw.SizedBox(height: 20),

              // تفاصيل الدفعة
              _buildPaymentDetails(payment, debt, arabicFont, arabicBoldFont),

              pw.Spacer(),

              // التوقيع والتاريخ
              _buildSignatureSection(arabicFont),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// إنشاء PDF كشف حساب العميل
  static Future<pw.Document> _generateCustomerStatementPDF(
    Customer customer,
    List<Debt> debts,
    List<Payment> payments,
    DateTime fromDate,
    DateTime toDate,
  ) async {
    final pdf = pw.Document();
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBoldFont = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return [
            // رأس كشف الحساب
            _buildStatementHeader(customer, fromDate, toDate, arabicBoldFont),
            pw.SizedBox(height: 20),

            // معلومات العميل
            _buildCustomerInfo(customer, arabicFont, arabicBoldFont),
            pw.SizedBox(height: 20),

            // جدول الديون
            if (debts.isNotEmpty) ...[
              pw.Text('الديون:',
                  style: pw.TextStyle(font: arabicBoldFont, fontSize: 16)),
              pw.SizedBox(height: 10),
              _buildDebtsTable(debts, arabicFont, arabicBoldFont),
              pw.SizedBox(height: 20),
            ],

            // جدول المدفوعات
            if (payments.isNotEmpty) ...[
              pw.Text('المدفوعات:',
                  style: pw.TextStyle(font: arabicBoldFont, fontSize: 16)),
              pw.SizedBox(height: 10),
              _buildPaymentsTable(payments, arabicFont, arabicBoldFont),
              pw.SizedBox(height: 20),
            ],

            // الملخص المالي
            _buildFinancialSummary(debts, payments, arabicFont, arabicBoldFont),
          ];
        },
      ),
    );

    return pdf;
  }

  /// بناء رأس الفاتورة
  static pw.Widget _buildInvoiceHeader(pw.Font boldFont) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'فاتورة دين',
            style: pw.TextStyle(font: boldFont, fontSize: 24),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'التاريخ: ${_formatDate(DateTime.now())}',
            style: pw.TextStyle(font: boldFont, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// بناء رأس الإيصال
  static pw.Widget _buildReceiptHeader(pw.Font boldFont) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        border: pw.Border.all(color: PdfColors.green),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'إيصال دفعة',
            style: pw.TextStyle(font: boldFont, fontSize: 24),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'التاريخ: ${_formatDate(DateTime.now())}',
            style: pw.TextStyle(font: boldFont, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// بناء رأس كشف الحساب
  static pw.Widget _buildStatementHeader(
      Customer customer, DateTime fromDate, DateTime toDate, pw.Font boldFont) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.purple50,
        border: pw.Border.all(color: PdfColors.purple),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'كشف حساب',
            style: pw.TextStyle(font: boldFont, fontSize: 24),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'من ${_formatDate(fromDate)} إلى ${_formatDate(toDate)}',
            style: pw.TextStyle(font: boldFont, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// بناء معلومات العميل
  static pw.Widget _buildCustomerInfo(
      Customer customer, pw.Font font, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('معلومات العميل:',
              style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.Text('الاسم: ${customer.name}',
              style: pw.TextStyle(font: font, fontSize: 12)),
          if (customer.address != null)
            pw.Text('العنوان: ${customer.address}',
                style: pw.TextStyle(font: font, fontSize: 12)),
        ],
      ),
    );
  }

  /// بناء تفاصيل الدين
  static pw.Widget _buildDebtDetails(
      Debt debt, pw.Font font, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('تفاصيل الدين:',
              style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.Text('الوصف: ${debt.description ?? "غير محدد"}',
              style: pw.TextStyle(font: font, fontSize: 12)),
          pw.Text('المبلغ: ${debt.amount.toStringAsFixed(2)} ريال',
              style: pw.TextStyle(font: font, fontSize: 12)),
          pw.Text(
              'تاريخ الاستحقاق: ${debt.dueDate != null ? _formatDate(debt.dueDate!) : "غير محدد"}',
              style: pw.TextStyle(font: font, fontSize: 12)),
          pw.Text('الحالة: ${_getDebtStatusText(debt.status)}',
              style: pw.TextStyle(font: font, fontSize: 12)),
        ],
      ),
    );
  }

  /// بناء إجمالي الدين
  static pw.Widget _buildDebtTotal(Debt debt, pw.Font font, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('إجمالي المبلغ:',
              style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.Text('${debt.amount.toStringAsFixed(2)} ريال',
              style: pw.TextStyle(font: boldFont, fontSize: 16)),
        ],
      ),
    );
  }

  /// بناء تفاصيل الدفعة
  static pw.Widget _buildPaymentDetails(
      Payment payment, Debt? debt, pw.Font font, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('تفاصيل الدفعة:',
              style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.Text('المبلغ المدفوع: ${payment.amount.toStringAsFixed(2)} ريال',
              style: pw.TextStyle(font: font, fontSize: 12)),
          pw.Text(
              'طريقة الدفع: ${_getPaymentMethodText(payment.paymentMethod)}',
              style: pw.TextStyle(font: font, fontSize: 12)),
          pw.Text('تاريخ الدفع: ${_formatDate(payment.paymentDate)}',
              style: pw.TextStyle(font: font, fontSize: 12)),
          if (payment.notes != null)
            pw.Text('ملاحظات: ${payment.notes}',
                style: pw.TextStyle(font: font, fontSize: 12)),
          if (debt != null)
            pw.Text('مرتبط بالدين: ${debt.description ?? "غير محدد"}',
                style: pw.TextStyle(font: font, fontSize: 12)),
        ],
      ),
    );
  }

  /// بناء قسم التوقيع
  static pw.Widget _buildSignatureSection(pw.Font font) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('توقيع العميل:',
                style: pw.TextStyle(font: font, fontSize: 12)),
            pw.SizedBox(height: 30),
            pw.Container(
              width: 150,
              height: 1,
              color: PdfColors.black,
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('توقيع المحاسب:',
                style: pw.TextStyle(font: font, fontSize: 12)),
            pw.SizedBox(height: 30),
            pw.Container(
              width: 150,
              height: 1,
              color: PdfColors.black,
            ),
          ],
        ),
      ],
    );
  }

  /// بناء جدول الديون
  static pw.Widget _buildDebtsTable(
      List<Debt> debts, pw.Font font, pw.Font boldFont) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        // رأس الجدول
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('الوصف',
                  style: pw.TextStyle(font: boldFont, fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('المبلغ',
                  style: pw.TextStyle(font: boldFont, fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('المدفوع',
                  style: pw.TextStyle(font: boldFont, fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('المتبقي',
                  style: pw.TextStyle(font: boldFont, fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('الحالة',
                  style: pw.TextStyle(font: boldFont, fontSize: 10)),
            ),
          ],
        ),
        // صفوف البيانات
        ...debts.map((debt) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(debt.description ?? 'غير محدد',
                      style: pw.TextStyle(font: font, fontSize: 9)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('${debt.amount.toStringAsFixed(2)}',
                      style: pw.TextStyle(font: font, fontSize: 9)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('${debt.paidAmount.toStringAsFixed(2)}',
                      style: pw.TextStyle(font: font, fontSize: 9)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('${debt.remainingAmount.toStringAsFixed(2)}',
                      style: pw.TextStyle(font: font, fontSize: 9)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(_getDebtStatusText(debt.status),
                      style: pw.TextStyle(font: font, fontSize: 9)),
                ),
              ],
            )),
      ],
    );
  }

  /// بناء جدول المدفوعات
  static pw.Widget _buildPaymentsTable(
      List<Payment> payments, pw.Font font, pw.Font boldFont) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        // رأس الجدول
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('التاريخ',
                  style: pw.TextStyle(font: boldFont, fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('المبلغ',
                  style: pw.TextStyle(font: boldFont, fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('الطريقة',
                  style: pw.TextStyle(font: boldFont, fontSize: 10)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('الملاحظات',
                  style: pw.TextStyle(font: boldFont, fontSize: 10)),
            ),
          ],
        ),
        // صفوف البيانات
        ...payments.map((payment) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(_formatDate(payment.paymentDate),
                      style: pw.TextStyle(font: font, fontSize: 9)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('${payment.amount.toStringAsFixed(2)}',
                      style: pw.TextStyle(font: font, fontSize: 9)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(_getPaymentMethodText(payment.paymentMethod),
                      style: pw.TextStyle(font: font, fontSize: 9)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(payment.notes ?? '-',
                      style: pw.TextStyle(font: font, fontSize: 9)),
                ),
              ],
            )),
      ],
    );
  }

  /// بناء الملخص المالي
  static pw.Widget _buildFinancialSummary(List<Debt> debts,
      List<Payment> payments, pw.Font font, pw.Font boldFont) {
    final totalDebts = debts.fold<double>(0, (sum, debt) => sum + debt.amount);
    final totalPayments =
        payments.fold<double>(0, (sum, payment) => sum + payment.amount);
    final balance = totalDebts - totalPayments;

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('الملخص المالي:',
              style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('إجمالي الديون:',
                  style: pw.TextStyle(font: font, fontSize: 12)),
              pw.Text('${totalDebts.toStringAsFixed(2)} ريال',
                  style: pw.TextStyle(font: font, fontSize: 12)),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('إجمالي المدفوعات:',
                  style: pw.TextStyle(font: font, fontSize: 12)),
              pw.Text('${totalPayments.toStringAsFixed(2)} ريال',
                  style: pw.TextStyle(font: font, fontSize: 12)),
            ],
          ),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('الرصيد:',
                  style: pw.TextStyle(font: boldFont, fontSize: 14)),
              pw.Text(
                '${balance.toStringAsFixed(2)} ريال',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 14,
                  color: balance >= 0 ? PdfColors.red : PdfColors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// تنسيق التاريخ
  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  /// الحصول على نص حالة الدين
  static String _getDebtStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'معلق';
      case 'partial':
        return 'مدفوع جزئياً';
      case 'paid':
        return 'مدفوع';
      case 'overdue':
        return 'متأخر';
      default:
        return 'غير محدد';
    }
  }

  /// الحصول على نص طريقة الدفع
  static String _getPaymentMethodText(String method) {
    switch (method) {
      case 'cash':
        return 'نقداً';
      case 'card':
        return 'بطاقة';
      case 'bank':
        return 'تحويل بنكي';
      case 'other':
        return 'أخرى';
      default:
        return 'غير محدد';
    }
  }

  /// إنشاء تقرير شامل للعميل
  Future<void> generateCustomerReport({
    required Customer customer,
    required List<Debt> debts,
    required List<Payment> payments,
  }) async {
    try {
      final pdf = await _generateCustomerReportPDF(customer, debts, payments);

      // طباعة أو مشاركة التقرير
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'تقرير_العميل_${customer.name}.pdf',
      );
    } catch (e) {
      throw Exception('فشل في إنشاء تقرير العميل: $e');
    }
  }

  /// إنشاء PDF لتقرير العميل
  static Future<pw.Document> _generateCustomerReportPDF(
    Customer customer,
    List<Debt> debts,
    List<Payment> payments,
  ) async {
    final pdf = pw.Document();

    // حساب الإحصائيات
    final totalDebt = debts.fold<double>(0, (sum, debt) => sum + debt.amount);
    final totalPaid =
        payments.fold<double>(0, (sum, payment) => sum + payment.amount);
    final remainingDebt = totalDebt - totalPaid;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // العنوان الرئيسي
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'تقرير العميل',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'التاريخ: ${DateTime.now().toString().split(' ')[0]}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // معلومات العميل
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'معلومات العميل',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text('الاسم: ${customer.name}'),
                  pw.Text(
                      'الحد الائتماني: ${customer.creditLimit.toStringAsFixed(2)} ريال'),
                  pw.Text(
                      'تاريخ الإنشاء: ${customer.createdAt.toString().split(' ')[0]}'),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // ملخص الحساب
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'ملخص الحساب',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('إجمالي الديون:'),
                      pw.Text('${totalDebt.toStringAsFixed(2)} ريال'),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('المبلغ المسدد:'),
                      pw.Text('${totalPaid.toStringAsFixed(2)} ريال'),
                    ],
                  ),
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'المبلغ المتبقي:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        '${remainingDebt.toStringAsFixed(2)} ريال',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // جدول الديون
            if (debts.isNotEmpty) ...[
              pw.Text(
                'تفاصيل الديون',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // رأس الجدول
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('الوصف',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('المبلغ',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('التاريخ',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // صفوف البيانات
                  ...debts.map((debt) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(debt.description ?? 'غير محدد'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                                '${debt.amount.toStringAsFixed(2)} ريال'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                                debt.createdAt.toString().split(' ')[0]),
                          ),
                        ],
                      )),
                ],
              ),
            ],

            pw.SizedBox(height: 20),

            // جدول المدفوعات
            if (payments.isNotEmpty) ...[
              pw.Text(
                'تفاصيل المدفوعات',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // رأس الجدول
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('المبلغ',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('التاريخ',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('الملاحظات',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // صفوف البيانات
                  ...payments.map((payment) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                                '${payment.amount.toStringAsFixed(2)} ريال'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                                payment.createdAt.toString().split(' ')[0]),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(payment.notes ?? '-'),
                          ),
                        ],
                      )),
                ],
              ),
            ],
          ];
        },
      ),
    );

    return pdf;
  }
}
