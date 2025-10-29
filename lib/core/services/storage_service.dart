import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';

class StorageService {
  // منع إنشاء instance من الكلاس
  StorageService._();

  static final _storage = GetStorage();

  // تهيئة خدمة التخزين
  static Future<void> init() async {
    await GetStorage.init();
  }

  // ===== العمليات الأساسية =====

  // حفظ قيمة نصية
  static Future<void> setString(String key, String value) async {
    await _storage.write(key, value);
  }

  // قراءة قيمة نصية
  static String? getString(String key) {
    return _storage.read(key);
  }

  // حفظ قيمة رقمية صحيحة
  static Future<void> setInt(String key, int value) async {
    await _storage.write(key, value);
  }

  // قراءة قيمة رقمية صحيحة
  static int? getInt(String key) {
    return _storage.read(key);
  }

  // حفظ قيمة رقمية عشرية
  static Future<void> setDouble(String key, double value) async {
    await _storage.write(key, value);
  }

  // قراءة قيمة رقمية عشرية
  static double? getDouble(String key) {
    return _storage.read(key);
  }

  // حفظ قيمة منطقية
  static Future<void> setBool(String key, bool value) async {
    await _storage.write(key, value);
  }

  // قراءة قيمة منطقية
  static bool? getBool(String key) {
    return _storage.read(key);
  }

  // حفظ قائمة
  static Future<void> setList(String key, List<dynamic> value) async {
    await _storage.write(key, value);
  }

  // الحصول على قائمة
  static List<dynamic>? getList(String key) {
    return _storage.read(key);
  }

  // حفظ خريطة
  static Future<void> setMap(String key, Map<String, dynamic> value) async {
    await _storage.write(key, jsonEncode(value));
  }

  // قراءة خريطة
  static Map<String, dynamic>? getMap(String key) {
    final jsonString = _storage.read(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  // === إضافة الطرق المفقودة ===
  
  /// حفظ بيانات JSON - 🔧 إصلاح
  static Future<void> setJson(String key, Map<String, dynamic> value) async {
    await setMap(key, value);
  }

  /// قراءة بيانات JSON - 🔧 إصلاح
  static Map<String, dynamic>? getJson(String key) {
    return getMap(key);
  }
  
  /// حذف جميع البيانات - 🔧 إصلاح
  static Future<void> clearAllData() async {
    await clear();
  }

  // الحصول على حجم التخزين المستخدم (تقديري)
  static int getStorageSize() {
    // حساب تقديري لحجم البيانات المحفوظة
    int totalSize = 0;
    final keys = _storage.getKeys();

    for (final key in keys) {
      final value = _storage.read(key);
      if (value != null) {
        // تقدير حجم البيانات بناءً على نوعها
        if (value is String) {
          totalSize += value.length * 2; // UTF-16 encoding
        } else if (value is List) {
          totalSize += value.length * 100; // تقدير متوسط
        } else if (value is Map) {
          totalSize += value.length * 200; // تقدير متوسط
        } else {
          totalSize += 50; // تقدير للأنواع الأخرى
        }
      }
    }

    return totalSize;
  }

  // ===== عمليات متقدمة =====

  // التحقق من وجود مفتاح
  static bool hasKey(String key) {
    return _storage.hasData(key);
  }

  // حذف مفتاح
  static Future<void> remove(String key) async {
    await _storage.remove(key);
  }

  // حذف جميع البيانات
  static Future<void> clear() async {
    await _storage.erase();
  }

  // الحصول على جميع المفاتيح
  static Iterable<String> getKeys() {
    return _storage.getKeys();
  }

  // الحصول على جميع القيم
  static Iterable<dynamic> getValues() {
    return _storage.getValues();
  }

  // ===== عمليات خاصة بالتطبيق =====

  // حفظ بيانات المستخدم
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await setMap(AppConstants.keyUserData, userData);
  }

  // قراءة بيانات المستخدم
  static Map<String, dynamic>? getUserData() {
    return getMap(AppConstants.keyUserData);
  }

  // حذف بيانات المستخدم
  static Future<void> clearUserData() async {
    await remove(AppConstants.keyUserData);
  }

  // حفظ حالة أول مرة
  static Future<void> setFirstTime(bool isFirstTime) async {
    await setBool(AppConstants.keyIsFirstTime, isFirstTime);
  }

  // التحقق من أول مرة
  static bool isFirstTime() {
    return getBool(AppConstants.keyIsFirstTime) ?? true;
  }

  // حفظ معرف الجهاز
  static Future<void> saveDeviceId(String deviceId) async {
    await setString(AppConstants.keyDeviceId, deviceId);
  }

  // قراءة معرف الجهاز
  static String? getDeviceId() {
    return getString(AppConstants.keyDeviceId);
  }

  // حفظ بيانات الاشتراك
  static Future<void> saveSubscriptionData(
      Map<String, dynamic> subscriptionData) async {
    await setMap(AppConstants.keySubscriptionData, subscriptionData);
  }

  // قراءة بيانات الاشتراك
  static Map<String, dynamic>? getSubscriptionData() {
    return getMap(AppConstants.keySubscriptionData);
  }

  // حفظ تاريخ بداية التجربة
  static Future<void> saveTrialStartDate(DateTime date) async {
    await setString(AppConstants.keyTrialStartDate, date.toIso8601String());
  }

  // قراءة تاريخ بداية التجربة
  static DateTime? getTrialStartDate() {
    final dateString = getString(AppConstants.keyTrialStartDate);
    if (dateString != null) {
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // ===== عمليات التصدير والاستيراد =====

  // تصدير جميع البيانات
  static Map<String, dynamic> exportAllData() {
    final allData = <String, dynamic>{};

    for (final key in getKeys()) {
      allData[key] = _storage.read(key);
    }

    return {
      'data': allData,
      'exportedAt': DateTime.now().toIso8601String(),
      'version': AppConstants.appVersion,
    };
  }

  // استيراد البيانات
  static Future<bool> importData(Map<String, dynamic> backupData) async {
    try {
      final data = backupData['data'] as Map<String, dynamic>?;

      if (data != null) {
        // حذف البيانات الحالية
        await clear();

        // استيراد البيانات الجديدة
        for (final entry in data.entries) {
          await _storage.write(entry.key, entry.value);
        }

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // ===== إحصائيات التخزين =====

  // الحصول على عدد العناصر المخزنة
  static int getItemCount() {
    return getKeys().length;
  }

  // الحصول على معلومات التخزين
  static Map<String, dynamic> getStorageInfo() {
    return {
      'itemCount': getItemCount(),
      'storageSize': getStorageSize(),
      'keys': getKeys().toList(),
      'hasUserData': hasKey(AppConstants.keyUserData),
      'hasSubscriptionData': hasKey(AppConstants.keySubscriptionData),
      'hasDeviceId': hasKey(AppConstants.keyDeviceId),
      'isFirstTime': isFirstTime(),
    };
  }

  // ===== تنظيف البيانات =====

  // حذف البيانات المنتهية الصلاحية
  static Future<void> cleanExpiredData() async {
    // يمكن إضافة منطق لحذف البيانات القديمة هنا
    // مثل حذف الجلسات المنتهية أو البيانات المؤقتة
  }

  // حذف البيانات غير المستخدمة
  static Future<void> cleanUnusedData() async {
    final keysToRemove = <String>[];

    for (final key in getKeys()) {
      final value = _storage.read(key);
      if (value == null || (value is String && value.isEmpty)) {
        keysToRemove.add(key);
      }
    }

    for (final key in keysToRemove) {
      await remove(key);
    }
  }

  // إعادة تعيين البيانات للحالة الافتراضية
  static Future<void> resetToDefaults() async {
    await clear();
    await setFirstTime(true);
  }
}