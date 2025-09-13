class AppStrings {
  // منع إنشاء instance من الكلاس
  AppStrings._();

  // ===== عام =====
  static const String appName = 'دائن مدين';
  static const String appDescription = 'نظام إدارة الديون الاحترافي';
  static const String version = '1.0.0';

  // ===== المصادقة =====
  static const String login = 'تسجيل الدخول';
  static const String logout = 'تسجيل الخروج';
  static const String email = 'البريد الإلكتروني';
  static const String password = 'كلمة المرور';
  static const String username = 'اسم المستخدم';
  static const String forgotPassword = 'نسيت كلمة المرور؟';
  static const String rememberMe = 'تذكرني';
  static const String loginWithFingerprint = 'تسجيل الدخول بالبصمة';
  static const String loginWithFaceId = 'تسجيل الدخول بـ Face ID';

  // ===== التنقل =====
  static const String home = 'الرئيسية';
  static const String customers = 'العملاء';
  static const String debts = 'الديون';
  static const String payments = 'المدفوعات';
  static const String reports = 'التقارير';
  static const String settings = 'الإعدادات';
  static const String profile = 'الملف الشخصي';

  // ===== الإجراءات =====
  static const String add = 'إضافة';
  static const String edit = 'تعديل';
  static const String delete = 'حذف';
  static const String save = 'حفظ';
  static const String cancel = 'إلغاء';
  static const String confirm = 'تأكيد';
  static const String search = 'بحث';
  static const String filter = 'فلترة';
  static const String sort = 'ترتيب';
  static const String refresh = 'تحديث';
  static const String export = 'تصدير';
  static const String print = 'طباعة';
  static const String share = 'مشاركة';

  // ===== العملاء =====
  static const String addCustomer = 'إضافة عميل جديد';
  static const String customerName = 'اسم العميل';
  static const String customerPhone = 'رقم الهاتف';
  static const String customerEmail = 'البريد الإلكتروني';
  static const String creditLimit = 'حد الائتمان';
  static const String currentBalance = 'الرصيد الحالي';
  static const String customerDetails = 'تفاصيل العميل';
  static const String customersList = 'قائمة العملاء';
  static const String noCustomers = 'لا يوجد عملاء';

  // ===== الديون =====
  static const String addDebt = 'إضافة دين جديد';
  static const String debtAmount = 'مبلغ الدين';
  static const String debtDescription = 'وصف الدين';
  static const String debtDate = 'تاريخ الدين';
  static const String debtStatus = 'حالة الدين';
  static const String totalDebts = 'إجمالي الديون';
  static const String paidDebts = 'الديون المدفوعة';
  static const String pendingDebts = 'الديون المعلقة';
  static const String debtsList = 'قائمة الديون';
  static const String noDebts = 'لا يوجد ديون';

  // ===== المدفوعات =====
  static const String addPayment = 'إضافة دفعة جديدة';
  static const String paymentAmount = 'مبلغ الدفعة';
  static const String paymentDate = 'تاريخ الدفعة';
  static const String paymentMethod = 'طريقة الدفع';
  static const String paymentNotes = 'ملاحظات الدفعة';
  static const String paymentDetails = 'تفاصيل الدفعة';
  static const String editPayment = 'تعديل الدفعة';
  static const String totalPayments = 'إجمالي المدفوعات';
  static const String paymentsList = 'قائمة المدفوعات';
  static const String noPayments = 'لا يوجد مدفوعات';
  static const String paymentReceipt = 'إيصال الدفع';

  // ===== طرق الدفع =====
  static const String cash = 'نقدي';
  static const String card = 'بطاقة';
  static const String bank = 'تحويل بنكي';

  // ===== الحالات =====
  static const String paid = 'مدفوع';
  static const String pending = 'معلق';
  static const String cancelled = 'ملغي';
  static const String active = 'نشط';
  static const String inactive = 'غير نشط';

  // ===== التقارير =====
  static const String dailyReport = 'التقرير اليومي';
  static const String monthlyReport = 'التقرير الشهري';
  static const String yearlyReport = 'التقرير السنوي';
  static const String customReport = 'تقرير مخصص';
  static const String generateReport = 'إنشاء تقرير';
  static const String exportReport = 'تصدير التقرير';
  static const String printReport = 'طباعة التقرير';
  static const String shareReport = 'مشاركة التقرير';
  static const String reportPeriod = 'فترة التقرير';
  static const String fromDate = 'من تاريخ';
  static const String toDate = 'إلى تاريخ';
  static const String analytics = 'التحليلات';

  // ===== الإحصائيات =====
  static const String statistics = 'الإحصائيات';
  static const String totalCustomers = 'إجمالي العملاء';
  static const String totalAmount = 'إجمالي المبلغ';
  static const String thisMonth = 'هذا الشهر';
  static const String thisYear = 'هذا العام';

  // ===== الاشتراك =====
  static const String subscription = 'الاشتراك';
  static const String trialPeriod = 'الفترة التجريبية';
  static const String subscriptionExpired = 'انتهى الاشتراك';
  static const String renewSubscription = 'تجديد الاشتراك';
  static const String contactUs = 'تواصل معنا';
  static const String deviceId = 'معرف الجهاز';
  static const String copyDeviceId = 'نسخ معرف الجهاز';

  // ===== الإعدادات =====
  static const String darkMode = 'الوضع الليلي';
  static const String lightMode = 'الوضع النهاري';
  static const String language = 'اللغة';
  static const String notifications = 'الإشعارات';
  static const String backup = 'النسخ الاحتياطي';
  static const String restore = 'الاستعادة';

  // ===== الرسائل =====
  static const String success = 'تم بنجاح';
  static const String error = 'حدث خطأ';
  static const String warning = 'تحذير';
  static const String info = 'معلومات';
  static const String loading = 'جاري التحميل...';
  static const String noData = 'لا توجد بيانات';
  static const String noInternet = 'لا يوجد اتصال بالإنترنت';
  static const String tryAgain = 'حاول مرة أخرى';
  static const String permission = 'الصلاحية';
  static const String noPermission = 'لا تملك صلاحية لإتمام هذا الإجراء';
  static String noPermissionMessage(String permissionName) =>
      noPermission + '. اطلب من مالك المنشأة منح الصلاحية: ' + permissionName;
  static const String debtDetails = 'تفاصيل الدين';
  static const String editDebt = 'تعديل الدين';

  // ===== التحقق =====
  static const String required = 'هذا الحقل مطلوب';
  static const String invalidEmail = 'البريد الإلكتروني غير صحيح';
  static const String invalidPhone = 'رقم الهاتف غير صحيح';
  static const String phoneRequired = 'رقم الهاتف مطلوب';
  static const String nameRequired = 'الاسم مطلوب';
  static const String passwordRequired = 'كلمة المرور مطلوبة';
  static const String passwordsDoNotMatch = 'كلمتا المرور غير متطابقتان';
  static const String passwordTooShort = 'كلمة المرور قصيرة جداً';
  static const String amountRequired = 'المبلغ مطلوب';
  static const String invalidAmount = 'المبلغ غير صحيح';

  // ===== التأكيد =====
  static const String confirmDelete = 'هل أنت متأكد من الحذف؟';
  static const String confirmLogout = 'هل أنت متأكد من تسجيل الخروج؟';
  static const String deleteWarning = 'لا يمكن التراجع عن هذا الإجراء';

  // ===== التواريخ والأوقات =====
  static const String today = 'اليوم';
  static const String yesterday = 'أمس';
  static const String thisWeek = 'هذا الأسبوع';
  static const String lastWeek = 'الأسبوع الماضي';
  static const String selectDate = 'اختر التاريخ';
  static const String selectTime = 'اختر الوقت';

  // ===== العملة =====
  static const String currency = 'ريال';
  static const String currencySymbol = 'ر.س';

  // ===== أخرى =====
  static const String welcome = 'مرحباً';
  static const String goodMorning = 'صباح الخير';
  static const String goodEvening = 'مساء الخير';
  static const String thankYou = 'شكراً لك';
  static const String comingSoon = 'قريباً';
  static const String underDevelopment = 'تحت التطوير';

  // ===== الإعلانات (i18n) =====
  static const String announcementsTitle = 'إعلانات';
  static const String announcementsEmpty = 'لا توجد إعلانات حالياً';
  static const String announcementsError = 'تعذّر تحميل الإعلانات';
  static const String announcementsOwnerHome = 'إعلانات المالك';
  static const String announcementsEmployeeHome = 'إعلانات الموظف';
  static const String announcementsCustomerHome = 'إعلانات العميل';
  static const String announcementsRegistration = 'إعلانات التسجيل';

  // ===== دوال مساعدة =====

  /// دالة للحصول على نص طريقة الدفع
  static String getPaymentMethodText(String method) {
    switch (method) {
      case 'cash':
        return cash;
      case 'card':
        return card;
      case 'bank':
        return bank;
      case 'other':
        return 'أخرى';
      default:
        return method;
    }
  }

  /// دالة للحصول على نص حالة الدين
  static String getStatusText(String status) {
    switch (status) {
      case 'paid':
        return paid;
      case 'pending':
        return pending;
      case 'partially_paid':
        return 'مدفوع جزئياً';
      case 'cancelled':
        return cancelled;
      default:
        return status;
    }
  }
}
