import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'storage_service.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'logger_service.dart';

/// خدمة إدارة الفترة التجريبية والاشتراك
class TrialService extends GetxService {
  static TrialService get instance => Get.find<TrialService>();

  // مدة الفترة التجريبية بالأيام
  static const int trialDurationDays = 30;

  // مفاتيح التخزين
  static const String _keyTrialStartDate = 'trial_start_date';
  static const String _keyTrialEndDate = 'trial_end_date';
  static const String _keyIsTrialActive = 'is_trial_active';
  static const String _keyTrialNotificationsSent = 'trial_notifications_sent';
  static const String _keyFirstLaunch = 'is_first_launch';
  static const String _keySubscriptionActive = 'subscription_active';
  static const String _keySubscriptionEndDate = 'subscription_end_date';

  // الخدمات
  late final FirestoreService _firestoreService;
  late String _ownerDocId;

  // حالات الاشتراك
  final RxBool _isSubscriptionActive = false.obs;
  final RxBool _isTrialActive = false.obs;
  final RxInt _remainingTrialDays = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    try {
      _firestoreService = Get.find<FirestoreService>();
      _ownerDocId = AuthService.instance.currentUser?.id ?? '';
      await _initializeTrial();
      await _loadSubscriptionStatus();
    } catch (e) {
      LoggerService.error('خطأ في تهيئة TrialService', error: e);
    }
  }

  // Getters
  bool get isSubscriptionActive => _isSubscriptionActive.value;
  bool get isTrialActive => _isTrialActive.value;
  int get remainingTrialDays => _remainingTrialDays.value;
  bool get hasActiveSubscription => isSubscriptionActive || isTrialActive;

  /// تهيئة الفترة التجريبية عند أول تشغيل
  Future<void> _initializeTrial() async {
    final isFirstLaunch = StorageService.getBool(_keyFirstLaunch) ?? true;

    if (isFirstLaunch) {
      await startTrial();
      await StorageService.setBool(_keyFirstLaunch, false);
    }
  }

  /// بدء الفترة التجريبية
  Future<void> startTrial() async {
    try {
      final startDate = DateTime.now();
      final endDate = startDate.add(const Duration(days: trialDurationDays));

      // حفظ محلياً
      await StorageService.setString(
          _keyTrialStartDate, startDate.toIso8601String());
      await StorageService.setString(
          _keyTrialEndDate, endDate.toIso8601String());
      await StorageService.setBool(_keyIsTrialActive, true);
      await StorageService.setList(_keyTrialNotificationsSent, []);

      // حفظ في Firestore
      await _saveTrialToFirestore(startDate, endDate);

      _isTrialActive.value = true;
      _remainingTrialDays.value = trialDurationDays;

      LoggerService.success(
          'تم بدء الفترة التجريبية: ${trialDurationDays} يوم');
    } catch (e) {
      LoggerService.error('خطأ في بدء الفترة التجريبية', error: e);
    }
  }

  /// حفظ الفترة التجريبية في Firestore
  Future<void> _saveTrialToFirestore(
      DateTime startDate, DateTime endDate) async {
    try {
      if (_ownerDocId.isEmpty) return;
      await _firestoreService.usersCol().doc(_ownerDocId).set({
        'trialStartDate': Timestamp.fromDate(startDate),
        'trialEndDate': Timestamp.fromDate(endDate),
        'isTrialActive': true,
        'subscriptionStatus': 'trial',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      LoggerService.error('خطأ في حفظ الفترة التجريبية في Firestore', error: e);
    }
  }

  /// تحميل حالة الاشتراك من Firestore
  Future<void> _loadSubscriptionStatus() async {
    try {
      if (_ownerDocId.isEmpty) return;

      final doc = await _firestoreService.usersCol().doc(_ownerDocId).get();
      if (!doc.exists) return;

      final data = doc.data()!;

      // تحميل حالة الاشتراك
      _isSubscriptionActive.value = data['subscriptionActive'] ?? false;

      // تحميل الفترة التجريبية
      final trialStart = data['trialStartDate'] as Timestamp?;
      final trialEnd = data['trialEndDate'] as Timestamp?;

      if (trialStart != null && trialEnd != null) {
        final now = DateTime.now();
        final endDate = trialEnd.toDate();

        _isTrialActive.value =
            now.isBefore(endDate) && !_isSubscriptionActive.value;

        if (_isTrialActive.value) {
          _remainingTrialDays.value = endDate.difference(now).inDays + 1;
        }
      }
    } catch (e) {
      LoggerService.error('خطأ في تحميل حالة الاشتراك', error: e);
    }
  }

  /// تفعيل الاشتراك
  Future<bool> activateSubscription({
    required String planType,
    required int durationMonths,
    required String paymentMethod,
    String? transactionId,
  }) async {
    try {
      final startDate = DateTime.now();
      final endDate = startDate.add(Duration(days: durationMonths * 30));

      // حفظ محلياً
      await StorageService.setBool(_keySubscriptionActive, true);
      await StorageService.setString(
          _keySubscriptionEndDate, endDate.toIso8601String());

      // حفظ في Firestore
      if (_ownerDocId.isEmpty) return false;
      await _firestoreService.usersCol().doc(_ownerDocId).set({
        'subscriptionActive': true,
        'subscriptionStartDate': Timestamp.fromDate(startDate),
        'subscriptionEndDate': Timestamp.fromDate(endDate),
        'subscriptionPlan': planType,
        'paymentMethod': paymentMethod,
        'transactionId': transactionId,
        'subscriptionStatus': 'active',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _isSubscriptionActive.value = true;
      _isTrialActive.value = false;

      LoggerService.success('تم تفعيل الاشتراك: $planType');
      return true;
    } catch (e) {
      LoggerService.error('خطأ في تفعيل الاشتراك', error: e);
      return false;
    }
  }

  /// إلغاء الاشتراك
  Future<bool> cancelSubscription() async {
    try {
      // حفظ محلياً
      await StorageService.setBool(_keySubscriptionActive, false);

      // حفظ في Firestore
      if (_ownerDocId.isEmpty) return false;
      await _firestoreService.usersCol().doc(_ownerDocId).set({
        'subscriptionActive': false,
        'subscriptionStatus': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _isSubscriptionActive.value = false;

      LoggerService.success('تم إلغاء الاشتراك');
      return true;
    } catch (e) {
      LoggerService.error('خطأ في إلغاء الاشتراك', error: e);
      return false;
    }
  }

  /// التحقق من انتهاء الاشتراك
  bool get isSubscriptionExpired {
    if (!_isSubscriptionActive.value) return true;

    final endDateString = StorageService.getString(_keySubscriptionEndDate);
    if (endDateString == null) return true;

    final endDate = DateTime.tryParse(endDateString);
    if (endDate == null) return true;

    return DateTime.now().isAfter(endDate);
  }

  /// الحصول على معلومات الاشتراك
  Map<String, dynamic> getSubscriptionInfo() {
    return {
      'isActive': _isSubscriptionActive.value,
      'isExpired': isSubscriptionExpired,
      'endDate': StorageService.getString(_keySubscriptionEndDate),
      'hasActiveSubscription': hasActiveSubscription,
    };
  }

  /// الحصول على تاريخ بداية الفترة التجريبية
  DateTime? getTrialStartDate() {
    final dateString = StorageService.getString(_keyTrialStartDate);
    if (dateString == null) return null;
    return DateTime.tryParse(dateString);
  }

  /// الحصول على تاريخ انتهاء الفترة التجريبية
  DateTime? getTrialEndDate() {
    final dateString = StorageService.getString(_keyTrialEndDate);
    if (dateString == null) return null;
    return DateTime.tryParse(dateString);
  }

  /// الحصول على عدد الأيام المتبقية في الفترة التجريبية
  int get remainingTrialDaysLocal {
    final endDate = getTrialEndDate();
    if (endDate == null) return 0;

    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;

    return endDate.difference(now).inDays + 1;
  }

  /// التحقق من انتهاء الفترة التجريبية
  bool get isTrialExpired {
    final endDate = getTrialEndDate();
    if (endDate == null) return true;

    return DateTime.now().isAfter(endDate);
  }

  /// التحقق من الحاجة لإرسال تذكير
  Future<bool> shouldSendReminder(int daysBeforeExpiry) async {
    if (isTrialExpired) return false;

    final remainingDays = remainingTrialDays;
    if (remainingDays != daysBeforeExpiry) return false;

    final sentNotifications =
        StorageService.getList(_keyTrialNotificationsSent) ?? [];
    return !sentNotifications.contains(daysBeforeExpiry);
  }

  /// تسجيل إرسال تذكير
  Future<void> markReminderSent(int daysBeforeExpiry) async {
    final sentNotifications =
        StorageService.getList(_keyTrialNotificationsSent) ?? [];
    sentNotifications.add(daysBeforeExpiry);
    await StorageService.setList(_keyTrialNotificationsSent, sentNotifications);
  }

  /// إنهاء الفترة التجريبية
  Future<void> endTrial() async {
    await StorageService.setBool(_keyIsTrialActive, false);
    print('⏰ انتهت الفترة التجريبية');
  }

  /// الحصول على معلومات الفترة التجريبية
  Map<String, dynamic> getTrialInfo() {
    return {
      'isActive': isTrialActive,
      'isExpired': isTrialExpired,
      'startDate': getTrialStartDate()?.toIso8601String(),
      'endDate': getTrialEndDate()?.toIso8601String(),
      'remainingDays': remainingTrialDays,
      'totalDays': trialDurationDays,
    };
  }

  /// تنسيق تاريخ انتهاء الفترة التجريبية
  String get formattedTrialEndDate {
    final endDate = getTrialEndDate();
    if (endDate == null) return 'غير محدد';

    return '${endDate.day.toString().padLeft(2, '0')}/'
        '${endDate.month.toString().padLeft(2, '0')}/'
        '${endDate.year}';
  }

  /// رسالة حالة الفترة التجريبية
  String get trialStatusMessage {
    if (isTrialExpired) {
      return 'انتهت الفترة التجريبية';
    } else if (remainingTrialDays <= 3) {
      return 'تنتهي الفترة التجريبية خلال $remainingTrialDays أيام';
    } else {
      return 'الفترة التجريبية نشطة - متبقي $remainingTrialDays يوم';
    }
  }

  /// التحقق من إمكانية الوصول لميزة معينة
  bool canAccessFeature(String feature) {
    // إذا كان لديه اشتراك نشط، يمكنه الوصول لجميع الميزات
    if (_isSubscriptionActive.value && !isSubscriptionExpired) {
      return true;
    }

    // إذا كان في الفترة التجريبية، يمكنه الوصول للميزات الأساسية فقط
    if (_isTrialActive.value && !isTrialExpired) {
      const trialFeatures = [
        'view_customers',
        'add_customers',
        'edit_customers',
        'view_debts',
        'add_debts',
        'view_payments',
        'add_payments',
        'view_reports',
        'basic_settings',
      ];
      return trialFeatures.contains(feature);
    }

    // إذا لم يكن لديه اشتراك أو فترة تجريبية، لا يمكنه الوصول لأي ميزة
    return false;
  }

  /// التحقق من الحاجة لإظهار شاشة الاشتراك
  bool shouldShowSubscriptionScreen() {
    return !hasActiveSubscription || isTrialExpired || isSubscriptionExpired;
  }

  /// الحصول على رسالة حالة الاشتراك
  String getSubscriptionStatusMessage() {
    if (_isSubscriptionActive.value && !isSubscriptionExpired) {
      return 'الاشتراك نشط';
    } else if (_isTrialActive.value && !isTrialExpired) {
      return 'الفترة التجريبية نشطة - متبقي $_remainingTrialDays يوم';
    } else if (isTrialExpired && !_isSubscriptionActive.value) {
      return 'انتهت الفترة التجريبية - يرجى الاشتراك للاستمرار';
    } else if (isSubscriptionExpired) {
      return 'انتهى الاشتراك - يرجى تجديد الاشتراك';
    } else {
      return 'لا يوجد اشتراك نشط';
    }
  }

  /// الحصول على الميزات المتاحة في الفترة التجريبية
  List<String> get availableTrialFeatures => [
        'عرض العملاء',
        'إضافة العملاء',
        'تعديل العملاء',
        'عرض الديون',
        'إضافة الديون',
        'عرض المدفوعات',
        'إضافة المدفوعات',
        'عرض التقارير',
        'الإعدادات الأساسية',
      ];

  /// الحصول على الميزات المحدودة في الفترة التجريبية
  List<String> get limitedTrialFeatures => [
        'حذف العملاء',
        'حذف الديون',
        'حذف المدفوعات',
        'تصدير التقارير',
        'إدارة الموظفين',
        'الإشعارات المتقدمة',
        'النسخ الاحتياطي',
        'الإعدادات المتقدمة',
      ];

  /// إرسال إشعارات انتهاء الفترة التجريبية
  Future<void> sendTrialExpirationNotifications() async {
    if (!isTrialActive || isTrialExpired) return;

    final userId = StorageService.getString('user_unique_id') ?? '';
    if (userId.isEmpty) return;

    final remainingDays = remainingTrialDays;
    final notificationsSent =
        StorageService.getList(_keyTrialNotificationsSent) ?? [];

    // إشعار قبل 7 أيام
    if (remainingDays == 7 && !notificationsSent.contains('7_days')) {
      await _sendTrialNotification('7 أيام متبقية',
          'تنتهي الفترة التجريبية خلال 7 أيام', userId, remainingDays);
      notificationsSent.add('7_days');
    }

    // إشعار قبل 3 أيام
    if (remainingDays == 3 && !notificationsSent.contains('3_days')) {
      await _sendTrialNotification('3 أيام متبقية',
          'تنتهي الفترة التجريبية خلال 3 أيام', userId, remainingDays);
      notificationsSent.add('3_days');
    }

    // إشعار قبل يوم واحد
    if (remainingDays == 1 && !notificationsSent.contains('1_day')) {
      await _sendTrialNotification('يوم واحد متبقي',
          'تنتهي الفترة التجريبية غداً', userId, remainingDays);
      notificationsSent.add('1_day');
    }

    // إشعار انتهاء الفترة
    if (remainingDays == 0 && !notificationsSent.contains('expired')) {
      await _sendTrialNotification(
          'انتهت الفترة التجريبية',
          'انتهت الفترة التجريبية. يرجى الاشتراك للاستمرار',
          userId,
          remainingDays);
      notificationsSent.add('expired');
    }

    await StorageService.setList(_keyTrialNotificationsSent, notificationsSent);
  }

  /// إرسال إشعار الفترة التجريبية
  Future<void> _sendTrialNotification(
      String title, String body, String userId, int daysRemaining) async {
    try {
      // إرسال إشعار FCM
      // يمكن إضافة منطق إرسال الإشعارات هنا لاحقاً
      print('إشعار الفترة التجريبية: $title - $body');
    } catch (e) {
      print('خطأ في إرسال إشعار الفترة التجريبية: $e');
    }
  }

  /// تمديد الفترة التجريبية (للمطورين فقط)
  Future<void> extendTrial(int additionalDays) async {
    if (!isTrialActive) return;

    final currentEndDate = getTrialEndDate();
    if (currentEndDate == null) return;

    final newEndDate = currentEndDate.add(Duration(days: additionalDays));
    await StorageService.setString(
        _keyTrialEndDate, newEndDate.toIso8601String());

    print('تم تمديد الفترة التجريبية بـ $additionalDays يوم');
  }

  /// إعادة تعيين الفترة التجريبية (للمطورين فقط)
  Future<void> resetTrial() async {
    await StorageService.remove(_keyTrialStartDate);
    await StorageService.remove(_keyTrialEndDate);
    await StorageService.remove(_keyIsTrialActive);
    await StorageService.remove(_keyTrialNotificationsSent);
    await StorageService.setBool(_keyFirstLaunch, true);

    await startTrial();
    print('تم إعادة تعيين الفترة التجريبية');
  }

  /// التحقق من الحاجة لإظهار تحذير انتهاء الفترة
  bool shouldShowExpirationWarning() {
    if (!isTrialActive || isTrialExpired) return false;
    return remainingTrialDays <= 3;
  }

  /// الحصول على رسالة تحذير انتهاء الفترة
  String getExpirationWarningMessage() {
    if (!isTrialActive) return 'الفترة التجريبية غير نشطة';
    if (isTrialExpired)
      return 'انتهت الفترة التجريبية. يرجى الاشتراك للاستمرار';

    final remaining = remainingTrialDays;
    if (remaining == 1) {
      return 'تنتهي الفترة التجريبية غداً. يرجى الاشتراك للاستمرار في استخدام جميع الميزات';
    } else if (remaining <= 3) {
      return 'تنتهي الفترة التجريبية خلال $remaining أيام. يرجى الاشتراك للاستمرار في استخدام جميع الميزات';
    }

    return 'الفترة التجريبية نشطة';
  }
}
