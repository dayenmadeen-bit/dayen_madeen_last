import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../widgets/custom_button.dart';

/// شاشة الصيانة
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة الصيانة
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.maintenance,
                  size: 60,
                  color: AppColors.warning,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // عنوان الصيانة
              Text(
                'التطبيق قيد الصيانة',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // رسالة الصيانة
              Text(
                'نحن نعمل على تحسين التطبيق لتقديم تجربة أفضل لك. سيكون التطبيق متاحاً قريباً.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // معلومات الصيانة
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          AppIcons.schedule,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'معلومات الصيانة',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildInfoRow('بدء الصيانة', '2:00 ص'),
                    _buildInfoRow('انتهاء الصيانة المتوقع', '6:00 ص'),
                    _buildInfoRow('المدة المتوقعة', '4 ساعات'),
                    _buildInfoRow('نوع الصيانة', 'تحديث النظام'),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // التحديثات المتوقعة
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          AppIcons.update,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ما الجديد؟',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    ...[
                      'تحسينات في الأداء والسرعة',
                      'إضافة ميزات جديدة للتقارير',
                      'تحسين واجهة المستخدم',
                      'إصلاح الأخطاء المعروفة',
                      'تعزيز الأمان والحماية',
                    ].map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            AppIcons.checkCircle,
                            color: AppColors.success,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // أزرار الإجراءات
              Column(
                children: [
                  // زر إعادة المحاولة
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'إعادة المحاولة',
                      onPressed: () {
                        // محاولة إعادة الاتصال
                        _checkMaintenanceStatus();
                      },
                      icon: AppIcons.refresh,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // زر التواصل مع الدعم
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'تواصل مع الدعم',
                      onPressed: () {
                        _contactSupport();
                      },
                      type: ButtonType.outlined,
                      icon: AppIcons.support,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // معلومات التواصل
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
                          'للاستفسارات',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'يمكنك التواصل معنا عبر البريد الإلكتروني أو الهاتف للحصول على آخر التحديثات حول حالة الصيانة.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _checkMaintenanceStatus() {
    // محاكاة فحص حالة الصيانة
    Get.dialog(
      AlertDialog(
        title: const Text('جاري الفحص...'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري فحص حالة الخادم...'),
          ],
        ),
      ),
    );

    // محاكاة انتظار
    Future.delayed(const Duration(seconds: 3), () {
      Get.back(); // إغلاق الحوار
      
      Get.snackbar(
        'لا يزال قيد الصيانة',
        'الخادم لا يزال قيد الصيانة. يرجى المحاولة لاحقاً.',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        icon: Icon(AppIcons.warning, color: Colors.white),
      );
    });
  }

  void _contactSupport() {
    Get.dialog(
      AlertDialog(
        title: const Text('تواصل مع الدعم'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('يمكنك التواصل معنا عبر:'),
            SizedBox(height: 12),
            Text('📧 البريد الإلكتروني:\nsupport@dayenmadeen.com'),
            SizedBox(height: 8),
            Text('📞 الهاتف:\n+966 50 123 4567'),
            SizedBox(height: 8),
            Text('💬 واتساب:\n+966 50 123 4567'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}
