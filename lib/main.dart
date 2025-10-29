import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/services/storage_service.dart';
import 'core/services/theme_service.dart';
import 'core/themes/app_themes.dart';
import 'core/services/notification_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/trial_service.dart';
import 'core/services/security_service.dart';
import 'core/services/subscription_reminder_service.dart';
import 'core/services/advanced_reports_service.dart';
import 'core/services/employee_service.dart';
import 'core/services/credentials_vault_service.dart';
import 'core/services/simplified_database_service.dart';
import 'core/services/firebase_integration_service.dart'; // الخدمة الجديدة
import 'core/services/smart_notification_service.dart'; // نظام الإشعارات الذكي
import 'app/routes/app_pages.dart';
import 'app/controllers/theme_controller.dart';
import 'app/widgets/not_found_screen.dart' as widgets;
import 'app/bindings/initial_binding.dart';
import 'core/utils/enhanced_error_handler.dart';
import 'core/services/logger_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/firestore_service.dart';
import 'core/services/fcm_service.dart';
import 'core/services/unique_id_service.dart';
import 'core/services/role_permission_service.dart';
import 'core/services/offline_service.dart';
import 'core/services/announcements_service.dart';
import 'core/services/biometric_auth_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://3a0d2a651415ccf5a56c71a4eb3e1df7@o4509985971175424.ingest.de.sentry.io/4509990688522320';
      options.tracesSampleRate = 1.0;
      options.debug = false;
      options.environment = 'production';
      options.release = '1.0.1+2';
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();
      EnhancedErrorHandler.initialize();
      await _initializeServices();
      runApp(const DayenMadeenApp());
    },
  );
}

/// تهيئة الخدمات الأساسية
Future<void> _initializeServices() async {
  try {
    LoggerService.info('🚀 بدء تهيئة الخدمات...');

    // === المرحلة 1: Firebase وقاعدة البيانات ===
    await _initializeFirebaseServices();
    
    // === المرحلة 2: الخدمات المحلية ===
    await _initializeLocalServices();
    
    // === المرحلة 3: خدمات التطبيق ===
    await _initializeAppServices();
    
    // === المرحلة 4: الكنترولرات ===
    _registerControllers();

    LoggerService.success('✅ تم تهيئة جميع الخدمات بنجاح');
  } catch (e, stackTrace) {
    EnhancedErrorHandler.handleError(
      error: e,
      stackTrace: stackTrace,
      context: 'تهيئة الخدمات الرئيسية',
      severity: ErrorSeverity.high,
    );
  }
}

/// تهيئة Firebase والخدمات السحابية
Future<void> _initializeFirebaseServices() async {
  try {
    LoggerService.info('🔥 تهيئة Firebase...');
    
    // تسجيل وتهيئة خدمة Firebase المتكاملة
    Get.put(FirebaseIntegrationService(), permanent: true);
    await Get.find<FirebaseIntegrationService>().initializeFirebase();
    
    // الخدمات السحابية الأخرى
    Get.put(FirestoreService(), permanent: true);
    Get.put(SimplifiedDatabaseService(), permanent: true);
    Get.put(UniqueIdService(), permanent: true);
    Get.put(OfflineService(), permanent: true);
    
    // تهيئة خدمة FCM
    await EnhancedErrorHandler.safeExecute(
      operation: () => FcmService.initBackgroundHandler(),
      context: 'تهيئة معالج FCM الخلفي',
      severity: ErrorSeverity.medium,
    );
    
    Get.put(FcmService(), permanent: true);
    await EnhancedErrorHandler.safeExecute(
      operation: () => FcmService.instance.init(),
      context: 'تهيئة خدمة FCM',
      severity: ErrorSeverity.medium,
    );
    
    LoggerService.success('✅ تم تهيئة خدمات Firebase');
  } catch (e, stackTrace) {
    LoggerService.error('❌ خطأ في تهيئة Firebase', error: e);
    // المتابعة بوضع أوفلاين
    EnhancedErrorHandler.handleError(
      error: e,
      stackTrace: stackTrace,
      context: 'Firebase Services',
      severity: ErrorSeverity.high,
    );
    throw e;
  }
}

/// تهيئة الخدمات المحلية
Future<void> _initializeLocalServices() async {
  try {
    LoggerService.info('🏠 تهيئة الخدمات المحلية...');
    
    // التخزين المحلي
    await EnhancedErrorHandler.safeExecute(
      operation: () async {
        await GetStorage.init();
        await StorageService.init();
      },
      context: 'تهيئة التخزين المحلي',
      severity: ErrorSeverity.high,
    );

    // الثيمات
    await EnhancedErrorHandler.safeExecute(
      operation: () => ThemeService.init(),
      context: 'تهيئة خدمة الثيمات',
      severity: ErrorSeverity.low,
    );

    // الإشعارات المحلية
    await EnhancedErrorHandler.safeExecute(
      operation: () => NotificationService.init(),
      context: 'تهيئة الإشعارات المحلية',
      severity: ErrorSeverity.medium,
    );
    
    LoggerService.success('✅ تم تهيئة الخدمات المحلية');
  } catch (e, stackTrace) {
    EnhancedErrorHandler.handleError(
      error: e,
      stackTrace: stackTrace,
      context: 'Local Services',
      severity: ErrorSeverity.medium,
    );
  }
}

/// تهيئة خدمات التطبيق
Future<void> _initializeAppServices() async {
  try {
    LoggerService.info('📱 تهيئة خدمات التطبيق...');
    
    // خدمات المصادقة والأمان
    Get.put(AuthService(), permanent: true);
    Get.put(RolePermissionService(), permanent: true);
    Get.put(SecurityService(), permanent: true);
    Get.put(BiometricAuthService(), permanent: true);
    Get.put(CredentialsVaultService(), permanent: true);
    
    // خدمات العمل
    Get.put(EmployeeService(), permanent: true);
    Get.put(TrialService(), permanent: true);
    Get.put(SubscriptionReminderService(), permanent: true);
    Get.put(AdvancedReportsService(), permanent: true);
    Get.put(AnnouncementsService(), permanent: true);
    
    // نظام الإشعارات الذكي الجديد
    Get.put(SmartNotificationService(), permanent: true);
    
    LoggerService.success('✅ تم تهيئة خدمات التطبيق');
  } catch (e, stackTrace) {
    EnhancedErrorHandler.handleError(
      error: e,
      stackTrace: stackTrace,
      context: 'App Services',
      severity: ErrorSeverity.medium,
    );
  }
}

/// تسجيل الكنترولرات الأساسية
void _registerControllers() {
  Get.put(ThemeController(), permanent: true);
  LoggerService.success('✅ تم تسجيل الكنترولرات');
}

class DayenMadeenApp extends StatelessWidget {
  const DayenMadeenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // معلومات التطبيق
      title: 'دائن مدين',
      debugShowCheckedModeBanner: false,

      // الثيمات
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeService.getThemeMode(),

      // اللغة والاتجاه
      locale: const Locale('ar', 'SA'),
      fallbackLocale: const Locale('ar', 'SA'),

      // المسارات والتنقل
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => const widgets.NotFoundScreen(),
      ),

      // إعدادات التنقل
      defaultTransition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      
      // تحسينات الأداء
      smartManagement: SmartManagement.keepFactory,
      
      // معالج البناء مع معالجة الأخطاء
      builder: (context, child) {
        return EnhancedErrorHandler.safeExecuteSync(
          operation: () => Directionality(
            textDirection: TextDirection.rtl,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: 1.0, // منع تكبير النص من إعدادات النظام
              ),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
          context: 'بناء واجهة التطبيق',
          defaultValue: const SizedBox.shrink(),
          showErrorToUser: false,
          severity: ErrorSeverity.high,
        )!;
      },
    );
  }
}