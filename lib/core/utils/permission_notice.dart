import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

/// فئة لعرض رسائل الأذونات
class PermissionNotice {
  /// عرض رسالة عدم وجود إذن
  static void show({
    required String permissionDisplayName,
    String? customMessage,
  }) {
    Get.snackbar(
      'لا يوجد إذن',
      customMessage ?? 'ليس لديك إذن لـ $permissionDisplayName',
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      icon: const Icon(
        Icons.block,
        color: Colors.white,
      ),
    );
  }

  /// عرض رسالة نجاح الأذن
  static void showSuccess({
    required String permissionDisplayName,
    String? customMessage,
  }) {
    Get.snackbar(
      'تم بنجاح',
      customMessage ?? 'تم تنفيذ $permissionDisplayName بنجاح',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      icon: const Icon(
        Icons.check_circle,
        color: Colors.white,
      ),
    );
  }

  /// عرض رسالة تحذير الأذن
  static void showWarning({
    required String permissionDisplayName,
    String? customMessage,
  }) {
    Get.snackbar(
      'تحذير',
      customMessage ?? 'تحذير: $permissionDisplayName',
      backgroundColor: AppColors.warning,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      icon: const Icon(
        Icons.warning,
        color: Colors.white,
      ),
    );
  }
}

/// استثناء عدم وجود إذن
class PermissionDeniedException implements Exception {
  final String permission;
  final String? message;

  PermissionDeniedException(this.permission, [this.message]);

  @override
  String toString() {
    return message ?? 'لا يوجد إذن لـ $permission';
  }
}
