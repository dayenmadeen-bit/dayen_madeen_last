import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../controllers/email_verification_controller.dart';

class EmailVerificationScreen extends GetView<EmailVerificationController> {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحقق من البريد الإلكتروني'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Icon(Icons.mark_email_unread, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Obx(() => Text(
                  'تم إرسال رابط تحقق إلى:\n${controller.email.value}',
                  style: AppTextStyles.bodyLarge,
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 8),
            const Text(
              'افتح بريدك واضغط رابط التحقق، ثم عد إلى التطبيق واضغط تحقق.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Obx(() => CustomButton(
                  text: controller.isChecking.value
                      ? 'جارٍ التحقق...'
                      : 'تحقق الآن',
                  onPressed: controller.isChecking.value
                      ? null
                      : () async {
                          await controller.check();
                          if (controller.isVerified.value) {
                            Get.back(result: true);
                          }
                        },
                  icon: Icons.verified,
                  isLoading: controller.isChecking.value,
                )),
            const SizedBox(height: 12),
            Obx(() => CustomButton(
                  text: controller.isSending.value
                      ? 'جارٍ الإرسال...'
                      : 'إعادة إرسال الرابط',
                  onPressed:
                      controller.isSending.value ? null : controller.resend,
                  type: ButtonType.outlined,
                  icon: Icons.send,
                )),
            const Spacer(),
            Text(
              'تأكد من التحقق قبل المتابعة لإنشاء الحساب.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
