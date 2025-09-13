import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_icons.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !controller.isLoading.value, // منع الإغلاق إذا كان التحميل جارياً
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Container(
          decoration: BoxDecoration(
            gradient: AppColors.getPrimaryGradient(),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // المساحة العلوية
                const Spacer(flex: 2),
                
                // شعار التطبيق
                _buildLogo(),
                
                const SizedBox(height: 24),
                
                // اسم التطبيق
                _buildAppName(),
                
                const SizedBox(height: 8),
                
                // وصف التطبيق
                _buildAppDescription(),
                
                const Spacer(flex: 2),
                
                // مؤشر التحميل
                _buildLoadingIndicator(),
                
                const SizedBox(height: 24),
                
                // نص التحميل
                _buildLoadingText(),
                
                const Spacer(),
                
                // معلومات الإصدار
                _buildVersionInfo(),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        AppIcons.logo,
        size: 60,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildAppName() {
    return Text(
      AppStrings.appName,
      style: AppTextStyles.displayLarge.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAppDescription() {
    return Text(
      AppStrings.appDescription,
      style: AppTextStyles.bodyLarge.copyWith(
        color: Colors.white.withValues(alpha: 0.9),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoadingIndicator() {
    return Obx(() => AnimatedOpacity(
      opacity: controller.isLoading.value ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: const SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 3,
        ),
      ),
    ));
  }

  Widget _buildLoadingText() {
    return Obx(() => AnimatedOpacity(
      opacity: controller.isLoading.value ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Text(
        controller.loadingMessage.value,
        style: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    ));
  }

  Widget _buildVersionInfo() {
    return Column(
      children: [
        Text(
          'الإصدار ${AppStrings.version}',
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'جميع الحقوق محفوظة © 2025',
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
