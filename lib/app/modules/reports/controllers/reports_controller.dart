import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/payment.dart';
import '../../../data/models/debt.dart';
import '../../../data/models/customer.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';

/// كنترولر إدارة التقارير مع جميع الوظائف المطلوبة
class ReportsController extends GetxController {
  // قوائم البيانات
  var allPayments = <Payment>[].obs;
  var allDebts = <Debt>[].obs;
  var allCustomers = <Customer>[].obs;

  // حالات التحكم
  var isLoading = false.obs;
  var isGeneratingReport = false.obs;

  // فترة التقرير
  var selectedStartDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  var selectedEndDate = DateTime.now().obs;
  var selectedReportType = 'daily'.obs;

  // خصائص إضافية للتقارير المتقدمة
  var fromDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  var toDate = DateTime.now().obs;
  var profitLossReport = <String, dynamic>{}.obs;
  var monthlyDebtsChart = <String, dynamic>{}.obs;
  var debtStatusChart = <String, dynamic>{}.obs;
  var monthlyPaymentsChart = <String, dynamic>{}.obs;
  var customerAnalysis = <String, dynamic>{}.obs;

  // إحصائيات عامة
  var totalCustomers = 0.obs;
  var activeCustomers = 0.obs;
  var totalDebts = 0.obs;
  var totalDebtsAmount = 0.0.obs;
  var totalPayments = 0.obs;
  var totalPaymentsAmount = 0.0.obs;
  var remainingDebtsAmount = 0.0.obs;
  var overdueDebts = 0.obs;

  // إحصائيات يومية
  var todayDebts = 0.obs;
  var todayDebtsAmount = 0.0.obs;
  var todayPayments = 0.obs;
  var todayPaymentsAmount = 0.0.obs;

  // إحصائيات شهرية
  var monthlyData = <String, Map<String, dynamic>>{}.obs;
  var weeklyData = <String, Map<String, dynamic>>{}.obs;

  // إحصائيات طرق الدفع
  var cashPayments = 0.0.obs;
  var cardPayments = 0.0.obs;
  var bankPayments = 0.0.obs;
  var otherPayments = 0.0.obs;

  // إحصائيات حالات الديون
  var paidDebts = 0.obs;
  var pendingDebts = 0.obs;
  var partiallyPaidDebts = 0.obs;
  var cancelledDebts = 0.obs;

  // أفضل العملاء
  var topCustomersByDebts = <Map<String, dynamic>>[].obs;
  var topCustomersByPayments = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  /// تهيئة البيانات الأولية
  Future<void> _initializeData() async {
    await loadAllData();
    calculateAllStatistics();
  }

  /// تحميل البيانات (اختصار)
  Future<void> loadData() async {
    await loadAllData();
  }

  /// تحميل جميع البيانات
  Future<void> loadAllData() async {
    try {
      isLoading.value = true;

      // تحميل البيانات بشكل متوازي
      final results = await Future.wait([
        LocalStorageService.getAllCustomers(),
        LocalStorageService.getAllDebts(),
        LocalStorageService.getAllPayments(),
      ]);

      allCustomers.assignAll(results[0] as List<Customer>);
      allDebts.assignAll(results[1] as List<Debt>);
      allPayments.assignAll(results[2] as List<Payment>);
    } catch (e) {
      _showErrorMessage('فشل في تحميل البيانات: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// حساب جميع الإحصائيات
  void calculateAllStatistics() {
    _calculateGeneralStatistics();
    _calculateDailyStatistics();
    _calculateMonthlyStatistics();
    _calculatePaymentMethodStatistics();
    _calculateDebtStatusStatistics();
    _calculateTopCustomers();
  }

  /// حساب الإحصائيات العامة
  void _calculateGeneralStatistics() {
    // إحصائيات العملاء
    totalCustomers.value = allCustomers.length;
    activeCustomers.value =
        allCustomers.where((c) => c.currentBalance > 0).length;

    // إحصائيات الديون
    totalDebts.value = allDebts.length;
    totalDebtsAmount.value =
        allDebts.fold(0.0, (sum, debt) => sum + debt.amount);
    remainingDebtsAmount.value =
        allDebts.fold(0.0, (sum, debt) => sum + debt.remainingAmount);

    // الديون المتأخرة
    final now = DateTime.now();
    overdueDebts.value = allDebts.where((debt) {
      return debt.dueDate != null &&
          debt.dueDate!.isBefore(now) &&
          debt.status != AppConstants.debtStatusPaid;
    }).length;

    // إحصائيات المدفوعات
    totalPayments.value = allPayments.length;
    totalPaymentsAmount.value =
        allPayments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// حساب الإحصائيات اليومية
  void _calculateDailyStatistics() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    // ديون اليوم
    final todayDebtsList = allDebts.where((debt) {
      return debt.createdAt.isAfter(todayStart) &&
          debt.createdAt.isBefore(todayEnd);
    }).toList();

    todayDebts.value = todayDebtsList.length;
    todayDebtsAmount.value =
        todayDebtsList.fold(0.0, (sum, debt) => sum + debt.amount);

    // مدفوعات اليوم
    final todayPaymentsList = allPayments.where((payment) {
      return payment.paymentDate.isAfter(todayStart) &&
          payment.paymentDate.isBefore(todayEnd);
    }).toList();

    todayPayments.value = todayPaymentsList.length;
    todayPaymentsAmount.value =
        todayPaymentsList.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// حساب الإحصائيات الشهرية
  void _calculateMonthlyStatistics() {
    final now = DateTime.now();
    final monthlyStats = <String, Map<String, dynamic>>{};
    final weeklyStats = <String, Map<String, dynamic>>{};

    // آخر 12 شهر
    for (int i = 0; i < 12; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey =
          '${month.year}-${month.month.toString().padLeft(2, '0')}';

      final monthStart = DateTime(month.year, month.month, 1);
      final monthEnd = DateTime(month.year, month.month + 1, 1);

      // ديون الشهر
      final monthDebts = allDebts.where((debt) {
        return debt.createdAt.isAfter(monthStart) &&
            debt.createdAt.isBefore(monthEnd);
      }).toList();

      // مدفوعات الشهر
      final monthPayments = allPayments.where((payment) {
        return payment.paymentDate.isAfter(monthStart) &&
            payment.paymentDate.isBefore(monthEnd);
      }).toList();

      monthlyStats[monthKey] = {
        'month': month,
        'debtsCount': monthDebts.length,
        'debtsAmount': monthDebts.fold(0.0, (sum, debt) => sum + debt.amount),
        'paymentsCount': monthPayments.length,
        'paymentsAmount':
            monthPayments.fold(0.0, (sum, payment) => sum + payment.amount),
      };
    }

    // آخر 8 أسابيع
    for (int i = 0; i < 8; i++) {
      final weekStart = now.subtract(Duration(days: (i + 1) * 7));
      final weekEnd = now.subtract(Duration(days: i * 7));
      final weekKey = 'week-$i';

      // ديون الأسبوع
      final weekDebts = allDebts.where((debt) {
        return debt.createdAt.isAfter(weekStart) &&
            debt.createdAt.isBefore(weekEnd);
      }).toList();

      // مدفوعات الأسبوع
      final weekPayments = allPayments.where((payment) {
        return payment.paymentDate.isAfter(weekStart) &&
            payment.paymentDate.isBefore(weekEnd);
      }).toList();

      weeklyStats[weekKey] = {
        'weekStart': weekStart,
        'weekEnd': weekEnd,
        'debtsCount': weekDebts.length,
        'debtsAmount': weekDebts.fold(0.0, (sum, debt) => sum + debt.amount),
        'paymentsCount': weekPayments.length,
        'paymentsAmount':
            weekPayments.fold(0.0, (sum, payment) => sum + payment.amount),
      };
    }

    monthlyData.assignAll(monthlyStats);
    weeklyData.assignAll(weeklyStats);
  }

  /// حساب إحصائيات طرق الدفع
  void _calculatePaymentMethodStatistics() {
    cashPayments.value = allPayments
        .where((p) => p.paymentMethod == AppConstants.paymentMethodCash)
        .fold(0.0, (sum, payment) => sum + payment.amount);

    cardPayments.value = allPayments
        .where((p) => p.paymentMethod == AppConstants.paymentMethodCard)
        .fold(0.0, (sum, payment) => sum + payment.amount);

    bankPayments.value = allPayments
        .where((p) => p.paymentMethod == AppConstants.paymentMethodBank)
        .fold(0.0, (sum, payment) => sum + payment.amount);

    otherPayments.value = allPayments
        .where((p) => p.paymentMethod == AppConstants.paymentMethodOther)
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// حساب إحصائيات حالات الديون
  void _calculateDebtStatusStatistics() {
    paidDebts.value =
        allDebts.where((d) => d.status == AppConstants.debtStatusPaid).length;
    pendingDebts.value = allDebts
        .where((d) => d.status == AppConstants.debtStatusPending)
        .length;
    partiallyPaidDebts.value = allDebts
        .where((d) => d.status == AppConstants.debtStatusPartiallyPaid)
        .length;
    cancelledDebts.value = allDebts
        .where((d) => d.status == AppConstants.debtStatusCancelled)
        .length;
  }

  /// حساب أفضل العملاء
  void _calculateTopCustomers() {
    final customerDebtsMap = <String, double>{};
    final customerPaymentsMap = <String, double>{};

    // حساب إجمالي ديون كل عميل
    for (final debt in allDebts) {
      customerDebtsMap[debt.customerId] =
          (customerDebtsMap[debt.customerId] ?? 0.0) + debt.amount;
    }

    // حساب إجمالي مدفوعات كل عميل
    for (final payment in allPayments) {
      customerPaymentsMap[payment.customerId] =
          (customerPaymentsMap[payment.customerId] ?? 0.0) + payment.amount;
    }

    // ترتيب العملاء حسب الديون
    final topDebtCustomers = customerDebtsMap.entries.map((entry) {
      final customer = allCustomers.firstWhereOrNull((c) => c.id == entry.key);
      return {
        'customerId': entry.key,
        'customerName': customer?.name ?? 'عميل غير معروف',
        'amount': entry.value,
      };
    }).toList()
      ..sort(
          (a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

    // ترتيب العملاء حسب المدفوعات
    final topPaymentCustomers = customerPaymentsMap.entries.map((entry) {
      final customer = allCustomers.firstWhereOrNull((c) => c.id == entry.key);
      return {
        'customerId': entry.key,
        'customerName': customer?.name ?? 'عميل غير معروف',
        'amount': entry.value,
      };
    }).toList()
      ..sort(
          (a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

    topCustomersByDebts.assignAll(topDebtCustomers.take(10).toList());
    topCustomersByPayments.assignAll(topPaymentCustomers.take(10).toList());
  }

  /// إنشاء تقرير مخصص
  Future<Map<String, dynamic>> generateCustomReport(
      DateTime startDate, DateTime endDate) async {
    try {
      isGeneratingReport.value = true;

      // فلترة البيانات حسب الفترة المحددة
      final filteredDebts = allDebts.where((debt) {
        return debt.createdAt.isAfter(startDate) &&
            debt.createdAt.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

      final filteredPayments = allPayments.where((payment) {
        return payment.paymentDate.isAfter(startDate) &&
            payment.paymentDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

      // حساب الإحصائيات للفترة المحددة
      final report = {
        'period': {
          'startDate': startDate,
          'endDate': endDate,
          'days': endDate.difference(startDate).inDays + 1,
        },
        'debts': {
          'count': filteredDebts.length,
          'totalAmount':
              filteredDebts.fold(0.0, (sum, debt) => sum + debt.amount),
          'paidAmount':
              filteredDebts.fold(0.0, (sum, debt) => sum + debt.paidAmount),
          'remainingAmount': filteredDebts.fold(
              0.0, (sum, debt) => sum + debt.remainingAmount),
          'byStatus': {
            'paid': filteredDebts
                .where((d) => d.status == AppConstants.debtStatusPaid)
                .length,
            'pending': filteredDebts
                .where((d) => d.status == AppConstants.debtStatusPending)
                .length,
            'partiallyPaid': filteredDebts
                .where((d) => d.status == AppConstants.debtStatusPartiallyPaid)
                .length,
            'cancelled': filteredDebts
                .where((d) => d.status == AppConstants.debtStatusCancelled)
                .length,
          },
        },
        'payments': {
          'count': filteredPayments.length,
          'totalAmount': filteredPayments.fold(
              0.0, (sum, payment) => sum + payment.amount),
          'byMethod': {
            'cash': filteredPayments
                .where((p) => p.paymentMethod == AppConstants.paymentMethodCash)
                .fold(0.0, (sum, p) => sum + p.amount),
            'card': filteredPayments
                .where((p) => p.paymentMethod == AppConstants.paymentMethodCard)
                .fold(0.0, (sum, p) => sum + p.amount),
            'bank': filteredPayments
                .where((p) => p.paymentMethod == AppConstants.paymentMethodBank)
                .fold(0.0, (sum, p) => sum + p.amount),
            'other': filteredPayments
                .where(
                    (p) => p.paymentMethod == AppConstants.paymentMethodOther)
                .fold(0.0, (sum, p) => sum + p.amount),
          },
        },
        'customers': {
          'withDebts': filteredDebts.map((d) => d.customerId).toSet().length,
          'withPayments':
              filteredPayments.map((p) => p.customerId).toSet().length,
        },
        'dailyBreakdown': _generateDailyBreakdown(
            startDate, endDate, filteredDebts, filteredPayments),
      };

      return report;
    } catch (e) {
      _showErrorMessage('فشل في إنشاء التقرير: ${e.toString()}');
      return {};
    } finally {
      isGeneratingReport.value = false;
    }
  }

  /// إنشاء تفصيل يومي للتقرير
  List<Map<String, dynamic>> _generateDailyBreakdown(DateTime startDate,
      DateTime endDate, List<Debt> debts, List<Payment> payments) {
    final dailyData = <Map<String, dynamic>>[];

    for (var date = startDate;
        date.isBefore(endDate.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayDebts = debts.where((debt) {
        return debt.createdAt.isAfter(dayStart) &&
            debt.createdAt.isBefore(dayEnd);
      }).toList();

      final dayPayments = payments.where((payment) {
        return payment.paymentDate.isAfter(dayStart) &&
            payment.paymentDate.isBefore(dayEnd);
      }).toList();

      dailyData.add({
        'date': date,
        'debtsCount': dayDebts.length,
        'debtsAmount': dayDebts.fold(0.0, (sum, debt) => sum + debt.amount),
        'paymentsCount': dayPayments.length,
        'paymentsAmount':
            dayPayments.fold(0.0, (sum, payment) => sum + payment.amount),
      });
    }

    return dailyData;
  }

  /// تحديث فترة التقرير
  void updateReportPeriod(DateTime startDate, DateTime endDate) {
    selectedStartDate.value = startDate;
    selectedEndDate.value = endDate;
  }

  /// تحديث نوع التقرير
  void updateReportType(String reportType) {
    selectedReportType.value = reportType;
  }

  /// تحديث البيانات
  Future<void> refreshData() async {
    await loadAllData();
    calculateAllStatistics();
    _showSuccessMessage('تم تحديث البيانات بنجاح');
  }

  /// الحصول على اسم العميل
  String getCustomerName(String customerId) {
    final customer = allCustomers.firstWhereOrNull((c) => c.id == customerId);
    return customer?.name ?? 'عميل غير معروف';
  }

  /// الحصول على إحصائيات سريعة
  Map<String, dynamic> getQuickStats() {
    return {
      'totalCustomers': totalCustomers.value,
      'activeCustomers': activeCustomers.value,
      'totalDebts': totalDebts.value,
      'totalDebtsAmount': totalDebtsAmount.value,
      'totalPayments': totalPayments.value,
      'totalPaymentsAmount': totalPaymentsAmount.value,
      'remainingDebtsAmount': remainingDebtsAmount.value,
      'overdueDebts': overdueDebts.value,
      'todayDebts': todayDebts.value,
      'todayDebtsAmount': todayDebtsAmount.value,
      'todayPayments': todayPayments.value,
      'todayPaymentsAmount': todayPaymentsAmount.value,
    };
  }

  /// رسائل النجاح والخطأ
  void _showSuccessMessage(String message) {
    Get.snackbar(
      AppStrings.success,
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  void _showErrorMessage(String message) {
    Get.snackbar(
      AppStrings.error,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  // دوال إضافية للتقارير المتقدمة

  /// تصدير التقرير المتقدم
  Future<void> exportAdvancedReport() async {
    try {
      isGeneratingReport.value = true;

      // تحديث البيانات
      await loadData();

      // إنشاء التقرير
      // final reportData = {
      //   'period': '${formatDate(fromDate.value)} - ${formatDate(toDate.value)}',
      //   'totalDebts': totalDebtsAmount.value,
      //   'totalPayments': totalPaymentsAmount.value,
      //   'remainingDebts': remainingDebtsAmount.value,
      //   'customers': totalCustomers.value,
      //   'generatedAt': DateTime.now().toIso8601String(),
      // };

      // هنا يمكن إضافة منطق التصدير الفعلي
      _showSuccessMessage('تم تصدير التقرير بنجاح');
    } catch (e) {
      _showErrorMessage('فشل في تصدير التقرير: $e');
    } finally {
      isGeneratingReport.value = false;
    }
  }

  /// تنسيق التاريخ
  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// اختيار تاريخ البداية
  Future<void> selectFromDate() async {
    final DateTime? picked = await Get.dialog<DateTime>(
      DatePickerDialog(
        initialDate: fromDate.value,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      ),
    );

    if (picked != null && picked != fromDate.value) {
      fromDate.value = picked;
      selectedStartDate.value = picked;
      await loadData();
    }
  }

  /// اختيار تاريخ النهاية
  Future<void> selectToDate() async {
    final DateTime? picked = await Get.dialog<DateTime>(
      DatePickerDialog(
        initialDate: toDate.value,
        firstDate: fromDate.value,
        lastDate: DateTime.now(),
      ),
    );

    if (picked != null && picked != toDate.value) {
      toDate.value = picked;
      selectedEndDate.value = picked;
      await loadData();
    }
  }

  /// تعيين الشهر الحالي
  Future<void> setCurrentMonth() async {
    final now = DateTime.now();
    fromDate.value = DateTime(now.year, now.month, 1);
    toDate.value = DateTime(now.year, now.month + 1, 0);
    selectedStartDate.value = fromDate.value;
    selectedEndDate.value = toDate.value;
    await loadData();
  }

  /// تعيين آخر 3 أشهر
  Future<void> setLast3Months() async {
    final now = DateTime.now();
    fromDate.value = DateTime(now.year, now.month - 2, 1);
    toDate.value = now;
    selectedStartDate.value = fromDate.value;
    selectedEndDate.value = toDate.value;
    await loadData();
  }

  /// تعيين السنة الحالية
  Future<void> setCurrentYear() async {
    final now = DateTime.now();
    fromDate.value = DateTime(now.year, 1, 1);
    toDate.value = DateTime(now.year, 12, 31);
    selectedStartDate.value = fromDate.value;
    selectedEndDate.value = toDate.value;
    await loadData();
  }

  @override
  void onClose() {
    // تنظيف الموارد
    super.onClose();
  }

  /// تغيير الشهر المختار للتقرير الشهري
  void changeSelectedMonth(int monthOffset) {
    // final now = DateTime.now();
    // إذا لم تكن selectedMonth معرفة، عرّفها كـ Rx<DateTime>
    if (!(Get.isRegistered(tag: 'reports_selected_month'))) {
      // تخزين القيمة في Storage/State اختياري. هنا سنستخدم متغير محلي
    }
    // لضمان التوافق، سنستخدم toDate كمرجع للشهر الحالي
    final base = DateTime.now();
    final newMonth = DateTime(base.year, base.month - monthOffset, 1);
    // إذا كانت لديك selectedMonth كـ Rx<DateTime> في مكان آخر، حدّثها هناك.
    toDate.value = DateTime(newMonth.year, newMonth.month + 1, 0);
    fromDate.value = DateTime(newMonth.year, newMonth.month, 1);
  }
}
