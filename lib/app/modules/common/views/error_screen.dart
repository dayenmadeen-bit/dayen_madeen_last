import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../widgets/custom_button.dart';

/// شاشة الخطأ العام
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // الحصول على معلومات الخطأ من المعاملات
    final arguments = Get.arguments as Map<String, dynamic>? ?? {};
    final errorTitle = arguments['title'] as String? ?? 'حدث خطأ';
    final errorMessage = arguments['message'] as String? ?? 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
    final errorCode = arguments['code'] as String?;
    final canRetry = arguments['canRetry'] as bool? ?? true;
    final onRetry = arguments['onRetry'] as VoidCallback?;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة الخطأ
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.error,
                  size: 60,
                  color: AppColors.error,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // عنوان الخطأ
              Text(
                errorTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // رسالة الخطأ
              Text(
                errorMessage,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              // رمز الخطأ (إن وجد)
              if (errorCode != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'رمز الخطأ: $errorCode',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 48),
              
              // أزرار الإجراءات
              Column(
                children: [
                  // زر المحاولة مرة أخرى
                  if (canRetry)
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'المحاولة مرة أخرى',
                        onPressed: onRetry ?? () {
                          // إعادة تحميل الصفحة الحالية
                          Get.back();
                        },
                        icon: AppIcons.refresh,
                      ),
                    ),
                  
                  const SizedBox(height: 12),
                  
                  // زر العودة للرئيسية
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'العودة للرئيسية',
                      onPressed: () {
                        Get.offAllNamed('/home');
                      },
                      type: ButtonType.outlined,
                      icon: AppIcons.home,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // رابط التواصل مع الدعم
                  TextButton.icon(
                    onPressed: () {
                      Get.toNamed('/contact');
                    },
                    icon: Icon(
                      AppIcons.support,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      'تواصل مع الدعم الفني',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // معلومات إضافية
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          AppIcons.info,
                          color: AppColors.info,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'نصائح لحل المشكلة',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTipItem('تأكد من اتصالك بالإنترنت'),
                        _buildTipItem('أعد تشغيل التطبيق'),
                        _buildTipItem('تحقق من آخر التحديثات'),
                        _buildTipItem('امسح ذاكرة التخزين المؤقت'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            AppIcons.checkCircle,
            color: AppColors.info,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// دالة مساعدة لعرض شاشة الخطأ
class ErrorHelper {
  /// عرض شاشة خطأ عام
  static void showError({
    String? title,
    String? message,
    String? code,
    bool canRetry = true,
    VoidCallback? onRetry,
  }) {
    Get.toNamed('/error', arguments: {
      'title': title,
      'message': message,
      'code': code,
      'canRetry': canRetry,
      'onRetry': onRetry,
    });
  }
  
  /// عرض شاشة خطأ الشبكة
  static void showNetworkError({VoidCallback? onRetry}) {
    showError(
      title: 'مشكلة في الاتصال',
      message: 'تعذر الاتصال بالخادم. تأكد من اتصالك بالإنترنت وحاول مرة أخرى.',
      code: 'NETWORK_ERROR',
      onRetry: onRetry,
    );
  }
  
  /// عرض شاشة خطأ الخادم
  static void showServerError({VoidCallback? onRetry}) {
    showError(
      title: 'خطأ في الخادم',
      message: 'حدث خطأ في الخادم. نحن نعمل على حل المشكلة. يرجى المحاولة لاحقاً.',
      code: 'SERVER_ERROR',
      onRetry: onRetry,
    );
  }
  
  /// عرض شاشة خطأ غير مصرح
  static void showUnauthorizedError() {
    showError(
      title: 'غير مصرح',
      message: 'انتهت صلاحية جلستك. يرجى تسجيل الدخول مرة أخرى.',
      code: 'UNAUTHORIZED',
      canRetry: false,
      onRetry: () => Get.offAllNamed('/login'),
    );
  }
}
