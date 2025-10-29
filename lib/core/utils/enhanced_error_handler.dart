import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../services/logger_service.dart';
import '../services/notification_service.dart';

/// مدير الأخطاء المحسن
/// يوفر معالجة شاملة للأخطاء مع تتبع متقدم
class EnhancedErrorHandler {
  static const String _tag = 'EnhancedErrorHandler';
  
  // === أنواع الأخطاء ===
  
  static const Map<String, String> _errorMessages = {
    // أخطاء الشبكة
    'network_error': 'خطأ في الاتصال بالإنترنت',
    'timeout_error': 'انتهت مهلة الانتظار',
    'connection_refused': 'تم رفض الاتصال',
    
    // أخطاء المصادقة
    'auth_invalid_credentials': 'بيانات تسجيل الدخول غير صحيحة',
    'auth_user_not_found': 'لم يتم العثور على المستخدم',
    'auth_too_many_requests': 'تم تجاوز الحد المسموح للمحاولات',
    'auth_email_already_in_use': 'البريد الإلكتروني مستخدم بالفعل',
    
    // أخطاء قاعدة البيانات
    'firestore_permission_denied': 'ليس لديك صلاحية للوصول لهذه البيانات',
    'firestore_unavailable': 'قاعدة البيانات غير متاحة حالياً',
    'firestore_data_loss': 'حدث فقدان في البيانات',
    
    // أخطاء التطبيق
    'validation_error': 'خطأ في صحة البيانات',
    'format_error': 'تنسيق غير صحيح',
    'storage_error': 'خطأ في التخزين',
    'permission_error': 'ليس لديك الصلاحية اللازمة',
    
    // رسالة عامة
    'unknown_error': 'حدث خطأ غير متوقع',
  };
  
  /// تهيئة مدير الأخطاء
  static void initialize() {
    // معالج أخطاء Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };
    
    // معالج أخطاء المنطقة (Zone)
    PlatformDispatcher.instance.onError = (error, stack) {
      _handlePlatformError(error, stack);
      return true;
    };
    
    LoggerService.info('$_tag: تم تهيئة مدير الأخطاء');
  }
  
  /// معالجة أخطاء Flutter
  static void _handleFlutterError(FlutterErrorDetails details) {
    // سجل الخطأ محلياً
    LoggerService.error(
      '$_tag: خطأ Flutter',
      error: details.exception,
      stackTrace: details.stack,
    );
    
    // إرسال لـ Sentry
    Sentry.captureException(
      details.exception,
      stackTrace: details.stack,
    );
    
    // في وضع التطوير، عرض الخطأ في وحدة التحكم
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  }
  
  /// معالجة أخطاء المنطقة
  static void _handlePlatformError(Object error, StackTrace stackTrace) {
    // سجل الخطأ محلياً
    LoggerService.error(
      '$_tag: خطأ في المنطقة',
      error: error,
      stackTrace: stackTrace,
    );
    
    // إرسال لـ Sentry
    Sentry.captureException(error, stackTrace: stackTrace);
  }
  
  /// معالجة عامة للأخطاء
  static void handleError({
    required dynamic error,
    StackTrace? stackTrace,
    String? context,
    bool showToUser = true,
    ErrorSeverity severity = ErrorSeverity.medium,
  }) {
    final errorType = _identifyErrorType(error);
    final userMessage = _errorMessages[errorType] ?? _errorMessages['unknown_error']!;
    
    // سجل الخطأ
    _logError(
      error: error,
      stackTrace: stackTrace,
      context: context,
      severity: severity,
    );
    
    // إرسال لـ Sentry (فقط للأخطاء الحرجة والمتوسطة)
    if (severity != ErrorSeverity.low) {
      _sendToSentry(error, stackTrace, context);
    }
    
    // عرض الخطأ للمستخدم (إذا لزم الأمر)
    if (showToUser) {
      _showUserError(userMessage, severity);
    }
  }
  
  /// تحديد نوع الخطأ
  static String _identifyErrorType(dynamic error) {
    if (error == null) return 'unknown_error';
    
    final errorString = error.toString().toLowerCase();
    
    // أخطاء الشبكة
    if (errorString.contains('socketexception') || 
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'network_error';
    }
    
    if (errorString.contains('timeout')) {
      return 'timeout_error';
    }
    
    // أخطاء Firebase Auth
    if (errorString.contains('invalid-credential') || 
        errorString.contains('wrong-password')) {
      return 'auth_invalid_credentials';
    }
    
    if (errorString.contains('user-not-found')) {
      return 'auth_user_not_found';
    }
    
    if (errorString.contains('too-many-requests')) {
      return 'auth_too_many_requests';
    }
    
    if (errorString.contains('email-already-in-use')) {
      return 'auth_email_already_in_use';
    }
    
    // أخطاء Firestore
    if (errorString.contains('permission-denied')) {
      return 'firestore_permission_denied';
    }
    
    if (errorString.contains('unavailable')) {
      return 'firestore_unavailable';
    }
    
    // أخطاء التحقق
    if (errorString.contains('validation') || 
        errorString.contains('invalid')) {
      return 'validation_error';
    }
    
    // أخطاء التنسيق
    if (errorString.contains('format') || 
        errorString.contains('parse')) {
      return 'format_error';
    }
    
    return 'unknown_error';
  }
  
  /// تسجيل الخطأ
  static void _logError({
    required dynamic error,
    StackTrace? stackTrace,
    String? context,
    required ErrorSeverity severity,
  }) {
    final message = context != null 
        ? '$_tag [$context]: ${error.toString()}'
        : '$_tag: ${error.toString()}';
    
    switch (severity) {
      case ErrorSeverity.low:
        LoggerService.warning(message, error: error, stackTrace: stackTrace);
        break;
      case ErrorSeverity.medium:
        LoggerService.error(message, error: error, stackTrace: stackTrace);
        break;
      case ErrorSeverity.high:
        LoggerService.critical(message, error: error, stackTrace: stackTrace);
        break;
    }
  }
  
  /// إرسال الخطأ لـ Sentry
  static void _sendToSentry(dynamic error, StackTrace? stackTrace, String? context) {
    try {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          if (context != null) {
            scope.setTag('context', context);
          }
          scope.setTag('app_version', '1.0.1+2');
          scope.setTag('platform', 'flutter');
        },
      );
    } catch (e) {
      LoggerService.error('$_tag: فشل في إرسال الخطأ لـ Sentry', error: e);
    }
  }
  
  /// عرض الخطأ للمستخدم
  static void _showUserError(String message, ErrorSeverity severity) {
    try {
      // عرض الخطأ عبر SnackBar
      if (Get.context != null) {
        Get.snackbar(
          _getSeverityTitle(severity),
          message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: _getSeverityColor(severity),
          colorText: Colors.white,
          icon: Icon(_getSeverityIcon(severity), color: Colors.white),
          duration: Duration(seconds: severity == ErrorSeverity.high ? 5 : 3),
          isDismissible: true,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        );
      }
      
      // إرسال إشعار محلي (للأخطاء الحرجة فقط)
      if (severity == ErrorSeverity.high) {
        NotificationService.showErrorNotification(
          title: 'خطأ في التطبيق',
          body: message,
        );
      }
      
    } catch (e) {
      LoggerService.error('$_tag: فشل في عرض الخطأ للمستخدم', error: e);
    }
  }
  
  /// الحصول على عنوان حسب شدة الخطأ
  static String _getSeverityTitle(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return 'تنبيه';
      case ErrorSeverity.medium:
        return 'خطأ';
      case ErrorSeverity.high:
        return 'خطأ حرج';
    }
  }
  
  /// الحصول على لون حسب شدة الخطأ
  static Color _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Colors.orange;
      case ErrorSeverity.medium:
        return Colors.red;
      case ErrorSeverity.high:
        return Colors.red.shade800;
    }
  }
  
  /// الحصول على أيقونة حسب شدة الخطأ
  static IconData _getSeverityIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Icons.warning;
      case ErrorSeverity.medium:
        return Icons.error;
      case ErrorSeverity.high:
        return Icons.error_outline;
    }
  }
  
  // === دوال مساعدة عامة ===
  
  /// تنفيذ عملية مع معالجة تلقائية للأخطاء
  static Future<T?> safeExecute<T>({
    required Future<T> Function() operation,
    String? context,
    T? defaultValue,
    bool showErrorToUser = true,
    ErrorSeverity severity = ErrorSeverity.medium,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      handleError(
        error: error,
        stackTrace: stackTrace,
        context: context,
        showToUser: showErrorToUser,
        severity: severity,
      );
      return defaultValue;
    }
  }
  
  /// تنفيذ عملية متزامنة مع معالجة تلقائية للأخطاء
  static T? safeExecuteSync<T>({
    required T Function() operation,
    String? context,
    T? defaultValue,
    bool showErrorToUser = true,
    ErrorSeverity severity = ErrorSeverity.medium,
  }) {
    try {
      return operation();
    } catch (error, stackTrace) {
      handleError(
        error: error,
        stackTrace: stackTrace,
        context: context,
        showToUser: showErrorToUser,
        severity: severity,
      );
      return defaultValue;
    }
  }
  
  /// إنشاء رسالة خطأ مخصصة
  static void reportCustomError({
    required String title,
    required String message,
    Map<String, dynamic>? additionalData,
    ErrorSeverity severity = ErrorSeverity.medium,
  }) {
    final error = CustomAppError(title, message, additionalData);
    
    handleError(
      error: error,
      context: title,
      severity: severity,
    );
  }
}

/// مستويات شدة الخطأ
enum ErrorSeverity {
  low,    // تنبيهات عامة
  medium, // أخطاء متوسطة
  high,   // أخطاء حرجة
}

/// فئة أخطاء مخصصة للتطبيق
class CustomAppError extends Error {
  final String title;
  final String message;
  final Map<String, dynamic>? additionalData;
  
  CustomAppError(this.title, this.message, [this.additionalData]);
  
  @override
  String toString() {
    return '$title: $message${additionalData != null ? ' - Data: $additionalData' : ''}';
  }
}