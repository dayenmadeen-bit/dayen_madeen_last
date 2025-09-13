import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_icons.dart';
import 'custom_button.dart';

/// شاشة الصفحة غير موجودة
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الصفحة غير موجودة'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الأيقونة
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  AppIcons.error,
                  size: 60,
                  color: AppColors.error,
                ),
              ),

              const SizedBox(height: 32),

              // العنوان
              Text(
                '404',
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // الرسالة
              Text(
                'الصفحة غير موجودة',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'عذراً، الصفحة التي تبحث عنها غير موجودة أو تم نقلها إلى مكان آخر.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // زر العودة للرئيسية
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'العودة للرئيسية',
                  onPressed: () => Get.offAllNamed('/'),
                  type: ButtonType.primary,
                  icon: AppIcons.home,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
