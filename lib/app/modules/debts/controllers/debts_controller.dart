import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/debt.dart';
import '../../../data/models/customer.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';

/// كنترولر إدارة الديون مع جميع الوظائف المطلوبة
class DebtsController extends GetxController {
  // قوائم البيانات
  var allDebts = <Debt>[].obs;
  var filteredDebts = <Debt>[].obs;
  var customers = <Customer>[].obs;

  // حالات التحكم
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var isRefreshing = false.obs;

  // البحث والفلترة
  var searchQuery = ''.obs;
  var selectedCustomerId = ''.obs;
  var selectedStatus = ''.obs;
  var selectedDateRange = Rxn<DateTimeRange>();

  // الترتيب
  var sortBy = 'date'.obs; // date, amount, customer, status
  var sortAscending = false.obs;

  // التصفح
  var currentPage = 0.obs;
  var hasMoreData = true.obs;
  final int pageSize = AppConstants.defaultPageSize;

  // الإحصائيات
  var totalDebts = 0.obs;
  var totalAmount = 0.0.obs;
  var paidAmount = 0.0.obs;
  var remainingAmount = 0.0.obs;
  var overdueDebts = 0.obs;

  // ===== Add/Edit Debt Form State =====
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final notesController = TextEditingController();

  var selectedCustomerIdForm = Rxn<String>();
  var selectedDueDateForm = Rxn<DateTime>();
  var isSavingDebt = false.obs;

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
    _calculateStatistics();
  }

  /// إعداد المستمعين للتغييرات
  void _setupListeners() {
    // مراقبة تغييرات البحث
    debounce(searchQuery, (_) => _applyFilters(),
        time: const Duration(milliseconds: 500));

    // مراقبة تغييرات الفلاتر
    ever(selectedCustomerId, (_) => _applyFilters());
    ever(selectedStatus, (_) => _applyFilters());
    ever(selectedDateRange, (_) => _applyFilters());

    // مراقبة تغييرات الترتيب
    ever(sortBy, (_) => _applySorting());
    ever(sortAscending, (_) => _applySorting());
  }

  /// تحميل جميع الديون
  Future<void> loadDebts({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;

      // إنشاء بيانات وهمية للديون
      final debts = _createMockDebts();
      allDebts.assignAll(debts);

      _applyFilters();
      _calculateStatistics();
    } catch (e) {
      _showErrorMessage('فشل في تحميل الديون: ${e.toString()}');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  /// إنشاء بيانات وهمية للديون
  List<Debt> _createMockDebts() {
    return [
      Debt.create(
        customerId: 'customer_1',
        businessOwnerId: 'owner_1',
        amount: 1500.0,
        description: 'شراء مواد غذائية',
        dueDate: DateTime.now().add(const Duration(days: 30)),
        notes: 'دين شهري',
      ),
      Debt.create(
        customerId: 'customer_2',
        businessOwnerId: 'owner_1',
        amount: 2200.0,
        description: 'شراء معدات',
        dueDate: DateTime.now().add(const Duration(days: 15)),
        notes: 'دين عاجل',
      ),
      Debt.create(
        customerId: 'customer_3',
        businessOwnerId: 'owner_1',
        amount: 800.0,
        description: 'خدمات استشارية',
        dueDate: DateTime.now().subtract(const Duration(days: 5)), // متأخر
        notes: 'دين متأخر',
      ),
      Debt.create(
        customerId: 'customer_1',
        businessOwnerId: 'owner_1',
        amount: 950.0,
        description: 'صيانة أجهزة',
        dueDate: DateTime.now().add(const Duration(days: 7)),
        notes: 'دين قصير المدى',
      ),
    ];
  }

  /// تحميل العملاء
  Future<void> loadCustomers() async {
    try {
      // إنشاء بيانات وهمية للعملاء
      final customersList = _createMockCustomers();
      customers.assignAll(customersList);
    } catch (e) {
      // print('خطأ في تحميل العملاء: $e');
    }
  }

  /// إنشاء بيانات وهمية للعملاء
  List<Customer> _createMockCustomers() {
    return [
      Customer.create(
        businessOwnerId: 'owner_1',
        name: 'أحمد محمد السعيد',
        uniqueId: '1234567',
        password: '1234',
        creditLimit: 5000.0,
      ),
      Customer.create(
        businessOwnerId: 'owner_1',
        name: 'سارة أحمد الزهراني',
        uniqueId: '1234568',
        password: '1234',
        creditLimit: 3000.0,
      ),
      Customer.create(
        businessOwnerId: 'owner_1',
        name: 'محمد علي القحطاني',
        uniqueId: '1234569',
        password: '1234',
        creditLimit: 7000.0,
      ),
    ];
  }

  /// تحديث البيانات
  Future<void> refreshDebts() async {
    try {
      isRefreshing.value = true;
      currentPage.value = 0;
      hasMoreData.value = true;

      await loadCustomers();
      await loadDebts(showLoading: false);

      _showSuccessMessage('تم تحديث البيانات بنجاح');
    } catch (e) {
      _showErrorMessage('فشل في تحديث البيانات');
    } finally {
      isRefreshing.value = false;
    }
  }

  /// إضافة دين جديد
  Future<bool> addDebt(Debt debt) async {
    try {
      isLoading.value = true;

      // التحقق من صحة البيانات
      final validationError = _validateDebt(debt);
      if (validationError != null) {
        _showErrorMessage(validationError);
        return false;
      }

      // حفظ الدين محلياً (مؤقتاً)
      // يمكن إضافة منطق الحفظ في قاعدة البيانات هنا

      // تحديث القوائم
      allDebts.add(debt);
      _applyFilters();
      _calculateStatistics();

      // تحديث رصيد العميل
      await _updateCustomerBalance(debt.customerId, debt.amount);

      _showSuccessMessage('تم إضافة الدين بنجاح');
      return true;
    } catch (e) {
      _showErrorMessage('فشل في إضافة الدين: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// تحديث دين موجود
  Future<bool> updateDebt(Debt updatedDebt) async {
    try {
      isLoading.value = true;

      // العثور على الدين الأصلي
      final originalDebt =
          allDebts.firstWhereOrNull((d) => d.id == updatedDebt.id);
      if (originalDebt == null) {
        _showErrorMessage('الدين غير موجود');
        return false;
      }

      // التحقق من صحة البيانات
      final validationError = _validateDebt(updatedDebt);
      if (validationError != null) {
        _showErrorMessage(validationError);
        return false;
      }

      // حفظ التحديث
      await LocalStorageService.updateDebt(updatedDebt);

      // تحديث القائمة
      final index = allDebts.indexWhere((d) => d.id == updatedDebt.id);
      if (index != -1) {
        allDebts[index] = updatedDebt;
        _applyFilters();
        _calculateStatistics();
      }

      // تحديث رصيد العميل إذا تغير المبلغ
      if (originalDebt.amount != updatedDebt.amount) {
        final difference = updatedDebt.amount - originalDebt.amount;
        await _updateCustomerBalance(updatedDebt.customerId, difference);
      }

      _showSuccessMessage('تم تحديث الدين بنجاح');
      return true;
    } catch (e) {
      _showErrorMessage('فشل في تحديث الدين: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// حذف دين
  Future<bool> deleteDebt(String debtId) async {
    try {
      isLoading.value = true;

      // العثور على الدين
      final debt = allDebts.firstWhereOrNull((d) => d.id == debtId);
      if (debt == null) {
        _showErrorMessage('الدين غير موجود');
        return false;
      }

      // حذف الدين
      await LocalStorageService.deleteDebt(debtId);

      // تحديث القوائم
      allDebts.removeWhere((d) => d.id == debtId);
      _applyFilters();
      _calculateStatistics();

      // تحديث رصيد العميل
      await _updateCustomerBalance(debt.customerId, -debt.remainingAmount);

      _showSuccessMessage('تم حذف الدين بنجاح');
      return true;
    } catch (e) {
      _showErrorMessage('فشل في حذف الدين: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// الحصول على دين بالمعرف
  Debt? getDebtById(String debtId) {
    return allDebts.firstWhereOrNull((debt) => debt.id == debtId);
  }

  /// الحصول على ديون عميل معين
  List<Debt> getDebtsByCustomer(String customerId) {
    return allDebts.where((debt) => debt.customerId == customerId).toList();
  }

  /// الحصول على اسم العميل
  String getCustomerName(String customerId) {
    final customer = customers.firstWhereOrNull((c) => c.id == customerId);
    return customer?.name ?? 'عميل غير معروف';
  }

  /// تطبيق الفلاتر
  void _applyFilters() {
    var filtered = allDebts.toList();

    // فلتر البحث
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((debt) {
        final customerName = getCustomerName(debt.customerId).toLowerCase();
        final description = debt.description?.toLowerCase() ?? '';
        return customerName.contains(query) || description.contains(query);
      }).toList();
    }

    // فلتر العميل
    if (selectedCustomerId.value.isNotEmpty) {
      filtered = filtered
          .where((debt) => debt.customerId == selectedCustomerId.value)
          .toList();
    }

    // فلتر الحالة
    if (selectedStatus.value.isNotEmpty) {
      filtered = filtered
          .where((debt) => debt.status == selectedStatus.value)
          .toList();
    }

    // فلتر التاريخ
    if (selectedDateRange.value != null) {
      final range = selectedDateRange.value!;
      filtered = filtered.where((debt) {
        return debt.createdAt
                .isAfter(range.start.subtract(const Duration(days: 1))) &&
            debt.createdAt.isBefore(range.end.add(const Duration(days: 1)));
      }).toList();
    }

    filteredDebts.assignAll(filtered);
    _applySorting();
  }

  /// تطبيق الترتيب
  void _applySorting() {
    final sorted = filteredDebts.toList();

    switch (sortBy.value) {
      case 'date':
        sorted.sort((a, b) => sortAscending.value
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
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

      case 'status':
        sorted.sort((a, b) => sortAscending.value
            ? a.status.compareTo(b.status)
            : b.status.compareTo(a.status));
        break;
    }

    filteredDebts.assignAll(sorted);
  }

  /// حساب الإحصائيات
  void _calculateStatistics() {
    totalDebts.value = allDebts.length;
    totalAmount.value = allDebts.fold(0.0, (sum, debt) => sum + debt.amount);
    paidAmount.value = allDebts.fold(0.0, (sum, debt) => sum + debt.paidAmount);
    remainingAmount.value =
        allDebts.fold(0.0, (sum, debt) => sum + debt.remainingAmount);

    // حساب الديون المتأخرة
    final now = DateTime.now();
    overdueDebts.value = allDebts.where((debt) {
      return debt.dueDate != null &&
          debt.dueDate!.isBefore(now) &&
          debt.status != AppConstants.debtStatusPaid;
    }).length;
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
      // print('خطأ في تحديث رصيد العميل: $e');
    }
  }

  /// التحقق من صحة بيانات الدين
  String? _validateDebt(Debt debt) {
    if (debt.customerId.isEmpty) {
      return 'يجب اختيار العميل';
    }

    if (debt.amount <= 0) {
      return 'مبلغ الدين يجب أن يكون أكبر من صفر';
    }

    if (debt.amount > AppConstants.maxAmount) {
      return 'مبلغ الدين كبير جداً';
    }

    if (debt.description?.trim().isEmpty ?? true) {
      return 'وصف الدين مطلوب';
    }

    if ((debt.description?.length ?? 0) > AppConstants.maxDescriptionLength) {
      return 'وصف الدين طويل جداً';
    }

    // التحقق من حد الائتمان
    final customer = customers.firstWhereOrNull((c) => c.id == debt.customerId);
    if (customer != null) {
      final newBalance = customer.currentBalance + debt.amount;
      if (newBalance > customer.creditLimit) {
        return 'هذا المبلغ يتجاوز حد الائتمان للعميل';
      }
    }

    return null;
  }

  /// وظائف البحث والفلترة
  void searchDebts(String query) {
    searchQuery.value = query;
  }

  void filterByCustomer(String customerId) {
    selectedCustomerId.value = customerId;
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
  }

  void filterByDateRange(DateTimeRange? range) {
    selectedDateRange.value = range;
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCustomerId.value = '';
    selectedStatus.value = '';
    selectedDateRange.value = null;
  }

  /// وظائف الترتيب
  void sortDebts(String sortField) {
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

  // Call this when opening the Add Debt screen
  void initAddDebtForm({String? customerId}) {
    amountController.clear();
    descriptionController.clear();
    notesController.clear();
    selectedCustomerIdForm.value = customerId;
    selectedDueDateForm.value = DateTime.now(); // Default to now
    isSavingDebt.value = false;
  }

  // Called from Dropdown
  void onCustomerChanged(String? value) {
    selectedCustomerIdForm.value = value;
  }

  // Called from Date field
  Future<void> selectDueDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDueDateForm.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (pickedDate == null) return;

    if (!context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(selectedDueDateForm.value ?? DateTime.now()),
    );

    if (pickedTime == null) return;

    selectedDueDateForm.value = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  void clearDueDate() {
    selectedDueDateForm.value = null;
  }

  // Called from Save Button
  Future<void> saveNewDebt() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    isSavingDebt.value = true;

    try {
      final newDebt = Debt.create(
        customerId: selectedCustomerIdForm.value!,
        businessOwnerId: 'default_owner', // Replace with actual owner ID
        amount: double.parse(amountController.text),
        description: descriptionController.text.trim(),
        dueDate: selectedDueDateForm.value,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      final success = await addDebt(newDebt); // Use the existing addDebt logic

      if (success) {
        Get.back(); // Go back after saving
      }
    } catch (e) {
      _showErrorMessage('فشل في حفظ الدين: ${e.toString()}');
    } finally {
      isSavingDebt.value = false;
    }
  }

  @override
  void onClose() {
    // تنظيف الموارد
    amountController.dispose();
    descriptionController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
