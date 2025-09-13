class AppConstants {
  // منع إنشاء instance من الكلاس
  AppConstants._();

  // ===== معلومات التطبيق =====
  static const String appName = 'دائن مدين';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // ===== الفترة التجريبية =====
  static const int trialPeriodDays = 30;
  static const int reminderDays7 = 7;
  static const int reminderDays3 = 3;
  static const int reminderDays1 = 1;

  // ===== حدود البيانات =====
  static const int maxCustomersInTrial = 50;
  static const int maxDebtsPerCustomer = 100;
  static const int maxPaymentsPerDebt = 50;

  // ===== أحجام الصفحات =====
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ===== مفاتيح التخزين المحلي =====
  static const String keyIsFirstTime = 'is_first_time';
  static const String keyUserData = 'user_data';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyDeviceId = 'device_id';
  static const String keySubscriptionData = 'subscription_data';
  static const String keyTrialStartDate = 'trial_start_date';
  static const String keyLastBackup = 'last_backup';

  // ===== أنواع المستخدمين =====
  static const String userTypeOwner = 'owner';
  static const String userTypeCustomer = 'customer';
  static const String userTypeEmployee = 'employee';

  // ===== حالات الديون =====
  static const String debtStatusPending = 'pending';
  static const String debtStatusPaid = 'paid';
  static const String debtStatusPartiallyPaid = 'partially_paid';
  static const String debtStatusCancelled = 'cancelled';

  // ===== طرق الدفع =====
  static const String paymentMethodCash = 'cash';
  static const String paymentMethodCard = 'card';
  static const String paymentMethodBank = 'bank';
  static const String paymentMethodOther = 'other';

  // ===== أنواع التقارير =====
  static const String reportTypeDaily = 'daily';
  static const String reportTypeWeekly = 'weekly';
  static const String reportTypeMonthly = 'monthly';
  static const String reportTypeYearly = 'yearly';
  static const String reportTypeCustom = 'custom';

  // ===== أنواع الإشعارات =====
  static const String notificationTypeReminder = 'reminder';
  static const String notificationTypePayment = 'payment';
  static const String notificationTypeDebt = 'debt';
  static const String notificationTypeSubscription = 'subscription';

  // ===== أنواع الملفات =====
  static const String fileTypePdf = 'pdf';
  static const String fileTypeExcel = 'excel';
  static const String fileTypeCsv = 'csv';
  static const String fileTypeImage = 'image';

  // ===== أحجام الخطوط =====
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;

  // ===== المسافات =====
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // ===== أحجام الأيقونات =====
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // ===== أحجام الأزرار =====
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;

  // ===== مدد الانتظار =====
  static const int splashDuration = 3000; // 3 ثواني
  static const int animationDuration = 300; // 300 مللي ثانية
  static const int debounceDelay = 500; // 500 مللي ثانية للبحث

  // ===== حدود النصوص =====
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 200;
  static const int maxNotesLength = 500;
  static const int minPasswordLength = 6;

  // ===== حدود المبالغ =====
  static const double minAmount = 0.01;
  static const double maxAmount = 999999.99;
  static const double defaultCreditLimit = 1000.0;

  // ===== أنماط التاريخ =====
  static const String dateFormatDisplay = 'dd/MM/yyyy';
  static const String dateFormatApi = 'yyyy-MM-dd';
  static const String dateTimeFormatDisplay = 'dd/MM/yyyy HH:mm';
  static const String timeFormatDisplay = 'HH:mm';

  // ===== الرسائل الافتراضية =====
  static const String defaultErrorMessage = 'حدث خطأ غير متوقع';
  static const String defaultSuccessMessage = 'تم بنجاح';
  static const String defaultLoadingMessage = 'جاري التحميل...';
  static const String defaultNoDataMessage = 'لا توجد بيانات';

  // ===== معلومات التواصل =====
  static const String supportEmail = 'support@dayenmadeen.com';
  static const String supportPhone = '+966500000000';
  static const String supportWhatsApp = '+966500000000';
  static const String websiteUrl = 'https://dayenmadeen.com';

  // ===== روابط التطبيق =====
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.dayenmadeen.app';
  static const String appStoreUrl =
      'https://apps.apple.com/app/dayenmadeen/id123456789';

  // ===== إعدادات الأمان =====
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 15;
  static const int sessionTimeoutMinutes = 60;

  // ===== إعدادات النسخ الاحتياطي =====
  static const int autoBackupIntervalHours = 24;
  static const int maxBackupFiles = 10;
  static const String backupFileExtension = '.backup';

  // ===== قوائم افتراضية =====
  static const List<String> paymentMethods = [
    paymentMethodCash,
    paymentMethodCard,
    paymentMethodBank,
    paymentMethodOther,
  ];

  static const List<String> debtStatuses = [
    debtStatusPending,
    debtStatusPaid,
    debtStatusPartiallyPaid,
    debtStatusCancelled,
  ];

  static const List<String> reportTypes = [
    reportTypeDaily,
    reportTypeWeekly,
    reportTypeMonthly,
    reportTypeYearly,
    reportTypeCustom,
  ];

  // ===== دوال مساعدة =====

  // التحقق من صحة البريد الإلكتروني
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // التحقق من صحة رقم الهاتف السعودي
  static bool isValidSaudiPhone(String phone) {
    return RegExp(r'^(05|5)[0-9]{8}$').hasMatch(phone);
  }

  // التحقق من صحة المبلغ
  static bool isValidAmount(double amount) {
    return amount >= minAmount && amount <= maxAmount;
  }

  // تنسيق المبلغ
  static String formatAmount(double amount) {
    return '${amount.toStringAsFixed(2)} ر.س';
  }

  // تنسيق التاريخ
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // تنسيق التاريخ والوقت
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
