import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import 'firebase_integration_service.dart';
import 'logger_service.dart';

/// خدمة متطورة للتحقق من البريد الإلكتروني بالعربية
class EmailVerificationService extends GetxService {
  static EmailVerificationService get instance => Get.find<EmailVerificationService>();

  Timer? _verificationCheckTimer;
  final _isVerificationSent = false.obs;
  final _isVerifying = false.obs;
  final _resendCountdown = 0.obs;
  final _canResend = true.obs;
  
  // خدمة Firebase
  late final FirebaseIntegrationService _firebaseService;
  
  bool get isVerificationSent => _isVerificationSent.value;
  bool get isVerifying => _isVerifying.value;
  int get resendCountdown => _resendCountdown.value;
  bool get canResend => _canResend.value;
  
  @override
  void onInit() {
    super.onInit();
    _firebaseService = Get.find<FirebaseIntegrationService>();
  }
  
  @override
  void onClose() {
    _verificationCheckTimer?.cancel();
    super.onClose();
  }

  /// إرسال بريد التحقق
  Future<bool> sendVerificationEmail() async {
    try {
      _isVerifying.value = true;
      
      final success = await _firebaseService.sendEmailVerification();
      
      if (success) {
        _isVerificationSent.value = true;
        _startResendCountdown();
        
        // عرض رسالة نجاح
        _showSuccessMessage();
        
        // بدء فحص حالة التحقق
        _startVerificationCheck();
        
        LoggerService.success('✅ تم إرسال بريد التحقق');
        return true;
      } else {
        _showErrorMessage('لم يتم إرسال بريد التحقق');
        return false;
      }
    } catch (e) {
      LoggerService.error('خطأ في إرسال بريد التحقق', error: e);
      _showErrorMessage('حدث خطأ في إرسال بريد التحقق');
      return false;
    } finally {
      _isVerifying.value = false;
    }
  }

  /// فحص حالة التحقق
  Future<bool> checkVerificationStatus() async {
    try {
      final isVerified = await _firebaseService.checkEmailVerification();
      
      if (isVerified) {
        _verificationCheckTimer?.cancel();
        _showVerificationSuccessDialog();
        LoggerService.success('✅ تم التحقق من البريد بنجاح');
      }
      
      return isVerified;
    } catch (e) {
      LoggerService.error('خطأ في فحص حالة التحقق', error: e);
      return false;
    }
  }

  /// بدء فحص دوري لحالة التحقق
  void _startVerificationCheck() {
    _verificationCheckTimer?.cancel();
    
    _verificationCheckTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) async {
        final isVerified = await checkVerificationStatus();
        if (isVerified) {
          _verificationCheckTimer?.cancel();
        }
      },
    );
  }

  /// بدء عد تنازلي لإعادة الإرسال
  void _startResendCountdown() {
    _canResend.value = false;
    _resendCountdown.value = 60; // 60 ثانية
    
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown.value > 0) {
        _resendCountdown.value--;
      } else {
        _canResend.value = true;
        timer.cancel();
      }
    });
  }

  /// عرض رسالة نجاح إرسال التحقق
  void _showSuccessMessage() {
    Get.snackbar(
      '✉️ تم إرسال بريد التحقق',
      'تفقد بريدك الإلكتروني للحصول على رابط التحقق',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      icon: const Icon(Icons.mark_email_read, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  /// عرض رسالة خطأ
  void _showErrorMessage(String message) {
    Get.snackbar(
      '❌ خطأ',
      message,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  /// عرض رسالة نجاح التحقق
  void _showVerificationSuccessDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified,
                color: AppColors.success,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('تم التحقق بنجاح!'),
            ),
          ],
        ),
        content: const Text(
          'تم التحقق من بريدك الإلكتروني بنجاح.\n\n'
          'يمكنك الآن استخدام جميع ميزات التطبيق.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              // الانتقال للشاشة الرئيسية
              Get.offAllNamed('/business-owner/home');
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('متابعة'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// عرض شاشة انتظار التحقق
  void showVerificationScreen() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              AppIcons.emailVerification,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('التحقق من البريد'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تم إرسال رابط التحقق إلى بريدك الإلكتروني:',
              style: Get.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.email,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _firebaseService.currentUser?.email ?? '',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'اتبع الخطوات التالية:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildVerificationStep('1', 'افتح بريدك الإلكتروني'),
            _buildVerificationStep('2', 'ابحث عن رسالة من "دائن مدين"'),
            _buildVerificationStep('3', 'اضغط على رابط التحقق'),
            _buildVerificationStep('4', 'عد لهذه الشاشة لمتابعة التحقق'),
            
            const SizedBox(height: 16),
            
            // معلومات إضافية
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'قد يستغرق وصول البريد بضع دقائق. تحقق من مجلد الرسائل المهملة.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // زر إعادة الإرسال
          Obx(() => TextButton(
                onPressed: _canResend.value && !_isVerifying.value
                    ? () => sendVerificationEmail()
                    : null,
                child: Text(
                  _canResend.value
                      ? 'إعادة إرسال'
                      : 'إعادة إرسال بعد ${_resendCountdown.value}ث',
                ),
              )),
          
          // زر فحص التحقق
          Obx(() => TextButton(
                onPressed: _isVerifying.value
                    ? null
                    : () => checkVerificationStatus(),
                child: _isVerifying.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('فحص التحقق'),
              )),
              
          // زر الإلغاء
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('إغلاق'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// بناء خطوة في عملية التحقق
  Widget _buildVerificationStep(String stepNumber, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: Get.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  /// عرض شاشة طلب إعادة إرسال التحقق
  void showResendVerificationDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('إعادة إرسال بريد التحقق'),
        content: const Text(
          'هل تريد إعادة إرسال بريد التحقق إلى عنوان بريدك الإلكتروني؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              sendVerificationEmail();
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('نعم، إعادة إرسال'),
          ),
        ],
      ),
    );
  }

  /// تنظيف الخدمة عند الخروج
  void cleanup() {
    _verificationCheckTimer?.cancel();
    _isVerificationSent.value = false;
    _isVerifying.value = false;
    _resendCountdown.value = 0;
    _canResend.value = true;
  }

  /// فحص فوري لحالة التحقق
  Future<void> forceCheckVerification() async {
    if (_firebaseService.currentUser != null) {
      await _firebaseService.currentUser!.reload();
      final isVerified = _firebaseService.currentUser!.emailVerified;
      
      if (isVerified) {
        _verificationCheckTimer?.cancel();
        _showVerificationSuccessDialog();
      } else {
        Get.snackbar(
          '⚠️ لم يتم التحقق بعد',
          'يرجى فحص بريدك الإلكتروني والنقر على رابط التحقق',
          backgroundColor: AppColors.warning,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  /// إعادة تعيين الخدمة لمستخدم جديد
  void resetForNewUser() {
    cleanup();
  }
}