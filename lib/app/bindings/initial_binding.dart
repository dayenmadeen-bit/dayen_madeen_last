import '../modules/payments/controllers/payments_controller.dart';
import '../modules/customers/controllers/customers_controller.dart';
import 'package:get/get.dart';

// Services
import '../../core/services/logger_service.dart';
import '../../core/services/credentials_vault_service.dart';
import '../controllers/theme_controller.dart';
import '../modules/debts/controllers/debts_controller.dart';
import '../../core/services/employee_service.dart';

/// ربط أولي للخدمات الأساسية
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    try {
      LoggerService.info('بدء تحميل الخدمات الأساسية...');

      // تسجيل الخدمات الأساسية فقط التي تحتاج instance
      Get.put<CredentialsVaultService>(CredentialsVaultService(), permanent: true);
      LoggerService.info('✅ تم تحميل CredentialsVaultService');

      Get.put<ThemeController>(ThemeController(), permanent: true);
      LoggerService.info('✅ تم تحميل ThemeController');

    // تسجيل خدمة الموظفين
    Get.put<EmployeeService>(EmployeeService(), permanent: true);
    LoggerService.info('✅ تم تحميل EmployeeService');

    // تسجيل كنترولر الديون
    Get.put<DebtsController>(DebtsController(), permanent: true);
    LoggerService.info('✅ تم تحميل DebtsController');

    // تسجيل كنترولر المدفوعات
    Get.put<PaymentsController>(PaymentsController(), permanent: true);
    LoggerService.info('✅ تم تحميل PaymentsController');

    // تسجيل كنترولر العملاء
    Get.put<CustomersController>(CustomersController(), permanent: true);
    LoggerService.info('✅ تم تحميل CustomersController');

      LoggerService.success('تم تحميل جميع الخدمات الأساسية بنجاح');
    } catch (e) {
      LoggerService.error('خطأ في تحميل الخدمات الأساسية', error: e);
      print('❌ خطأ في InitialBinding: $e');
    }
  }
}
