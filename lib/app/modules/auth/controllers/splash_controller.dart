import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart'; // <-- تمت الإضافة
import 'package:flutter/material.dart'; // For AlertDialog, TextButton, etc.
import 'package:flutter/services.dart'; // For SystemNavigator.pop()

import '../../../../core/services/auth_service.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/models/subscription.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  // حالة التحميل
  var isLoading = true.obs;
  var loadingMessage = 'جاري التحميل...'.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  // تهيئة التطبيق
  Future<void> _initializeApp() async {
    try {
      // 1. طلب الصلاحيات أولاً
      final allPermissionsGranted = await _checkAndRequestPermissions();
      if (!allPermissionsGranted) {
        // إذا لم يتم منح جميع الصلاحيات، سيتم إغلاق التطبيق من داخل الدالة
        return;
      }

      // تحديث رسالة التحميل
      loadingMessage.value = 'تهيئة التطبيق...';

      // تهيئة خدمات التخزين
      await _initializeStorage();

      // تم إزالة قاعدة البيانات المحلية - نستخدم Firestore فقط

      // تحديث معلومات الجهاز
      await _updateDeviceInfo();

      // فحص حالة المصادقة
      await _checkAuthenticationStatus();
    } catch (e) {
      // في حالة الخطأ، الانتقال لشاشة تسجيل الدخول
      _navigateToLogin();
    }
  }

  // تهيئة خدمات التخزين
  Future<void> _initializeStorage() async {
    loadingMessage.value = 'تهيئة التخزين...';
    await StorageService.init();
  }

  // تحديث معلومات الجهاز
  Future<void> _updateDeviceInfo() async {
    loadingMessage.value = 'تحديث معلومات الجهاز...';

    // تحديث عدد مرات فتح التطبيق
    await DeviceService.incrementAppOpenCount();

    // تحديث وقت آخر استخدام
    await DeviceService.updateLastUsed();

    // التأكد من وجود معرف الجهاز
    await DeviceService.getDeviceId();
  }

  // فحص حالة المصادقة
  Future<void> _checkAuthenticationStatus() async {
    loadingMessage.value = 'فحص حالة تسجيل الدخول...';

    // التحقق من وجود مستخدم مسجل
    final isLoggedIn = AuthService.instance.isLoggedIn;

    if (isLoggedIn) {
      // التحقق من صحة الجلسة
      final user = AuthService.instance.currentUser;

      if (user != null && user.isActive) {
        // فحص حالة الاشتراك
        await _checkSubscriptionStatus(user);
      } else {
        // جلسة غير صالحة
        await AuthService.instance.logout();
        _navigateToLogin();
      }
    } else {
      // لا يوجد مستخدم مسجل
      _navigateToLogin();
    }
  }

  // فحص حالة الاشتراك
  Future<void> _checkSubscriptionStatus(user) async {
    loadingMessage.value = 'فحص حالة الاشتراك...';

    try {
      // الحصول على معرف الجهاز
      final deviceId = await DeviceService.getDeviceId();

      // البحث عن الاشتراك
      final subscription =
          await LocalStorageService.getSubscriptionByDeviceId(deviceId);

      if (subscription == null) {
        // لا يوجد اشتراك، إنشاء فترة تجريبية
        await _createTrialSubscription(user, deviceId);
        _navigateToHome();
      } else if (subscription.isExpired) {
        // الاشتراك منتهي
        _navigateToSubscriptionExpired();
      } else {
        // الاشتراك نشط
        _navigateToHome();
      }
    } catch (e) {
      // في حالة الخطأ، الانتقال للرئيسية مع تحذير
      _navigateToHome();
    }
  }

  // إنشاء اشتراك تجريبي
  Future<void> _createTrialSubscription(user, String deviceId) async {
    try {
      final subscription = Subscription.createTrial(
        deviceId: deviceId,
        businessOwnerId: user.id,
        businessName: user.businessName ?? user.name,
        trialDays: AppConstants.trialPeriodDays,
      );

      await LocalStorageService.saveSubscription(subscription);

      // حفظ تاريخ بداية التجربة
      await StorageService.setString(
        AppConstants.keyTrialStartDate,
        subscription.trialStartDate!.toIso8601String(),
      );
    } catch (e) {
      // في حالة فشل إنشاء الاشتراك، المتابعة بدون اشتراك
      print('Error creating trial subscription: $e');
    }
  }

  // الانتقال لشاشة تسجيل الدخول
  void _navigateToLogin() {
    isLoading.value = false;

    // تأخير قصير لإظهار الشاشة
    Future.delayed(const Duration(milliseconds: 500), () {
      Get.offAllNamed(AppRoutes.login);
    });
  }

  // الانتقال للشاشة الرئيسية
  void _navigateToHome() {
    isLoading.value = false;

    // تأخير قصير لإظهار الشاشة
    Future.delayed(const Duration(milliseconds: 500), () {
      Get.offAllNamed(AppRoutes.home);
    });
  }

  // الانتقال لشاشة انتهاء الاشتراك
  void _navigateToSubscriptionExpired() {
    isLoading.value = false;

    // تأخير قصير لإظهار الشاشة
    Future.delayed(const Duration(milliseconds: 500), () {
      Get.offAllNamed(AppRoutes.subscriptionExpired);
    });
  }

  // إعادة تحميل التطبيق
  void reloadApp() {
    isLoading.value = true;
    loadingMessage.value = 'جاري إعادة التحميل...';
    _initializeApp();
  }

  // فحص التحديثات
  Future<void> checkForUpdates() async {
    loadingMessage.value = 'فحص التحديثات...';

    // هنا يمكن إضافة منطق فحص التحديثات
    await Future.delayed(const Duration(seconds: 1));

    // للآن، لا توجد تحديثات
    loadingMessage.value = 'لا توجد تحديثات متاحة';
  }

  // تنظيف البيانات المؤقتة
  Future<void> clearCache() async {
    loadingMessage.value = 'تنظيف البيانات المؤقتة...';

    try {
      // تنظيف البيانات المنتهية الصلاحية
      await StorageService.cleanExpiredData();
      await StorageService.cleanUnusedData();

      loadingMessage.value = 'تم تنظيف البيانات بنجاح';
    } catch (e) {
      loadingMessage.value = 'فشل في تنظيف البيانات';
    }
  }

  // الحصول على معلومات التطبيق
  Map<String, dynamic> getAppInfo() {
    return {
      'name': AppConstants.appName,
      'version': AppConstants.appVersion,
      'buildNumber': AppConstants.appBuildNumber,
      'isFirstTime':
          StorageService.getBool(AppConstants.keyIsFirstTime) ?? true,
      'deviceId': StorageService.getString(AppConstants.keyDeviceId),
    };
  }

  // تصدير سجل التشغيل
  Future<String> exportStartupLog() async {
    final appInfo = getAppInfo();
    final deviceInfo = await DeviceService.exportDeviceInfo();

    return '''
سجل تشغيل التطبيق
================

معلومات التطبيق:
- الاسم: ${appInfo['name']}
- الإصدار: ${appInfo['version']}
- رقم البناء: ${appInfo['buildNumber']}
- أول مرة: ${appInfo['isFirstTime']}
- معرف الجهاز: ${appInfo['deviceId']}

معلومات الجهاز:
${deviceInfo.toString()}

وقت التشغيل: ${DateTime.now()}
''';
  }

  // ===================================================================
  // ============== START: Permission Request Logic ==================
  // ===================================================================

  /// يتحقق ويطلب الصلاحيات المطلوبة لتشغيل التطبيق
  Future<bool> _checkAndRequestPermissions() async {
    loadingMessage.value = 'جاري طلب الصلاحيات...';

    // قائمة الصلاحيات الأساسية المطلوبة
    final List<Permission> permissionsToRequest = [
      Permission.notification, // صلاحية الإشعارات
      Permission.storage, // صلاحية التخزين
    ];

    for (final permission in permissionsToRequest) {
      PermissionStatus status = await permission.status;

      // إذا لم يتم منح الصلاحية، اطلبها
      if (status.isDenied) {
        status = await permission.request();
      }

      // إذا تم رفض الصلاحية بشكل دائم (لا تسأل مرة أخرى)
      if (status.isPermanentlyDenied) {
        await _showPermissionDeniedDialog(permission);
        return false; // إغلاق التطبيق
      }

      // إذا تم رفض الصلاحية (ولكن ليس بشكل دائم)
      if (!status.isGranted) {
        await _showPermissionDeniedDialog(permission, isPermanent: false);
        return false; // إغلاق التطبيق
      }
    }
    return true; // تم منح جميع الصلاحيات
  }

  /// يعرض حواراً للمستخدم عند رفض الصلاحية
  Future<void> _showPermissionDeniedDialog(Permission permission,
      {bool isPermanent = true}) async {
    String permissionName = '';
    switch (permission) {
      case Permission.storage:
        permissionName = 'التخزين';
        break;
      case Permission.manageExternalStorage:
        permissionName = 'إدارة الملفات';
        break;
      case Permission.notification:
        permissionName = 'الإشعارات';
        break;
      default:
        permissionName = 'صلاحية غير معروفة';
    }

    await Get.dialog(
      AlertDialog(
        title: Text('صلاحية ${permissionName} مطلوبة'),
        content: Text(
          isPermanent
              ? 'التطبيق يحتاج صلاحية ${permissionName} للعمل بشكل صحيح. الرجاء تفعيلها من إعدادات التطبيق.'
              : 'التطبيق يحتاج صلاحية ${permissionName} للمتابعة. الرجاء السماح بها.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // إغلاق الحوار
              SystemNavigator.pop(); // إغلاق التطبيق
            },
            child: const Text('إغلاق التطبيق'),
          ),
          if (isPermanent)
            TextButton(
              onPressed: () {
                Get.back(); // إغلاق الحوار
                openAppSettings(); // فتح إعدادات التطبيق
              },
              child: const Text('فتح الإعدادات'),
            ),
        ],
      ),
      barrierDismissible: false, // المستخدم يجب أن يتفاعل مع الحوار
    );
  }

  // ===================================================================
  // ============== END: Permission Request Logic ====================
  // ===================================================================

  @override
  void onClose() {
    // تنظيف الموارد
    super.onClose();
  }
}
