import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../../app/data/models/debt.dart';
import '../../app/data/models/customer.dart';
import 'firestore_service.dart';
import 'notification_service.dart';
import 'storage_service.dart';
import 'logger_service.dart';

/// نظام إشعارات ذكي يراقب الديون ويرسل تنبيهات تلقائية
class SmartNotificationService extends GetxService {
  static SmartNotificationService get instance => Get.find<SmartNotificationService>();

  Timer? _reminderTimer;
  Timer? _dailyCheckTimer;
  final _unreadNotifications = 0.obs;
  final _overdueDebts = <Debt>[].obs;
  final _upcomingPayments = <Debt>[].obs;

  // خدمات مرتبطة
  late final FirestoreService _firestoreService;
  late final NotificationService _notificationService;

  // إعدادات التذكير
  final _settings = {
    'overdueReminders': true,
    'upcomingPayments': true,
    'dailyReports': true,
    'weeklyReports': false,
    'reminderHour': 9, // الساعة 9 صباحاً
  }.obs;

  int get unreadNotificationsCount => _unreadNotifications.value;
  List<Debt> get overdueDebts => _overdueDebts;
  List<Debt> get upcomingPayments => _upcomingPayments;
  Map<String, dynamic> get settings => _settings;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    _loadSettings();
    _startPeriodicChecks();
  }

  @override
  void onClose() {
    _reminderTimer?.cancel();
    _dailyCheckTimer?.cancel();
    super.onClose();
  }

  /// تهيئة الخدمات
  void _initializeServices() {
    try {
      _firestoreService = Get.find<FirestoreService>();
      _notificationService = Get.find<NotificationService>();
      LoggerService.success('تم تهيئة خدمات الإشعارات الذكية');
    } catch (e) {
      LoggerService.error('خطأ في تهيئة خدمات الإشعارات', error: e);
    }
  }

  /// تحميل إعدادات الإشعارات
  void _loadSettings() {
    try {
      final savedSettings = StorageService.getJson('notification_settings') ?? {};
      _settings.addAll(savedSettings);
      LoggerService.info('تم تحميل إعدادات الإشعارات');
    } catch (e) {
      LoggerService.warning('استخدام إعدادات افتراضية للإشعارات');
    }
  }

  /// حفظ إعدادات الإشعارات
  Future<void> _saveSettings() async {
    try {
      await StorageService.setJson('notification_settings', _settings);
      LoggerService.success('تم حفظ إعدادات الإشعارات');
    } catch (e) {
      LoggerService.error('خطأ في حفظ إعدادات الإشعارات', error: e);
    }
  }

  /// بدء عمليات الفحص الدورية
  void _startPeriodicChecks() {
    // فحص كل ساعة
    _reminderTimer = Timer.periodic(const Duration(hours: 1), (_) {
      if (_settings['overdueReminders'] == true) {
        _checkOverdueDebts();
      }
      if (_settings['upcomingPayments'] == true) {
        _checkUpcomingPayments();
      }
    });

    // فحص يومي في ساعة محددة
    _dailyCheckTimer = Timer.periodic(const Duration(hours: 1), (_) {
      final now = DateTime.now();
      if (now.hour == _settings['reminderHour'] &&
          _settings['dailyReports'] == true) {
        _sendDailySummary();
      }
    });

    // فحص فوري عند البدء
    _checkOverdueDebts();
    _checkUpcomingPayments();
    
    LoggerService.info('تم بدء نظام الإشعارات الذكي');
  }

  /// فحص الديون المتأخرة
  Future<void> _checkOverdueDebts() async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestoreService
          .debtsCol()
          .where('status', whereIn: ['pending', 'partially_paid'])
          .where('dueDate', isLessThan: Timestamp.fromDate(now))
          .limit(50)
          .get();

      final overdueList = querySnapshot.docs
          .map((doc) => Debt.fromFirestore(doc.data(), doc.id))
          .toList();

      _overdueDebts.value = overdueList;

      if (overdueList.isNotEmpty) {
        await _sendOverdueNotification(overdueList);
        _updateUnreadCount();
      }

      LoggerService.info('تم فحص الديون المتأخرة: ${overdueList.length} دين متأخر');
    } catch (e) {
      LoggerService.error('خطأ في فحص الديون المتأخرة', error: e);
    }
  }

  /// فحص الدفعات القريبة الاستحقاق
  Future<void> _checkUpcomingPayments() async {
    try {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final nextWeek = DateTime.now().add(const Duration(days: 7));
      
      final querySnapshot = await _firestoreService
          .debtsCol()
          .where('status', whereIn: ['pending', 'partially_paid'])
          .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(tomorrow))
          .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(nextWeek))
          .limit(30)
          .get();

      final upcomingList = querySnapshot.docs
          .map((doc) => Debt.fromFirestore(doc.data(), doc.id))
          .toList();

      _upcomingPayments.value = upcomingList;

      if (upcomingList.isNotEmpty) {
        await _sendUpcomingPaymentsNotification(upcomingList);
      }

      LoggerService.info('تم فحص الدفعات القريبة: ${upcomingList.length} دفعة قريبة');
    } catch (e) {
      LoggerService.error('خطأ في فحص الدفعات القريبة', error: e);
    }
  }

  /// إرسال إشعار الديون المتأخرة
  Future<void> _sendOverdueNotification(List<Debt> overdueDebts) async {
    try {
      final totalAmount = overdueDebts.fold<double>(
          0.0, (sum, debt) => sum + debt.remainingAmount);
      
      final title = 'ديون متأخرة ❗';
      final body = 'لديك ${overdueDebts.length} دين متأخر بمجموع ${totalAmount.toStringAsFixed(2)} ر.ي';
      
      // إشعار داخلي
      _showInAppNotification(
        title: title,
        message: body,
        type: NotificationType.warning,
        action: () => Get.toNamed('/debts', parameters: {'filter': 'overdue'}),
      );

      // إشعار محلي
      await _notificationService.showNotification(
        id: 'overdue_debts',
        title: title,
        body: body,
        icon: AppIcons.warning,
        color: AppColors.error,
      );

      LoggerService.info('تم إرسال إشعار الديون المتأخرة');
    } catch (e) {
      LoggerService.error('خطأ في إرسال إشعار الديون المتأخرة', error: e);
    }
  }

  /// إرسال إشعار الدفعات القريبة
  Future<void> _sendUpcomingPaymentsNotification(List<Debt> upcomingPayments) async {
    try {
      final title = 'دفعات قريبة الاستحقاق ⏰';
      final body = 'لديك ${upcomingPayments.length} دفعة قريبة الاستحقاق خلال الأسبوع';
      
      // إشعار داخلي
      _showInAppNotification(
        title: title,
        message: body,
        type: NotificationType.info,
        action: () => Get.toNamed('/debts', parameters: {'filter': 'upcoming'}),
      );

      // إشعار محلي
      await _notificationService.showNotification(
        id: 'upcoming_payments',
        title: title,
        body: body,
        icon: AppIcons.time,
        color: AppColors.info,
      );

      LoggerService.info('تم إرسال إشعار الدفعات القريبة');
    } catch (e) {
      LoggerService.error('خطأ في إرسال إشعار الدفعات القريبة', error: e);
    }
  }

  /// إرسال ملخص يومي
  Future<void> _sendDailySummary() async {
    try {
      // حساب إحصائيات اليوم
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // ديون اليوم
      final todayDebtsQuery = await _firestoreService
          .debtsCol()
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      // مدفوعات اليوم
      final todayPaymentsQuery = await _firestoreService
          .paymentsCol()
          .where('paymentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('paymentDate', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      final debtsCount = todayDebtsQuery.docs.length;
      final paymentsCount = todayPaymentsQuery.docs.length;
      final overdueCount = _overdueDebts.length;

      if (debtsCount > 0 || paymentsCount > 0 || overdueCount > 0) {
        final title = 'ملخص يومي 📈';
        final body = 'اليوم: $debtsCount دين جديد، $paymentsCount دفعة، $overdueCount دين متأخر';

        _showInAppNotification(
          title: title,
          message: body,
          type: NotificationType.info,
          action: () => Get.toNamed('/reports/daily'),
        );

        await _notificationService.showNotification(
          id: 'daily_summary',
          title: title,
          body: body,
          icon: AppIcons.analytics,
          color: AppColors.info,
        );
      }

      LoggerService.info('تم إرسال الملخص اليومي');
    } catch (e) {
      LoggerService.error('خطأ في إرسال الملخص اليومي', error: e);
    }
  }

  /// عرض إشعار داخل التطبيق
  void _showInAppNotification({
    required String title,
    required String message,
    required NotificationType type,
    VoidCallback? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    Color backgroundColor;
    IconData icon;

    switch (type) {
      case NotificationType.success:
        backgroundColor = AppColors.success;
        icon = AppIcons.checkCircle;
        break;
      case NotificationType.warning:
        backgroundColor = AppColors.warning;
        icon = AppIcons.warning;
        break;
      case NotificationType.error:
        backgroundColor = AppColors.error;
        icon = AppIcons.error;
        break;
      case NotificationType.info:
      default:
        backgroundColor = AppColors.info;
        icon = AppIcons.info;
        break;
    }

    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      isDismissible: true,
      onTap: action != null ? (_) => action() : null,
      mainButton: action != null
          ? TextButton(
              onPressed: () {
                Get.back(); // أغلق الإشعار
                action();
              },
              child: const Text(
                'عرض',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  /// تحديث عدد الإشعارات غير المقروءة
  void _updateUnreadCount() {
    final overdueCount = _overdueDebts.length;
    final upcomingCount = _upcomingPayments.length;
    _unreadNotifications.value = overdueCount + upcomingCount;
  }

  /// تعيين إعداد معين
  Future<void> updateSetting(String key, dynamic value) async {
    _settings[key] = value;
    await _saveSettings();
    LoggerService.info('تم تحديث إعداد الإشعارات: $key = $value');
  }

  /// تفعيل/إيقاف نوع معين من الإشعارات
  Future<void> toggleNotificationType(String type, bool enabled) async {
    await updateSetting(type, enabled);
    
    if (enabled) {
      // اعادة بدء الفحوصات عند التفعيل
      if (type == 'overdueReminders') {
        _checkOverdueDebts();
      } else if (type == 'upcomingPayments') {
        _checkUpcomingPayments();
      }
    }
  }

  /// تغيير ساعة التذكير اليومي
  Future<void> setReminderHour(int hour) async {
    if (hour >= 0 && hour <= 23) {
      await updateSetting('reminderHour', hour);
    }
  }

  /// مسح جميع الإشعارات
  void clearAllNotifications() {
    _unreadNotifications.value = 0;
    LoggerService.info('تم مسح جميع الإشعارات');
  }

  /// فرض فحص فوري
  Future<void> forceCheck() async {
    LoggerService.info('بدء فحص فوري للإشعارات');
    await Future.wait([
      _checkOverdueDebts(),
      _checkUpcomingPayments(),
    ]);
    _updateUnreadCount();
  }

  /// إرسال إشعار فوري مخصص
  Future<void> sendCustomNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
    VoidCallback? action,
  }) async {
    _showInAppNotification(
      title: title,
      message: message,
      type: type,
      action: action,
    );

    await _notificationService.showNotification(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: message,
      icon: AppIcons.info,
      color: AppColors.primary,
    );
  }
}

/// أنواع الإشعارات
enum NotificationType {
  success,
  warning,
  error,
  info,
}