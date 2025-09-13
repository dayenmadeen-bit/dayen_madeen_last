import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'استعادة كلمة المرور',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(controller),

              const SizedBox(height: 32),

              // المحتوى حسب المرحلة
              Obx(() {
                switch (controller.currentStep.value) {
                  case ForgotPasswordStep.email:
                    return _buildEmailStep(controller);
                  case ForgotPasswordStep.verification:
                    return _buildVerificationStep(controller);
                  case ForgotPasswordStep.newPassword:
                    return _buildNewPasswordStep(controller);
                  case ForgotPasswordStep.success:
                    return _buildSuccessStep(controller);
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ForgotPasswordController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withValues(alpha: 0.1),
            AppColors.warning.withValues(alpha: 0.05)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.lock_reset,
              size: 40,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'استعادة كلمة المرور',
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            String subtitle;
            switch (controller.currentStep.value) {
              case ForgotPasswordStep.email:
                subtitle = 'أدخل الرقم المميز + البريد لإرسال رمز الاستعادة';
                break;
              case ForgotPasswordStep.verification:
                subtitle = 'أدخل رمز الاستعادة المرسل إليك';
                break;
              case ForgotPasswordStep.newPassword:
                subtitle = 'أدخل كلمة المرور الجديدة';
                break;
              case ForgotPasswordStep.success:
                subtitle = 'تم تغيير كلمة المرور بنجاح';
                break;
            }

            return Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmailStep(ForgotPasswordController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: controller.emailFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // الرقم المميز
            CustomTextField(
              controller: controller.uniqueIdController,
              label: 'الرقم المميز *',
              hintText: 'أدخل الرقم المميز (7 خانات)',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.confirmation_number,
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.length != 7 || int.tryParse(v) == null) {
                  return 'الرقم المميز غير صالح';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // البريد الإلكتروني
            CustomTextField(
              controller: controller.emailController,
              label: 'البريد الإلكتروني *',
              hintText: 'example@email.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (value) {
                return Validators.email(value);
              },
            ),

            const SizedBox(height: 24),

            // زر الإرسال
            Obx(() => CustomButton(
                  text: 'التالي',
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.sendResetCode,
                  isLoading: controller.isLoading.value,
                  icon: Icons.send,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationStep(ForgotPasswordController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: controller.tokenFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('أدخل رمز التحقق المرسل إلى بريدك',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 16),
            CustomTextField(
              controller: controller.tokenController,
              label: 'رمز التحقق *',
              hintText: 'أدخل الرمز',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.verified,
              validator: (value) {
                if ((value?.trim().isEmpty ?? true)) {
                  return 'الرمز مطلوب';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Obx(() => CustomButton(
                  text: 'تحقق',
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.verifyToken,
                  isLoading: controller.isLoading.value,
                  icon: Icons.verified_user,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildNewPasswordStep(ForgotPasswordController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: controller.passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('أدخل كلمة المرور الجديدة',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 16),
            Obx(() => CustomTextField(
                  controller: controller.newPasswordController,
                  label: 'كلمة المرور الجديدة *',
                  hintText: '•••••••',
                  prefixIcon: Icons.lock,
                  obscureText: controller.isNewPasswordHidden.value,
                  suffixIcon: IconButton(
                    icon: Icon(controller.isNewPasswordHidden.value
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: controller.toggleNewPasswordVisibility,
                  ),
                  validator: (value) {
                    if ((value?.isEmpty ?? true) || (value!.length < 6)) {
                      return 'كلمة المرور ضعيفة (6 أحرف على الأقل)';
                    }
                    return null;
                  },
                )),
            const SizedBox(height: 16),
            Obx(() => CustomTextField(
                  controller: controller.confirmNewPasswordController,
                  label: 'تأكيد كلمة المرور *',
                  hintText: '•••••••',
                  prefixIcon: Icons.lock_outline,
                  obscureText: controller.isConfirmNewPasswordHidden.value,
                  suffixIcon: IconButton(
                    icon: Icon(controller.isConfirmNewPasswordHidden.value
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: controller.toggleConfirmNewPasswordVisibility,
                  ),
                  validator: (value) {
                    if (value != controller.newPasswordController.text) {
                      return 'كلمتا المرور غير متطابقتين';
                    }
                    return null;
                  },
                )),
            const SizedBox(height: 16),
            Obx(() => CustomButton(
                  text: 'حفظ',
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.resetPassword,
                  isLoading: controller.isLoading.value,
                  icon: Icons.save,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessStep(ForgotPasswordController controller) {
    return const Center(
      child: Text('مرحلة النجاح - قيد التطوير'),
    );
  }
}
