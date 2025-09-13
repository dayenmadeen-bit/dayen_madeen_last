import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class FcmService extends GetxService {
  static FcmService get instance => Get.find<FcmService>();

  late final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  @override
  void onInit() {
    _messaging = FirebaseMessaging.instance;
    super.onInit();
  }

  static Future<void> initBackgroundHandler() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> init() async {
    await _requestPermissions();
    await _initLocalNotifications();

    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      _showLocal(message);
    });

    // App opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleTap(message);
    });
  }

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);
    await _local.initialize(initSettings,
        onDidReceiveNotificationResponse: (details) {
      // Handle local tap if needed
    });
  }

  Future<void> _showLocal(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'default_channel',
      'General Notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const NotificationDetails details =
        NotificationDetails(android: androidDetails);
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  void _handleTap(RemoteMessage message) {
    // Route based on message.data if needed
  }

  // ========== إشعارات الديون والدفعات ==========

  /// إرسال إشعار دين جديد
  Future<void> sendNewDebtNotification({
    required String customerName,
    required double amount,
    required String businessOwnerId,
  }) async {
    try {
      final title = 'دين جديد';
      final body =
          'تم إضافة دين جديد للعميل $customerName بقيمة ${amount.toStringAsFixed(2)} ريال';

      await _sendNotificationToBusinessOwner(
        businessOwnerId: businessOwnerId,
        title: title,
        body: body,
        type: 'new_debt',
        data: {
          'customer_name': customerName,
          'amount': amount.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('خطأ في إرسال إشعار الدين الجديد: $e');
    }
  }

  /// إرسال إشعار دفعة مستلمة
  Future<void> sendPaymentReceivedNotification({
    required String customerName,
    required double amount,
    required String businessOwnerId,
  }) async {
    try {
      final title = 'دفعة مستلمة';
      final body =
          'تم استلام دفعة من العميل $customerName بقيمة ${amount.toStringAsFixed(2)} ريال';

      await _sendNotificationToBusinessOwner(
        businessOwnerId: businessOwnerId,
        title: title,
        body: body,
        type: 'payment_received',
        data: {
          'customer_name': customerName,
          'amount': amount.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('خطأ في إرسال إشعار الدفعة المستلمة: $e');
    }
  }

  /// إرسال إشعار تجاوز حد الائتمان
  Future<void> sendCreditLimitExceededNotification({
    required String customerName,
    required double currentDebt,
    required double creditLimit,
    required String businessOwnerId,
  }) async {
    try {
      final title = 'تجاوز حد الائتمان';
      final body =
          'العميل $customerName تجاوز حد الائتمان. الدين الحالي: ${currentDebt.toStringAsFixed(2)} ريال، الحد المسموح: ${creditLimit.toStringAsFixed(2)} ريال';

      await _sendNotificationToBusinessOwner(
        businessOwnerId: businessOwnerId,
        title: title,
        body: body,
        type: 'credit_limit_exceeded',
        data: {
          'customer_name': customerName,
          'current_debt': currentDebt.toString(),
          'credit_limit': creditLimit.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('خطأ في إرسال إشعار تجاوز حد الائتمان: $e');
    }
  }

  /// إرسال إشعار انتهاء التجربة المجانية
  Future<void> sendTrialExpiredNotification({
    required String businessOwnerId,
    required String businessName,
  }) async {
    try {
      final title = 'انتهت التجربة المجانية';
      final body =
          'انتهت التجربة المجانية لـ $businessName. يرجى الاشتراك للاستمرار في استخدام التطبيق';

      await _sendNotificationToBusinessOwner(
        businessOwnerId: businessOwnerId,
        title: title,
        body: body,
        type: 'trial_expired',
        data: {
          'business_name': businessName,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('خطأ في إرسال إشعار انتهاء التجربة المجانية: $e');
    }
  }

  /// إرسال إشعار تذكير بالدفع للعميل
  Future<void> sendPaymentReminderToCustomer({
    required String customerId,
    required String customerName,
    required double debtAmount,
    required String businessName,
  }) async {
    try {
      final title = 'تذكير بالدفع';
      final body =
          'مرحباً $customerName، لديك دين مستحق بقيمة ${debtAmount.toStringAsFixed(2)} ريال لـ $businessName';

      await _sendNotificationToCustomer(
        customerId: customerId,
        title: title,
        body: body,
        type: 'payment_reminder',
        data: {
          'customer_name': customerName,
          'debt_amount': debtAmount.toString(),
          'business_name': businessName,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('خطأ في إرسال تذكير الدفع للعميل: $e');
    }
  }

  /// إرسال إشعار لصاحب العمل
  Future<void> _sendNotificationToBusinessOwner({
    required String businessOwnerId,
    required String title,
    required String body,
    required String type,
    required Map<String, String> data,
  }) async {
    try {
      // إرسال إشعار محلي
      await _local.show(
        businessOwnerId.hashCode,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'business_notifications',
            'إشعارات الأعمال',
            channelDescription: 'إشعارات متعلقة بالأعمال والديون والدفعات',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: type,
      );

      // إرسال إشعار FCM للسيرفر
      await _sendFCMNotification(businessOwnerId, title, body, data);
    } catch (e) {
      print('خطأ في إرسال الإشعار لصاحب العمل: $e');
    }
  }

  /// إرسال إشعار للعميل
  Future<void> _sendNotificationToCustomer({
    required String customerId,
    required String title,
    required String body,
    required String type,
    required Map<String, String> data,
  }) async {
    try {
      // إرسال إشعار محلي
      await _local.show(
        customerId.hashCode,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'customer_notifications',
            'إشعارات العملاء',
            channelDescription: 'إشعارات متعلقة بالديون والدفعات',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: type,
      );

      // إرسال إشعار FCM للسيرفر
      await _sendFCMNotification(customerId, title, body, data);
    } catch (e) {
      print('خطأ في إرسال الإشعار للعميل: $e');
    }
  }

  /// إرسال إشعار FCM للسيرفر (للمستقبل)
  Future<void> _sendFCMNotification(
    String targetUserId,
    String title,
    String body,
    Map<String, String> data,
  ) async {
    // TODO: تنفيذ إرسال FCM للسيرفر
    // هذا يتطلب سيرفر لإرسال الإشعارات
    print('إرسال FCM: $title - $body إلى $targetUserId');
  }

  /// إعداد قنوات الإشعارات
  Future<void> _setupNotificationChannels() async {
    const AndroidNotificationChannel businessChannel =
        AndroidNotificationChannel(
      'business_notifications',
      'إشعارات الأعمال',
      description: 'إشعارات متعلقة بالأعمال والديون والدفعات',
      importance: Importance.high,
    );

    const AndroidNotificationChannel customerChannel =
        AndroidNotificationChannel(
      'customer_notifications',
      'إشعارات العملاء',
      description: 'إشعارات متعلقة بالديون والدفعات',
      importance: Importance.high,
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(businessChannel);

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(customerChannel);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Optionally handle background messages
}
