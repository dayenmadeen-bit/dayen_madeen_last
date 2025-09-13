import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/auth_service.dart';
import '../../../data/models/auth_result.dart';
import '../../../../core/constants/app_colors.dart';

/// مراحل استعادة كلمة المرور
enum ForgotPasswordStep {
  email,
  verification,
  newPassword,
  success,
}

enum RecoveryMethod { email, phone }

class ForgotPasswordController extends GetxController {
  // مفاتيح النماذج
  final GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> tokenFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();

  // متحكمات النصوص
  final TextEditingController emailController = TextEditingController();
  final TextEditingController uniqueIdController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();

  // حالات التفاعل
  final Rx<ForgotPasswordStep> currentStep = ForgotPasswordStep.email.obs;
  final RxBool isLoading = false.obs;
  final RxBool isNewPasswordHidden = true.obs;
  final RxBool isConfirmNewPasswordHidden = true.obs;
  final RxInt remainingTime = 0.obs;
  final selectedRecoveryMethod = RecoveryMethod.email.obs;

  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();

    // إذا تم تمرير بريد إلكتروني من شاشة أخرى
    final email = Get.arguments?['email'] as String?;
    if (email != null) {
      emailController.text = email;
    }
  }

  @override
  void onClose() {
    // تنظيف المتحكمات والمؤقتات
    emailController.dispose();
    uniqueIdController.dispose();
    tokenController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    _countdownTimer?.cancel();
    super.onClose();
  }

  /// تبديل إظهار/إخفاء كلمة المرور الجديدة
  void toggleNewPasswordVisibility() {
    isNewPasswordHidden.value = !isNewPasswordHidden.value;
  }

  /// تبديل إظهار/إخفاء تأكيد كلمة المرور الجديدة
  void toggleConfirmNewPasswordVisibility() {
    isConfirmNewPasswordHidden.value = !isConfirmNewPasswordHidden.value;
  }

  /// إرسال رمز الاستعادة (يتطلب مطابقة uniqueId + email)
  Future<void> sendResetCode() async {
    try {
      // التحقق من صحة النموذج
      if (currentStep.value == ForgotPasswordStep.email) {
        if (!emailFormKey.currentState!.validate()) {
          return;
        }
      }

      isLoading.value = true;
      final email = emailController.text.trim().toLowerCase();
      final uniqueId = uniqueIdController.text.trim();

      // تحقق من تطابق الرقم المميز مع البريد
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('uniqueId', isEqualTo: uniqueId)
          .limit(1)
          .get();
      if (userDoc.docs.isEmpty) {
        _errorSnack('الرقم المميز غير موجود');
        return;
      }
      final data = userDoc.docs.first.data();
      final userEmail = (data['email'] as String?)?.toLowerCase();
      if (userEmail == null || userEmail != email) {
        _errorSnack('البريد الإلكتروني لا يطابق هذا الرقم المميز');
        return;
      }

      // إرسال طلب إعادة تعيين كلمة المرور
      final result = await AuthService.instance.sendPasswordReset(email);

      if (result.isSuccess) {
        // نجح الإرسال
        Get.snackbar(
          'تم الإرسال',
          'تم إرسال رمز الاستعادة إلى بريدك الإلكتروني',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: AppColors.onSuccess,
          duration: const Duration(seconds: 4),
        );

        // الانتقال للمرحلة التالية
        currentStep.value = ForgotPasswordStep.verification;

        // بدء العد التنازلي
        _startCountdown();

        // في النسخة المحلية، عرض الرمز للمستخدم
        final token = result.data?['reset_token'] as String?;
        if (token != null) {
          _showTokenDialog(token);
        }
      } else {
        // فشل الإرسال
        Get.snackbar(
          'خطأ',
          result.error ?? 'فشل في إرسال رمز الاستعادة',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// التحقق من رمز الاستعادة
  Future<void> verifyToken() async {
    try {
      // التحقق من صحة النموذج
      if (!tokenFormKey.currentState!.validate()) {
        return;
      }

      isLoading.value = true;

      // في النسخة المحلية، نتحقق من الرمز محلياً
      // في النسخة الحقيقية، سيتم التحقق من الخادم

      // محاكاة التحقق
      await Future.delayed(const Duration(seconds: 1));

      // الانتقال للمرحلة التالية
      currentStep.value = ForgotPasswordStep.newPassword;

      Get.snackbar(
        'تم التحقق',
        'تم التحقق من الرمز بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.onSuccess,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'رمز الاستعادة غير صحيح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// إعادة تعيين كلمة المرور
  Future<void> resetPassword() async {
    try {
      // التحقق من صحة النموذج
      if (!passwordFormKey.currentState!.validate()) {
        return;
      }

      isLoading.value = true;

      // إنشاء بيانات إعادة التعيين
      final resetData = PasswordResetData(
        email: emailController.text.trim().toLowerCase(),
        token: tokenController.text.trim(),
        newPassword: newPasswordController.text,
      );

      // محاولة إعادة تعيين كلمة المرور
      final result = await AuthService.instance.resetPassword(resetData);

      if (result.isSuccess) {
        // نجحت العملية
        currentStep.value = ForgotPasswordStep.success;

        Get.snackbar(
          'تم بنجاح',
          'تم تغيير كلمة المرور بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: AppColors.onSuccess,
          duration: const Duration(seconds: 4),
        );
      } else {
        // فشلت العملية
        Get.snackbar(
          'خطأ',
          result.error ?? 'فشل في تغيير كلمة المرور',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// بدء العد التنازلي لإعادة الإرسال
  void _startCountdown() {
    remainingTime.value = 60; // 60 ثانية

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (remainingTime.value > 0) {
          remainingTime.value--;
        } else {
          timer.cancel();
        }
      },
    );
  }

  /// عرض الرمز في حوار (للنسخة المحلية فقط)
  void _showTokenDialog(String token) {
    Get.dialog(
      AlertDialog(
        title: const Text('رمز الاستعادة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'في النسخة الحقيقية، سيتم إرسال هذا الرمز إلى بريدك الإلكتروني:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                token,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              // ملء الرمز تلقائياً للتسهيل في النسخة التجريبية
              tokenController.text = token;
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// تحديد طريقة الاستعادة
  void setRecoveryMethod(RecoveryMethod method) {
    selectedRecoveryMethod.value = method;
  }

  /// العودة للمرحلة السابقة
  void goToPreviousStep() {
    switch (currentStep.value) {
      case ForgotPasswordStep.verification:
        currentStep.value = ForgotPasswordStep.email;
        break;
      case ForgotPasswordStep.newPassword:
        currentStep.value = ForgotPasswordStep.verification;
        break;
      default:
        Get.back();
        break;
    }
  }

  /// إعادة تعيين النموذج
  void resetForm() {
    emailController.clear();
    uniqueIdController.clear();
    tokenController.clear();
    newPasswordController.clear();
    confirmNewPasswordController.clear();
    currentStep.value = ForgotPasswordStep.email;
    remainingTime.value = 0;
    _countdownTimer?.cancel();
  }

  void _errorSnack(String message) {
    Get.snackbar(
      'خطأ',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: AppColors.onError,
      duration: const Duration(seconds: 4),
    );
  }
}
