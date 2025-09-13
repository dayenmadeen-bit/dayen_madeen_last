import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../controllers/customer_settings_controller.dart';

/// شاشة الإعدادات للزبون
class CustomerSettingsScreen extends GetView<CustomerSettingsController> {
  const CustomerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('إعدادات'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildThemeSection(),
          const SizedBox(height: 24),
          _buildSecuritySection(),
          const SizedBox(height: 24),
          _buildPersonalInfoSection(),
        ],
      ),
    );
  }

  Widget _buildThemeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المظهر',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => SwitchListTile(
                title: const Text('الوضع الداكن'),
                subtitle: const Text('تفعيل الوضع الداكن'),
                value: controller.isDarkMode.value,
                onChanged: controller.toggleTheme,
                activeColor: AppColors.primary,
              )),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الأمان',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => SwitchListTile(
                title: const Text('تفعيل البصمة'),
                subtitle: const Text('استخدام البصمة لتسجيل الدخول'),
                value: controller.isFingerprintEnabled.value,
                onChanged: controller.toggleFingerprint,
                activeColor: AppColors.primary,
              )),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المعلومات الشخصية',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // الاسم
          _buildInfoItem(
            title: 'الاسم',
            value: controller.userName.value,
            icon: AppIcons.person,
            onEdit: controller.editName,
          ),
          const SizedBox(height: 16),

          // الرقم المميز
          _buildInfoItem(
            title: 'الرقم المميز',
            value: controller.uniqueId.value,
            icon: AppIcons.creditCard,
            isReadOnly: true,
          ),
          const SizedBox(height: 16),

          // البريد الإلكتروني
          _buildInfoItem(
            title: 'البريد الإلكتروني',
            value: controller.email.value,
            icon: AppIcons.email,
            onEdit: controller.editEmail,
          ),
          const SizedBox(height: 24),

          // تغيير كلمة المرور
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.changePassword,
              icon: const Icon(Icons.lock, color: Colors.white),
              label: const Text(
                'تغيير كلمة المرور',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required String title,
    required String value,
    required IconData icon,
    bool isReadOnly = false,
    VoidCallback? onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (!isReadOnly && onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }
}


