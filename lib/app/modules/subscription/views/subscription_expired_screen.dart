import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/subscription_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../widgets/custom_button.dart';

class SubscriptionExpiredScreen extends GetView<SubscriptionController> {
  const SubscriptionExpiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withValues(alpha: 0.1),
              AppColors.backgroundLight,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // أيقونة انتهاء الاشتراك
                _buildExpiredIcon(),

                const SizedBox(height: 32),

                // عنوان انتهاء الاشتراك
                _buildTitle(),

                const SizedBox(height: 16),

                // رسالة انتهاء الاشتراك
                _buildMessage(),

                const SizedBox(height: 32),

                // معلومات الاشتراك
                _buildSubscriptionInfo(),

                const SizedBox(height: 32),

                // معرف الجهاز
                _buildDeviceIdSection(),

                const SizedBox(height: 32),

                // معلومات التواصل
                _buildContactInfo(),

                const SizedBox(height: 40),

                // أزرار الإجراءات
                _buildActionButtons(),

                const SizedBox(height: 24),

                // رابط الخروج
                _buildExitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpiredIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(60),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Icon(
        AppIcons.subscription,
        size: 60,
        color: AppColors.warning,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      AppStrings.subscriptionExpired,
      style: AppTextStyles.headlineMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.warning,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage() {
    return Column(
      children: [
        Text(
          'انتهت فترة الاشتراك الخاصة بك',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'للمتابعة في استخدام التطبيق، يرجى تجديد الاشتراك',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubscriptionInfo() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'معلومات الاشتراك',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'نوع الاشتراك',
                controller.currentSubscription.value?.planName ?? 'غير محدد',
              ),
              _buildInfoRow(
                'تاريخ الانتهاء',
                controller.currentSubscription.value?.formattedEndDate ??
                    'غير محدد',
              ),
              _buildInfoRow(
                'الحالة',
                controller.currentSubscription.value?.statusName ?? 'منتهي',
              ),
            ],
          ),
        ));
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceIdSection() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.deviceId,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'يرجى إرسال معرف الجهاز التالي عند التواصل معنا:',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.deviceId.value,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: controller.copyDeviceId,
                      icon: const Icon(AppIcons.share),
                      tooltip: AppStrings.copyDeviceId,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.contactUs,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: AppIcons.whatsapp,
            label: 'واتساب',
            value: '+966500000000',
            onTap: controller.contactWhatsApp,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: AppIcons.phone,
            label: 'هاتف',
            value: '+966500000000',
            onTap: controller.contactPhone,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: AppIcons.email,
            label: 'بريد إلكتروني',
            value: 'support@dayenmadeen.com',
            onTap: controller.contactEmail,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textHintLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomButton(
          text: AppStrings.renewSubscription,
          onPressed: controller.renewSubscription,
          icon: AppIcons.subscription,
          type: ButtonType.primary,
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'فحص الاشتراك',
          onPressed: controller.checkSubscription,
          icon: AppIcons.refresh,
          type: ButtonType.outlined,
        ),
      ],
    );
  }

  Widget _buildExitButton() {
    return TextButton(
      onPressed: controller.exitApp,
      child: Text(
        'إغلاق التطبيق',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}
