import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import 'storage_service.dart';

/// أنواع الإشعارات
enum NotificationType {
  system('system', 'النظام', 'إشعارات النظام والتحديثات'),
  employee('employee', 'الموظفين', 'إشعارات الموظفين والعمليات'),
  customer('customer', 'العملاء', 'إشعارات العملاء والطلبات'),
  debt('debt', 'الديون', 'إشعارات الديون والمدفوعات'),
  payment('payment', 'المدفوعات', 'إشعارات المدفوعات'),
  subscription('subscription', 'الاشتراك', 'إشعارات الاشتراك والدفع'),
  security('security', 'الأمان', 'إشعارات الأمان والتحقق');

  const NotificationType(this.value, this.displayName, this.description);

  final String value;
  final String displayName;
  final String description;
}

/// فلتر الإشعارات
class NotificationFilter {
  final NotificationType? type;
  final bool? isRead;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? searchQuery;

  const NotificationFilter({
    this.type,
    this.isRead,
    this.fromDate,
    this.toDate,
    this.searchQuery,
  });
}

/// خدمة الإشعارات المحلية والخارجية
class NotificationService {
  // منع إنشاء instance من الكلاس
  NotificationService._();

  // قائمة الإشعارات المحلية
  static final RxList<LocalNotification> _notifications =
      <LocalNotification>[].obs;

  // عداد الإشعارات غير المقروءة
  static final RxInt _unreadCount = 0.obs;

  // الفلتر الحالي
  static final Rx<NotificationFilter> _currentFilter =
      const NotificationFilter().obs;

  // Firebase Messaging
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  // Local Notifications
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // ===== الخصائص العامة =====

  static List<LocalNotification> get notifications => _notifications;
  static int get unreadCount => _unreadCount.value;
  static bool get hasUnreadNotifications => _unreadCount.value > 0;
  static NotificationFilter get currentFilter => _currentFilter.value;

  // ===== فلترة الإشعارات =====

  /// تطبيق فلتر على الإشعارات
  static void applyFilter(NotificationFilter filter) {
    _currentFilter.value = filter;
  }

  /// إزالة الفلتر
  static void clearFilter() {
    _currentFilter.value = const NotificationFilter();
  }

  /// الحصول على الإشعارات المفلترة
  static List<LocalNotification> get filteredNotifications {
    List<LocalNotification> filtered = List.from(_notifications);

    final filter = _currentFilter.value;

    // فلترة حسب النوع
    if (filter.type != null) {
      filtered = filtered
          .where((notification) => notification.type == filter.type!.value)
          .toList();
    }

    // فلترة حسب حالة القراءة
    if (filter.isRead != null) {
      filtered = filtered
          .where((notification) => notification.isRead == filter.isRead)
          .toList();
    }

    // فلترة حسب التاريخ
    if (filter.fromDate != null) {
      filtered = filtered
          .where((notification) =>
              notification.timestamp.isAfter(filter.fromDate!) ||
              notification.timestamp.isAtSameMomentAs(filter.fromDate!))
          .toList();
    }

    if (filter.toDate != null) {
      filtered = filtered
          .where((notification) =>
              notification.timestamp.isBefore(filter.toDate!) ||
              notification.timestamp.isAtSameMomentAs(filter.toDate!))
          .toList();
    }

    // فلترة حسب البحث
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!.toLowerCase();
      filtered = filtered
          .where((notification) =>
              notification.title.toLowerCase().contains(query) ||
              notification.body.toLowerCase().contains(query))
          .toList();
    }

    // ترتيب حسب التاريخ (الأحدث أولاً)
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return filtered;
  }

  /// الحصول على عدد الإشعارات المفلترة
  static int get filteredCount => filteredNotifications.length;

  /// الحصول على عدد الإشعارات غير المقروءة المفلترة
  static int get filteredUnreadCount {
    return filteredNotifications.where((n) => !n.isRead).length;
  }

  /// الحصول على إحصائيات الإشعارات حسب النوع
  static Map<NotificationType, int> get notificationsByType {
    Map<NotificationType, int> stats = {};

    for (final type in NotificationType.values) {
      stats[type] = _notifications.where((n) => n.type == type.value).length;
    }

    return stats;
  }

  // ===== تهيئة الخدمة =====

  static Future<void> init() async {
    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
    await _loadNotifications();
    _schedulePeriodicChecks();
  }

  // تهيئة الإشعارات المحلية
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // تهيئة Firebase Messaging
  static Future<void> _initializeFirebaseMessaging() async {
    // طلب إذن الإشعارات
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // إعداد معالج الإشعارات
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // الحصول على token مع معالجة الأخطاء (SERVICE_NOT_AVAILABLE وغيرها)
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _saveFCMToken(token);
      }
    } catch (e) {
      debugPrint('[NotificationService] FCM getToken failed: $e');
      // تجاهل الفشل واستمر بدون كسر تهيئة الخدمات
    }
  }

  // معالج الإشعارات في المقدمة
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    await showNotification(
      title: message.notification?.title ?? 'إشعار جديد',
      body: message.notification?.body ?? '',
      type: message.data['type'] ?? 'system',
      data: message.data,
    );
  }

  // معالج النقر على الإشعار
  static Future<void> _handleNotificationTap(RemoteMessage message) async {
    // معالجة النقر على الإشعار
    final data = message.data;
    if (data['route'] != null) {
      Get.toNamed(data['route'], arguments: data['arguments']);
    }
  }

  // معالج الإشعارات في الخلفية
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // معالجة الإشعارات في الخلفية
    await showNotification(
      title: message.notification?.title ?? 'إشعار جديد',
      body: message.notification?.body ?? '',
      type: message.data['type'] ?? 'system',
      data: message.data,
    );
  }

  // معالج النقر على الإشعار المحلي
  static void _onNotificationTapped(NotificationResponse response) {
    final data = response.payload != null
        ? Map<String, dynamic>.from(response.payload as Map)
        : <String, dynamic>{};

    if (data['route'] != null) {
      Get.toNamed(data['route'], arguments: data['arguments']);
    }
  }

  // حفظ FCM Token
  static Future<void> _saveFCMToken(String token) async {
    await StorageService.setString('fcm_token', token);
    // هنا يمكن إرسال الـ token إلى الخادم
  }

  // تحميل الإشعارات المحفوظة
  static Future<void> _loadNotifications() async {
    try {
      final notificationsData = StorageService.getList('notifications') ?? [];
      _notifications.clear();

      for (final data in notificationsData) {
        final notification = LocalNotification.fromJson(data);
        _notifications.add(notification);
      }

      _updateUnreadCount();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  // حفظ الإشعارات
  static Future<void> _saveNotifications() async {
    try {
      final notificationsData = _notifications.map((n) => n.toJson()).toList();
      await StorageService.setList('notifications', notificationsData);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  // ===== إنشاء الإشعارات =====

  // إشعار عام
  static Future<void> showNotification({
    required String title,
    required String body,
    String type = 'system',
    Map<String, dynamic>? data,
    VoidCallback? onTap,
  }) async {
    final notification = LocalNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      data: data ?? {},
      timestamp: DateTime.now(),
    );

    _notifications.insert(0, notification);
    _updateUnreadCount();
    await _saveNotifications();

    // عرض الإشعار في الواجهة
    _showSnackbarNotification(notification, onTap);
  }

  // إشعار تذكير بالديون المستحقة
  static Future<void> showDebtReminderNotification({
    required String customerName,
    required double amount,
    required DateTime dueDate,
    String? debtId,
  }) async {
    await showNotification(
      title: 'تذكير بدين مستحق',
      body:
          'دين $customerName بقيمة ${amount.toStringAsFixed(2)} ر.س مستحق في ${AppConstants.formatDate(dueDate)}',
      type: 'debt',
      data: {
        'debtId': debtId,
        'customerName': customerName,
        'amount': amount,
        'dueDate': dueDate.toIso8601String(),
      },
    );
  }

  // إشعار دفعة جديدة
  static Future<void> showPaymentNotification({
    required String customerName,
    required double amount,
    required String paymentMethod,
    String? paymentId,
  }) async {
    await showNotification(
      title: 'دفعة جديدة',
      body:
          'تم استلام دفعة من $customerName بقيمة ${amount.toStringAsFixed(2)} ر.س ($paymentMethod)',
      type: 'payment',
      data: {
        'paymentId': paymentId,
        'customerName': customerName,
        'amount': amount,
        'paymentMethod': paymentMethod,
      },
    );
  }

  // إشعار انتهاء الاشتراك
  static Future<void> showSubscriptionExpiryNotification({
    required int daysRemaining,
  }) async {
    String message;
    if (daysRemaining <= 0) {
      message = 'انتهى اشتراكك. يرجى التجديد للمتابعة';
    } else if (daysRemaining == 1) {
      message = 'ينتهي اشتراكك غداً. يرجى التجديد';
    } else {
      message = 'ينتهي اشتراكك خلال $daysRemaining أيام';
    }

    await showNotification(
      title: 'تذكير الاشتراك',
      body: message,
      type: 'subscription',
      data: {
        'daysRemaining': daysRemaining,
      },
    );
  }

  // إشعار نسخة احتياطية
  static Future<void> showBackupNotification({
    required bool isSuccess,
    String? errorMessage,
  }) async {
    if (isSuccess) {
      await showNotification(
        title: 'نسخة احتياطية',
        body: 'تم إنشاء النسخة الاحتياطية بنجاح',
        type: 'system',
      );
    } else {
      await showNotification(
        title: 'فشل النسخة الاحتياطية',
        body: errorMessage ?? 'فشل في إنشاء النسخة الاحتياطية',
        type: 'system',
      );
    }
  }

  // إشعار طلب مشتريات من العميل
  static Future<void> showPurchaseRequestNotification({
    required String customerName,
    required String businessName,
    required String requestDetails,
    String? requestId,
  }) async {
    await showNotification(
      title: 'طلب مشتريات جديد',
      body: '$customerName يطلب مشتريات من $businessName',
      type: 'customer',
      data: {
        'requestId': requestId,
        'customerName': customerName,
        'businessName': businessName,
        'requestDetails': requestDetails,
        'route': '/purchase-requests',
        'arguments': {'requestId': requestId},
      },
    );
  }

  // إشعار طلب دفعة من العميل
  static Future<void> showPaymentRequestNotification({
    required String customerName,
    required String businessName,
    required double amount,
    String? requestId,
  }) async {
    await showNotification(
      title: 'طلب دفعة جديد',
      body:
          '$customerName يطلب تسجيل دفعة بقيمة ${amount.toStringAsFixed(2)} ر.س',
      type: 'customer',
      data: {
        'requestId': requestId,
        'customerName': customerName,
        'businessName': businessName,
        'amount': amount,
        'route': '/payment-requests',
        'arguments': {'requestId': requestId},
      },
    );
  }

  // إشعار عملية موظف
  static Future<void> showEmployeeActionNotification({
    required String employeeName,
    required String action,
    required String details,
    String? actionId,
  }) async {
    await showNotification(
      title: 'عملية موظف',
      body: '$employeeName قام بـ $action',
      type: 'employee',
      data: {
        'actionId': actionId,
        'employeeName': employeeName,
        'action': action,
        'details': details,
        'route': '/employee-actions',
        'arguments': {'actionId': actionId},
      },
    );
  }

  // إشعار تحديث النظام
  static Future<void> showSystemUpdateNotification({
    required String version,
    required List<String> features,
  }) async {
    final featuresText = features.join('، ');
    await showNotification(
      title: 'تحديث النظام',
      body:
          'تم تحديث التطبيق إلى الإصدار $version. الميزات الجديدة: $featuresText',
      type: 'system',
      data: {
        'version': version,
        'features': features,
        'route': '/system-updates',
      },
    );
  }

  // إشعار قرب انتهاء الاشتراك
  static Future<void> showSubscriptionWarningNotification({
    required int daysRemaining,
  }) async {
    String message;
    if (daysRemaining <= 0) {
      message = 'انتهى اشتراكك. يرجى التجديد فوراً للمتابعة';
    } else if (daysRemaining <= 3) {
      message = 'اشتراكك ينتهي خلال $daysRemaining أيام. يرجى التجديد';
    } else {
      message = 'اشتراكك ينتهي خلال $daysRemaining أيام';
    }

    await showNotification(
      title: 'تذكير الاشتراك',
      body: message,
      type: 'subscription',
      data: {
        'daysRemaining': daysRemaining,
        'route': '/subscription',
      },
    );
  }

  // ===== إدارة الإشعارات =====

  // تحديد إشعار كمقروء
  static Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _updateUnreadCount();
      await _saveNotifications();
    }
  }

  // تحديد جميع الإشعارات كمقروءة
  static Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _updateUnreadCount();
    await _saveNotifications();
  }

  // حذف إشعار
  static Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    _updateUnreadCount();
    await _saveNotifications();
  }

  // حذف جميع الإشعارات
  static Future<void> clearAllNotifications() async {
    _notifications.clear();
    _updateUnreadCount();
    await _saveNotifications();
  }

  // حذف الإشعارات القديمة (أكثر من 30 يوم)
  static Future<void> cleanOldNotifications() async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    _notifications.removeWhere((n) => n.timestamp.isBefore(cutoffDate));
    _updateUnreadCount();
    await _saveNotifications();
  }

  // ===== الفحص الدوري =====

  // جدولة الفحص الدوري للديون المستحقة
  static void _schedulePeriodicChecks() {
    // فحص كل ساعة
    Stream.periodic(const Duration(hours: 1)).listen((_) {
      _checkOverdueDebts();
      _checkSubscriptionExpiry();
    });

    // فحص يومي للنظام
    Stream.periodic(const Duration(days: 1)).listen((_) {
      _checkSystemReminder();
      cleanOldNotifications();
    });
  }

  // فحص الديون المستحقة
  static Future<void> _checkOverdueDebts() async {
    // سيتم ربطها مع خدمة الديون لاحقاً
    // هنا يمكن إضافة منطق فحص الديون المستحقة
  }

  // فحص انتهاء الاشتراك
  static Future<void> _checkSubscriptionExpiry() async {
    // سيتم ربطها مع خدمة الاشتراكات لاحقاً
    // هنا يمكن إضافة منطق فحص انتهاء الاشتراك
  }

  // تذكير النظام
  static Future<void> _checkSystemReminder() async {
    // يمكن إضافة تذكيرات أخرى هنا
    await showNotification(
      title: 'تذكير النظام',
      body: 'تأكد من تحديث التطبيق للحصول على أحدث الميزات',
      type: 'system',
    );
  }

  // ===== الدوال المساعدة =====

  // تحديث عداد الإشعارات غير المقروءة
  static void _updateUnreadCount() {
    _unreadCount.value = _notifications.where((n) => !n.isRead).length;
  }

  // عرض الإشعار في الواجهة
  static void _showSnackbarNotification(
      LocalNotification notification, VoidCallback? onTap) {
    // التحقق من تفعيل الإشعارات
    final isEnabled = StorageService.getBool('notifications_enabled') ?? true;
    if (!isEnabled) return;

    // عرض السنackbar بعد انتهاء الإطار الحالي لتفادي أخطاء GetX في الرسم
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.snackbar(
        notification.title,
        notification.body,
        backgroundColor: _getNotificationColor(notification.type),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: Icon(
          _getNotificationIcon(notification.type),
          color: Colors.white,
        ),
        onTap: onTap != null ? (_) => onTap() : null,
        isDismissible: true,
      );
    });
  }

  // الحصول على لون الإشعار
  static Color _getNotificationColor(String type) {
    switch (type) {
      case 'success':
        return AppColors.success;
      case 'error':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      case 'debt':
        return AppColors.warning;
      case 'payment':
        return AppColors.success;
      case 'subscription':
        return AppColors.primary;
      case 'employee':
        return AppColors.info;
      case 'customer':
        return AppColors.primary;
      case 'security':
        return AppColors.error;
      case 'system':
      default:
        return AppColors.info;
    }
  }

  // الحصول على أيقونة الإشعار
  static IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'debt':
        return Icons.schedule;
      case 'payment':
        return Icons.payment;
      case 'subscription':
        return Icons.card_membership;
      case 'employee':
        return Icons.people;
      case 'customer':
        return Icons.person;
      case 'security':
        return Icons.security;
      case 'system':
      default:
        return Icons.info;
    }
  }

  // الحصول على الإشعارات حسب النوع
  static List<LocalNotification> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // الحصول على الإشعارات غير المقروءة
  static List<LocalNotification> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  // الحصول على آخر الإشعارات
  static List<LocalNotification> getRecentNotifications({int limit = 10}) {
    return _notifications.take(limit).toList();
  }

  // ===== إدارة الإشعارات المتقدمة =====

  // إرسال إشعار محلي مع تفاصيل
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String type = 'system',
    Map<String, dynamic>? data,
    int? id,
  }) async {
    final notificationId =
        id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000);

    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'الإشعارات العامة',
      channelDescription: 'إشعارات التطبيق العامة',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notificationId,
      title,
      body,
      details,
      payload: data?.toString(),
    );
  }

  // إرسال إشعار مجدول
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String type = 'system',
    Map<String, dynamic>? data,
    int? id,
  }) async {
    // final notificationId =
    //     id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000);

    // const androidDetails = AndroidNotificationDetails(
    //   'scheduled_channel',
    //   'الإشعارات المجدولة',
    //   channelDescription: 'الإشعارات المجدولة مسبقاً',
    //   importance: Importance.high,
    //   priority: Priority.high,
    // );

    // const iosDetails = DarwinNotificationDetails(
    //   presentAlert: true,
    //   presentBadge: true,
    //   presentSound: true,
    // );

    // const details = NotificationDetails(
    //   android: androidDetails,
    //   iOS: iosDetails,
    // );

    // Note: Implement timezone support for scheduled notifications
    // await _localNotifications.zonedSchedule(
    //   notificationId,
    //   title,
    //   body,
    //   scheduledDate,
    //   details,
    //   payload: data?.toString(),
    //   uiLocalNotificationDateInterpretation:
    //       UILocalNotificationDateInterpretation.absoluteTime,
    // );

    // Fallback to immediate notification
    await showLocalNotification(
      title: title,
      body: body,
      data: data,
    );
  }

  // إلغاء إشعار مجدول
  static Future<void> cancelScheduledNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  // إلغاء جميع الإشعارات المجدولة
  static Future<void> cancelAllScheduledNotifications() async {
    await _localNotifications.cancelAll();
  }

  // الحصول على FCM Token
  static Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  // الاشتراك في موضوع معين
  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // إلغاء الاشتراك من موضوع
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  // إعدادات الإشعارات
  static Future<void> updateNotificationSettings({
    bool? enabled,
    bool? sound,
    bool? vibration,
    bool? badge,
  }) async {
    if (enabled != null) {
      await StorageService.setBool('notifications_enabled', enabled);
    }
    if (sound != null) {
      await StorageService.setBool('notifications_sound', sound);
    }
    if (vibration != null) {
      await StorageService.setBool('notifications_vibration', vibration);
    }
    if (badge != null) {
      await StorageService.setBool('notifications_badge', badge);
    }
  }

  // الحصول على إعدادات الإشعارات
  static Map<String, bool> getNotificationSettings() {
    return {
      'enabled': StorageService.getBool('notifications_enabled') ?? true,
      'sound': StorageService.getBool('notifications_sound') ?? true,
      'vibration': StorageService.getBool('notifications_vibration') ?? true,
      'badge': StorageService.getBool('notifications_badge') ?? true,
    };
  }

  // إحصائيات الإشعارات
  static Map<String, int> getNotificationStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthAgo = today.subtract(const Duration(days: 30));

    return {
      'total': _notifications.length,
      'unread': _notifications.where((n) => !n.isRead).length,
      'today': _notifications.where((n) => n.timestamp.isAfter(today)).length,
      'thisWeek':
          _notifications.where((n) => n.timestamp.isAfter(weekAgo)).length,
      'thisMonth':
          _notifications.where((n) => n.timestamp.isAfter(monthAgo)).length,
    };
  }
}

/// نموذج الإشعار المحلي
class LocalNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool isRead;

  const LocalNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.timestamp,
    this.isRead = false,
  });

  LocalNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return LocalNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory LocalNotification.fromJson(Map<String, dynamic> json) {
    return LocalNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'] ?? json['message'] ?? '',
      type: json['type'] ?? 'system',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      timestamp: DateTime.parse(json['timestamp'] ?? json['createdAt']),
      isRead: json['isRead'] ?? false,
    );
  }
}
