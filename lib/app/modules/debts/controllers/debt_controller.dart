import 'debts_controller.dart';

/// كلاس للتوافق مع الأسماء القديمة
/// يعيد توجيه جميع الاستدعاءات إلى DebtsController
class DebtController extends DebtsController {
  // وراثة كاملة من DebtsController
  DebtController() : super();
}
