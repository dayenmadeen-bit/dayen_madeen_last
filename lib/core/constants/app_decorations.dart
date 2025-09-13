import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  // منع إنشاء instance من الكلاس
  AppDecorations._();

  // ===== أنصاف الأقطار =====
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusCircular = 50.0;

  // ===== المسافات =====
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // ===== الارتفاعات (Elevation) =====
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;

  // ===== تزيينات البطاقات =====
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: elevationSmall,
            offset: const Offset(0, 1),
          ),
        ],
      );

  static BoxDecoration get cardDecorationDark => BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: elevationMedium,
            offset: const Offset(0, 2),
          ),
        ],
      );

  // ===== تزيينات الأزرار =====
  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: elevationSmall,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration get secondaryButtonDecoration => BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.2),
            blurRadius: elevationSmall,
            offset: const Offset(0, 1),
          ),
        ],
      );

  // ===== تزيينات حقول الإدخال =====
  static InputDecoration getInputDecoration({
    required String label,
    String? hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool isDark = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon != null
          ? Icon(
              prefixIcon,
              color: isDark ? AppColors.textSecondaryDark : AppColors.primary,
            )
          : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        borderSide: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        borderSide: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        borderSide: BorderSide(
          color: AppColors.error,
          width: 1.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        borderSide: BorderSide(
          color: AppColors.error,
          width: 2.0,
        ),
      ),
      filled: true,
      fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingMedium,
        vertical: spacingMedium,
      ),
    );
  }

  // ===== تزيينات الحالة =====
  static BoxDecoration getStatusDecoration(String status) {
    Color color = AppColors.getStatusColorWithOpacity(status, 0.1);
    Color borderColor = AppColors.getStatusColorWithOpacity(status, 1.0);

    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radiusSmall),
      border: Border.all(color: borderColor, width: 1),
    );
  }

  // ===== تزيينات الحاويات =====
  static BoxDecoration get containerDecoration => BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(radiusMedium),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      );

  static BoxDecoration get containerDecorationDark => BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(radiusMedium),
        border: Border.all(
          color: AppColors.borderDark,
          width: 1,
        ),
      );

  // ===== دوال مساعدة =====

  // إنشاء تزيين مخصص للبطاقة
  static BoxDecoration createCardDecoration({
    Color? backgroundColor,
    double? borderRadius,
    Color? shadowColor,
    double? elevation,
    Color? borderColor,
    double? borderWidth,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.cardLight,
      borderRadius: BorderRadius.circular(borderRadius ?? radiusLarge),
      border: borderColor != null
          ? Border.all(color: borderColor, width: borderWidth ?? 1)
          : null,
      boxShadow: elevation != null && elevation > 0
          ? [
              BoxShadow(
                color: shadowColor ?? AppColors.shadow,
                blurRadius: elevation,
                offset: Offset(0, elevation / 2),
              ),
            ]
          : null,
    );
  }

  // إنشاء تزيين مخصص للحاوية
  static BoxDecoration createContainerDecoration({
    Color? backgroundColor,
    double? borderRadius,
    Color? borderColor,
    double? borderWidth,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(borderRadius ?? radiusMedium),
      border: borderColor != null
          ? Border.all(color: borderColor, width: borderWidth ?? 1)
          : null,
    );
  }

  // إنشاء تزيين مع تدرج لوني
  static BoxDecoration createGradientDecoration({
    required List<Color> colors,
    double? borderRadius,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius ?? radiusMedium),
      gradient: LinearGradient(
        colors: colors,
        begin: begin ?? Alignment.topLeft,
        end: end ?? Alignment.bottomRight,
      ),
    );
  }
}
