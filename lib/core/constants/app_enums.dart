/// تعدادات التطبيق المختلفة

/// أنواع الإشعارات (مهمل - استخدم NotificationType من notification_service.dart)
// enum NotificationType {
//   info,
//   success,
//   warning,
//   error,
//   reminder,
//   payment,
//   subscription,
// }

/// حالات الدين
enum DebtStatus {
  pending,
  partial,
  paid,
  overdue,
  cancelled,
}

/// طرق الدفع
enum PaymentMethod {
  cash,
  card,
  bank,
  other,
}

/// أنواع المستخدمين
enum UserType {
  businessOwner,
  employee,
  customer,
}

/// حالات الاشتراك
enum SubscriptionStatus {
  trial,
  active,
  expired,
  cancelled,
}

/// أنواع التقارير
enum ReportType {
  daily,
  weekly,
  monthly,
  yearly,
  custom,
}

/// حالات العميل
enum CustomerStatus {
  active,
  inactive,
  blocked,
}

/// أنواع العمليات
enum OperationType {
  create,
  update,
  delete,
  view,
}

/// مستويات الأمان
enum SecurityLevel {
  low,
  medium,
  high,
}

/// أنواع النسخ الاحتياطي
enum BackupType {
  manual,
  automatic,
  scheduled,
}

/// حالات المزامنة
enum SyncStatus {
  pending,
  inProgress,
  completed,
  failed,
}

/// أنواع الأخطاء
enum ErrorType {
  network,
  database,
  validation,
  authentication,
  authorization,
  unknown,
}

/// أولويات المهام
enum Priority {
  low,
  medium,
  high,
  urgent,
}

/// حالات الموظف
enum EmployeeStatus {
  active,
  inactive,
  suspended,
}

/// صلاحيات الموظفين
enum Permission {
  // إدارة العملاء
  viewCustomers,
  addCustomers,
  editCustomers,
  deleteCustomers,

  // إدارة الديون
  viewDebts,
  addDebts,
  editDebts,
  deleteDebts,

  // إدارة المدفوعات
  viewPayments,
  addPayments,
  editPayments,
  deletePayments,

  // التقارير
  viewReports,
  exportReports,

  // الإعدادات
  viewSettings,
  editSettings,

  // النسخ الاحتياطي
  createBackup,
  restoreBackup,

  // إدارة الموظفين (للمدراء فقط)
  manageEmployees,

  // الوصول الكامل
  fullAccess,
}

/// أنواع الأنشطة
enum ActivityType {
  login,
  logout,
  createCustomer,
  updateCustomer,
  deleteCustomer,
  createDebt,
  updateDebt,
  deleteDebt,
  createPayment,
  updatePayment,
  deletePayment,
  generateReport,
  createBackup,
  restoreBackup,
  changeSettings,
}

/// حالات التحميل
enum LoadingState {
  idle,
  loading,
  success,
  error,
}

/// أنواع الرسائل
enum MessageType {
  sms,
  whatsapp,
  email,
  push,
}

/// حالات الرسالة
enum MessageStatus {
  pending,
  sent,
  delivered,
  failed,
}

/// أنواع الملفات
enum FileType {
  pdf,
  excel,
  csv,
  image,
  backup,
}

/// أوضاع العرض
enum ViewMode {
  list,
  grid,
  card,
}

/// أنواع الفلترة
enum FilterType {
  all,
  active,
  inactive,
  recent,
  overdue,
}

/// أنواع الترتيب
enum SortType {
  name,
  date,
  amount,
  status,
}

/// اتجاه الترتيب
enum SortDirection {
  ascending,
  descending,
}

/// أنواع التنبيهات
enum AlertType {
  info,
  success,
  warning,
  error,
  confirmation,
}

/// حالات الشبكة
enum NetworkStatus {
  connected,
  disconnected,
  connecting,
}

/// أنواع التحديثات
enum UpdateType {
  minor,
  major,
  critical,
}

/// حالات التطبيق
enum AppState {
  initializing,
  ready,
  error,
  maintenance,
}

/// أنواع المصادقة
enum AuthType {
  password,
  biometric,
  pin,
}

/// حالات المصادقة البيومترية
enum BiometricStatus {
  available,
  unavailable,
  notEnrolled,
  disabled,
}

/// أنواع الأجهزة
enum DeviceType {
  phone,
  tablet,
  desktop,
}

/// أنظمة التشغيل
enum Platform {
  android,
  ios,
  windows,
  macos,
  linux,
  web,
}

/// Extensions لتحويل التعدادات إلى نصوص

// extension NotificationTypeExtension on NotificationType {
//   String get displayName {
//     switch (this) {
//       case NotificationType.info:
//         return 'معلومات';
//       case NotificationType.success:
//         return 'نجح';
//       case NotificationType.warning:
//         return 'تحذير';
//       case NotificationType.error:
//         return 'خطأ';
//       case NotificationType.reminder:
//         return 'تذكير';
//       case NotificationType.payment:
//         return 'دفعة';
//       case NotificationType.subscription:
//         return 'اشتراك';
//     }
//   }
// }

extension DebtStatusExtension on DebtStatus {
  String get displayName {
    switch (this) {
      case DebtStatus.pending:
        return 'معلق';
      case DebtStatus.partial:
        return 'مدفوع جزئياً';
      case DebtStatus.paid:
        return 'مدفوع';
      case DebtStatus.overdue:
        return 'متأخر';
      case DebtStatus.cancelled:
        return 'ملغي';
    }
  }
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'نقداً';
      case PaymentMethod.card:
        return 'بطاقة';
      case PaymentMethod.bank:
        return 'تحويل بنكي';
      case PaymentMethod.other:
        return 'أخرى';
    }
  }
}

extension PermissionExtension on Permission {
  String get displayName {
    switch (this) {
      case Permission.viewCustomers:
        return 'عرض العملاء';
      case Permission.addCustomers:
        return 'إضافة عملاء';
      case Permission.editCustomers:
        return 'تعديل العملاء';
      case Permission.deleteCustomers:
        return 'حذف العملاء';
      case Permission.viewDebts:
        return 'عرض الديون';
      case Permission.addDebts:
        return 'إضافة ديون';
      case Permission.editDebts:
        return 'تعديل الديون';
      case Permission.deleteDebts:
        return 'حذف الديون';
      case Permission.viewPayments:
        return 'عرض المدفوعات';
      case Permission.addPayments:
        return 'إضافة مدفوعات';
      case Permission.editPayments:
        return 'تعديل المدفوعات';
      case Permission.deletePayments:
        return 'حذف المدفوعات';
      case Permission.viewReports:
        return 'عرض التقارير';
      case Permission.exportReports:
        return 'تصدير التقارير';
      case Permission.viewSettings:
        return 'عرض الإعدادات';
      case Permission.editSettings:
        return 'تعديل الإعدادات';
      case Permission.createBackup:
        return 'إنشاء نسخة احتياطية';
      case Permission.restoreBackup:
        return 'استعادة نسخة احتياطية';
      case Permission.manageEmployees:
        return 'إدارة الموظفين';
      case Permission.fullAccess:
        return 'الوصول الكامل';
    }
  }

  String get description {
    switch (this) {
      case Permission.viewCustomers:
        return 'يمكن عرض قائمة العملاء وتفاصيلهم';
      case Permission.addCustomers:
        return 'يمكن إضافة عملاء جدد';
      case Permission.editCustomers:
        return 'يمكن تعديل بيانات العملاء';
      case Permission.deleteCustomers:
        return 'يمكن حذف العملاء';
      case Permission.viewDebts:
        return 'يمكن عرض الديون';
      case Permission.addDebts:
        return 'يمكن إضافة ديون جديدة';
      case Permission.editDebts:
        return 'يمكن تعديل الديون';
      case Permission.deleteDebts:
        return 'يمكن حذف الديون';
      case Permission.viewPayments:
        return 'يمكن عرض المدفوعات';
      case Permission.addPayments:
        return 'يمكن إضافة مدفوعات جديدة';
      case Permission.editPayments:
        return 'يمكن تعديل المدفوعات';
      case Permission.deletePayments:
        return 'يمكن حذف المدفوعات';
      case Permission.viewReports:
        return 'يمكن عرض التقارير';
      case Permission.exportReports:
        return 'يمكن تصدير التقارير';
      case Permission.viewSettings:
        return 'يمكن عرض الإعدادات';
      case Permission.editSettings:
        return 'يمكن تعديل الإعدادات';
      case Permission.createBackup:
        return 'يمكن إنشاء نسخة احتياطية';
      case Permission.restoreBackup:
        return 'يمكن استعادة نسخة احتياطية';
      case Permission.manageEmployees:
        return 'يمكن إدارة الموظفين';
      case Permission.fullAccess:
        return 'الوصول الكامل لجميع الميزات';
    }
  }
}
