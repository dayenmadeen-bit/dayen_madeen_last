import 'package:get/get.dart';
import '../views/business_owner_notifications_screen.dart';

/// Controller إشعارات مالك المنشأة
class BusinessOwnerNotificationsController extends GetxController {
  // حالات التفاعل
  final RxBool isLoading = false.obs;

  // قوائم البيانات
  final RxList<BusinessOwnerNotification> allNotifications =
      <BusinessOwnerNotification>[].obs;
  final RxList<BusinessOwnerNotification> filteredNotifications =
      <BusinessOwnerNotification>[].obs;

  // الفلاتر
  final RxnString selectedFilter = RxnString(null);

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  /// تحميل الإشعارات
  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;

      // محاكاة تحميل البيانات
      await Future.delayed(const Duration(milliseconds: 800));

      // بيانات وهمية للإشعارات
      allNotifications.value = [
        BusinessOwnerNotification(
          id: '1',
          title: 'طلب دين جديد',
          message: 'أحمد محمد طلب دين بقيمة 1,500 ر.س',
          type: 'client_request',
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        BusinessOwnerNotification(
          id: '2',
          title: 'دين متأخر',
          message: 'دين سارة أحمد متأخر منذ 5 أيام (800 ر.س)',
          type: 'overdue_debt',
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        BusinessOwnerNotification(
          id: '3',
          title: 'دفعة جديدة',
          message: 'محمد علي دفع 500 ر.س من دينه',
          type: 'payment_received',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        BusinessOwnerNotification(
          id: '4',
          title: 'طلب سداد',
          message: 'فاطمة خالد طلبت تأكيد سداد 300 ر.س',
          type: 'client_request',
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
        BusinessOwnerNotification(
          id: '5',
          title: 'تحديث النظام',
          message: 'تم تحديث النظام إلى الإصدار 2.1.0',
          type: 'system_alert',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        BusinessOwnerNotification(
          id: '6',
          title: 'نسخة احتياطية',
          message: 'تم إنشاء نسخة احتياطية من البيانات بنجاح',
          type: 'system_alert',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];

      _applyFilter();
    } catch (e) {
      _showErrorMessage('فشل في تحميل الإشعارات');
    } finally {
      isLoading.value = false;
    }
  }

  /// تطبيق الفلتر
  void _applyFilter() {
    if (selectedFilter.value == null) {
      filteredNotifications.value = allNotifications;
    } else {
      filteredNotifications.value = allNotifications
          .where((notification) => notification.type == selectedFilter.value)
          .toList();
    }
  }

  /// تغيير الفلتر
  void changeFilter(String? filter) {
    selectedFilter.value = filter;
    _applyFilter();
  }

  /// الحصول على عدد الإشعارات حسب النوع
  int getNotificationCountByType(String? type) {
    if (type == null) {
      return allNotifications.length;
    }
    return allNotifications.where((n) => n.type == type).length;
  }

  /// تحديث الإشعارات
  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  /// تمييز الإشعار كمقروء
  void markAsRead(String notificationId) {
    final index = allNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final notification = allNotifications[index];
      if (!notification.isRead) {
        allNotifications[index] = BusinessOwnerNotification(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          isRead: true,
          createdAt: notification.createdAt,
          data: notification.data,
        );
        _applyFilter();
      }
    }
  }

  /// تمييز جميع الإشعارات كمقروءة
  void markAllAsRead() {
    for (int i = 0; i < allNotifications.length; i++) {
      final notification = allNotifications[i];
      if (!notification.isRead) {
        allNotifications[i] = BusinessOwnerNotification(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          isRead: true,
          createdAt: notification.createdAt,
          data: notification.data,
        );
      }
    }
    _applyFilter();
  }

  /// حذف إشعار
  void deleteNotification(String notificationId) {
    allNotifications.removeWhere((n) => n.id == notificationId);
    _applyFilter();
  }

  /// حذف جميع الإشعارات المقروءة
  void deleteReadNotifications() {
    allNotifications.removeWhere((n) => n.isRead);
    _applyFilter();
  }

  /// عرض رسالة خطأ
  void _showErrorMessage(String message) {
    Get.snackbar(
      'خطأ',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 3),
    );
  }

  /// عرض رسالة نجاح
  void _showSuccessMessage(String message) {
    Get.snackbar(
      'نجح',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
      duration: const Duration(seconds: 2),
    );
  }
}

/// أنواع الإشعارات
class NotificationTypes {
  static const String clientRequest = 'client_request';
  static const String overdueDebt = 'overdue_debt';
  static const String paymentReceived = 'payment_received';
  static const String systemAlert = 'system_alert';
}

/// إحصائيات الإشعارات
class NotificationStats {
  final int total;
  final int unread;
  final int clientRequests;
  final int overdueDebts;
  final int systemAlerts;

  NotificationStats({
    required this.total,
    required this.unread,
    required this.clientRequests,
    required this.overdueDebts,
    required this.systemAlerts,
  });
}
