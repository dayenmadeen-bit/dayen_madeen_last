import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';
import '../themes/app_themes.dart';

class ThemeService {
  // منع إنشاء instance من الكلاس
  ThemeService._();

  static final _storage = GetStorage();

  // تهيئة خدمة الثيمات
  static Future<void> init() async {
    await GetStorage.init();
  }

  // الحصول على الثيم المحفوظ
  static ThemeMode getThemeMode() {
    final isDarkMode = _storage.read(AppConstants.keyThemeMode);
    
    if (isDarkMode == null) {
      return ThemeMode.system;
    }
    
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  // حفظ وضع الثيم
  static Future<void> saveThemeMode(ThemeMode themeMode) async {
    switch (themeMode) {
      case ThemeMode.light:
        await _storage.write(AppConstants.keyThemeMode, false);
        break;
      case ThemeMode.dark:
        await _storage.write(AppConstants.keyThemeMode, true);
        break;
      case ThemeMode.system:
        await _storage.remove(AppConstants.keyThemeMode);
        break;
    }
  }

  // تطبيق الثيم
  static void changeTheme(ThemeMode themeMode) {
    Get.changeThemeMode(themeMode);
    saveThemeMode(themeMode);
  }

  // التبديل بين الثيمات
  static void toggleTheme() {
    final currentMode = getThemeMode();
    
    switch (currentMode) {
      case ThemeMode.light:
        changeTheme(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        changeTheme(ThemeMode.light);
        break;
      case ThemeMode.system:
        // إذا كان النظام في الوضع الليلي، غير للنهاري والعكس
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        changeTheme(brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
        break;
    }
  }

  // الحصول على الثيم الحالي
  static bool get isDarkMode {
    final themeMode = getThemeMode();
    
    switch (themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark;
    }
  }

  // الحصول على البيانات الأساسية للثيم
  static Map<String, dynamic> getThemeData() {
    final themeMode = getThemeMode();
    final isDark = isDarkMode;
    
    return {
      'themeMode': themeMode.toString(),
      'isDarkMode': isDark,
      'themeName': isDark ? 'الوضع الليلي' : 'الوضع النهاري',
      'themeIcon': isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
    };
  }

  // إعادة تعيين الثيم للافتراضي
  static void resetTheme() {
    changeTheme(ThemeMode.system);
  }

  // التحقق من وجود تفضيل محفوظ
  static bool get hasCustomTheme {
    return _storage.hasData(AppConstants.keyThemeMode);
  }

  // الحصول على لون أساسي حسب الثيم
  static Color getPrimaryColor() {
    return isDarkMode ? AppThemes.darkTheme.primaryColor : AppThemes.lightTheme.primaryColor;
  }

  // الحصول على لون الخلفية حسب الثيم
  static Color getBackgroundColor() {
    return isDarkMode 
        ? AppThemes.darkTheme.scaffoldBackgroundColor 
        : AppThemes.lightTheme.scaffoldBackgroundColor;
  }

  // الحصول على لون النص حسب الثيم
  static Color getTextColor() {
    return isDarkMode 
        ? AppThemes.darkTheme.textTheme.bodyLarge?.color ?? Colors.white
        : AppThemes.lightTheme.textTheme.bodyLarge?.color ?? Colors.black;
  }

  // الاستماع لتغييرات النظام
  static void listenToSystemChanges() {
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      if (getThemeMode() == ThemeMode.system) {
        // إعادة تطبيق الثيم عند تغيير إعداد النظام
        Get.forceAppUpdate();
      }
    };
  }

  // تصدير إعدادات الثيم
  static Map<String, dynamic> exportThemeSettings() {
    return {
      'themeMode': getThemeMode().toString(),
      'isDarkMode': isDarkMode,
      'hasCustomTheme': hasCustomTheme,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  // استيراد إعدادات الثيم
  static Future<bool> importThemeSettings(Map<String, dynamic> settings) async {
    try {
      final themeModeString = settings['themeMode'] as String?;
      
      if (themeModeString != null) {
        ThemeMode themeMode;
        
        switch (themeModeString) {
          case 'ThemeMode.light':
            themeMode = ThemeMode.light;
            break;
          case 'ThemeMode.dark':
            themeMode = ThemeMode.dark;
            break;
          case 'ThemeMode.system':
          default:
            themeMode = ThemeMode.system;
            break;
        }
        
        changeTheme(themeMode);
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error importing theme settings: $e');
      return false;
    }
  }
}
