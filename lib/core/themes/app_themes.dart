import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

class AppThemes {
  // منع إنشاء instance من الكلاس
  AppThemes._();

  // الثيم النهاري
  static ThemeData get lightTheme => LightTheme.theme;

  // الثيم الليلي
  static ThemeData get darkTheme => DarkTheme.theme;

  // الحصول على الثيم حسب الوضع
  static ThemeData getTheme(bool isDarkMode) {
    return isDarkMode ? darkTheme : lightTheme;
  }

  // التحقق من الوضع الليلي
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // الحصول على الثيم المقابل
  static ThemeData getOppositeTheme(BuildContext context) {
    return isDarkMode(context) ? lightTheme : darkTheme;
  }
}
