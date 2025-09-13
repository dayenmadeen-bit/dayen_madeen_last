import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/offline_action_wrapper.dart';
import '../controllers/settings_controller.dart';

/// شاشة تغيير كلمة المرور
class ChangePasswordScreen extends GetView<SettingsController> {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'تغيير كلمة المرور',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس الصفحة
            _buildHeader(),

            const SizedBox(height: 32),

            // نموذج تغيير كلمة المرور
            _buildPasswordForm(),

            const SizedBox(height: 32),

            // نصائح الأمان
            _buildSecurityTips(),

            const SizedBox(height: 32),

            // أزرار الإجراءات
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              AppIcons.security,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تأمين حسابك',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'قم بتحديث كلمة المرور بانتظام لحماية حسابك',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Form(
      key: controller.changePasswordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // كلمة المرور الحالية
          Obx(() => CustomTextField(
                controller: controller.currentPasswordController,
                label: 'كلمة المرور الحالية',
                hint: 'أدخل كلمة المرور الحالية',
                prefixIcon: AppIcons.lock,
                obscureText: controller.hideCurrentPassword.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.hideCurrentPassword.value
                        ? AppIcons.visibility
                        : AppIcons.visibilityOff,
                  ),
                  onPressed: controller.toggleCurrentPasswordVisibility,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'كلمة المرور الحالية مطلوبة';
                  }
                  return null;
                },
              )),

          const SizedBox(height: 16),

          // كلمة المرور الجديدة
          Obx(() => CustomTextField(
                controller: controller.newPasswordController,
                label: 'كلمة المرور الجديدة',
                hint: 'أدخل كلمة المرور الجديدة',
                prefixIcon: AppIcons.lock,
                obscureText: controller.hideNewPassword.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.hideNewPassword.value
                        ? AppIcons.visibility
                        : AppIcons.visibilityOff,
                  ),
                  onPressed: controller.toggleNewPasswordVisibility,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'كلمة المرور الجديدة مطلوبة';
                  }
                  if (value.length < 8) {
                    return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                  }
                  return null;
                },
                onChanged: controller.onNewPasswordChanged,
              )),

          const SizedBox(height: 8),

          // مؤشر قوة كلمة المرور
          Obx(() => _buildPasswordStrengthIndicator()),

          const SizedBox(height: 16),

          // تأكيد كلمة المرور الجديدة
          Obx(() => CustomTextField(
                controller: controller.confirmPasswordController,
                label: 'تأكيد كلمة المرور الجديدة',
                hint: 'أعد إدخال كلمة المرور الجديدة',
                prefixIcon: AppIcons.lock,
                obscureText: controller.hideConfirmPassword.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.hideConfirmPassword.value
                        ? AppIcons.visibility
                        : AppIcons.visibilityOff,
                  ),
                  onPressed: controller.toggleConfirmPasswordVisibility,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'تأكيد كلمة المرور مطلوب';
                  }
                  if (value != controller.newPasswordController.text) {
                    return 'كلمة المرور غير متطابقة';
                  }
                  return null;
                },
              )),
        ],
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final strength = controller.passwordStrength.value;
    final strengthText = controller.getPasswordStrengthText(strength);
    final strengthColor = controller.getPasswordStrengthColor(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'قوة كلمة المرور: ',
              style: AppTextStyles.bodySmall,
            ),
            Text(
              strengthText,
              style: AppTextStyles.bodySmall.copyWith(
                color: strengthColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: strength / 4,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
        ),
      ],
    );
  }

  Widget _buildSecurityTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                'نصائح لكلمة مرور قوية',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...[
            'استخدم 8 أحرف على الأقل',
            'امزج بين الأحرف الكبيرة والصغيرة',
            'أضف أرقام ورموز خاصة',
            'تجنب المعلومات الشخصية',
            'لا تستخدم كلمات مرور سابقة',
          ]
              .map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
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
                            tip,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // زر تغيير كلمة المرور
        Obx(() => OfflineActionButton(
              action: 'change_password',
              text: 'تغيير كلمة المرور',
              onPressed: controller.isChangingPassword.value
                  ? null
                  : controller.changePassword,
              icon: AppIcons.save,
            )),

        const SizedBox(height: 12),

        // زر الإلغاء
        CustomButton(
          text: 'إلغاء',
          onPressed: () => Get.back(),
          type: ButtonType.outlined,
          icon: AppIcons.cancel,
        ),
      ],
    );
  }
}
