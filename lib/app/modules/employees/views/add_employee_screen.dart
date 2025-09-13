import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/employee.dart';
import '../controllers/employees_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/offline_action_wrapper.dart';

/// شاشة إضافة موظف جديد
class AddEmployeeScreen extends GetView<EmployeesController> {
  const AddEmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('إضافة موظف جديد'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingWidget(
          type: LoadingType.circular,
          size: LoadingSize.large,
          message: 'جاري الحفظ...',
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.addEmployeeFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // المعلومات الأساسية
              _buildBasicInfoSection(),

              const SizedBox(height: 24),

              // معلومات الاتصال
              _buildContactInfoSection(),

              const SizedBox(height: 24),

              // معلومات الوظيفة
              _buildJobInfoSection(),

              const SizedBox(height: 24),

              // الصلاحيات
              _buildPermissionsSection(),

              const SizedBox(height: 32),

              // أزرار الحفظ والإلغاء
              _buildActionButtons(),
            ],
          ),
        ),
      );
    });
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
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.nameController,
            label: 'اسم الموظف',
            hint: 'أدخل اسم الموظف الكامل',
            prefixIcon: AppIcons.person,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'اسم الموظف مطلوب';
              }
              if (value.trim().length < 2) {
                return 'اسم الموظف يجب أن يكون أكثر من حرفين';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.usernameController,
            label: 'اسم المستخدم',
            hint: 'أدخل اسم المستخدم للدخول',
            prefixIcon: AppIcons.person,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'اسم المستخدم مطلوب';
              }
              if (value.trim().length < 3) {
                return 'اسم المستخدم يجب أن يكون أكثر من 3 أحرف';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.passwordController,
            label: 'كلمة المرور',
            hint: 'أدخل كلمة مرور قوية',
            prefixIcon: AppIcons.security,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'كلمة المرور مطلوبة';
              }
              if (value.length < 6) {
                return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات الاتصال',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.emailController,
            label: 'البريد الإلكتروني',
            hint: 'أدخل البريد الإلكتروني (اختياري)',
            prefixIcon: AppIcons.email,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildJobInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات الوظيفة',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.positionController,
            label: 'المنصب',
            hint: 'أدخل منصب الموظف',
            prefixIcon: AppIcons.work,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'المنصب مطلوب';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.salaryController,
            label: 'الراتب (ر.س)',
            hint: 'أدخل راتب الموظف',
            prefixIcon: AppIcons.money,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الراتب مطلوب';
              }
              final salary = double.tryParse(value);
              if (salary == null || salary <= 0) {
                return 'أدخل راتب صحيح';
              }
              return null;
            },
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
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'اختر الصلاحيات التي تريد منحها للموظف:',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),

          const SizedBox(height: 12),

          // قوالب أدوار سريعة
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

          // سيتم إضافة قائمة الصلاحيات هنا
          _buildPermissionsList(),
        ],
      ),
    );
  }

  Widget _buildPermissionsList() {
    return Obx(() => Column(
          children: Permission.values.map((permission) {
            final isSelected =
                controller.selectedPermissions.contains(permission);

            return CheckboxListTile(
              title: Text(
                permission.displayName,
                style: AppTextStyles.bodyMedium,
              ),
              value: isSelected,
              onChanged: (value) {
                controller.togglePermission(permission);
              },
              activeColor: AppColors.primary,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        ));
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'إلغاء',
            onPressed: () => Get.back(),
            type: ButtonType.outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OfflineActionButton(
            action: 'add_employees',
            text: 'حفظ الموظف',
            onPressed: controller.saveEmployee,
            isLoading: controller.isLoading.value,
            icon: AppIcons.save,
          ),
        ),
      ],
    );
  }
}
