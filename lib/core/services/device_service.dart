import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'storage_service.dart';
import '../constants/app_constants.dart';

class DeviceService {
  // منع إنشاء instance من الكلاس
  DeviceService._();

  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // ===== معرف الجهاز =====

  // الحصول على معرف الجهاز الفريد
  static Future<String> getDeviceId() async {
    try {
      // محاولة الحصول على المعرف المحفوظ محلياً
      final savedId = StorageService.getString(AppConstants.keyDeviceId);
      if (savedId != null && savedId.isNotEmpty) {
        return savedId;
      }

      // إنشاء معرف جديد إذا لم يكن موجوداً
      String deviceId;

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceId = androidInfo.id; // Android ID
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'ios_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        deviceId = 'unknown_${DateTime.now().millisecondsSinceEpoch}';
      }

      // حفظ المعرف محلياً
      await StorageService.setString(AppConstants.keyDeviceId, deviceId);

      return deviceId;
    } catch (e) {
      // في حالة الخطأ، إنشاء معرف عشوائي
      final fallbackId = 'fallback_${DateTime.now().millisecondsSinceEpoch}';
      await StorageService.setString(AppConstants.keyDeviceId, fallbackId);
      return fallbackId;
    }
  }

  // نسخ معرف الجهاز للحافظة
  static Future<bool> copyDeviceIdToClipboard() async {
    try {
      final deviceId = await getDeviceId();
      await Clipboard.setData(ClipboardData(text: deviceId));
      return true;
    } catch (e) {
      return false;
    }
  }

  // ===== معلومات الجهاز =====

  // الحصول على معلومات الجهاز الأساسية
  static Future<Map<String, dynamic>> getBasicDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': 'Android',
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': 'iOS',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
        };
      } else {
        return {
          'platform': Platform.operatingSystem,
          'version': Platform.operatingSystemVersion,
        };
      }
    } catch (e) {
      return {
        'platform': 'Unknown',
        'error': e.toString(),
      };
    }
  }

  // الحصول على معلومات الجهاز المفصلة
  static Future<Map<String, dynamic>> getDetailedDeviceInfo() async {
    try {
      final basicInfo = await getBasicDeviceInfo();
      final deviceId = await getDeviceId();

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          ...basicInfo,
          'deviceId': deviceId,
          'androidId': androidInfo.id,
          'fingerprint': androidInfo.fingerprint,
          'hardware': androidInfo.hardware,
          'host': androidInfo.host,
          'product': androidInfo.product,
          'tags': androidInfo.tags,
          'type': androidInfo.type,
          'bootloader': androidInfo.bootloader,
          'display': androidInfo.display,
          'board': androidInfo.board,
          'device': androidInfo.device,
          'supportedAbis': androidInfo.supportedAbis,
          'supported32BitAbis': androidInfo.supported32BitAbis,
          'supported64BitAbis': androidInfo.supported64BitAbis,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          ...basicInfo,
          'deviceId': deviceId,
          'identifierForVendor': iosInfo.identifierForVendor,
          'localizedModel': iosInfo.localizedModel,
          'utsname': {
            'sysname': iosInfo.utsname.sysname,
            'nodename': iosInfo.utsname.nodename,
            'release': iosInfo.utsname.release,
            'version': iosInfo.utsname.version,
            'machine': iosInfo.utsname.machine,
          },
        };
      } else {
        return {
          ...basicInfo,
          'deviceId': deviceId,
        };
      }
    } catch (e) {
      return {
        'deviceId': await getDeviceId(),
        'platform': Platform.operatingSystem,
        'error': e.toString(),
      };
    }
  }

  // ===== فحص الجهاز =====

  // التحقق من كون الجهاز حقيقي (ليس محاكي)
  static Future<bool> isPhysicalDevice() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.isPhysicalDevice;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.isPhysicalDevice;
      }
      return true; // افتراض أنه جهاز حقيقي للمنصات الأخرى
    } catch (e) {
      return true;
    }
  }

  // التحقق من إصدار النظام
  static Future<bool> isOSVersionSupported({
    int? minAndroidSdk,
    String? minIOSVersion,
  }) async {
    try {
      if (Platform.isAndroid && minAndroidSdk != null) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.version.sdkInt >= minAndroidSdk;
      } else if (Platform.isIOS && minIOSVersion != null) {
        final iosInfo = await _deviceInfo.iosInfo;
        final currentVersion = iosInfo.systemVersion;
        return _compareVersions(currentVersion, minIOSVersion) >= 0;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // مقارنة إصدارات iOS
  static int _compareVersions(String version1, String version2) {
    final v1Parts = version1.split('.').map(int.parse).toList();
    final v2Parts = version2.split('.').map(int.parse).toList();
    
    final maxLength = v1Parts.length > v2Parts.length ? v1Parts.length : v2Parts.length;
    
    for (int i = 0; i < maxLength; i++) {
      final v1Part = i < v1Parts.length ? v1Parts[i] : 0;
      final v2Part = i < v2Parts.length ? v2Parts[i] : 0;
      
      if (v1Part < v2Part) return -1;
      if (v1Part > v2Part) return 1;
    }
    
    return 0;
  }

  // ===== معلومات التطبيق =====

  // الحصول على اسم التطبيق
  static String getAppName() {
    return AppConstants.appName;
  }

  // الحصول على إصدار التطبيق
  static String getAppVersion() {
    return AppConstants.appVersion;
  }

  // الحصول على رقم البناء
  static String getBuildNumber() {
    return AppConstants.appBuildNumber;
  }

  // ===== إحصائيات الاستخدام =====

  // حفظ وقت آخر استخدام
  static Future<void> updateLastUsed() async {
    await StorageService.setString('last_used', DateTime.now().toIso8601String());
  }

  // الحصول على وقت آخر استخدام
  static DateTime? getLastUsed() {
    final lastUsedString = StorageService.getString('last_used');
    if (lastUsedString != null) {
      try {
        return DateTime.parse(lastUsedString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // حفظ عدد مرات فتح التطبيق
  static Future<void> incrementAppOpenCount() async {
    final currentCount = StorageService.getInt('app_open_count') ?? 0;
    await StorageService.setInt('app_open_count', currentCount + 1);
  }

  // الحصول على عدد مرات فتح التطبيق
  static int getAppOpenCount() {
    return StorageService.getInt('app_open_count') ?? 0;
  }



  /// الحصول على معرف الجهاز المختصر للعرض
  static Future<String> getShortDeviceId() async {
    final fullId = await getDeviceId();
    if (fullId.length <= 12) return fullId;
    return '${fullId.substring(0, 6)}...${fullId.substring(fullId.length - 6)}';
  }

  // ===== تصدير معلومات الجهاز =====

  // تصدير جميع معلومات الجهاز
  static Future<Map<String, dynamic>> exportDeviceInfo() async {
    final deviceInfo = await getDetailedDeviceInfo();
    final lastUsed = getLastUsed();
    final appOpenCount = getAppOpenCount();

    return {
      'deviceInfo': deviceInfo,
      'appInfo': {
        'name': getAppName(),
        'version': getAppVersion(),
        'buildNumber': getBuildNumber(),
      },
      'usage': {
        'lastUsed': lastUsed?.toIso8601String(),
        'appOpenCount': appOpenCount,
      },
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  // إنشاء تقرير الجهاز
  static Future<String> generateDeviceReport() async {
    final info = await exportDeviceInfo();
    final deviceInfo = info['deviceInfo'] as Map<String, dynamic>;
    final appInfo = info['appInfo'] as Map<String, dynamic>;
    final usage = info['usage'] as Map<String, dynamic>;

    return '''
تقرير معلومات الجهاز
===================

معلومات التطبيق:
- الاسم: ${appInfo['name']}
- الإصدار: ${appInfo['version']}
- رقم البناء: ${appInfo['buildNumber']}

معلومات الجهاز:
- المنصة: ${deviceInfo['platform']}
- الطراز: ${deviceInfo['model'] ?? 'غير محدد'}
- معرف الجهاز: ${deviceInfo['deviceId']}
- جهاز حقيقي: ${await isPhysicalDevice() ? 'نعم' : 'لا'}

إحصائيات الاستخدام:
- عدد مرات الفتح: ${usage['appOpenCount']}
- آخر استخدام: ${usage['lastUsed'] ?? 'غير محدد'}

تاريخ التقرير: ${DateTime.now().toString()}
''';
  }
}
