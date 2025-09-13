import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/payment.dart';
import '../../../data/models/debt.dart';
import '../../../data/models/customer.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../home/controllers/home_controller.dart';

/// كنترولر إدارة المدفوعات مع جميع الوظائف المطلوبة
class PaymentsController extends GetxController {
  // قوائم البيانات
  var allPayments = <Payment>[].obs;
  var filteredPayments = <Payment>[].obs;
  var debts = <Debt>[].obs;
  var customers = <Customer>[].obs;

  // حالات التحكم
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var isRefreshing = false.obs;

  // البحث والفلترة
  var searchQuery = ''.obs;
  var selectedCustomerId = ''.obs;
  var selectedDebtId = ''.obs;
  var selectedPaymentMethod = ''.obs;
  var selectedDateRange = Rxn<DateTimeRange>();

  // الترتيب
  var sortBy = 'date'.obs; // date, amount, customer, method
  var sortAscending = false.obs;

  // التصفح
  var currentPage = 0.obs;
  var hasMoreData = true.obs;
  final int pageSize = AppConstants.defaultPageSize;

  // الإحصائيات
  var totalPayments = 0.obs;
  var totalAmount = 0.0.obs;
  var todayPayments = 0.obs;
  var todayAmount = 0.0.obs;
  var cashPayments = 0.0.obs;
  var cardPayments = 0.0.obs;
  var bankPayments = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    _setupListeners();
  }

  /// تهيئة البيانات الأولية
  Future<void> _initializeData() async {
    await loadCustomers();
    await loadDebts();
    await loadPayments();
    _calculateStatistics();
  }

  /// إعداد المستمعين للتغييرات
  void _setupListeners() {
    // مراقبة تغييرات البحث
    debounce(searchQuery, (_) => _applyFilters(),
        time: const Duration(milliseconds: 500));

    // مراقبة تغييرات الفلاتر
    ever(selectedCustomerId, (_) => _applyFilters());
    ever(selectedDebtId, (_) => _applyFilters());
    ever(selectedPaymentMethod, (_) => _applyFilters());
    ever(selectedDateRange, (_) => _applyFilters());

    // مراقبة تغييرات الترتيب
    ever(sortBy, (_) => _applySorting());
    ever(sortAscending, (_) => _applySorting());
  }

  /// تحميل جميع المدفوعات
  Future<void> loadPayments({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;

      final payments = await LocalStorageService.getAllPayments();
      allPayments.assignAll(payments);

      _applyFilters();
      _calculateStatistics();
    } catch (e) {
      _showErrorMessage('فشل في تحميل المدفوعات: ${e.toString()}');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  /// تحميل الديون
  Future<void> loadDebts() async {
    try {
      final debtsList = await LocalStorageService.getAllDebts();
      debts.assignAll(debtsList);
    } catch (e) {
      print('خطأ في تحميل الديون: $e');
    }
  }

  /// تحميل العملاء
  Future<void> loadCustomers() async {
    try {
      final customersList = await LocalStorageService.getAllCustomers();
      customers.assignAll(customersList);
    } catch (e) {
      print('خطأ في تحميل العملاء: $e');
    }
  }

  /// تحديث البيانات
  Future<void> refreshPayments() async {
    try {
      isRefreshing.value = true;
      currentPage.value = 0;
      hasMoreData.value = true;

      await loadCustomers();
      await loadDebts();
      await loadPayments(showLoading: false);

      _showSuccessMessage('تم تحديث البيانات بنجاح');
    } catch (e) {
      _showErrorMessage('فشل في تحديث البيانات');
    } finally {
      isRefreshing.value = false;
    }
  }

  /// إضافة دفعة جديدة
  Future<bool> addPayment(Payment payment) async {
    try {
      isLoading.value = true;

      // التحقق من صحة البيانات
      final validationError = _validatePayment(payment);
      if (validationError != null) {
        _showErrorMessage(validationError);
        return false;
      }

      // حفظ الدفعة
      await LocalStorageService.savePayment(payment);

      // تحديث القوائم
      allPayments.add(payment);
      _applyFilters();
      _calculateStatistics();

      // تحديث الدين المرتبط
      if (payment.debtId.isNotEmpty) {
        await _updateDebtPayment(payment.debtId, payment.amount);
      }

      // تحديث رصيد العميل
      await _updateCustomerBalance(payment.customerId, -payment.amount);

      // تحديث الإحصائيات في الصفحة الرئيسية فوراً
      if (Get.isRegistered<BusinessOwnerHomeController>()) {
        await Get.find<BusinessOwnerHomeController>().updateStatistics();
      }

      _showSuccessMessage('تم إضافة الدفعة بنجاح');
      return true;
    } catch (e) {
      _showErrorMessage('فشل في إضافة الدفعة: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// تحديث دفعة موجودة
  Future<bool> updatePayment(Payment updatedPayment) async {
    try {
      isLoading.value = true;

      // العثور على الدفعة الأصلية
      final originalPayment =
          allPayments.firstWhereOrNull((p) => p.id == updatedPayment.id);
      if (originalPayment == null) {
        _showErrorMessage('الدفعة غير موجودة');
        return false;
      }

      // التحقق من صحة البيانات
      final validationError = _validatePayment(updatedPayment);
      if (validationError != null) {
        _showErrorMessage(validationError);
        return false;
      }

      // حفظ التحديث
      await LocalStorageService.updatePayment(updatedPayment);

      // تحديث القائمة
      final index = allPayments.indexWhere((p) => p.id == updatedPayment.id);
      if (index != -1) {
        allPayments[index] = updatedPayment;
        _applyFilters();
        _calculateStatistics();
      }

      // تحديث الدين إذا تغير المبلغ
      if (originalPayment.amount != updatedPayment.amount) {
        final difference = updatedPayment.amount - originalPayment.amount;
        if (updatedPayment.debtId.isNotEmpty) {
          await _updateDebtPayment(updatedPayment.debtId, difference);
        }
        // تحديث رصيد العميل
        await _updateCustomerBalance(updatedPayment.customerId, -difference);
      }

      _showSuccessMessage('تم تحديث الدفعة بنجاح');
      return true;
    } catch (e) {
      _showErrorMessage('فشل في تحديث الدفعة: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// حذف دفعة
  Future<bool> deletePayment(String paymentId) async {
    try {
      isLoading.value = true;

      // العثور على الدفعة
      final payment = allPayments.firstWhereOrNull((p) => p.id == paymentId);
      if (payment == null) {
        _showErrorMessage('الدفعة غير موجودة');
        return false;
      }

      // حذف الدفعة
      await LocalStorageService.deletePayment(paymentId);

      // تحديث القوائم
      allPayments.removeWhere((p) => p.id == paymentId);
      _applyFilters();
      _calculateStatistics();

      // تحديث الدين المرتبط
      if (payment.debtId.isNotEmpty) {
        await _updateDebtPayment(payment.debtId, -payment.amount);
      }

      // تحديث رصيد العميل
      await _updateCustomerBalance(payment.customerId, payment.amount);

      _showSuccessMessage('تم حذف الدفعة بنجاح');
      return true;
    } catch (e) {
      _showErrorMessage('فشل في حذف الدفعة: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// الحصول على دفعة بالمعرف
  Payment? getPaymentById(String paymentId) {
    return allPayments.firstWhereOrNull((payment) => payment.id == paymentId);
  }

  /// الحصول على مدفوعات عميل معين
  List<Payment> getPaymentsByCustomer(String customerId) {
    return allPayments
        .where((payment) => payment.customerId == customerId)
        .toList();
  }

  /// الحصول على مدفوعات دين معين
  List<Payment> getPaymentsByDebt(String debtId) {
    return allPayments.where((payment) => payment.debtId == debtId).toList();
  }

  /// الحصول على اسم العميل
  String getCustomerName(String customerId) {
    final customer = customers.firstWhereOrNull((c) => c.id == customerId);
    return customer?.name ?? 'عميل غير معروف';
  }

  /// الحصول على وصف الدين
  String getDebtDescription(String? debtId) {
    if (debtId == null) return 'دفعة مستقلة';
    final debt = debts.firstWhereOrNull((d) => d.id == debtId);
    return debt?.description ?? 'دين غير معروف';
  }

  /// تطبيق الفلاتر
  void _applyFilters() {
    var filtered = allPayments.toList();

    // فلتر البحث
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((payment) {
        final customerName = getCustomerName(payment.customerId).toLowerCase();
        final debtDescription =
            getDebtDescription(payment.debtId).toLowerCase();
        final notes = (payment.notes ?? '').toLowerCase();
        return customerName.contains(query) ||
            debtDescription.contains(query) ||
            notes.contains(query);
      }).toList();
    }

    // فلتر العميل
    if (selectedCustomerId.value.isNotEmpty) {
      filtered = filtered
          .where((payment) => payment.customerId == selectedCustomerId.value)
          .toList();
    }

    // فلتر الدين
    if (selectedDebtId.value.isNotEmpty) {
      filtered = filtered
          .where((payment) => payment.debtId == selectedDebtId.value)
          .toList();
    }

    // فلتر طريقة الدفع
    if (selectedPaymentMethod.value.isNotEmpty) {
      filtered = filtered
          .where(
              (payment) => payment.paymentMethod == selectedPaymentMethod.value)
          .toList();
    }

    // فلتر التاريخ
    if (selectedDateRange.value != null) {
      final range = selectedDateRange.value!;
      filtered = filtered.where((payment) {
        return payment.paymentDate
                .isAfter(range.start.subtract(const Duration(days: 1))) &&
            payment.paymentDate
                .isBefore(range.end.add(const Duration(days: 1)));
      }).toList();
    }

    filteredPayments.assignAll(filtered);
    _applySorting();
  }

  /// تطبيق الترتيب
  void _applySorting() {
    final sorted = filteredPayments.toList();

    switch (sortBy.value) {
      case 'date':
        sorted.sort((a, b) => sortAscending.value
            ? a.paymentDate.compareTo(b.paymentDate)
            : b.paymentDate.compareTo(a.paymentDate));
        break;

      case 'amount':
        sorted.sort((a, b) => sortAscending.value
            ? a.amount.compareTo(b.amount)
            : b.amount.compareTo(a.amount));
        break;

      case 'customer':
        sorted.sort((a, b) {
          final nameA = getCustomerName(a.customerId);
          final nameB = getCustomerName(b.customerId);
          return sortAscending.value
              ? nameA.compareTo(nameB)
              : nameB.compareTo(nameA);
        });
        break;

      case 'method':
        sorted.sort((a, b) => sortAscending.value
            ? a.paymentMethod.compareTo(b.paymentMethod)
            : b.paymentMethod.compareTo(a.paymentMethod));
        break;
    }

    filteredPayments.assignAll(sorted);
  }

  /// حساب الإحصائيات
  void _calculateStatistics() {
    totalPayments.value = allPayments.length;
    totalAmount.value =
        allPayments.fold(0.0, (sum, payment) => sum + payment.amount);

    // إحصائيات اليوم
    final today = DateTime.now();
    final todayPaymentsList = allPayments.where((payment) {
      return payment.paymentDate.year == today.year &&
          payment.paymentDate.month == today.month &&
          payment.paymentDate.day == today.day;
    }).toList();

    todayPayments.value = todayPaymentsList.length;
    todayAmount.value =
        todayPaymentsList.fold(0.0, (sum, payment) => sum + payment.amount);

    // إحصائيات طرق الدفع
    cashPayments.value = allPayments
        .where((p) => p.paymentMethod == AppConstants.paymentMethodCash)
        .fold(0.0, (sum, payment) => sum + payment.amount);

    cardPayments.value = allPayments
        .where((p) => p.paymentMethod == AppConstants.paymentMethodCard)
        .fold(0.0, (sum, payment) => sum + payment.amount);

    bankPayments.value = allPayments
        .where((p) => p.paymentMethod == AppConstants.paymentMethodBank)
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// تحديث دفعة الدين
  Future<void> _updateDebtPayment(String debtId, double amount) async {
    try {
      final debt = debts.firstWhereOrNull((d) => d.id == debtId);
      if (debt != null) {
        final newPaidAmount = debt.paidAmount + amount;
        final newRemainingAmount = debt.amount - newPaidAmount;

        String newStatus;
        if (newRemainingAmount <= 0) {
          newStatus = AppConstants.debtStatusPaid;
        } else if (newPaidAmount > 0) {
          newStatus = AppConstants.debtStatusPartiallyPaid;
        } else {
          newStatus = AppConstants.debtStatusPending;
        }

        final updatedDebt = debt.copyWith(
          paidAmount: newPaidAmount,
          status: newStatus,
          updatedAt: DateTime.now(),
        );

        await LocalStorageService.updateDebt(updatedDebt);

        // تحديث القائمة المحلية
        final index = debts.indexWhere((d) => d.id == debtId);
        if (index != -1) {
          debts[index] = updatedDebt;
        }
      }
    } catch (e) {
      print('خطأ في تحديث دفعة الدين: $e');
    }
  }

  /// تحديث رصيد العميل
  Future<void> _updateCustomerBalance(String customerId, double amount) async {
    try {
      final customer = customers.firstWhereOrNull((c) => c.id == customerId);
      if (customer != null) {
        final updatedCustomer = customer.copyWith(
          currentBalance: customer.currentBalance + amount,
        );
        await LocalStorageService.updateCustomer(updatedCustomer);

        // تحديث القائمة المحلية
        final index = customers.indexWhere((c) => c.id == customerId);
        if (index != -1) {
          customers[index] = updatedCustomer;
        }
      }
    } catch (e) {
      print('خطأ في تحديث رصيد العميل: $e');
    }
  }

  /// التحقق من صحة بيانات الدفعة
  String? _validatePayment(Payment payment) {
    if (payment.customerId.isEmpty) {
      return 'يجب اختيار العميل';
    }

    if (payment.amount <= 0) {
      return 'مبلغ الدفعة يجب أن يكون أكبر من صفر';
    }

    if (payment.amount > AppConstants.maxAmount) {
      return 'مبلغ الدفعة كبير جداً';
    }

    if (payment.paymentMethod.isEmpty) {
      return 'يجب اختيار طريقة الدفع';
    }

    // التحقق من مبلغ الدين إذا كانت الدفعة مرتبطة بدين
    if (payment.debtId.isNotEmpty) {
      final debt = debts.firstWhereOrNull((d) => d.id == payment.debtId);
      if (debt != null && payment.amount > debt.remainingAmount) {
        return 'مبلغ الدفعة أكبر من المبلغ المتبقي للدين';
      }
    }

    return null;
  }

  /// وظائف البحث والفلترة
  void searchPayments(String query) {
    searchQuery.value = query;
  }

  void filterByCustomer(String customerId) {
    selectedCustomerId.value = customerId;
  }

  void filterByDebt(String debtId) {
    selectedDebtId.value = debtId;
  }

  void filterByPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  void filterByDateRange(DateTimeRange? range) {
    selectedDateRange.value = range;
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCustomerId.value = '';
    selectedDebtId.value = '';
    selectedPaymentMethod.value = '';
    selectedDateRange.value = null;
  }

  /// وظائف الترتيب
  void sortPayments(String sortField) {
    if (sortBy.value == sortField) {
      sortAscending.value = !sortAscending.value;
    } else {
      sortBy.value = sortField;
      sortAscending.value = false;
    }
  }

  /// رسائل النجاح والخطأ
  void _showSuccessMessage(String message) {
    Get.snackbar(
      'تم بنجاح ✅',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      snackPosition: SnackPosition.TOP,
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

  @override
  void onClose() {
    // تنظيف الموارد
    super.onClose();
  }
}
