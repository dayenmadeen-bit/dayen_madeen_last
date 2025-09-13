import 'payments_controller.dart';

/// كلاس للتوافق مع الأسماء القديمة
/// يعيد توجيه جميع الاستدعاءات إلى PaymentsController
class PaymentController extends PaymentsController {
  // وراثة كاملة من PaymentsController
  PaymentController() : super();
}
