import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/user.dart';
import '../../../../core/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../routes/app_routes.dart';
import '../../../../core/services/announcements_service.dart';
import '../../../../app/data/models/employee.dart';
import '../../../../core/services/employee_service.dart';

/// Controller لوحة تحكم مالك المنشأة
class BusinessOwnerHomeController extends GetxController {
  // مالك المنشأة الحالي
  var currentUser = Rxn<User>();

  // إحصائيات المنشأة
  var totalCustomers = 0.obs; // إجمالي الزبائن
  var totalDebts = 0.obs; // إجمالي الديون
  var totalPayments = 0.obs; // إجمالي المدفوعات
  var totalAmount = 0.0.obs; // إجمالي المبالغ

  // إحصائيات شهرية مطلوبة للواجهة
  var monthlyDebtCount = 0.obs; // عدد الديون هذا الشهر
  var monthlyDebtAmount = 0.0.obs; // إجمالي مبالغ الديون هذا الشهر
  var monthlyPaymentCount = 0.obs; // عدد المدفوعات هذا الشهر
  var monthlyPaymentAmount = 0.0.obs; // إجمالي مبالغ المدفوعات هذا الشهر

  // التنقل بين التبويبات
  var currentTabIndex = 0.obs;
  var pendingDebtsCount = 0.obs; // عدد الديون المعلقة للإشعارات
  var unreadNotificationsCount = 0.obs; // عدد الإشعارات غير المقروءة

  // النشاط الأخير
  var recentActivities = <Map<String, dynamic>>[].obs;

  // تم إزالة بيانات الرسم البياني وفق المتطلبات الجديدة

  // حالة التحميل
  var isLoading = false.obs;

  // مؤقت التحديث التلقائي
  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _loadStatistics();
    _loadRecentActivity();
    // تأكيد منح المالك صلاحية كتابة الإعلانات إذا كان مالكاً
    final uid = AuthService.instance.currentUser?.id;
    final isOwner = AuthService.instance.currentUser?.role.displayName ==
            'Business Owner' ||
        AuthService.instance.currentUser?.role.value == 'business_owner';
    if (uid != null) {
      try {
        Get.find<AnnouncementsService>()
            .ensureCurrentUserIsAdminIfOwner(uid, isOwner: isOwner);
      } catch (_) {}
    }
    // الرسوم البيانية أُزيلت
    updatePendingDebtsCount(); // تحديث عدد الديون المعلقة
    updateUnreadNotificationsCount(); // تحديث عدد الإشعارات غير المقروءة
  }

  @override
  void onReady() {
    super.onReady();
    // تحديث البيانات عند جاهزية الصفحة
    refreshData();
    // بدء التحديث التلقائي كل 5 دقائق
    _startAutoRefresh();
  }

  // تحديث البيانات (للـ Pull-to-refresh)
  Future<void> refreshData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        _loadUserData(),
        _loadStatistics(),
        _loadRecentActivity(),
        // الرسوم البيانية أُزيلت
      ]);

      // إظهار رسالة تأكيد التحديث
      Get.snackbar(
        'تم التحديث ✅',
        'تم تحديث جميع البيانات بنجاح',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.refresh, color: Colors.white),
      );
    } catch (e) {
      print('Error refreshing data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // تحميل بيانات المستخدم
  Future<void> _loadUserData() async {
    try {
      final user = AuthService.instance.currentUser;
      currentUser.value = user;
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // لا توجد دوال تحميل رسوم بيانية بعد الآن

  // تحميل الإحصائيات
  Future<void> _loadStatistics() async {
    try {
      //isLoading.value = true;

      // بيانات وهمية مؤقتة - يمكن استبدالها بالبيانات الحقيقية لاحقاً
      await Future.delayed(
          const Duration(milliseconds: 500)); // محاكاة تحميل البيانات

      // تحميل من Firestore
      final user = AuthService.instance.currentUser;
      if (user == null) return;
      final db = FirebaseFirestore.instance;
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final nextMonth = DateTime(now.year, now.month + 1, 1);

      // إجمالي العملاء المرتبطين
      final customersSnap = await db
          .collection('users')
          .doc(user.id)
          .collection('customers')
          .get();
      totalCustomers.value = customersSnap.size;

      // ديون هذا الشهر (عدد ومجموع)
      try {
        final debtsSnap = await db
            .collection('users')
            .doc(user.id)
            .collection('debts')
            .where('createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
            .where('createdAt', isLessThan: Timestamp.fromDate(nextMonth))
            .get();
        monthlyDebtCount.value = debtsSnap.size;
        double debtSum = 0;
        for (final d in debtsSnap.docs) {
          final data = d.data();
          final amount = (data['amount'] as num?)?.toDouble();
          if (amount != null) debtSum += amount;
        }
        monthlyDebtAmount.value = debtSum;
      } catch (e) {
        monthlyDebtCount.value = 0;
        monthlyDebtAmount.value = 0.0;
      }

      // مدفوعات هذا الشهر (عدد ومجموع)
      try {
        final paymentsSnap = await db
            .collection('users')
            .doc(user.id)
            .collection('payments')
            .where('createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
            .where('createdAt', isLessThan: Timestamp.fromDate(nextMonth))
            .get();
        monthlyPaymentCount.value = paymentsSnap.size;
        double paymentSum = 0;
        for (final p in paymentsSnap.docs) {
          final data = p.data();
          final amount = (data['amount'] as num?)?.toDouble();
          if (amount != null) paymentSum += amount;
        }
        monthlyPaymentAmount.value = paymentSum;
      } catch (e) {
        monthlyPaymentCount.value = 0;
        monthlyPaymentAmount.value = 0.0;
      }

      // مجاميع تاريخية بسيطة
      try {
        totalDebts.value = (await db
                .collection('users')
                .doc(user.id)
                .collection('debts')
                .get())
            .size;
      } catch (_) {
        totalDebts.value = 0;
      }
      try {
        totalPayments.value = (await db
                .collection('users')
                .doc(user.id)
                .collection('payments')
                .get())
            .size;
      } catch (_) {
        totalPayments.value = 0;
      }

      // يمكن إضافة منطق تحميل البيانات الحقيقية هنا
      // مثل الاتصال بقاعدة البيانات أو API
    } catch (e) {
      print('Error loading statistics: $e');
      // في حالة الخطأ، استخدم قيم افتراضية
      totalCustomers.value = 0;
      totalDebts.value = 0;
      totalPayments.value = 0;
      totalAmount.value = 0.0;
    } finally {
      //isLoading.value = false;
    }
  }

  // تحميل النشاط الأخير
  Future<void> _loadRecentActivity() async {
    try {
      final activities = <Map<String, dynamic>>[];

      // بيانات وهمية للنشاط الأخير
      await Future.delayed(const Duration(milliseconds: 300));

      activities.addAll([
        {
          'type': 'customer',
          'title': 'تم إضافة عميل جديد',
          'description': 'أحمد محمد',
          'time': 'منذ ساعتين',
          'icon': 'person_add',
          'color': 'success',
        },
        {
          'type': 'payment',
          'title': 'تم تسجيل دفعة',
          'description': '500 ر.س من سارة أحمد',
          'time': 'منذ 3 ساعات',
          'icon': 'payment',
          'color': 'primary',
        },
        {
          'type': 'debt',
          'title': 'تم إضافة دين جديد',
          'description': '1200 ر.س لمحمد علي',
          'time': 'منذ 5 ساعات',
          'icon': 'receipt',
          'color': 'warning',
        },
        {
          'type': 'customer',
          'title': 'تم تحديث بيانات عميل',
          'description': 'فاطمة خالد',
          'time': 'أمس',
          'icon': 'edit',
          'color': 'info',
        },
      ]);

      // تحديث قائمة الأنشطة
      recentActivities.value = activities;
    } catch (e) {
      print('Error loading recent activity: $e');
      // في حالة الخطأ، عرض أنشطة وهمية
      recentActivities.value = [
        {
          'type': 'info',
          'title': 'مرحباً بك',
          'description': 'ابدأ بإضافة العملاء والديون',
          'time': 'الآن',
        },
      ];
    }
  }

  // تحويل التاريخ إلى نص نسبي
  // تم إلغاء استخدام الدالة

  // الحصول على تحية مناسبة للوقت
  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'صباح الخير';
    } else if (hour < 17) {
      return 'مساء الخير';
    } else {
      return 'مساء الخير';
    }
  }

  // اسم المتجر للعرض في الشريط العلوي
  String get storeDisplayName {
    final name = currentUser.value?.businessName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return 'متجري';
  }

  // الإجراءات السريعة

  // إضافة عميل جديد
  void addCustomer() {
    if (!EmployeeService.instance.hasPermission(Permission.addCustomers)) {
      _showMessage('صلاحيات', 'ليس لديك صلاحية لإضافة العملاء');
      return;
    }
    Get.toNamed(AppRoutes.addCustomer);
  }

  // إضافة دين جديد
  void addDebt() {
    if (!EmployeeService.instance.hasPermission(Permission.addDebts)) {
      _showMessage('صلاحيات', 'ليس لديك صلاحية لإضافة الديون');
      return;
    }
    // التحقق من وجود عملاء أولاً
    if (totalCustomers.value == 0) {
      _showMessage(
        'تنبيه',
        'يجب إضافة عميل واحد على الأقل قبل إضافة الديون',
        isError: false,
      );
      return;
    }

    Get.toNamed(AppRoutes.addDebt);
  }

  // تسجيل دفعة جديدة
  void addPayment() {
    if (!EmployeeService.instance.hasPermission(Permission.addPayments)) {
      _showMessage('صلاحيات', 'ليس لديك صلاحية لإضافة المدفوعات');
      return;
    }
    // التحقق من وجود ديون أولاً
    if (totalDebts.value == 0) {
      _showMessage(
        'تنبيه',
        'يجب وجود ديون لتسجيل المدفوعات',
        isError: false,
      );
      return;
    }

    Get.toNamed(AppRoutes.addPayment);
  }

  // عرض التقارير
  void viewReports() {
    if (!EmployeeService.instance.hasPermission(Permission.viewReports)) {
      _showMessage('صلاحيات', 'ليس لديك صلاحية لعرض التقارير');
      return;
    }
    Get.toNamed(AppRoutes.reports);
  }

  // عرض الإشعارات
  void viewNotifications() {
    Get.toNamed(AppRoutes.notifications);
  }

  // عرض جميع الأنشطة
  void viewAllActivity() {
    if (!EmployeeService.instance.hasPermission(Permission.viewReports)) {
      _showMessage('صلاحيات', 'ليس لديك صلاحية لعرض جميع الأنشطة');
      return;
    }
    Get.toNamed(AppRoutes.allActivity);
  }

  // إظهار القائمة السريعة
  void showQuickMenu() {
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
            // مقبض السحب
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // العنوان
            const Text(
              'إجراءات سريعة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // الخيارات
            _buildQuickMenuItem(
              icon: Icons.person_add,
              title: 'إضافة عميل',
              onTap: () {
                Get.back();
                addCustomer();
              },
            ),
            _buildQuickMenuItem(
              icon: Icons.receipt_long,
              title: 'إضافة دين',
              onTap: () {
                Get.back();
                addDebt();
              },
            ),
            _buildQuickMenuItem(
              icon: Icons.payment,
              title: 'تسجيل دفعة',
              onTap: () {
                Get.back();
                addPayment();
              },
            ),
            _buildQuickMenuItem(
              icon: Icons.analytics,
              title: 'عرض التقارير',
              onTap: () {
                Get.back();
                viewReports();
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildQuickMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.blue,
        ),
      ),
      title: Text(title),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  // تسجيل الخروج
  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await AuthService.instance.logout();
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  // إظهار رسالة
  void _showMessage(String title, String message, {bool isError = true}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: isError ? Colors.red : Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  // الحصول على ملخص الإحصائيات
  Map<String, dynamic> getStatsSummary() {
    return {
      'totalCustomers': totalCustomers.value,
      'totalDebts': totalDebts.value,
      'totalPayments': totalPayments.value,
      'totalAmount': totalAmount.value,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  // البحث السريع
  void quickSearch(String query) {
    if (query.isEmpty) return;

    // يمكن إضافة منطق البحث هنا
    _showMessage(
      'البحث',
      'البحث عن: $query',
      isError: false,
    );
  }

  // تحديث الإحصائيات فقط (للاستخدام من الصفحات الأخرى)
  Future<void> updateStatistics() async {
    await _loadStatistics();
  }

  // تحديث النشاط الأخير فقط
  Future<void> updateRecentActivity() async {
    await _loadRecentActivity();
  }

  // دالة تحديث عامة للاستخدام من أي مكان في التطبيق
  static Future<void> updateHomeData() async {
    if (Get.isRegistered<BusinessOwnerHomeController>()) {
      final homeController = Get.find<BusinessOwnerHomeController>();
      await homeController.refreshData();
    }
  }

  /// تغيير التبويب
  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  /// تحديث عدد الديون المعلقة للإشعارات
  void updatePendingDebtsCount() {
    // هنا يمكن حساب عدد الديون المعلقة من قاعدة البيانات
    // مؤقتاً سنضع رقم وهمي
    pendingDebtsCount.value = 5; // مثال: 5 ديون معلقة
  }

  /// تحديث عدد الإشعارات غير المقروءة
  void updateUnreadNotificationsCount() {
    // حساب الإشعارات غير المقروءة
    // مثال: طلبات جديدة من الزبائن + ديون متأخرة + تنبيهات أخرى
    int newClientRequests = 3; // طلبات جديدة من الزبائن
    int overdueDebts = 2; // ديون متأخرة
    int systemAlerts = 1; // تنبيهات النظام

    unreadNotificationsCount.value =
        newClientRequests + overdueDebts + systemAlerts;
  }

  /// فتح صفحة الإشعارات
  void openNotifications() {
    // فتح صفحة الإشعارات
    Get.toNamed(AppRoutes.businessOwnerNotifications);

    // تصفير عداد الإشعارات عند فتح الصفحة
    unreadNotificationsCount.value = 0;
  }

  /// فتح صفحة الإعدادات
  void openSettings() {
    if (!EmployeeService.instance.hasPermission(Permission.manageSettings)) {
      _showMessage('صلاحيات', 'ليس لديك صلاحية لفتح الإعدادات');
      return;
    }
    Get.toNamed(AppRoutes.settings);
  }

  // ===== دوال التنقل للصفحات المفقودة =====

  /// الانتقال لصفحة الموظفين
  void viewEmployees() {
    if (!EmployeeService.instance.hasPermission(Permission.manageEmployees)) {
      _showMessage('صلاحيات', 'ليس لديك صلاحية لإدارة الموظفين');
      return;
    }
    Get.toNamed('/employees');
  }

  /// الانتقال لصفحة النسخ الاحتياطي
  void viewBackup() {
    Get.toNamed('/backup');
  }

  // بدء التحديث التلقائي
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) => updateStatistics(),
    );
  }

  // إيقاف التحديث التلقائي
  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void onClose() {
    // تنظيف الموارد
    _stopAutoRefresh();
    super.onClose();
  }
}
