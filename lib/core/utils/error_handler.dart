import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/logger_service.dart';
import '../constants/app_colors.dart';

/// معالج الأخطاء العام للتطبيق
class ErrorHandler {
  /// معالجة أخطاء GetX
  static void handleGetxError(String error, StackTrace stackTrace) {
    LoggerService.error('خطأ GetX', error: error, stackTrace: stackTrace);

    // إظهار رسالة خطأ للمستخدم
    if (Get.context != null) {
      _showErrorSnackbar('حدث خطأ في التطبيق', 'يرجى إعادة تشغيل التطبيق');
    }
  }

  /// معالجة أخطاء Flutter العامة
  static void handleFlutterError(FlutterErrorDetails details) {
    LoggerService.error(
      'خطأ Flutter: ${details.exception}',
      error: details.exception,
      stackTrace: details.stack,
    );

    // في وضع التطوير، إظهار الخطأ
    if (Get.context != null) {
      _showErrorSnackbar('خطأ في واجهة المستخدم', details.exception.toString());
    }
  }

  /// معالجة أخطاء الشبكة
  static void handleNetworkError(dynamic error) {
    LoggerService.error('خطأ في الشبكة', error: error);

    if (Get.context != null) {
      _showErrorSnackbar(
        'خطأ في الاتصال',
        'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
      );
    }
  }

  /// معالجة أخطاء قاعدة البيانات
  static void handleDatabaseError(dynamic error) {
    LoggerService.error('خطأ في قاعدة البيانات', error: error);

    if (Get.context != null) {
      _showErrorSnackbar(
        'خطأ في حفظ البيانات',
        'حدث خطأ أثناء حفظ البيانات، يرجى المحاولة مرة أخرى',
      );
    }
  }

  /// معالجة أخطاء المصادقة
  static void handleAuthError(dynamic error) {
    LoggerService.error('خطأ في المصادقة', error: error);

    if (Get.context != null) {
      _showErrorSnackbar(
        'خطأ في تسجيل الدخول',
        'تحقق من بيانات تسجيل الدخول وحاول مرة أخرى',
      );
    }
  }

  /// إظهار رسالة خطأ للمستخدم
  static void _showErrorSnackbar(String title, String message) {
    // تجنب جدولة بناء أثناء الإطار الحالي
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Get.isSnackbarOpen) {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
          duration: const Duration(seconds: 5),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          icon: const Icon(
            Icons.error_outline,
            color: Colors.white,
          ),
          shouldIconPulse: true,
          barBlur: 20,
        );
      }
    });
  }

  /// إظهار dialog للأخطاء الحرجة
  static void showCriticalErrorDialog(String title, String message) {
    if (Get.context == null) return;

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: AppColors.error),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('موافق'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // يمكن إضافة منطق إعادة تشغيل التطبيق هنا
            },
            child: const Text('إعادة تشغيل'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// تسجيل خطأ بسيط
  static void logError(String message,
      {dynamic error, StackTrace? stackTrace}) {
    LoggerService.error(message, error: error, stackTrace: stackTrace);
  }

  /// تسجيل تحذير
  static void logWarning(String message) {
    LoggerService.warning(message);
  }
}
