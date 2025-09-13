abstract class AppRoutes {
  // مسارات المصادقة
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String businessOwnerRegister = '/business-owner-register';
  static const String emailVerification = '/email-verification';
  static const String CustomerRegister = '/customer-register';
  static const String customerRegistration = '/customer-registration';
  static const String forgotPassword = '/forgot-password';
  static const String contactSupport = '/contact-support';
  static const String businessOwnerSupport = '/business-owner-support';

  // المسارات الرئيسية - مالك المنشأة
  static const String businessOwnerHome = '/business-owner/home';

  // مسارات إدارة الزبائن - مالك المنشأة
  static const String customers = '/business-owner/customers';
  static const String customerDetails = '/business-owner/customer-details';
  static const String addCustomer = '/business-owner/add-customer';
  static const String editCustomer = '/business-owner/edit-customer';
  static const String importCustomers =
      '/business-owner/import-customers'; // <-- تمت الإضافة

  // مسارات إدارة الديون - مالك المنشأة
  static const String debts = '/business-owner/debts';
  static const String debtDetails = '/business-owner/debt-details';
  static const String addDebt = '/business-owner/add-debt';
  static const String editDebt = '/business-owner/edit-debt';

  // مسارات إدارة المدفوعات - مالك المنشأة
  static const String payments = '/business-owner/payments';
  static const String paymentDetails = '/business-owner/payment-details';
  static const String addPayment = '/business-owner/add-payment';
  static const String editPayment = '/business-owner/edit-payment';

  // مسارات الموظفين
  static const String employees = '/employees';
  static const String employeeDetails = '/employee-details';
  static const String addEmployee = '/add-employee';
  static const String editEmployee = '/edit-employee';

  // مسارات التقارير - مالك المنشأة
  static const String reports = '/business-owner/reports';
  static const String dailyReport = '/business-owner/daily-report';
  static const String monthlyReport = '/business-owner/monthly-report';
  static const String customReport = '/business-owner/custom-report';

  // مسارات إدارة طلبات الزبائن - مالك المنشأة
  static const String manageClientRequests = '/business-owner/client-requests';
  static const String approveRequest = '/business-owner/approve-request';
  static const String rejectRequest = '/business-owner/reject-request';

  // مسارات تطبيق الزبون (العميل)
  static const String clientShops = '/client-Shops';
  static const String clientDashboard = '/client/dashboard';
  static const String clientDebts = '/client/debts';
  static const String clientPayments = '/client/payments';
  static const String clientProfile = '/client/profile';
  static const String clientRequestDebt = '/client/request-debt';
  static const String clientRequestPayment = '/client/request-payment';
  static const String clientRequests = '/client/requests';

  // مسارات جديدة للزبون
  static const String customerStores = '/customer-stores';
  static const String customerStoreHome = '/customer-store-home';
  static const String customerSettings = '/customer-settings';
  static const String debtRequest = '/debt-request';
  static const String paymentRequest = '/payment-request';

  // مسارات إضافية للتوافق
  static const String home = '/business-owner/home';
  static const String dashboard = '/business-owner/dashboard';

  // مسارات الإعدادات
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String notifications = '/notifications';
  static const String businessOwnerNotifications =
      '/business-owner/notifications';

  // مسارات الاشتراك
  static const String subscription = '/subscription';
  static const String subscriptionExpired = '/subscription-expired';
  static const String subscriptionInfo = '/subscription-info';

  // مسارات إضافية
  static const String about = '/about';
  static const String help = '/help';
  static const String contact = '/contact';
  static const String privacy = '/privacy';
  static const String terms = '/terms';
  static const String allActivity = '/all-activity';

  // مسارات الأخطاء
  static const String notFound = '/not-found';
  static const String error = '/error';
  static const String maintenance = '/maintenance';

  // دوال مساعدة للتنقل مع المعاملات

  // التنقل لتفاصيل العميل
  static String customerDetailsWithId(String customerId) {
    return '$customerDetails?id=$customerId';
  }

  // التنقل لتعديل العميل
  static String editCustomerWithId(String customerId) {
    return '$editCustomer?id=$customerId';
  }

  // التنقل لتفاصيل الدين
  static String debtDetailsWithId(String debtId) {
    return '$debtDetails?id=$debtId';
  }

  // التنقل لتعديل الدين
  static String editDebtWithId(String debtId) {
    return '$editDebt?id=$debtId';
  }

  // التنقل لإضافة دين لعميل محدد
  static String addDebtForCustomer(String customerId) {
    return '$addDebt?customerId=$customerId';
  }

  // التنقل لتفاصيل الدفعة
  static String paymentDetailsWithId(String paymentId) {
    return '$paymentDetails?id=$paymentId';
  }

  // التنقل لإضافة دفعة لدين محدد
  static String addPaymentForDebt(String debtId) {
    return '$addPayment?debtId=$debtId';
  }

  // التنقل للتقرير المخصص مع فترة زمنية
  static String customReportWithDates(DateTime startDate, DateTime endDate) {
    return '$customReport?start=${startDate.toIso8601String()}&end=${endDate.toIso8601String()}';
  }

  // التحقق من صحة المسار
  static bool isValidRoute(String route) {
    return _getAllRoutes().contains(route.split('?')[0]);
  }

  // الحصول على جميع المسارات
  static List<String> _getAllRoutes() {
    return [
      splash,
      login,
      register,
      businessOwnerRegister,
      forgotPassword,
      contactSupport,
      businessOwnerSupport,
      home,
      dashboard,
      customers,
      customerDetails,
      addCustomer,
      editCustomer,
      importCustomers, // <-- تمت الإضافة
      debts,
      debtDetails,
      addDebt,
      editDebt,
      payments,
      paymentDetails,
      addPayment,
      editPayment,
      reports,
      dailyReport,
      monthlyReport,
      customReport,
      manageClientRequests,
      approveRequest,
      rejectRequest,
      clientDashboard,
      clientDebts,
      clientPayments,
      clientProfile,
      clientRequestDebt,
      clientRequestPayment,
      clientRequests,
      customerStores,
      customerStoreHome,
      customerSettings,
      debtRequest,
      paymentRequest,
      settings,
      profile,
      editProfile,
      changePassword,
      notifications,
      businessOwnerNotifications,
      subscription,
      subscriptionExpired,
      subscriptionInfo,
      about,
      help,
      contact,
      privacy,
      terms,
      notFound,
      error,
      maintenance,
    ];
  }

  // الحصول على اسم المسار للعرض
  static String getRouteDisplayName(String route) {
    switch (route) {
      case splash:
        return 'شاشة البداية';
      case login:
        return 'تسجيل الدخول';
      case register:
        return 'إنشاء حساب';
      case businessOwnerRegister:
        return 'إنشاء حساب مالك منشأة';
      case forgotPassword:
        return 'نسيت كلمة المرور';
      case contactSupport:
        return 'التواصل والدعم';
      case businessOwnerSupport:
        return 'دعم مالك المنشأة';
      case home:
        return 'الرئيسية';
      case dashboard:
        return 'لوحة التحكم';
      case customers:
        return 'العملاء';
      case customerDetails:
        return 'تفاصيل العميل';
      case addCustomer:
        return 'إضافة عميل';
      case editCustomer:
        return 'تعديل العميل';
      case importCustomers:
        return 'استيراد العملاء'; // <-- تمت الإضافة
      case debts:
        return 'الديون';
      case debtDetails:
        return 'تفاصيل الدين';
      case addDebt:
        return 'إضافة دين';
      case editDebt:
        return 'تعديل الدين';
      case payments:
        return 'المدفوعات';
      case paymentDetails:
        return 'تفاصيل الدفعة';
      case addPayment:
        return 'إضافة دفعة';
      case editPayment:
        return 'تعديل الدفعة';
      case reports:
        return 'التقارير';
      case dailyReport:
        return 'التقرير اليومي';
      case monthlyReport:
        return 'التقرير الشهري';
      case customReport:
        return 'تقرير مخصص';
      case manageClientRequests:
        return 'إدارة طلبات الزبائن';
      case approveRequest:
        return 'الموافقة على الطلب';
      case rejectRequest:
        return 'رفض الطلب';
      case clientDashboard:
        return 'لوحة تحكم الزبون';
      case clientDebts:
        return 'ديون الزبون';
      case clientPayments:
        return 'مدفوعات الزبون';
      case clientProfile:
        return 'ملف الزبون الشخصي';
      case clientRequestDebt:
        return 'طلب دين جديد';
      case clientRequestPayment:
        return 'طلب سداد';
      case clientRequests:
        return 'طلبات الزبون';
      case settings:
        return 'الإعدادات';
      case profile:
        return 'الملف الشخصي';
      case editProfile:
        return 'تعديل الملف الشخصي';
      case changePassword:
        return 'تغيير كلمة المرور';
      case notifications:
        return 'الإشعارات';
      case subscription:
        return 'الاشتراك';
      case subscriptionExpired:
        return 'انتهى الاشتراك';
      case subscriptionInfo:
        return 'معلومات الاشتراك';
      case about:
        return 'حول التطبيق';
      case help:
        return 'المساعدة';
      case contact:
        return 'تواصل معنا';
      case privacy:
        return 'سياسة الخصوصية';
      case terms:
        return 'شروط الاستخدام';
      case notFound:
        return 'الصفحة غير موجودة';
      case error:
        return 'خطأ';
      case maintenance:
        return 'صيانة';
      default:
        return 'غير معروف';
    }
  }

  // الحصول على أيقونة المسار
  static String getRouteIcon(String route) {
    switch (route) {
      case home:
      case dashboard:
        return 'home';
      case customers:
      case customerDetails:
      case addCustomer:
      case editCustomer:
      case importCustomers: // <-- تمت الإضافة
        return 'people';
      case debts:
      case debtDetails:
      case addDebt:
      case editDebt:
        return 'receipt_long';
      case payments:
      case paymentDetails:
      case addPayment:
      case editPayment:
        return 'payment';
      case reports:
      case dailyReport:
      case monthlyReport:
      case customReport:
        return 'analytics';
      case manageClientRequests:
      case approveRequest:
      case rejectRequest:
      case clientRequests:
        return 'request_page';
      case clientDashboard:
        return 'dashboard';
      case clientDebts:
        return 'receipt_long';
      case clientPayments:
        return 'payment';
      case clientProfile:
        return 'person';
      case clientRequestDebt:
        return 'add_circle';
      case clientRequestPayment:
        return 'payment';
      case settings:
      case profile:
      case editProfile:
      case changePassword:
      case notifications:
        return 'settings';
      case subscription:
      case subscriptionExpired:
      case subscriptionInfo:
        return 'card_membership';
      default:
        return 'info';
    }
  }
}
