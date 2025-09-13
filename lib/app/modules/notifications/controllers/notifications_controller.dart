import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../data/models/app_notification.dart' as app_models;
import '../../../routes/app_routes.dart';

/// كنترولر إدارة الإشعارات
class NotificationsController extends GetxController {
  // ===== المتغيرات التفاعلية =====

  // حالة التحميل
  final isLoading = false.obs;

  // قائمة الإشعارات
  final notifications = <LocalNotification>[].obs;

  // الإشعارات المفلترة
  final filteredNotifications = <LocalNotification>[].obs;

  // عداد الإشعارات غير المقروءة
  final unreadCount = 0.obs;

  // الفلتر المحدد
  final selectedFilter = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
    _setupNotificationListener();
  }

  // ===== تحميل البيانات =====

  // تحميل الإشعارات
  Future<void> _loadNotifications() async {
    try {
      isLoading.value = true;

      // تحميل الإشعارات من الخدمة
      notifications.value = NotificationService.notifications;
      unreadCount.value = NotificationService.unreadCount;

      // تطبيق الفلتر
      _applyFilter();
    } catch (e) {
      _showErrorMessage('فشل في تحميل الإشعارات');
    } finally {
      isLoading.value = false;
    }
  }

  // إعداد مستمع تحديثات الإشعارات
  void _setupNotificationListener() {
    // مراقبة تغييرات الإشعارات
    ever(notifications, (_) {
      unreadCount.value = NotificationService.unreadCount;
      _applyFilter();
    });
  }

  // ===== إدارة الفلاتر =====

  // تعيين فلتر
  void setFilter(String? filter) {
    selectedFilter.value = filter;
    _applyFilter();
  }

  // تطبيق الفلتر
  void _applyFilter() {
    List<LocalNotification> filtered = notifications;

    if (selectedFilter.value != null) {
      switch (selectedFilter.value) {
        case 'unread':
          filtered = notifications.where((n) => !n.isRead).toList();
          break;
        default:
          // فلترة حسب نوع الإشعار
          final type = app_models.NotificationType.values.firstWhereOrNull(
            (t) => t.name == selectedFilter.value,
          );
          if (type != null) {
            filtered = notifications.where((n) => n.type == type).toList();
          }
          break;
      }
    }

    filteredNotifications.value = filtered;
  }

  // ===== إجراءات الإشعارات =====

  // تحديد إشعار كمقروء
  Future<void> markAsRead(String notificationId) async {
    try {
      await NotificationService.markAsRead(notificationId);
      await _loadNotifications();

      _showSuccessMessage('تم تحديد الإشعار كمقروء');
    } catch (e) {
      _showErrorMessage('فشل في تحديث الإشعار');
    }
  }

  // تحديد جميع الإشعارات كمقروءة
  Future<void> markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead();
      await _loadNotifications();

      _showSuccessMessage('تم تحديد جميع الإشعارات كمقروءة');
    } catch (e) {
      _showErrorMessage('فشل في تحديث الإشعارات');
    }
  }

  // حذف إشعار
  Future<void> deleteNotification(String notificationId) async {
    try {
      await NotificationService.deleteNotification(notificationId);
      await _loadNotifications();

      _showSuccessMessage('تم حذف الإشعار');
    } catch (e) {
      _showErrorMessage('فشل في حذف الإشعار');
    }
  }

  // حذف جميع الإشعارات
  Future<void> clearAllNotifications() async {
    // عرض تأكيد
    final confirmed = await _showConfirmationDialog(
      'حذف جميع الإشعارات',
      'هل أنت متأكد من حذف جميع الإشعارات؟ لا يمكن التراجع عن هذا الإجراء.',
    );

    if (!confirmed) return;

    try {
      await NotificationService.clearAllNotifications();
      await _loadNotifications();

      _showSuccessMessage('تم حذف جميع الإشعارات');
    } catch (e) {
      _showErrorMessage('فشل في حذف الإشعارات');
    }
  }

  // ===== التفاعل مع الإشعارات =====

  // النقر على إشعار
  Future<void> onNotificationTap(LocalNotification notification) async {
    // تحديد الإشعار كمقروء إذا لم يكن مقروءاً
    if (!notification.isRead) {
      await markAsRead(notification.id);
    }

    // التنقل حسب نوع الإشعار
    _handleNotificationNavigation(notification);
  }

  // التعامل مع التنقل حسب نوع الإشعار
  void _handleNotificationNavigation(LocalNotification notification) {
    switch (notification.type) {
      case 'payment_received':
        // الانتقال لتفاصيل الدفعة
        final paymentId = notification.data['paymentId'];
        if (paymentId != null) {
          Get.toNamed(AppRoutes.paymentDetails,
              arguments: {'paymentId': paymentId});
        } else {
          Get.toNamed(AppRoutes.payments);
        }
        break;

      case 'debt':
        // الانتقال لتفاصيل الدين
        final debtId = notification.data['debtId'];
        if (debtId != null) {
          Get.toNamed(AppRoutes.debtDetails, arguments: {'debtId': debtId});
        } else {
          Get.toNamed(AppRoutes.debts);
        }
        break;

      case 'subscription':
        // الانتقال لشاشة الاشتراك
        Get.toNamed(AppRoutes.subscription);
        break;

      case 'success':
      case 'error':
        // عرض تفاصيل الإشعار
        _showNotificationDetails(notification);
        break;

      default:
        // عرض تفاصيل الإشعار
        _showNotificationDetails(notification);
        break;
    }
  }

  // عرض تفاصيل الإشعار
  void _showNotificationDetails(LocalNotification notification) {
    Get.dialog(
      AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 16),
            Text(
              'الوقت: ${_formatDateTime(notification.timestamp)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            if (notification.data.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'بيانات إضافية:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              ...notification.data.entries
                  .map((entry) => Text(
                        '${entry.key}: ${entry.value}',
                        style: const TextStyle(fontSize: 12),
                      ))
                  .toList(),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إغلاق'),
          ),
          if (!notification.isRead)
            TextButton(
              onPressed: () {
                Get.back();
                markAsRead(notification.id);
              },
              child: const Text('تحديد كمقروء'),
            ),
        ],
      ),
    );
  }

  // ===== التنقل =====

  // الانتقال لإعدادات الإشعارات
  void goToNotificationSettings() {
    Get.toNamed('/notification-settings');
  }

  // ===== التحديث =====

  // تحديث الإشعارات
  Future<void> refreshNotifications() async {
    await _loadNotifications();
  }

  // ===== الدوال المساعدة =====

  // تنسيق التاريخ والوقت
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // عرض حوار التأكيد
  Future<bool> _showConfirmationDialog(String title, String message) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // عرض رسالة نجاح
  void _showSuccessMessage(String message) {
    Get.snackbar(
      'نجح',
      message,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  // عرض رسالة خطأ
  void _showErrorMessage(String message) {
    Get.snackbar(
      'خطأ',
      message,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  // ===== إنشاء إشعارات تجريبية =====

  // إنشاء إشعارات تجريبية للاختبار
  Future<void> createTestNotifications() async {
    await NotificationService.showNotification(
      title: 'مرحباً بك',
      body: 'هذا إشعار تجريبي للترحيب',
      type: 'system',
    );

    await NotificationService.showDebtReminderNotification(
      customerName: 'أحمد محمد',
      amount: 500.0,
      dueDate: DateTime.now().add(const Duration(days: 3)),
    );

    await NotificationService.showPaymentNotification(
      customerName: 'فاطمة علي',
      amount: 250.0,
      paymentMethod: 'نقدي',
    );

    await NotificationService.showSubscriptionExpiryNotification(
      daysRemaining: 5,
    );

    await NotificationService.showBackupNotification(
      isSuccess: true,
    );

    await _loadNotifications();
  }
}
