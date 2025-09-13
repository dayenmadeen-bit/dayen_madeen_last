import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../controllers/employee_profile_controller.dart';

class EmployeeProfileScreen extends StatelessWidget {
  const EmployeeProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EmployeeProfileController>(
      init: EmployeeProfileController(),
      builder: (controller) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('الملف الشخصي'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Obx(() {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildProfileContent(controller);
        }),
      ),
    );
  }

  Widget _buildProfileContent(EmployeeProfileController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildProfileHeader(controller),
          const SizedBox(height: 24),
          _buildAccountInfo(controller),
          const SizedBox(height: 24),
          _buildSecuritySettings(controller),
          const SizedBox(height: 24),
          _buildBiometricSettings(controller),
          const SizedBox(height: 24),
          _buildActions(controller),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(EmployeeProfileController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(
              Icons.person,
              size: 50,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            controller.employee?.name ?? 'غير محدد',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'موظف',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'الرقم المميز: ${controller.employee?.uniqueId ?? 'غير محدد'}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(EmployeeProfileController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات الحساب',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'الاسم الكامل',
            controller.employee?.name ?? 'غير محدد',
            AppIcons.person,
            onEdit: () => _showEditDialog(controller, 'name'),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'البريد الإلكتروني',
            controller.employee?.email ?? 'غير محدد',
            AppIcons.email,
            onEdit: controller.employee?.email != null
                ? () => _showEditDialog(controller, 'email')
                : null,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'رقم الهاتف',
            controller.employee?.phone ?? 'غير محدد',
            AppIcons.phone,
            onEdit: () => _showEditDialog(controller, 'phone'),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'تاريخ الانضمام',
            controller.employee?.createdAt != null
                ? _formatDate(controller.employee!.createdAt)
                : 'غير محدد',
            AppIcons.calendar,
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings(EmployeeProfileController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إعدادات الأمان',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'تغيير كلمة المرور',
            '**********',
            AppIcons.password,
            onEdit: () => _showChangePasswordDialog(controller),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'إضافة بريد إلكتروني',
            controller.employee?.email != null
                ? 'تم إضافة البريد الإلكتروني'
                : 'لم يتم إضافة بريد إلكتروني',
            AppIcons.email,
            onEdit: controller.employee?.email == null
                ? () => _showAddEmailDialog(controller)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricSettings(EmployeeProfileController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المصادقة البيومترية',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => SwitchListTile(
                title: Text(
                  'تفعيل البصمة',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  controller.isBiometricEnabled
                      ? 'مفعل - يمكنك تسجيل الدخول بالبصمة'
                      : 'معطل - اضغط لتفعيل البصمة',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                value: controller.isBiometricEnabled,
                onChanged: (value) {
                  if (value) {
                    _enableBiometric(controller);
                  } else {
                    _disableBiometric(controller);
                  }
                },
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              )),
        ],
      ),
    );
  }

  Widget _buildActions(EmployeeProfileController controller) {
    return Column(
      children: [
        CustomButton(
          text: 'تسجيل الخروج',
          onPressed: () => _showLogoutDialog(controller),
          backgroundColor: AppColors.error,
          textColor: Colors.white,
          icon: AppIcons.logout,
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onEdit,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (onEdit != null)
          IconButton(
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit,
              size: 20,
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }

  void _showEditDialog(EmployeeProfileController controller, String field) {
    final TextEditingController textController = TextEditingController();
    String currentValue = '';
    String title = '';
    String hint = '';

    switch (field) {
      case 'name':
        currentValue = controller.employee?.name ?? '';
        title = 'تعديل الاسم';
        hint = 'أدخل الاسم الكامل';
        break;
      case 'email':
        currentValue = controller.employee?.email ?? '';
        title = 'تعديل البريد الإلكتروني';
        hint = 'أدخل البريد الإلكتروني';
        break;
      case 'phone':
        currentValue = controller.employee?.phone ?? '';
        title = 'تعديل رقم الهاتف';
        hint = 'أدخل رقم الهاتف';
        break;
    }

    textController.text = currentValue;

    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: CustomTextField(
          controller: textController,
          label: title,
          hint: hint,
          keyboardType: field == 'email'
              ? TextInputType.emailAddress
              : field == 'phone'
                  ? TextInputType.phone
                  : TextInputType.text,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              controller.updateField(field, textController.text.trim());
              Get.back();
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(EmployeeProfileController controller) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: currentPasswordController,
              label: 'كلمة المرور الحالية',
              hint: 'أدخل كلمة المرور الحالية',
              obscureText: true,
              prefixIcon: AppIcons.password,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: newPasswordController,
              label: 'كلمة المرور الجديدة',
              hint: 'أدخل كلمة المرور الجديدة',
              obscureText: true,
              prefixIcon: AppIcons.password,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: confirmPasswordController,
              label: 'تأكيد كلمة المرور',
              hint: 'أدخل كلمة المرور الجديدة مرة أخرى',
              obscureText: true,
              prefixIcon: AppIcons.password,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                Get.snackbar(
                  'خطأ',
                  'كلمة المرور الجديدة غير متطابقة',
                  backgroundColor: AppColors.error,
                  colorText: Colors.white,
                );
                return;
              }
              controller.changePassword(
                currentPasswordController.text,
                newPasswordController.text,
              );
              Get.back();
            },
            child: const Text('تغيير'),
          ),
        ],
      ),
    );
  }

  void _showAddEmailDialog(EmployeeProfileController controller) {
    final emailController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('إضافة بريد إلكتروني'),
        content: CustomTextField(
          controller: emailController,
          label: 'البريد الإلكتروني',
          hint: 'أدخل بريدك الإلكتروني',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: AppIcons.email,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              controller.addEmail(emailController.text.trim());
              Get.back();
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _enableBiometric(EmployeeProfileController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('تفعيل البصمة'),
        content: const Text(
          'سيتم تفعيل المصادقة بالبصمة. تأكد من أن جهازك يدعم البصمة وأنها مفعلة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              controller.enableBiometric();
              Get.back();
            },
            child: const Text('تفعيل'),
          ),
        ],
      ),
    );
  }

  void _disableBiometric(EmployeeProfileController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('إلغاء تفعيل البصمة'),
        content: const Text(
          'سيتم إلغاء تفعيل المصادقة بالبصمة. ستحتاج إلى استخدام كلمة المرور لتسجيل الدخول.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              controller.disableBiometric();
              Get.back();
            },
            child: const Text('إلغاء التفعيل'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(EmployeeProfileController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              controller.logout();
              Get.back();
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
