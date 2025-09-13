import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/themes/app_themes.dart';
import '../../core/constants/app_constants.dart';

class ThemeController extends GetxController {
  // التخزين المحلي
  final _storage = GetStorage();

  // الحالة الحالية للثيم
  var isDarkMode = false.obs;

  // حالة التحميل
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemePreference();
  }

  // تحميل تفضيلات الثيم المحفوظة
  void _loadThemePreference() {
    try {
      isLoading.value = true;
      
      // قراءة الإعداد المحفوظ
      final savedTheme = _storage.read(AppConstants.keyThemeMode);
      
      if (savedTheme != null) {
        isDarkMode.value = savedTheme as bool;
      } else {
        // إذا لم يكن هناك إعداد محفوظ، استخدم إعداد النظام
        _followSystemTheme();
      }
      
      // تطبيق الثيم
      _applyTheme();
      
    } catch (e) {
      // في حالة الخطأ، استخدم الثيم النهاري كافتراضي
      isDarkMode.value = false;
      _applyTheme();
    } finally {
      isLoading.value = false;
    }
  }

  // تبديل الثيم
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _applyTheme();
    _saveThemePreference();
  }

  // تطبيق الثيم النهاري
  void setLightTheme() {
    if (isDarkMode.value) {
      isDarkMode.value = false;
      _applyTheme();
      _saveThemePreference();
    }
  }

  // تطبيق الثيم الليلي
  void setDarkTheme() {
    if (!isDarkMode.value) {
      isDarkMode.value = true;
      _applyTheme();
      _saveThemePreference();
    }
  }

  // اتباع إعداد النظام
  void followSystemTheme() {
    _followSystemTheme();
    _applyTheme();
    _saveThemePreference();
  }

  // تطبيق الثيم
  void _applyTheme() {
    Get.changeTheme(
      isDarkMode.value ? AppThemes.darkTheme : AppThemes.lightTheme,
    );
  }

  // حفظ تفضيلات الثيم
  void _saveThemePreference() {
    try {
      _storage.write(AppConstants.keyThemeMode, isDarkMode.value);
    } catch (e) {
      // في حالة فشل الحفظ، لا نفعل شيء
      debugPrint('Error saving theme preference: $e');
    }
  }

  // اتباع إعداد النظام
  void _followSystemTheme() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    isDarkMode.value = brightness == Brightness.dark;
  }

  // الحصول على اسم الثيم الحالي
  String get currentThemeName {
    return isDarkMode.value ? 'الوضع الليلي' : 'الوضع النهاري';
  }

  // الحصول على أيقونة الثيم الحالي
  IconData get currentThemeIcon {
    return isDarkMode.value ? Icons.dark_mode_rounded : Icons.light_mode_rounded;
  }

  // الحصول على أيقونة الثيم المقابل
  IconData get oppositeThemeIcon {
    return isDarkMode.value ? Icons.light_mode_rounded : Icons.dark_mode_rounded;
  }

  // الحصول على اسم الثيم المقابل
  String get oppositeThemeName {
    return isDarkMode.value ? 'الوضع النهاري' : 'الوضع الليلي';
  }

  // التحقق من وجود تفضيل محفوظ
  bool get hasStoredPreference {
    return _storage.hasData(AppConstants.keyThemeMode);
  }

  // حذف التفضيل المحفوظ
  void clearStoredPreference() {
    try {
      _storage.remove(AppConstants.keyThemeMode);
      _followSystemTheme();
      _applyTheme();
    } catch (e) {
      debugPrint('Error clearing theme preference: $e');
    }
  }

  // إعادة تعيين الثيم للافتراضي
  void resetToDefault() {
    isDarkMode.value = false;
    _applyTheme();
    clearStoredPreference();
  }

  // الاستماع لتغييرات النظام
  void listenToSystemChanges() {
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      if (!hasStoredPreference) {
        _followSystemTheme();
        _applyTheme();
      }
    };
  }

  @override
  void onClose() {
    // تنظيف الموارد
    super.onClose();
  }
}
