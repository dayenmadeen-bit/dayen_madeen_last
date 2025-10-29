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
import 'core/services/simplified_database_service.dart'; // خدمة جديدة
import 'app/routes/app_pages.dart';
import 'app/controllers/theme_controller.dart';
import 'app/widgets/not_found_screen.dart' as widgets;
import 'app/bindings/initial_binding.dart';
import 'core/utils/enhanced_error_handler.dart'; // مدير أخطاء محسن
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
      options.dsn =
          'https://3a0d2a651415ccf5a56c71a4eb3e1df7@o4509985971175424.ingest.de.sentry.io/4509990688522320';
      options.tracesSampleRate = 1.0;
      options.debug = false; // تم إيقافه في الإنتاج
      options.environment = 'production'; // تحديد بيئة الإنتاج
      options.release = '1.0.1+2'; // إصدار التطبيق
    },
    appRunner: () async {
      // تأكد من تهيئة Flutter
      WidgetsFlutterBinding.ensureInitialized();

      // تهيئة مدير الأخطاء المحسن
      EnhancedErrorHandler.initialize();

      // تهيئة الخدمات الأساسية
      await _initializeServices();

      // تشغيل التطبيق
      runApp(const DayenMadeenApp());
    },
  );
}

/// تهيئة الخدمات الأساسية
Future<void> _initializeServices() async {
  try {
    LoggerService.info('بدء تهيئة الخدمات...');

    // === تهيئة Firebase ===
    await _initializeFirebase();
    
    // === تهيئة قاعدة البيانات والخدمات السحابية ===
    await _initializeDatabaseServices();
    
    // === تهيئة الخدمات المحلية ===
    await _initializeLocalServices();
    
    // === تهيئة خدمات التطبيق ===
    await _initializeAppServices();
    
    // === تسجيل الكنترولرات ===
    _registerControllers();

    LoggerService.success('تم تهيئة جميع الخدمات بنجاح');
  } catch (e, stackTrace) {
    EnhancedErrorHandler.handleError(
      error: e,
      stackTrace: stackTrace,
      context: 'تهيئة الخدمات',
      severity: ErrorSeverity.high,
    );
  }
}

/// تهيئة Firebase
Future<void> _initializeFirebase() async {
  try {
    try {
      // التحقق من وجود تطبيق Firebase مهيأ مسبقاً
      Firebase.app();
      LoggerService.info('Firebase مُهيّأ مسبقاً، سيتم استخدام التطبيق الافتراضي');
    } catch (_) {
      // لم يتم تهيئته بعد، قم بالتهيئة الآن
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      LoggerService.success('تم تهيئة Firebase بنجاح');
    }
  } catch (e, stackTrace) {
    EnhancedErrorHandler.handleError(
      error: e,
      stackTrace: stackTrace,
      context: 'تهيئة Firebase',
      severity: ErrorSeverity.high,
    );
    
    // رغم فشل Firebase، ستتم المتابعة بوضع أوفلاين
    LoggerService.warning('تعذر تهيئة Firebase، سيتم المتابعة بدونها مؤقتاً');
    throw e; // إعادة رفع الخطأ للمعالجة في المستوى الأعلى
  }
}

/// تهيئة خدمات قاعدة البيانات
Future<void> _initializeDatabaseServices() async {
  // تفعيل وضع الأوفلاين لـ Firestore
  await EnhancedErrorHandler.safeExecute(
    operation: () => FirestoreService.enableOfflinePersistence(),
    context: 'تفعيل وضع الأوفلاين',
    severity: ErrorSeverity.medium,
  );
  
  // تسجيل خدمات قاعدة البيانات
  Get.put(FirestoreService(), permanent: true);
  Get.put(SimplifiedDatabaseService(), permanent: true); // الخدمة الجديدة
  Get.put(UniqueIdService(), permanent: true);
  Get.put(OfflineService(), permanent: true);
  
  LoggerService.success('تم تهيئة خدمات قاعدة البيانات');
}

/// تهيئة الخدمات المحلية
Future<void> _initializeLocalServices() async {
  // تهيئة التخزين المحلي
  await EnhancedErrorHandler.safeExecute(
    operation: () async {
      await GetStorage.init();
      await StorageService.init();
    },
    context: 'تهيئة التخزين المحلي',
    severity: ErrorSeverity.high,
  );

  // تهيئة خدمة الثيمات
  await EnhancedErrorHandler.safeExecute(
    operation: () => ThemeService.init(),
    context: 'تهيئة خدمة الثيمات',
    severity: ErrorSeverity.low,
  );

  // تهيئة الإشعارات المحلية
  await EnhancedErrorHandler.safeExecute(
    operation: () => NotificationService.init(),
    context: 'تهيئة الإشعارات المحلية',
    severity: ErrorSeverity.medium,
  );
  
  LoggerService.success('تم تهيئة الخدمات المحلية');
}

/// تهيئة خدمات التطبيق
Future<void> _initializeAppServices() async {
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
  
  // خدمات الإشعارات السحابية
  await EnhancedErrorHandler.safeExecute(
    operation: () => FcmService.initBackgroundHandler(),
    context: 'تهيئة معالج الخلفية FCM',
    severity: ErrorSeverity.medium,
  );
  
  Get.put(FcmService(), permanent: true);
  
  await EnhancedErrorHandler.safeExecute(
    operation: () => FcmService.instance.init(),
    context: 'تهيئة خدمة FCM',
    severity: ErrorSeverity.medium,
  );
  
  LoggerService.success('تم تهيئة خدمات التطبيق');
}

/// تسجيل الكنترولرات الأساسية
void _registerControllers() {
  Get.put(ThemeController(), permanent: true);
  LoggerService.success('تم تسجيل الكنترولرات');
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

      // إعدادات إضافية
      defaultTransition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      
      // تحسينات الأداء
      smartManagement: SmartManagement.keepFactory,
      
      // معالج البناء مع معالجة محسنة للأخطاء
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