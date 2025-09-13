import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/unique_id_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../data/models/customer.dart';
import '../../../routes/app_routes.dart';
import '../../home/controllers/home_controller.dart';

class CustomersController extends GetxController {
  // Controllers
  final searchController = TextEditingController();

  // البيانات
  var allCustomers = <Customer>[].obs;
  var filteredCustomers = <Customer>[].obs;

  // حالات التحكم
  var isLoading = false.obs;
  var selectedFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  // تحميل العملاء
  Future<void> loadCustomers() async {
    try {
      isLoading.value = true;

      // جلب العملاء من Firestore
      await _loadCustomersFromFirestore();
      // سيتم تنفيذ هذا لاحقاً عند ربط Firestore

      // إذا لم توجد عملاء، استخدم البيانات الوهمية للتجربة
      if (allCustomers.isEmpty) {
        allCustomers.value = [
          Customer(
              id: '1',
              name: 'أحمد محمد علي',
              uniqueId: '1234567',
              password: '1234',
              email: 'ahmed.ali@email.com',
              address: 'الرياض, حي الملز',
              currentBalance: 1500,
              isActive: true,
              createdAt: DateTime.now().subtract(const Duration(days: 10)),
              businessOwnerId: 'mock_owner_id',
              updatedAt: DateTime.now()),
          Customer(
              id: '2',
              name: 'فاطمة خالد الغامدي',
              uniqueId: '2345678',
              password: '1234',
              email: 'fatima.k@email.com',
              address: 'جدة, حي السلامة',
              currentBalance: -500,
              isActive: true,
              createdAt: DateTime.now().subtract(const Duration(days: 25)),
              businessOwnerId: 'mock_owner_id',
              updatedAt: DateTime.now()),
          Customer(
              id: '3',
              name: 'عبدالله سالم',
              uniqueId: '3456789',
              password: '1234',
              currentBalance: 0,
              isActive: false,
              createdAt: DateTime.now().subtract(const Duration(days: 40)),
              businessOwnerId: 'mock_owner_id',
              updatedAt: DateTime.now()),
        ];
      }

      _applyFilters();
    } catch (e) {
      _showErrorMessage('فشل في تحميل العملاء');
      print('Error loading customers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ===================================================================
  // ============== START: PDF Generation Logic ======================
  // ===================================================================

  /// الدالة الرئيسية لإنشاء ومشاركة كشف الحساب
  Future<void> generateAndShareCustomerStatement(String customerId) async {
    try {
      isLoading.value = true;
      _showSuccessMessage('جاري تحضير التقرير...', duration: 2);

      final customer = await getCustomerById(customerId);
      if (customer == null) {
        _showErrorMessage('لم يتم العثور على العميل');
        return;
      }

      final transactions = _getMockTransactions(customerId);
      final pdfBytes = await _generatePdf(customer, transactions);

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename:
            'statement_${customer.uniqueId}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e, st) {
      print('PDF Generation Error: $e\n$st');
      _showErrorMessage('حدث خطأ أثناء إنشاء ملف PDF.');
    } finally {
      isLoading.value = false;
    }
  }

  /// إنشاء ملف PDF باستخدام البيانات
  Future<Uint8List> _generatePdf(
      Customer customer, List<Map<String, dynamic>> transactions) async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
    final arabicFont = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFont),
        header: (context) => _buildPdfHeader(customer),
        footer: (context) => _buildPdfFooter(context),
        build: (context) => [
          _buildPdfSummary(transactions),
          pw.SizedBox(height: 20),
          _buildTransactionsTable(transactions),
        ],
      ),
    );

    return pdf.save();
  }

  /// بناء رأس الصفحة
  pw.Widget _buildPdfHeader(Customer customer) {
    final formattedDate =
        DateFormat('yyyy/MM/dd - hh:mm a').format(DateTime.now());
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('كشف حساب عميل',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('العميل: ${customer.name}'),
                pw.Text('الرقم المميز: ${customer.uniqueId}'),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('اسم المنشأة (وهمي)'),
                pw.Text('تاريخ التقرير: $formattedDate'),
              ],
            ),
          ],
        ),
        pw.Divider(height: 20, thickness: 1),
      ],
    );
  }

  /// بناء ملخص الحساب
  pw.Widget _buildPdfSummary(List<Map<String, dynamic>> transactions) {
    double totalDebits = transactions
        .where((t) => t['type'] == 'debt')
        .fold(0, (sum, t) => sum + t['amount']);
    double totalCredits = transactions
        .where((t) => t['type'] == 'payment')
        .fold(0, (sum, t) => sum + t['amount']);
    double balance = totalDebits - totalCredits;

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey, width: 1),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('إجمالي الديون', '${totalDebits.toStringAsFixed(2)} ر.س',
              PdfColors.orange),
          _summaryItem('إجمالي السداد',
              '${totalCredits.toStringAsFixed(2)} ر.س', PdfColors.green),
          _summaryItem('الرصيد الحالي', '${balance.toStringAsFixed(2)} ر.س',
              PdfColors.blue),
        ],
      ),
    );
  }

  pw.Widget _summaryItem(String title, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(title, style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 4),
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: 12, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }

  /// بناء جدول الحركات المالية
  pw.Widget _buildTransactionsTable(List<Map<String, dynamic>> transactions) {
    final headers = [
      'التاريخ والوقت',
      'البيان',
      'مدين (دين)',
      'دائن (سداد)',
      'الرصيد'
    ];
    double currentBalance = 0;

    final data = transactions.map((tx) {
      final amount = tx['amount'] as double;
      if (tx['type'] == 'debt') {
        currentBalance += amount;
      } else {
        currentBalance -= amount;
      }

      return [
        DateFormat('yyyy-MM-dd hh:mm a').format(tx['date']),
        tx['description'],
        tx['type'] == 'debt' ? amount.toStringAsFixed(2) : '-',
        tx['type'] == 'payment' ? amount.toStringAsFixed(2) : '-',
        currentBalance.toStringAsFixed(2),
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignments: {
        0: pw.Alignment.centerRight,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
      },
    );
  }

  /// بناء تذييل الصفحة
  pw.Widget _buildPdfFooter(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text('صفحة ${context.pageNumber} من ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
        pw.SizedBox(width: 20),
        pw.Text('هذا كشف حساب تم إنشاؤه بواسطة نظام دائن مدين',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
      ],
    );
  }

  /// توليد بيانات وهمية للتجربة
  List<Map<String, dynamic>> _getMockTransactions(String customerId) {
    return [
      {
        'id': 'd1',
        'type': 'debt',
        'amount': 1000.0,
        'description': 'فاتورة مشتريات رقم #101',
        'date': DateTime.now().subtract(const Duration(days: 15, hours: 3))
      },
      {
        'id': 'p1',
        'type': 'payment',
        'amount': 500.0,
        'description': 'دفعة نقدية',
        'date': DateTime.now().subtract(const Duration(days: 12, hours: 5))
      },
      {
        'id': 'd2',
        'type': 'debt',
        'amount': 850.50,
        'description': 'خدمات صيانة',
        'date': DateTime.now().subtract(const Duration(days: 10, hours: 2))
      },
      {
        'id': 'd3',
        'type': 'debt',
        'amount': 150.0,
        'description': 'مشتريات إضافية',
        'date': DateTime.now().subtract(const Duration(days: 8, hours: 8))
      },
      {
        'id': 'p2',
        'type': 'payment',
        'amount': 1000.0,
        'description': 'تحويل بنكي',
        'date': DateTime.now().subtract(const Duration(days: 5, hours: 1))
      },
    ]..sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
  }

  // ===================================================================
  // ============== END: PDF Generation Logic ========================
  // ===================================================================

  // تحديث العملاء
  Future<void> refreshCustomers() async {
    await loadCustomers();
  }

  // البحث في العملاء
  void onSearchChanged(String query) {
    _applyFilters();
  }

  // مسح البحث
  void clearSearch() {
    searchController.clear();
    _applyFilters();
  }

  // تطبيق الفلاتر
  void _applyFilters() {
    var customers = allCustomers.toList();

    final searchQuery = searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      customers = customers.where((customer) {
        return customer.name.toLowerCase().contains(searchQuery) ||
            customer.uniqueId.contains(searchQuery) ||
            (customer.email?.contains(searchQuery) ?? false);
      }).toList();
    }

    switch (selectedFilter.value) {
      case 'active':
        customers = customers.where((customer) => customer.isActive).toList();
        break;
      case 'has_debts':
        customers =
            customers.where((customer) => customer.currentBalance > 0).toList();
        break;
      case 'all':
      default:
        break;
    }

    filteredCustomers.value = customers;
  }

  // تعيين الفلتر
  void setFilter(String filter) {
    selectedFilter.value = filter;
    _applyFilters();
  }

  // إضافة عميل جديد
  void addCustomer() {
    Get.toNamed(AppRoutes.addCustomer);
  }

  Future<bool> addNewCustomer(Customer customer) async {
    try {
      final nameExists = allCustomers.any((c) =>
          c.name.toLowerCase().trim() == customer.name.toLowerCase().trim());

      if (nameExists) {
        _showErrorMessage('يوجد عميل بنفس الاسم بالفعل');
        return false;
      }

      if (customer.uniqueId.isNotEmpty) {
        final uniqueIdExists =
            allCustomers.any((c) => c.uniqueId == customer.uniqueId);

        if (uniqueIdExists) {
          _showErrorMessage('يوجد عميل بنفس الرقم المميز بالفعل');
          return false;
        }
      }

      // توليد رقم مميز للعميل إذا لم يكن موجوداً
      String customerId = customer.id;
      if (customerId.isEmpty) {
        final uniqueIdService = UniqueIdService.instance;
        customerId = await uniqueIdService.generateTemporaryCustomerId();
      }

      // إضافة العميل إلى Firestore
      await _addCustomerToFirestore(customer);
      // سيتم تنفيذ هذا لاحقاً عند ربط Firestore

      // إنشاء عميل جديد بالمعرف الصحيح
      final newCustomer = customer;

      // إضافة العميل إلى القائمة المحلية
      allCustomers.add(newCustomer);
      _applyFilters();

      if (Get.isRegistered<BusinessOwnerHomeController>()) {
        await Get.find<BusinessOwnerHomeController>().updateStatistics();
      }

      _showSuccessMessage('تم إضافة العميل بنجاح ✅');
      return true;
    } catch (e) {
      _showErrorMessage('فشل في إضافة العميل');
      print('Error adding customer: $e');
      return false;
    }
  }

  void viewCustomerDetails(String customerId) {
    Get.toNamed(
      AppRoutes.customerDetails,
      arguments: {'customerId': customerId},
    );
  }

  void editCustomer(Customer customer) {
    Get.toNamed(
      AppRoutes.editCustomer,
      arguments: customer,
    );
  }

  Future<bool> deleteCustomer(String customerId) async {
    try {
      isLoading.value = true;

      // حذف العميل من Firestore
      await _deleteCustomerFromFirestore(customerId);
      // سيتم تنفيذ هذا لاحقاً عند ربط Firestore

      // حذف العميل من القائمة المحلية
      allCustomers.removeWhere((customer) => customer.id == customerId);
      _applyFilters();

      if (Get.isRegistered<BusinessOwnerHomeController>()) {
        await Get.find<BusinessOwnerHomeController>().updateStatistics();
      }

      _showSuccessMessage('تم حذف العميل بنجاح ✅');

      Get.back();

      return true;
    } catch (e) {
      _showErrorMessage('فشل في حذف العميل');
      print('Error deleting customer: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void handleMenuAction(String action) {
    switch (action) {
      case 'sort_name':
        _sortCustomers((a, b) => a.name.compareTo(b.name));
        break;
      case 'sort_balance':
        _sortCustomers((a, b) => b.currentBalance.compareTo(a.currentBalance));
        break;
      case 'sort_date':
        _sortCustomers((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'export':
        _exportCustomers();
        break;
    }
  }

  void _sortCustomers(int Function(Customer, Customer) compare) {
    final sorted = filteredCustomers.toList()..sort(compare);
    filteredCustomers.value = sorted;
  }

  Future<void> _exportCustomers() async {
    try {
      _showSuccessMessage('سيتم إضافة ميزة التصدير قريباً');
    } catch (e) {
      _showErrorMessage('فشل في تصدير البيانات');
    }
  }

  Map<String, dynamic> getCustomersStats() {
    final activeCustomers = allCustomers.where((c) => c.isActive).length;
    final customersWithDebts =
        allCustomers.where((c) => c.currentBalance > 0).length;
    final totalBalance =
        allCustomers.fold<double>(0, (sum, c) => sum + c.currentBalance);

    return {
      'total': allCustomers.length,
      'active': activeCustomers,
      'withDebts': customersWithDebts,
      'totalBalance': totalBalance,
    };
  }

  void advancedSearch() {
    Get.dialog(
      AlertDialog(
        title: const Text('البحث المتقدم'),
        content: const Text('سيتم إضافة البحث المتقدم قريباً'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message, {int duration = 3}) {
    Get.snackbar(
      'تم بنجاح ✅',
      message,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      duration: Duration(seconds: duration),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      snackPosition: SnackPosition.TOP,
    );
  }

  void _showErrorMessage(String message) {
    Get.snackbar(
      'خطأ ❌',
      message,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error, color: Colors.white),
      snackPosition: SnackPosition.TOP,
    );
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<bool> updateCustomer(Customer updatedCustomer) async {
    try {
      isLoading.value = true;

      // تحديث العميل باستخدام الدوال الهجينة
      // تحديث العميل في Firestore
      await _updateCustomerInFirestore(updatedCustomer);
      // سيتم تنفيذ هذا لاحقاً عند ربط Firestore

      // تحديث العميل في القائمة المحلية
      final index = allCustomers
          .indexWhere((customer) => customer.id == updatedCustomer.id);
      if (index != -1) {
        allCustomers[index] = updatedCustomer;
        _applyFilters();

        if (Get.isRegistered<BusinessOwnerHomeController>()) {
          await Get.find<BusinessOwnerHomeController>().updateStatistics();
        }

        _showSuccessMessage('تم تحديث العميل بنجاح ✅');
        return true;
      } else {
        _showErrorMessage('العميل غير موجود');
        return false;
      }
    } catch (e) {
      _showErrorMessage('فشل في تحديث العميل');
      print('Error updating customer: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Customer?> getCustomerById(String customerId) async {
    try {
      return allCustomers.firstWhere((c) => c.id == customerId);
    } catch (e) {
      print('Error getting customer: $e');
      return null;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// تحميل العملاء من Firestore
  Future<void> _loadCustomersFromFirestore() async {
    try {
      final authService = Get.find<AuthService>();
      final currentUser = authService.currentUser;
      if (currentUser == null) return;

      final customersQuery = await FirestoreService.instance
          .usersCol()
          .doc(currentUser.id)
          .collection('customers')
          .orderBy('createdAt', descending: true)
          .get();

      allCustomers.clear();
      for (var doc in customersQuery.docs) {
        final data = doc.data();
        allCustomers.add(Customer.fromJson({
          'id': doc.id,
          ...data,
        }));
      }
    } catch (e) {
      print('خطأ في تحميل العملاء من Firestore: $e');
    }
  }

  /// إضافة عميل إلى Firestore
  Future<void> _addCustomerToFirestore(Customer customer) async {
    try {
      final authService = Get.find<AuthService>();
      final currentUser = authService.currentUser;
      if (currentUser == null) return;

      await FirestoreService.instance
          .usersCol()
          .doc(currentUser.id)
          .collection('customers')
          .doc(customer.id)
          .set(customer.toJson());
    } catch (e) {
      print('خطأ في إضافة العميل إلى Firestore: $e');
    }
  }

  /// حذف عميل من Firestore
  Future<void> _deleteCustomerFromFirestore(String customerId) async {
    try {
      final authService = Get.find<AuthService>();
      final currentUser = authService.currentUser;
      if (currentUser == null) return;

      await FirestoreService.instance
          .usersCol()
          .doc(currentUser.id)
          .collection('customers')
          .doc(customerId)
          .delete();
    } catch (e) {
      print('خطأ في حذف العميل من Firestore: $e');
    }
  }

  /// تحديث عميل في Firestore
  Future<void> _updateCustomerInFirestore(Customer customer) async {
    try {
      final authService = Get.find<AuthService>();
      final currentUser = authService.currentUser;
      if (currentUser == null) return;

      await FirestoreService.instance
          .usersCol()
          .doc(currentUser.id)
          .collection('customers')
          .doc(customer.id)
          .update(customer.toJson());
    } catch (e) {
      print('خطأ في تحديث العميل في Firestore: $e');
    }
  }
}
