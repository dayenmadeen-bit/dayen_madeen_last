import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/offline_action_wrapper.dart';
import '../controllers/employees_controller.dart';
import '../../../data/models/employee.dart';

/// شاشة تعديل بيانات موظف قائم
class EditEmployeeScreen extends GetView<EmployeesController> {
  const EditEmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final employeeId = Get.arguments?['employeeId'] as String?;

    if (employeeId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: const Center(child: Text('معرّف الموظف غير صحيح')),
      );
    }

    controller.loadEmployeeForEdit(employeeId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الموظف'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.currentEmployee.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: controller.editEmployeeFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBasicInfoSection(),
                const SizedBox(height: 24),
                _buildPermissionsSection(),
                const SizedBox(height: 24),
                _buildStatusSection(),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المعلومات الأساسية',
            style:
                AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.nameController,
            label: 'اسم الموظف',
            hint: 'أدخل اسم الموظف الكامل',
            prefixIcon: AppIcons.person,
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'اسم الموظف مطلوب';
              if (value.trim().length < 2) return 'الاسم قصير جداً';
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.emailController,
            label: 'البريد الإلكتروني (اختياري)',
            hint: 'example@company.com',
            prefixIcon: AppIcons.email,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الصلاحيات',
            style:
                AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Obx(() => Row(
                children: [
                  const Text('قالب جاهز:'),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: controller.selectedRolePreset.value,
                    items: controller.rolePresets
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(
                                r == 'viewer'
                                    ? 'مشاهِد'
                                    : r == 'accountant'
                                        ? 'محاسب'
                                        : 'مدير فرع',
                              ),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) controller.applyRolePreset(v);
                    },
                  ),
                ],
              )),
          const SizedBox(height: 12),
          Obx(() => Column(
                children: Permission.values.map((permission) {
                  final isSelected =
                      controller.selectedPermissions.contains(permission);
                  return CheckboxListTile(
                    title: Text(permission.displayName,
                        style: AppTextStyles.bodyMedium),
                    subtitle: Text(permission.description),
                    value: isSelected,
                    onChanged: (v) => controller.togglePermission(permission),
                    activeColor: AppColors.primary,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حالة الموظف',
            style:
                AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Obx(() => SwitchListTile(
                title: Text(
                  controller.isEmployeeActive.value ? 'نشط' : 'غير نشط',
                  style: AppTextStyles.bodyMedium,
                ),
                value: controller.isEmployeeActive.value,
                onChanged: controller.toggleEmployeeActiveStatus,
                activeColor: AppColors.success,
              )),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'إلغاء',
            onPressed: () => Get.back(),
            type: ButtonType.outlined,
            icon: AppIcons.cancel,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OfflineActionButton(
            action: 'update_employees',
            text: 'حفظ التعديلات',
            onPressed: controller.updateEmployee,
            icon: AppIcons.save,
          ),
        ),
      ],
    );
  }
}
