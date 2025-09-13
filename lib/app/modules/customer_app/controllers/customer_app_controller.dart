import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/client_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/debt.dart';
import '../../../data/models/payment.dart';
import '../../../data/models/client_request.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/client_constants.dart';
import '../../../routes/app_routes.dart';

/// Controller تطبيق الزبون (العميل)
class ClientAppController extends GetxController {
  // الخدمات
  final ClientService _clientService = ClientService.instance;
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // الحصول على AuthService بطريقة آمنة
  AuthService? get _authService {
    try {
      return Get.find<AuthService>();
    } catch (e) {
      // AuthService غير متوفر
      return null;
    }
  }

  // حالات التفاعل
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  // بيانات الزبون
  final Rx<Customer?> currentClient = Rx<Customer?>(null);
  final RxList<Debt> clientDebts = <Debt>[].obs;
  final RxList<Payment> clientPayments = <Payment>[].obs;

  // الإحصائيات
  final RxDouble totalDebts = 0.0.obs;
  final RxDouble totalPayments = 0.0.obs;
  final RxDouble remainingBalance = 0.0.obs;
  final RxInt pendingDebtsCount = 0.obs;
  final RxInt overdueDebtsCount = 0.obs;

  // طلبات الزبون
  final RxList<ClientRequest> clientRequests = <ClientRequest>[].obs;
  final RxString selectedRequestFilter = 'all'.obs;
  final RxInt pendingRequestsCount = 0.obs;
  final RxInt approvedRequestsCount = 0.obs;
  final RxInt rejectedRequestsCount = 0.obs;

  // التنقل بين التبويبات
  final RxInt currentTabIndex = 0.obs;

  // فلاتر التواريخ
  final Rx<DateTime> fromDate =
      DateTime.now().subtract(const Duration(days: 30)).obs;
  final Rx<DateTime> toDate = DateTime.now().obs;

  // كلمة مرور مؤقتة للمحاكاة
  final _mockPassword = 'A1234'.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    // بدء تحميل بيانات الزبون

    // التحقق من توفر AuthService
    final authService = _authService;
    if (authService == null) {
      // AuthService غير متوفر، سيتم استخدام بيانات تجريبية
    } else {
      // AuthService متوفر
    }

    await loadCustomerData();
    // تم تحميل البيانات بنجاح
  }

  /// تحميل بيانات العميل
  Future<void> loadCustomerData() async {
    try {
      isLoading.value = true;

      final authService = _authService;
      if (authService?.currentUser != null) {
        // تحميل البيانات الحقيقية من Firestore
        await _loadCustomerInfo(authService!.currentUser!.id);
        await _loadCustomerDebts();
        await _loadCustomerPayments();
      } else {
        // محاكاة تحميل البيانات
        await Future.delayed(const Duration(milliseconds: 800));

        // بيانات وهمية للزبون
        currentClient.value = Customer.create(
          businessOwnerId: 'owner_1',
          name: 'أحمد محمد السعيد',
          uniqueId: '1234567',
          password: "A1234",
          creditLimit: 5000.0,
          email: 'ahmed@example.com',
        );

        // بيانات وهمية للديون
        await _loadMockDebts();

        // بيانات وهمية للمدفوعات
        await _loadMockPayments();
      }

      // تحميل طلبات الزبون
      await _loadClientRequests();

      // حساب الإحصائيات
      _calculateStatistics();
    } catch (e) {
      Get.snackbar(
        'خطأ ❌',
        'فشل في تحميل البيانات: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// تحديث البيانات
  Future<void> refreshData() async {
    isRefreshing.value = true;
    await loadCustomerData();
    isRefreshing.value = false;

    // إظهار رسالة تأكيد التحديث
    Get.snackbar(
      'تم التحديث ✅',
      'تم تحديث جميع البيانات بنجاح',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.refresh, color: Colors.white),
    );
  }

  /// تحميل ديون وهمية
  Future<void> _loadMockDebts() async {
    clientDebts.value = [
      Debt.create(
        businessOwnerId: 'owner_1',
        customerId: currentClient.value!.id,
        amount: 1500.0,
        description: 'فاتورة شراء مواد غذائية',
        dueDate: DateTime.now().add(const Duration(days: 15)),
      ),
      Debt.create(
        businessOwnerId: 'owner_1',
        customerId: currentClient.value!.id,
        amount: 800.0,
        description: 'فاتورة خدمات صيانة',
        dueDate: DateTime.now().add(const Duration(days: 7)),
      ),
      Debt.create(
        businessOwnerId: 'owner_1',
        customerId: currentClient.value!.id,
        amount: 2200.0,
        description: 'فاتورة معدات مكتبية',
        dueDate: DateTime.now().add(const Duration(days: 30)),
      ),
    ];
  }

  /// تحميل مدفوعات وهمية
  Future<void> _loadMockPayments() async {
    clientPayments.value = [
      Payment.create(
        businessOwnerId: 'owner_1',
        customerId: currentClient.value!.id,
        debtId: clientDebts.first.id,
        amount: 500.0,
        paymentMethod: 'نقداً',
        notes: 'دفعة جزئية',
      ),
      Payment.create(
        businessOwnerId: 'owner_1',
        customerId: currentClient.value!.id,
        debtId: clientDebts[1].id,
        amount: 800.0,
        paymentMethod: 'تحويل بنكي',
        notes: 'دفعة كاملة',
      ),
    ];
  }

  /// طلب دين جديد
  Future<void> requestDebt({
    required double amount,
    required String description,
  }) async {
    try {
      final client = currentClient.value;
      if (client == null) throw Exception('معلومات الزبون غير متوفرة');

      // إرسال الطلب عبر الخدمة
      final newRequest = await _clientService.submitDebtRequest(
        clientId: client.id,
        clientName: client.name,
        amount: amount,
        description: description,
      );

      // إضافة الطلب للقائمة المحلية
      clientRequests.insert(0, newRequest);
      _updateRequestStatistics();
    } catch (e) {
      throw ClientServiceException(ClientConstants.debtRequestErrorMessage);
    }
  }

  /// طلب سداد
  Future<void> requestPayment({
    required double amount,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      final client = currentClient.value;
      if (client == null) throw Exception('معلومات الزبون غير متوفرة');

      // إرسال الطلب عبر الخدمة
      final newRequest = await _clientService.submitPaymentRequest(
        clientId: client.id,
        clientName: client.name,
        amount: amount,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      // إضافة الطلب للقائمة المحلية
      clientRequests.insert(0, newRequest);
      _updateRequestStatistics();
    } catch (e) {
      throw ClientServiceException(ClientConstants.paymentRequestErrorMessage);
    }
  }

  /// تحميل طلبات الزبون
  Future<void> _loadClientRequests() async {
    final client = currentClient.value;
    if (client == null) return;

    try {
      final requests = await _clientService.loadClientRequests(client.id);
      clientRequests.value = requests;
      _updateRequestStatistics();
    } catch (e) {
      _showErrorMessage(ClientConstants.loadRequestsErrorMessage);
    }
  }

  /// تحديث إحصائيات الطلبات
  void _updateRequestStatistics() {
    final stats = _clientService.calculateRequestStatistics(clientRequests);

    pendingRequestsCount.value = stats.pending;
    approvedRequestsCount.value = stats.approved;
    rejectedRequestsCount.value = stats.rejected;
  }

  /// تغيير فلتر الطلبات
  void changeRequestFilter(String filter) {
    selectedRequestFilter.value = filter;
  }

  /// الحصول على الطلبات المفلترة
  List<ClientRequest> get filteredClientRequests {
    switch (selectedRequestFilter.value) {
      case 'pending':
        return clientRequests
            .where((req) => req.status == RequestStatus.pending)
            .toList();
      case 'approved':
        return clientRequests
            .where((req) => req.status == RequestStatus.approved)
            .toList();
      case 'rejected':
        return clientRequests
            .where((req) => req.status == RequestStatus.rejected)
            .toList();
      default:
        return clientRequests.toList();
    }
  }

  /// تغيير التبويب
  void changeTab(int index) {
    // تغيير التبويب
    currentTabIndex.value = index;

    // أسماء التبويبات للـ debug
    final tabNames = [
      'الرئيسية',
      'الطلبات',
      'الديون',
      'المدفوعات',
      'الملف الشخصي'
    ];
    if (index < tabNames.length) {
      // التبويب الحالي
    }
  }

  /// عرض رسالة خطأ
  void _showErrorMessage(String message) {
    Get.snackbar(
      'خطأ ❌',
      message,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  /// تحميل معلومات العميل
  Future<void> _loadCustomerInfo(String customerId) async {
    try {
      final userDoc = await _firestoreService.usersCol().doc(customerId).get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        currentClient.value = Customer.create(
          businessOwnerId: data['businessOwnerId'] ?? '',
          name: data['name'] ?? '',
          uniqueId: data['uniqueId'] ?? '',
          password: data['password'] ?? '',
          creditLimit: (data['creditLimit'] ?? 0.0).toDouble(),
          email: data['email'] ?? '',
        );
      }
    } catch (e) {
      // خطأ في تحميل معلومات العميل
    }
  }

  /// تحميل ديون العميل
  Future<void> _loadCustomerDebts() async {
    try {
      final authService = _authService;
      if (authService?.currentUser == null) return;

      final debtsQuery = await _firestoreService
          .usersCol()
          .doc(authService!.currentUser!.id)
          .collection('debts')
          .orderBy('createdAt', descending: true)
          .get();

      clientDebts.clear();
      for (var doc in debtsQuery.docs) {
        final data = doc.data();
        clientDebts.add(Debt.create(
          businessOwnerId: data['businessOwnerId'] ?? '',
          customerId: data['customerId'] ?? '',
          amount: (data['amount'] ?? 0.0).toDouble(),
          description: data['description'] ?? '',
          dueDate: data['dueDate']?.toDate(),
        ));
      }

      _updateDebtStats();
    } catch (e) {
      // خطأ في تحميل الديون
    }
  }

  /// تحميل مدفوعات العميل
  Future<void> _loadCustomerPayments() async {
    try {
      final authService = _authService;
      if (authService?.currentUser == null) return;

      final paymentsQuery = await _firestoreService
          .usersCol()
          .doc(authService!.currentUser!.id)
          .collection('payments')
          .orderBy('createdAt', descending: true)
          .get();

      clientPayments.clear();
      for (var doc in paymentsQuery.docs) {
        final data = doc.data();
        clientPayments.add(Payment.create(
          businessOwnerId: data['businessOwnerId'] ?? '',
          customerId: data['customerId'] ?? '',
          debtId: data['debtId'] ?? '',
          amount: (data['amount'] ?? 0.0).toDouble(),
          paymentMethod: data['paymentMethod'] ?? '',
          notes: data['notes'] ?? '',
        ));
      }

      _updatePaymentStats();
    } catch (e) {
      // خطأ في تحميل المدفوعات
    }
  }

  /// حساب الإحصائيات
  void _calculateStatistics() {
    // إجمالي الديون
    totalDebts.value = clientDebts.fold(0.0, (sum, debt) => sum + debt.amount);

    // إجمالي المدفوعات
    totalPayments.value =
        clientPayments.fold(0.0, (sum, payment) => sum + payment.amount);

    // الرصيد المتبقي
    remainingBalance.value = totalDebts.value - totalPayments.value;

    // عدد الديون المعلقة
    pendingDebtsCount.value = clientDebts
        .where((debt) => debt.status == 'pending' || debt.status == 'partial')
        .length;

    // عدد الديون المتأخرة
    overdueDebtsCount.value =
        clientDebts.where((debt) => debt.status == 'overdue').length;
  }

  /// فلترة الديون حسب الحالة
  List<Debt> getDebtsByStatus(String status) {
    return clientDebts.where((debt) => debt.status == status).toList();
  }

  /// الحصول على الديون المعلقة
  List<Debt> get pendingDebts => getDebtsByStatus('pending');

  /// الحصول على الديون المدفوعة جزئياً
  List<Debt> get partialDebts => getDebtsByStatus('partial');

  /// الحصول على الديون المدفوعة
  List<Debt> get paidDebts => getDebtsByStatus('paid');

  /// الحصول على الديون المتأخرة
  List<Debt> get overdueDebts => getDebtsByStatus('overdue');

  /// فلترة المدفوعات حسب الفترة
  List<Payment> getPaymentsByPeriod(DateTime from, DateTime to) {
    return clientPayments.where((payment) {
      return payment.paymentDate.isAfter(from) &&
          payment.paymentDate.isBefore(to.add(const Duration(days: 1)));
    }).toList();
  }

  /// طلب كشف حساب
  Future<void> requestStatement() async {
    try {
      // في التطبيق الحقيقي، سيتم إرسال طلب للخادم
      // هنا سنعرض رسالة تأكيد

      Get.dialog(
        AlertDialog(
          title: const Text('طلب كشف حساب'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('هل تريد طلب كشف حساب للفترة المحددة؟'),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('من: '),
                  Text(
                    '${fromDate.value.day}/${fromDate.value.month}/${fromDate.value.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('إلى: '),
                  Text(
                    '${toDate.value.day}/${toDate.value.month}/${toDate.value.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                _sendStatementRequest();
              },
              child: const Text('طلب'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في طلب كشف الحساب: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
      );
    }
  }

  /// إرسال طلب كشف الحساب
  Future<void> _sendStatementRequest() async {
    // محاكاة إرسال الطلب
    await Future.delayed(const Duration(seconds: 1));

    Get.snackbar(
      'تم الطلب',
      'تم إرسال طلب كشف الحساب بنجاح. سيتم التواصل معك قريباً.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: AppColors.onSuccess,
      duration: const Duration(seconds: 4),
    );
  }

  /// تحديث الملف الشخصي
  Future<void> updateProfile({
    String? name,
    String? email,
    String? address,
  }) async {
    try {
      final customer = currentClient.value;
      if (customer == null) return;

      final updatedCustomer = customer.copyWith(
        name: name,
        email: email,
        updatedAt: DateTime.now(),
      );

      // تحديث معلومات العميل في Firestore
      await _updateCustomerInFirestore();
      // سيتم تنفيذ هذا لاحقاً عند ربط Firestore

      currentClient.value = updatedCustomer;

      Get.snackbar(
        'تم التحديث',
        'تم تحديث الملف الشخصي بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.onSuccess,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحديث الملف الشخصي: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
      );
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    try {
      // بدء عملية تسجيل الخروج

      // إغلاق أي حوارات مفتوحة (مثل مؤشر التحميل)
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // مسح البيانات المحلية
      clientDebts.clear();
      clientPayments.clear();
      clientRequests.clear();

      // إعادة تعيين الإحصائيات
      totalDebts.value = 0.0;
      totalPayments.value = 0.0;
      remainingBalance.value = 0.0;

      // إعادة تعيين التبويب الحالي
      currentTabIndex.value = 0;

      // تم مسح البيانات المحلية

      // تسجيل الخروج من AuthService
      final authService = _authService;
      if (authService != null) {
        await authService.logout();
      } else {
        // AuthService غير متوفر، الانتقال المباشر لتسجيل الدخول
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      // خطأ في تسجيل الخروج

      // إغلاق أي حوارات مفتوحة
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // في حالة الخطأ، انتقل لتسجيل الدخول على أي حال
      Get.offAllNamed(AppRoutes.login);

      // عرض رسالة خطأ
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تسجيل الخروج، تم تسجيل خروجك',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// تحديد فترة التقرير
  Future<void> selectDateRange() async {
    final picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: fromDate.value,
        end: toDate.value,
      ),
    );

    if (picked != null) {
      fromDate.value = picked.start;
      toDate.value = picked.end;
    }
  }

  /// تنسيق المبلغ
  String formatAmount(double amount) {
    return '${amount.toStringAsFixed(2)} ريال';
  }

  /// تنسيق التاريخ
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // دوال تعديل معلومات الملف الشخصي
  void updateName(String newName) {
    if (currentClient.value != null) {
      currentClient.update((val) {
        val!.name = newName;
      });
      Get.back();
      Get.snackbar(
        'نجاح',
        'تم تحديث الاسم بنجاح.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  bool verifyOldPassword(String oldPassword) {
    if (currentClient.value != null) {
      // هنا يجب عليك استخدام خدمة المصادقة للتحقق من كلمة المرور القديمة
      // في هذا المثال، نستخدم كلمة مرور وهمية للمحاكاة
      return oldPassword == _mockPassword.value;
    }
    return false;
  }

  void changePassword(String newPassword) {
    if (currentClient.value != null) {
      _mockPassword.value = newPassword;
      Get.back(); // إغلاق النافذة المنبثقة
      Get.snackbar(
        'نجاح',
        'تم تغيير كلمة المرور بنجاح.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  /// تحديث إحصائيات الديون
  void _updateDebtStats() {
    totalDebts.value = clientDebts.fold(0.0, (sum, debt) => sum + debt.amount);
    pendingDebtsCount.value = clientDebts
        .where((debt) => debt.status == 'pending' || debt.status == 'partial')
        .length;
    _calculateStatistics();
  }

  /// تحديث إحصائيات المدفوعات
  void _updatePaymentStats() {
    totalPayments.value =
        clientPayments.fold(0.0, (sum, payment) => sum + payment.amount);
    _calculateStatistics();
  }

  /// تحديث معلومات العميل في Firestore
  Future<void> _updateCustomerInFirestore() async {
    try {
      final authService = _authService;
      if (authService?.currentUser == null) return;

      await _firestoreService
          .usersCol()
          .doc(authService!.currentUser!.id)
          .update(currentClient.value!.toJson());
    } catch (e) {
      print('خطأ في تحديث معلومات العميل في Firestore: $e');
    }
  }
}
