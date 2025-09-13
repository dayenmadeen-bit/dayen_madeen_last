import 'package:get/get.dart';
import '../controllers/customer_app_controller.dart';

/// ربط تطبيق الزبون
class ClientAppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientAppController>(
      () => ClientAppController(),
    );
  }
}
