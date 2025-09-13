import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_icons.dart';

/// ثوابت خاصة بالزبائن
class ClientConstants {
  ClientConstants._();

  // ===== أنواع الطلبات =====
  static const String debtRequestType = 'debt';
  static const String paymentRequestType = 'payment';

  // ===== حالات الطلبات =====
  static const String pendingStatus = 'pending';
  static const String approvedStatus = 'approved';
  static const String rejectedStatus = 'rejected';

  // ===== نصوص أنواع الطلبات =====
  static const Map<String, String> requestTypeTexts = {
    debtRequestType: 'طلب دين',
    paymentRequestType: 'طلب سداد',
  };

  // ===== نصوص حالات الطلبات =====
  static const Map<String, String> requestStatusTexts = {
    pendingStatus: 'في الانتظار',
    approvedStatus: 'موافق عليه',
    rejectedStatus: 'مرفوض',
  };

  // ===== ألوان حالات الطلبات =====
  static const Map<String, Color> requestStatusColors = {
    pendingStatus: AppColors.pendingStatus,
    approvedStatus: AppColors.approvedStatus,
    rejectedStatus: AppColors.rejectedStatus,
  };

  // ===== أيقونات أنواع الطلبات =====
  static const Map<String, IconData> requestTypeIcons = {
    debtRequestType: AppIcons.requestDebt,
    paymentRequestType: AppIcons.requestPayment,
  };

  // ===== أيقونات حالات الطلبات =====
  static const Map<String, IconData> requestStatusIcons = {
    pendingStatus: AppIcons.pendingRequest,
    approvedStatus: AppIcons.approvedRequest,
    rejectedStatus: AppIcons.rejectedRequest,
  };

  // ===== تبويبات التنقل للزبون =====
  static const List<ClientTabItem> navigationTabs = [
    ClientTabItem(
      index: 0,
      title: 'الرئيسية',
      icon: AppIcons.clientDashboard,
    ),
    ClientTabItem(
      index: 1,
      title: 'طلباتي',
      icon: AppIcons.clientRequests,
    ),
    ClientTabItem(
      index: 2,
      title: 'ديوني',
      icon: AppIcons.clientDebts,
    ),
    ClientTabItem(
      index: 3,
      title: 'مدفوعاتي',
      icon: AppIcons.clientPayments,
    ),
    ClientTabItem(
      index: 4,
      title: 'الملف الشخصي',
      icon: AppIcons.clientProfile,
    ),
  ];

  // ===== طرق الدفع =====
  static const List<PaymentMethodItem> paymentMethods = [
    PaymentMethodItem(
      value: 'bank_transfer',
      title: 'تحويل بنكي',
      icon: AppIcons.bank,
    ),
    PaymentMethodItem(
      value: 'cash',
      title: 'نقداً',
      icon: AppIcons.cash,
    ),
    PaymentMethodItem(
      value: 'mobile_payment',
      title: 'محفظة إلكترونية',
      icon: AppIcons.phone,
    ),
  ];

  // ===== حدود الطلبات =====
  static const double maxDebtAmount = 50000.0;
  static const double minRequestAmount = 1.0;
  static const int minDescriptionLength = 10;
  static const int maxDescriptionLength = 500;

  // ===== رسائل التحقق =====
  static const String amountRequiredMessage = 'المبلغ مطلوب';
  static const String invalidAmountMessage = 'أدخل مبلغ صحيح';
  static const String maxAmountExceededMessage = 'المبلغ يجب أن يكون أقل من 50,000 ر.س';
  static const String descriptionRequiredMessage = 'وصف الطلب مطلوب';
  static const String minDescriptionMessage = 'الوصف يجب أن يكون أكثر من 10 أحرف';
  static const String maxDescriptionMessage = 'الوصف يجب أن يكون أقل من 500 حرف';

  // ===== رسائل النجاح =====
  static const String debtRequestSuccessMessage = 'تم إرسال طلب الدين بنجاح. ستحصل على إشعار عند المراجعة.';
  static const String paymentRequestSuccessMessage = 'تم إرسال طلب السداد بنجاح. ستحصل على إشعار عند المراجعة.';
  static const String requestApprovedMessage = 'تم الموافقة على الطلب بنجاح ✅';
  static const String requestRejectedMessage = 'تم رفض الطلب ❌';

  // ===== رسائل الخطأ =====
  static const String debtRequestErrorMessage = 'فشل في إرسال طلب الدين';
  static const String paymentRequestErrorMessage = 'فشل في إرسال طلب السداد';
  static const String loadRequestsErrorMessage = 'فشل في تحميل الطلبات';

  // ===== دوال مساعدة =====
  
  /// الحصول على نص نوع الطلب
  static String getRequestTypeText(String type) {
    return requestTypeTexts[type] ?? 'غير محدد';
  }

  /// الحصول على نص حالة الطلب
  static String getRequestStatusText(String status) {
    return requestStatusTexts[status] ?? 'غير محدد';
  }

  /// الحصول على لون حالة الطلب
  static Color getRequestStatusColor(String status) {
    return requestStatusColors[status] ?? AppColors.info;
  }

  /// الحصول على أيقونة نوع الطلب
  static IconData getRequestTypeIcon(String type) {
    return requestTypeIcons[type] ?? AppIcons.info;
  }

  /// الحصول على أيقونة حالة الطلب
  static IconData getRequestStatusIcon(String status) {
    return requestStatusIcons[status] ?? AppIcons.info;
  }

  /// الحصول على نص طريقة الدفع
  static String getPaymentMethodText(String method) {
    final paymentMethod = paymentMethods.firstWhere(
      (pm) => pm.value == method,
      orElse: () => const PaymentMethodItem(
        value: 'unknown',
        title: 'غير محدد',
        icon: AppIcons.info,
      ),
    );
    return paymentMethod.title;
  }

  /// التحقق من صحة المبلغ
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return amountRequiredMessage;
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return invalidAmountMessage;
    }
    if (amount > maxDebtAmount) {
      return maxAmountExceededMessage;
    }
    return null;
  }

  /// التحقق من صحة الوصف
  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return descriptionRequiredMessage;
    }
    if (value.trim().length < minDescriptionLength) {
      return minDescriptionMessage;
    }
    if (value.trim().length > maxDescriptionLength) {
      return maxDescriptionMessage;
    }
    return null;
  }
}

/// عنصر تبويب الزبون
class ClientTabItem {
  final int index;
  final String title;
  final IconData icon;

  const ClientTabItem({
    required this.index,
    required this.title,
    required this.icon,
  });
}

/// عنصر طريقة الدفع
class PaymentMethodItem {
  final String value;
  final String title;
  final IconData icon;

  const PaymentMethodItem({
    required this.value,
    required this.title,
    required this.icon,
  });
}
