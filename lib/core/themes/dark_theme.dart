import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_decorations.dart';

class DarkTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // نظام الألوان
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        onPrimary: AppColors.backgroundDark,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        background: AppColors.backgroundDark,
        onBackground: AppColors.textPrimaryDark,
        error: AppColors.error,
        onError: Colors.white,
      ),

      // الخط الأساسي
      fontFamily: GoogleFonts.cairo().fontFamily,

      // شريط التطبيق
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          color: AppColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimaryDark,
        ),
      ),

      // البطاقات
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: AppDecorations.elevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusLarge),
        ),
        margin: EdgeInsets.all(AppDecorations.spacingSmall),
      ),

      // الأزرار المرفوعة
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.backgroundDark,
          elevation: AppDecorations.elevationSmall,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDecorations.radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDecorations.spacingLarge,
            vertical: AppDecorations.spacingMedium,
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // الأزرار المحددة
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.accent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDecorations.radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDecorations.spacingLarge,
            vertical: AppDecorations.spacingMedium,
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // الأزرار النصية
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDecorations.radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDecorations.spacingMedium,
            vertical: AppDecorations.spacingSmall,
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusLarge),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusLarge),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusLarge),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusLarge),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusLarge),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDecorations.spacingMedium,
          vertical: AppDecorations.spacingMedium,
        ),
        labelStyle: GoogleFonts.cairo(
          color: AppColors.textSecondaryDark,
          fontSize: 16,
        ),
        hintStyle: GoogleFonts.cairo(
          color: AppColors.textHintDark,
          fontSize: 16,
        ),
      ),

      // أيقونات
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryDark,
        size: 24,
      ),

      // الفواصل
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: 1,
      ),

      // أشرطة التقدم
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
      ),

      // التبديل
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.accent;
          }
          return AppColors.textHintDark;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.accent.withValues(alpha: 0.3);
          }
          return AppColors.borderDark;
        }),
      ),

      // مربعات الاختيار
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.accent;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(AppColors.backgroundDark),
        side: const BorderSide(color: AppColors.borderDark),
      ),

      // أزرار الراديو
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.accent;
          }
          return AppColors.textHintDark;
        }),
      ),

      // القوائم المنسدلة
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: GoogleFonts.cairo(
          color: AppColors.textPrimaryDark,
          fontSize: 16,
        ),
      ),

      // أشرطة التمرير
      scrollbarTheme: ScrollbarThemeData(
        thumbColor:
            MaterialStateProperty.all(AppColors.accent.withValues(alpha: 0.5)),
        trackColor: MaterialStateProperty.all(AppColors.borderDark),
        radius: const Radius.circular(AppDecorations.radiusSmall),
      ),

      // الحوارات
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusLarge),
        ),
        titleTextStyle: GoogleFonts.cairo(
          color: AppColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: GoogleFonts.cairo(
          color: AppColors.textPrimaryDark,
          fontSize: 16,
        ),
      ),

      // القوائم السفلية
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDecorations.radiusLarge),
          ),
        ),
      ),

      // أشرطة التنقل السفلية
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: AppDecorations.elevationMedium,
        selectedLabelStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
