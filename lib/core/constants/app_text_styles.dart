import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // منع إنشاء instance من الكلاس
  AppTextStyles._();

  // ===== الخط الأساسي =====
  static String get fontFamily => GoogleFonts.cairo().fontFamily!;

  // ===== أحجام الخطوط =====
  static const double fontSizeXSmall = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeHeading = 28.0;
  static const double fontSizeDisplay = 32.0;

  // ===== أوزان الخطوط =====
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightExtraBold = FontWeight.w800;

  // ===== أنماط العناوين =====
  static TextStyle get displayLarge => GoogleFonts.cairo(
    fontSize: fontSizeDisplay,
    fontWeight: fontWeightBold,
    color: AppColors.textPrimaryLight,
    height: 1.2,
  );
  
  // === إضافة headlineLarge المفقود - 🔧 إصلاح ===
  static TextStyle get headlineLarge => GoogleFonts.cairo(
    fontSize: fontSizeDisplay, // 32px
    fontWeight: fontWeightBold,
    color: AppColors.textPrimaryLight,
    height: 1.2,
  );
  // === نهاية الإضافة ===

  static TextStyle get headlineMedium => GoogleFonts.cairo(
    fontSize: fontSizeHeading,
    fontWeight: fontWeightSemiBold,
    color: AppColors.textPrimaryLight,
    height: 1.3,
  );

  static TextStyle get headlineSmall => GoogleFonts.cairo(
    fontSize: fontSizeTitle,
    fontWeight: fontWeightSemiBold,
    color: AppColors.textPrimaryLight,
    height: 1.3,
  );

  static TextStyle get titleLarge => GoogleFonts.cairo(
    fontSize: fontSizeTitle,
    fontWeight: fontWeightSemiBold,
    color: AppColors.textPrimaryLight,
    height: 1.3,
  );

  static TextStyle get titleMedium => GoogleFonts.cairo(
    fontSize: fontSizeXLarge,
    fontWeight: fontWeightMedium,
    color: AppColors.textPrimaryLight,
    height: 1.4,
  );

  static TextStyle get titleSmall => GoogleFonts.cairo(
    fontSize: fontSizeLarge,
    fontWeight: fontWeightMedium,
    color: AppColors.textPrimaryLight,
    height: 1.3,
  );

  // ===== أنماط النصوص الأساسية =====
  static TextStyle get bodyLarge => GoogleFonts.cairo(
    fontSize: fontSizeLarge,
    fontWeight: fontWeightRegular,
    color: AppColors.textPrimaryLight,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.cairo(
    fontSize: fontSizeMedium,
    fontWeight: fontWeightRegular,
    // color: AppColors.textPrimaryLight,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.cairo(
    fontSize: fontSizeSmall,
    fontWeight: fontWeightRegular,
    color: AppColors.textSecondaryLight,
    height: 1.4,
  );

  // ===== أنماط خاصة بالتطبيق =====

  // نمط أرقام المبالغ المالية
  static TextStyle get currency => GoogleFonts.cairo(
    fontSize: fontSizeXLarge,
    fontWeight: fontWeightBold,
    color: AppColors.primary,
    height: 1.2,
  );

  // نمط نص الأزرار
  static TextStyle get button => GoogleFonts.cairo(
    fontSize: fontSizeMedium,
    fontWeight: fontWeightSemiBold,
    color: Colors.white,
    height: 1.2,
  );

  // نمط التسميات
  static TextStyle get label => GoogleFonts.cairo(
    fontSize: fontSizeSmall,
    fontWeight: fontWeightMedium,
    color: AppColors.textSecondaryLight,
    height: 1.3,
  );

  static TextStyle get labelMedium => GoogleFonts.cairo(
    fontSize: fontSizeMedium,
    fontWeight: fontWeightMedium,
    color: AppColors.textSecondaryLight,
    height: 1.3,
  );

  // نمط النص التوضيحي
  static TextStyle get caption => GoogleFonts.cairo(
    fontSize: fontSizeXSmall,
    fontWeight: fontWeightRegular,
    color: AppColors.textHintLight,
    height: 1.3,
  );

  // ===== دوال مساعدة =====

  // الحصول على نمط حسب الحالة
  static TextStyle getStatusTextStyle(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'success':
      case 'paid':
        color = AppColors.success;
        break;
      case 'warning':
      case 'pending':
        color = AppColors.warning;
        break;
      case 'error':
      case 'failed':
        color = AppColors.error;
        break;
      default:
        color = AppColors.info;
    }

    return bodyMedium.copyWith(
      color: color,
      fontWeight: fontWeightSemiBold,
    );
  }

  // الحصول على نمط للوضع الداكن
  static TextStyle getDarkModeStyle(TextStyle lightStyle) {
    Color darkColor;
    if (lightStyle.color == AppColors.textPrimaryLight) {
      darkColor = AppColors.textPrimaryDark;
    } else if (lightStyle.color == AppColors.textSecondaryLight) {
      darkColor = AppColors.textSecondaryDark;
    } else {
      darkColor = lightStyle.color ?? AppColors.textPrimaryDark;
    }

    return lightStyle.copyWith(color: darkColor);
  }

  // الحصول على نمط مخصص
  static TextStyle getCustomStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    return GoogleFonts.cairo(
      fontSize: fontSize ?? fontSizeMedium,
      fontWeight: fontWeight ?? fontWeightRegular,
      color: color ?? AppColors.textPrimaryLight,
      height: height ?? 1.4,
    );
  }
}