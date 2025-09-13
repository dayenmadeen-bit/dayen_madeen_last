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
import 'app/routes/app_pages.dart';
import 'app/controllers/theme_controller.dart';
import 'app/widgets/not_found_screen.dart' as widgets;
import 'app/bindings/initial_binding.dart';
import 'core/utils/error_handler.dart';
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
          'https://3a0d2a651415ccf5a56c71a4eb3e1df7@o4509985971175424.ingest.de.sentry.io/4509990688522320'; // سيتم استبدالها بـ DSN حقيقي
      options.tracesSampleRate = 1.0;
      options.debug = true; // إزالة هذا في الإنتاج
    },
    appRunner: () async {
      // تأكد من تهيئة Flutter
      WidgetsFlutterBinding.ensureInitialized();

      // إعداد معالج الأخطاء العام
      FlutterError.onError = ErrorHandler.handleFlutterError;

      // تهيئة الخدمات الأساسية
      await _initializeServices();

      // تشغيل التطبيق
      runApp(const DayenMadeenApp());
    },
  );
}

// تهيئة الخدمات الأساسية
Future<void> _initializeServices() async {
  try {
    // تهيئة Firebase
    try {
      try {
        // إذا كانت موجودة، استخدم التطبيق الافتراضي بدون إعادة التهيئة
        Firebase.app();
        LoggerService.info(
            'Firebase مُهيّأ مسبقاً، سيتم استخدام التطبيق الافتراضي');
      } catch (_) {
        // غير مهيأ بعد، قم بالتهيئة الآن
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        LoggerService.success('تم تهيئة Firebase بنجاح');
      }
    } catch (e, st) {
      LoggerService.error('تعذر تهيئة Firebase، سيتم المتابعة بدونها مؤقتاً',
          error: e, stackTrace: st);
    }
    // تمكين وضع الأوفلاين لFirestore وتهيئة الخدمات السحابية
    await FirestoreService.enableOfflinePersistence();
    Get.put(FirestoreService(), permanent: true);
    Get.put(UniqueIdService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(RolePermissionService(), permanent: true);
    Get.put(OfflineService(), permanent: true);
    await FcmService.initBackgroundHandler();

    // تهيئة التخزين المحلي
    await GetStorage.init();
    await StorageService.init();

    // تهيئة خدمة الثيمات
    await ThemeService.init();

    // تهيئة خدمة الإشعارات المحلية (داخل التطبيق)
    await NotificationService.init();
    // تهيئة FCM + الإشعارات المحلية للنظام
    Get.put(FcmService(), permanent: true);
    await FcmService.instance.init();

    // تسجيل الكنترولرات الأساسية
    Get.put(ThemeController(), permanent: true);

    // تهيئة الخدمات الجديدة
    Get.put(EmployeeService(), permanent: true);
    Get.put(TrialService(), permanent: true);
    Get.put(SecurityService(), permanent: true);
    Get.put(SubscriptionReminderService(), permanent: true);
    Get.put(AdvancedReportsService(), permanent: true);
    Get.put(CredentialsVaultService(), permanent: true);
    Get.put(AnnouncementsService(), permanent: true);
    Get.put(BiometricAuthService(), permanent: true);

    LoggerService.success('تم تهيئة جميع الخدمات بنجاح');
  } catch (e, st) {
    LoggerService.error('خطأ في تهيئة الخدمات', error: e, stackTrace: st);
  }
}

class DayenMadeenApp extends StatelessWidget {
  const DayenMadeenApp({super.key});

  @override
  Widget build(BuildContext context) {
    // تعيين اتجاه النص للعربية
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

      // معالج الأخطاء العامة
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0, // منع تكبير النص من إعدادات النظام
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
