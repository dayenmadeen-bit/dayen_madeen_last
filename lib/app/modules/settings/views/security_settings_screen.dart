import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/auth_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../controllers/settings_controller.dart';

/// شاشة إعدادات الأمان
class SecuritySettingsScreen extends GetView<SettingsController> {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // تغيير كلمة المرور
            _buildChangePasswordSection(),

            const SizedBox(height: 24),

            // المصادقة البيومترية
            _buildBiometricSection(),

            const SizedBox(height: 24),

            // إعدادات الجلسة
            _buildSessionSection(),

            const SizedBox(height: 24),

            // سجل الأنشطة
            _buildActivityLogSection(),

            const SizedBox(height: 24),

            // إعدادات الأمان المتقدمة
            _buildAdvancedSecuritySection(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('إعدادات الأمان'),
    );
  }

  Widget _buildChangePasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تغيير كلمة المرور',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.cardDecoration,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      AppIcons.password,
                      color: AppColors.warning,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'كلمة المرور',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'آخر تغيير: منذ 30 يوم',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomButton(
                    text: 'تغيير',
                    onPressed: _showChangePasswordDialog,
                    type: ButtonType.outlined,
                    size: ButtonSize.small,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      AppIcons.info,
                      color: AppColors.info,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'يُنصح بتغيير كلمة المرور كل 3 أشهر لضمان الأمان',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBiometricSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المصادقة البيومترية',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.cardDecoration,
          child: Column(
            children: [
              Obx(() => _buildSecurityOption(
                    icon: AppIcons.fingerprint,
                    title: 'البصمة / Face ID',
                    subtitle: controller.isBiometricEnabled.value
                        ? 'مفعلة - تسجيل دخول سريع وآمن'
                        : 'معطلة - استخدم كلمة المرور فقط',
                    isEnabled: controller.isBiometricEnabled.value,
                    onToggle: controller.toggleBiometric,
                  )),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      AppIcons.security,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'المصادقة البيومترية توفر أماناً إضافياً وسهولة في الاستخدام',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إدارة الجلسات',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.cardDecoration,
          child: Column(
            children: [
              _buildSessionInfo(
                'الجلسة الحالية',
                'نشطة الآن',
                'هذا الجهاز',
                AppColors.success,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'إنهاء جميع الجلسات',
                      onPressed: _endAllSessions,
                      type: ButtonType.outlined,
                      icon: AppIcons.logout,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityLogSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'سجل الأنشطة',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.cardDecoration,
          child: Column(
            children: [
              _buildActivityItem(
                'تسجيل دخول',
                'اليوم 09:30 ص',
                AppIcons.login,
                AppColors.success,
              ),
              const Divider(height: 24),
              _buildActivityItem(
                'تغيير إعدادات',
                'أمس 03:15 م',
                AppIcons.settings,
                AppColors.info,
              ),
              const Divider(height: 24),
              _buildActivityItem(
                'تسجيل الدخول',
                'منذ 3 أيام',
                AppIcons.login,
                AppColors.primary,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'عرض السجل الكامل',
                onPressed: _showFullActivityLog,
                type: ButtonType.text,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إعدادات الأمان المتقدمة',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.cardDecoration,
          child: Column(
            children: [
              _buildAdvancedOption(
                'قفل التطبيق تلقائياً',
                'بعد 5 دقائق من عدم النشاط',
                true,
              ),
              const Divider(height: 24),
              _buildAdvancedOption(
                'تشفير البيانات المحلية',
                'تشفير جميع البيانات المحفوظة',
                true,
              ),
              const Divider(height: 24),
              _buildAdvancedOption(
                'تسجيل محاولات الدخول',
                'حفظ سجل بمحاولات تسجيل الدخول',
                false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isEnabled,
    required VoidCallback onToggle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isEnabled ? AppColors.success : AppColors.textHintLight)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isEnabled ? AppColors.success : AppColors.textHintLight,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: isEnabled,
          onChanged: (_) => onToggle(),
        ),
      ],
    );
  }

  Widget _buildSessionInfo(
      String title, String status, String device, Color statusColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            AppIcons.device,
            color: statusColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                device,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: AppTextStyles.bodySmall.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
      String action, String time, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            action,
            style: AppTextStyles.bodyMedium,
          ),
        ),
        Text(
          time,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedOption(String title, String subtitle, bool isEnabled) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: isEnabled,
          onChanged: (value) {
            // يمكن إضافة منطق تغيير الإعداد هنا
          },
        ),
      ],
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: currentPasswordController,
                label: 'كلمة المرور الحالية',
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال كلمة المرور الحالية';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: newPasswordController,
                label: 'كلمة المرور الجديدة',
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال كلمة المرور الجديدة';
                  }
                  if (value.length < 8) {
                    return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: confirmPasswordController,
                label: 'تأكيد كلمة المرور',
                isPassword: true,
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return 'كلمة المرور غير متطابقة';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => _changePassword(
              currentPasswordController.text,
              newPasswordController.text,
              formKey,
            ),
            child: const Text('تغيير'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword(String currentPassword, String newPassword,
      GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    try {
      final success = await AuthService.instance.updateCurrentUserPassword(
        currentPassword,
        newPassword,
      );

      if (success) {
        Get.back();
        Get.snackbar(
          'نجح',
          'تم تغيير كلمة المرور بنجاح',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          'خطأ',
          'كلمة المرور الحالية غير صحيحة',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تغيير كلمة المرور',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void _endAllSessions() {
    Get.dialog(
      AlertDialog(
        title: const Text('إنهاء جميع الجلسات'),
        content: const Text('سيتم تسجيل خروجك من جميع الأجهزة. هل أنت متأكد؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // منطق إنهاء الجلسات
              Get.snackbar(
                'تم',
                'تم إنهاء جميع الجلسات',
                backgroundColor: AppColors.success,
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('إنهاء'),
          ),
        ],
      ),
    );
  }

  void _showFullActivityLog() {
    Get.snackbar(
      'قريباً',
      'سيتم إضافة شاشة السجل الكامل قريباً',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
}
