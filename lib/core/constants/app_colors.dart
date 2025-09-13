import 'package:flutter/material.dart';

class AppColors {
  // منع إنشاء instance من الكلاس
  AppColors._();

  // ===== الألوان الأساسية =====
  static const Color primary = Color(0xFF1E3A8A); // أزرق كحلي داكن
  static const Color primaryLight = Color(0xFF3B82F6); // أزرق كحلي فاتح
  static const Color primaryDark = Color(0xFF0F172A); // أزرق كحلي أغمق
  static const Color secondary = Color(0xFF64748B); // رمادي أزرق
  static const Color accent = Color(0xFF3B82F6); // أزرق فاتح

  // ===== ألوان الخلفيات =====
  static const Color backgroundLight = Color(0xFFFFFFFF); // أبيض
  static const Color backgroundDark = Color(0xFF0F172A); // أسود مزرق
  static const Color surfaceLight = Color(0xFFF8FAFC); // رمادي فاتح جداً
  static const Color surfaceDark = Color(0xFF1E293B); // رمادي داكن
  static const Color cardLight = Color(0xFFFFFFFF); // بطاقات فاتحة
  static const Color cardDark = Color(0xFF1E293B); // بطاقات داكنة

  // ===== ألوان النصوص =====
  static const Color textPrimaryLight = Color(0xFF1E3A8A); // نص أساسي فاتح
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // نص أساسي داكن
  static const Color textSecondaryLight = Color(0xFF64748B); // نص ثانوي فاتح
  static const Color textSecondaryDark = Color(0xFF94A3B8); // نص ثانوي داكن
  static const Color textHintLight = Color(0xFF9CA3AF); // نص تلميح فاتح
  static const Color textHintDark = Color(0xFF6B7280); // نص تلميح داكن

  // ===== ألوان الحالة =====
  static const Color success = Color(0xFF10B981); // أخضر - نجاح
  static const Color successLight = Color(0xFF34D399); // أخضر فاتح
  static const Color successDark = Color(0xFF059669); // أخضر داكن

  static const Color warning = Color(0xFFF59E0B); // برتقالي - تحذير
  static const Color warningLight = Color(0xFFFBBF24); // برتقالي فاتح
  static const Color warningDark = Color(0xFFD97706); // برتقالي داكن

  static const Color error = Color(0xFFEF4444); // أحمر - خطأ
  static const Color errorLight = Color(0xFFF87171); // أحمر فاتح
  static const Color errorDark = Color(0xFFDC2626); // أحمر داكن

  static const Color info = Color(0xFF3B82F6); // أزرق - معلومات
  static const Color infoLight = Color(0xFF60A5FA); // أزرق فاتح
  static const Color infoDark = Color(0xFF2563EB); // أزرق داكن

  // ===== ألوان الحدود والفواصل =====
  static const Color borderLight = Color(0xFFE5E7EB); // حدود فاتحة
  static const Color borderDark = Color(0xFF374151); // حدود داكنة
  static const Color dividerLight = Color(0xFFF3F4F6); // فاصل فاتح
  static const Color dividerDark = Color(0xFF4B5563); // فاصل داكن

  // ===== ألوان خاصة بالتطبيق =====
  static const Color debt = Color(0xFFEF4444); // لون الديون
  static const Color payment = Color(0xFF10B981); // لون المدفوعات
  static const Color customer = Color(0xFF3B82F6); // لون العملاء
  static const Color report = Color(0xFF8B5CF6); // لون التقارير

  // ===== ألوان الزبائن =====
  static const Color client = Color(0xFF6366F1); // لون الزبون
  static const Color clientRequest = Color(0xFF8B5CF6); // لون طلبات الزبون
  static const Color businessOwner = Color(0xFF1E3A8A); // لون مالك المنشأة
  static const Color pendingStatus = Color(0xFFF59E0B); // حالة معلق
  static const Color approvedStatus = Color(0xFF10B981); // حالة موافق
  static const Color rejectedStatus = Color(0xFFEF4444); // حالة مرفوض

  // ===== ألوان الشفافية =====
  static const Color overlay = Color(0x80000000); // طبقة شفافة
  static const Color shadow = Color(0x1A000000); // ظل

  // ===== ألوان مختصرة للاستخدام السريع =====
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color background = backgroundLight;
  static const Color surface = surfaceLight;
  static const Color border = borderLight;
  static const Color outline = borderLight;

  // ألوان النصوص على الخلفيات الملونة
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color onBackground = Color(0xFF1A1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color onSuccess = Color(0xFFFFFFFF);

  // ===== دوال مساعدة =====

  // الحصول على لون النص المناسب للخلفية
  static Color getTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? textPrimaryLight
        : textPrimaryDark;
  }

  // الحصول على لون الحالة مع الشفافية
  static Color getStatusColorWithOpacity(String status, double opacity) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'paid':
        return success.withValues(alpha: opacity);
      case 'warning':
      case 'pending':
        return warning.withValues(alpha: opacity);
      case 'error':
      case 'failed':
        return error.withValues(alpha: opacity);
      case 'info':
      default:
        return info.withValues(alpha: opacity);
    }
  }

  // الحصول على تدرج لوني
  static LinearGradient getPrimaryGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primary, primaryLight],
    );
  }

  // الحصول على تدرج لوني للحالة
  static LinearGradient getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return const LinearGradient(
          colors: [success, successLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'warning':
        return const LinearGradient(
          colors: [warning, warningLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'error':
        return const LinearGradient(
          colors: [error, errorLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [info, infoLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}
