import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// خدمة السجلات (Logging Service)
class LoggerService {
  static const String _appName = 'DayenMadeen';
  
  /// تسجيل معلومات عامة
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: _appName,
        level: 800, // INFO level
        time: DateTime.now(),
      );
    }
  }
  
  /// تسجيل تحذيرات
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: _appName,
        level: 900, // WARNING level
        time: DateTime.now(),
      );
    }
  }
  
  /// تسجيل أخطاء
  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: _appName,
        level: 1000, // ERROR level
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
    }
  }
  
  /// تسجيل تصحيح الأخطاء
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: _appName,
        level: 700, // DEBUG level
        time: DateTime.now(),
      );
    }
  }
  
  /// تسجيل العمليات الناجحة
  static void success(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(
        '✅ $message',
        name: _appName,
        level: 800, // INFO level
        time: DateTime.now(),
      );
    }
  }
  
  /// تسجيل بداية العمليات
  static void start(String operation, {String? tag}) {
    if (kDebugMode) {
      developer.log(
        '🚀 بدء: $operation',
        name: _appName,
        level: 700, // DEBUG level
        time: DateTime.now(),
      );
    }
  }
  
  /// تسجيل انتهاء العمليات
  static void end(String operation, {String? tag}) {
    if (kDebugMode) {
      developer.log(
        '🏁 انتهاء: $operation',
        name: _appName,
        level: 700, // DEBUG level
        time: DateTime.now(),
      );
    }
  }
  
  /// تسجيل بيانات المستخدم (للتطوير فقط)
  static void user(String action, Map<String, dynamic> data) {
    if (kDebugMode) {
      developer.log(
        '👤 $action: ${data.toString()}',
        name: _appName,
        level: 700, // DEBUG level
        time: DateTime.now(),
      );
    }
  }
  
  /// تسجيل التنقل
  static void navigation(String from, String to) {
    if (kDebugMode) {
      developer.log(
        '🧭 التنقل من $from إلى $to',
        name: _appName,
        level: 700, // DEBUG level
        time: DateTime.now(),
      );
    }
  }
}
