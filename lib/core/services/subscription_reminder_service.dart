import 'dart:async';
import 'package:get/get.dart';
import 'trial_service.dart';
import 'notification_service.dart';
import 'storage_service.dart';

/// خدمة تذكيرات الاشتراك والفترة التجريبية
class SubscriptionReminderService extends GetxService {
  static SubscriptionReminderService get instance =>
      Get.find<SubscriptionReminderService>();

  Timer? _reminderTimer;

  // أيام التذكير قبل انتهاء الفترة التجريبية
  static const List<int> reminderDays = [7, 3, 1, 0];

  @override
  Future<void> onInit() async {
    super.onInit();
    await _startReminderService();
  }

  @override
  void onClose() {
    _reminderTimer?.cancel();
    super.onClose();
  }

  /// بدء خدمة التذكيرات
  Future<void> _startReminderService() async {
    // فحص فوري عند البدء
    await _checkAndSendReminders();

    // فحص دوري كل ساعة
    _reminderTimer = Timer.periodic(
      const Duration(hours: 1),
      (timer) => _checkAndSendReminders(),
    );
  }

  /// فحص وإرسال التذكيرات
  Future<void> _checkAndSendReminders() async {
    try {
      final trialService = TrialService.instance;

      // التحقق من حالة الفترة التجريبية
      if (!trialService.isTrialActive) {
        await _handleExpiredTrial();
        return;
      }

      // فحص التذكيرات المطلوبة
      for (final days in reminderDays) {
        if (await trialService.shouldSendReminder(days)) {
          await _sendTrialReminder(days);
          await trialService.markReminderSent(days);
        }
      }
    } catch (e) {
      print('خطأ في فحص التذكيرات: $e');
    }
  }

  /// إرسال تذكير الفترة التجريبية
  Future<void> _sendTrialReminder(int daysRemaining) async {
    String title;
    String message;

    switch (daysRemaining) {
      case 7:
        title = 'تذكير: الفترة التجريبية';
        message =
            'تنتهي فترتك التجريبية خلال 7 أيام. احصل على اشتراك لمواصلة الاستخدام.';
        break;
      case 3:
        title = 'تحذير: الفترة التجريبية';
        message =
            'تنتهي فترتك التجريبية خلال 3 أيام فقط! اشترك الآن لتجنب انقطاع الخدمة.';
        break;
      case 1:
        title = 'تحذير عاجل: الفترة التجريبية';
        message =
            'تنتهي فترتك التجريبية غداً! اشترك فوراً لمواصلة استخدام التطبيق.';
        break;
      case 0:
        title = 'انتهت الفترة التجريبية';
        message = 'انتهت فترتك التجريبية اليوم. يرجى الاشتراك للمتابعة.';
        break;
      default:
        title = 'تذكير الاشتراك';
        message = 'تنتهي فترتك التجريبية خلال $daysRemaining أيام.';
    }

    // إرسال الإشعار
    await NotificationService.showNotification(
      title: title,
      body: message,
      type: 'subscription',
      data: {'daysRemaining': daysRemaining},
    );

    // حفظ سجل التذكير
    await _logReminder(daysRemaining, title, message);
  }

  /// التعامل مع انتهاء الفترة التجريبية
  Future<void> _handleExpiredTrial() async {
    await NotificationService.showNotification(
      title: 'انتهت الفترة التجريبية',
      body: 'لقد انتهت فترتك التجريبية. يرجى الاشتراك لمواصلة الاستخدام.',
      type: 'subscription',
      data: {'type': 'trial_expired'},
    );

    // إيقاف التذكيرات
    _reminderTimer?.cancel();
  }

  /// حفظ سجل التذكير
  Future<void> _logReminder(
      int daysRemaining, String title, String message) async {
    final logs = StorageService.getList('reminder_logs') ?? [];

    logs.add({
      'daysRemaining': daysRemaining,
      'title': title,
      'message': message,
      'sentAt': DateTime.now().toIso8601String(),
    });

    // الاحتفاظ بآخر 50 تذكير فقط
    if (logs.length > 50) {
      logs.removeRange(0, logs.length - 50);
    }

    await StorageService.setList('reminder_logs', logs);
  }

  /// الحصول على سجل التذكيرات
  List<Map<String, dynamic>> getReminderLogs() {
    final logs = StorageService.getList('reminder_logs') ?? [];
    return logs.cast<Map<String, dynamic>>();
  }

  /// مسح سجل التذكيرات
  Future<void> clearReminderLogs() async {
    await StorageService.remove('reminder_logs');
  }

  /// فحص فوري للتذكيرات (للاستخدام اليدوي)
  Future<void> checkRemindersNow() async {
    await _checkAndSendReminders();
  }

  /// إعادة تشغيل خدمة التذكيرات
  Future<void> restartReminderService() async {
    _reminderTimer?.cancel();
    await _startReminderService();
  }

  /// الحصول على معلومات حالة الخدمة
  Map<String, dynamic> getServiceStatus() {
    return {
      'isRunning': _reminderTimer?.isActive ?? false,
      'nextCheck':
          DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      'reminderDays': reminderDays,
      'totalReminders': getReminderLogs().length,
    };
  }
}
