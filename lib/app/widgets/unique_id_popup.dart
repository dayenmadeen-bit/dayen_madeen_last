import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/logger_service.dart';
import '../../core/services/storage_service.dart';

/// ويجت عرض الرقم المميز في نافذة منبثقة
class UniqueIdPopup {
  /// عرض الرقم المميز في نافذة منبثقة جميلة
  static void showUniqueIdDialog({
    required String uniqueId,
    required String userType, // 'business_owner', 'customer', 'employee'
    String? userEmail,
    String? userName,
    VoidCallback? onContinue,
  }) {
    String title;
    String description;
    String instruction;
    IconData icon;
    Color primaryColor;

    // تخصيص المحتوى حسب نوع المستخدم
    switch (userType) {
      case 'business_owner':
        title = 'مرحباً بك يا مالك المنشأة!';
        description = 'تم إنشاء حسابك بنجاح\nرقمك المميز يمكن استخدامه لتسجيل الدخول';
        instruction = 'احفظ هذا الرقم في مكان آمن وشاركه مع زبائنك';
        icon = AppIcons.business;
        primaryColor = AppColors.primary;
        break;
      case 'customer':
        title = 'مرحباً بك!';
        description = 'تم إنشاء حسابك بنجاح\nاستخدم هذا الرقم لتسجيل الدخول';
        instruction = 'احفظ هذا الرقم في هاتفك أو مفكرتك';
        icon = AppIcons.customers;
        primaryColor = AppColors.success;
        break;
      case 'employee':
        title = 'مرحباً بالموظف الجديد!';
        description = 'تم إضافتك لفريق العمل\nاستخدم هذا الرقم لتسجيل الدخول';
        instruction = 'شارك هذا الرقم مع الموظف ليتمكن من الدخول';
        icon = AppIcons.person;
        primaryColor = AppColors.info;
        break;
      default:
        title = 'رقمك المميز';
        description = 'تم توليد رقمك المميز';
        instruction = 'احفظ هذا الرقم';
        icon = AppIcons.info;
        primaryColor = AppColors.primary;
    }

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // منع الإغلاق بالعودة
        child: AlertDialog(
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          content: Container(
            width: Get.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withValues(alpha: 0.1),
                  Colors.white,
                  primaryColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // الهيدر مع الأيقونة
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // أيقونة متحركة
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                icon,
                                size: 40,
                                color: primaryColor,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // عنوان
                      Text(
                        title,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // المحتوى
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // وصف
                      Text(
                        description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // عرض الرقم المميز
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor.withValues(alpha: 0.1),
                              primaryColor.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'رقمك المميز',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // عرض الرقم بخط كبير
                                Text(
                                  uniqueId,
                                  style: AppTextStyles.headlineLarge.copyWith(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 3,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // زر النسخ
                                GestureDetector(
                                  onTap: () => _copyToClipboard(uniqueId, primaryColor),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.copy,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // تعليمات هامة
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.warning,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                instruction,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // عرض معلومات إضافية إذا توفرت
                      if (userEmail != null || userName != null) ..[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (userName != null) ..[
                                Text('الاسم: $userName',
                                    style: AppTextStyles.bodySmall),
                                const SizedBox(height: 4),
                              ],
                              if (userEmail != null)
                                Text('البريد: $userEmail',
                                    style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // أزرار العمل
                      Row(
                        children: [
                          // زر نسخ الرقم
                          Expanded(
                            flex: 2,
                            child: OutlinedButton.icon(
                              onPressed: () => _copyToClipboard(uniqueId, primaryColor),
                              icon: Icon(Icons.copy, size: 18),
                              label: const Text('نسخ الرقم'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryColor,
                                side: BorderSide(color: primaryColor),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // زر المتابعة
                          Expanded(
                            flex: 3,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Get.back();
                                _saveUniqueIdToStorage(uniqueId);
                                if (onContinue != null) {
                                  onContinue();
                                }
                              },
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('متابعة'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false, // منع الإغلاق باللمس
    );
  }

  /// نسخ الرقم إلى الحافظة
  static void _copyToClipboard(String uniqueId, Color primaryColor) {
    Clipboard.setData(ClipboardData(text: uniqueId));
    Get.snackbar(
      'تم النسخ',
      'تم نسخ الرقم المميز ($uniqueId) إلى الحافظة',
      backgroundColor: primaryColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
    
    // تسجيل عملية النسخ
    LoggerService.info('تم نسخ الرقم المميز: $uniqueId');
  }

  /// حفظ الرقم المميز في التخزين المحلي
  static void _saveUniqueIdToStorage(String uniqueId) {
    try {
      StorageService.setString('user_unique_id', uniqueId);
      LoggerService.success('تم حفظ الرقم المميز محلياً: $uniqueId');
    } catch (e) {
      LoggerService.error('خطأ في حفظ الرقم المميز', error: e);
    }
  }

  /// عرض الرقم المميز المحفوظ
  static void showStoredUniqueId() {
    final storedId = StorageService.getString('user_unique_id');
    if (storedId != null && storedId.isNotEmpty) {
      showUniqueIdDialog(
        uniqueId: storedId,
        userType: 'stored', // نوع خاص للرقم المحفوظ
      );
    } else {
      Get.snackbar(
        'غير متوفر',
        'لا يوجد رقم مميز محفوظ',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// حذف الرقم المميز من التخزين
  static void clearStoredUniqueId() {
    try {
      StorageService.remove('user_unique_id');
      LoggerService.info('تم حذف الرقم المميز المحفوظ');
    } catch (e) {
      LoggerService.error('خطأ في حذف الرقم المميز', error: e);
    }
  }

  /// الحصول على الرقم المميز المحفوظ
  static String? getStoredUniqueId() {
    return StorageService.getString('user_unique_id');
  }

  /// عرض رقم مميز بسيط (بدون عناصر معقدة)
  static void showSimpleIdDialog(String uniqueId) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(AppIcons.info, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('رقمك المميز'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(
              uniqueId,
              style: AppTextStyles.headlineMedium.copyWith(
                fontFamily: 'monospace',
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text('استخدم هذا الرقم لتسجيل الدخول'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _copyToClipboard(uniqueId, AppColors.primary),
            child: const Text('نسخ'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}