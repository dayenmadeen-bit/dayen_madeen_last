import 'package:get/get.dart';

// Controllers
import '../modules/customers/controllers/customers_controller.dart';
import '../modules/customers/controllers/customer_controller.dart';
import '../modules/debts/controllers/debts_controller.dart';
import '../modules/debts/controllers/debt_controller.dart';
import '../modules/payments/controllers/payments_controller.dart';
import '../modules/payments/controllers/payment_controller.dart';
import '../modules/home/controllers/home_controller.dart';

/// ربط شامل لجميع Controllers لضمان توفرها في جميع أنحاء التطبيق
class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    try {
      // تسجيل Controllers الأساسية
      Get.lazyPut<CustomersController>(() => CustomersController(),
          fenix: true);
      Get.lazyPut<CustomerController>(() => CustomerController(), fenix: true);

      Get.lazyPut<DebtsController>(() => DebtsController(), fenix: true);
      Get.lazyPut<DebtController>(() => DebtController(), fenix: true);

      Get.lazyPut<PaymentsController>(() => PaymentsController(), fenix: true);
      Get.lazyPut<PaymentController>(() => PaymentController(), fenix: true);

      Get.lazyPut<BusinessOwnerHomeController>(
          () => BusinessOwnerHomeController(),
          fenix: true);

      print('✅ تم تحميل جميع Controllers بنجاح');
    } catch (e) {
      print('❌ خطأ في تحميل Controllers: $e');
    }
  }
}
