import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../controllers/employees_controller.dart';

/// شاشة تفاصيل الموظف
class EmployeeDetailsScreen extends GetView<EmployeesController> {
  const EmployeeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final employeeId = Get.arguments?['employeeId'] as String?;

    if (employeeId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: const Center(
          child: Text('معرف الموظف غير صحيح'),
        ),
      );
    }

    // تحميل بيانات الموظف
    controller.loadEmployeeDetails(employeeId);

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(employeeId),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('تفاصيل الموظف'),
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
          message: 'جاري تحميل البيانات...',
        );
      }

      if (controller.currentEmployee.value == null) {
        return _buildNotFoundState();
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadEmployeeDetails(
          controller.currentEmployee.value!.id,
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة معلومات الموظف الأساسية
              _buildEmployeeCard(),

              const SizedBox(height: 24),

              // معلومات الاتصال
              _buildContactInfoSection(),

              const SizedBox(height: 24),

              // معلومات الوظيفة
              _buildJobInfoSection(),

              const SizedBox(height: 24),

              // الصلاحيات
              _buildPermissionsSection(),

              const SizedBox(height: 24),

              // إحصائيات الموظف
              _buildEmployeeStatsSection(),

              const SizedBox(height: 24),

              // معلومات إضافية
              _buildAdditionalInfoSection(),

              const SizedBox(height: 100), // مساحة للـ FAB
            ],
          ),
        ),
      );
    });
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.error,
            size: 64,
            color: AppColors.textHintLight,
          ),
          const SizedBox(height: 16),
          Text(
            'لم يتم العثور على الموظف',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'العودة',
            onPressed: () => Get.back(),
            type: ButtonType.outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard() {
    return Obx(() {
      final employee = controller.currentEmployee.value!;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: AppDecorations.cardDecoration.copyWith(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // صورة الموظف
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Text(
                employee.name.isNotEmpty ? employee.name[0].toUpperCase() : 'م',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // اسم الموظف
            Text(
              employee.name,
              style: AppTextStyles.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // المنصب
            Text(
              'موظف', // قيمة افتراضية
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // حالة الموظف
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: employee.isActive ? AppColors.success : AppColors.error,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                employee.isActive ? 'نشط' : 'غير نشط',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildContactInfoSection() {
    return Obx(() {
      final employee = controller.currentEmployee.value!;

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
            if (employee.email != null) ...[
              _buildInfoRow(
                icon: AppIcons.person,
                label: 'اسم المستخدم',
                value: employee.email!
                    .split('@')[0], // استخراج اسم المستخدم من البريد
              ),
            ],
            if (employee.email != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: AppIcons.email,
                label: 'البريد الإلكتروني',
                value: employee.email!,
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildJobInfoSection() {
    return Obx(() {
      final employee = controller.currentEmployee.value!;

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
            _buildInfoRow(
              icon: AppIcons.work,
              label: 'المنصب',
              value: 'موظف', // قيمة افتراضية
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: AppIcons.money,
              label: 'الراتب',
              value: '3000 ر.س', // قيمة افتراضية
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: AppIcons.calendar,
              label: 'تاريخ التوظيف',
              value: _formatDate(employee.createdAt),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPermissionsSection() {
    return Obx(() {
      final employee = controller.currentEmployee.value!;

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
            if (employee.permissions.isEmpty)
              Text(
                'لا توجد صلاحيات محددة',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: employee.permissions.map((permission) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      permission.displayName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildEmployeeStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إحصائيات الموظف',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: AppIcons.calendar,
                  title: 'أيام العمل',
                  value: _calculateWorkDays().toString(),
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: AppIcons.security,
                  title: 'الصلاحيات',
                  value: controller.currentEmployee.value!.permissions.length
                      .toString(),
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Obx(() {
      final employee = controller.currentEmployee.value!;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات إضافية',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: AppIcons.info,
              label: 'معرف الموظف',
              value: employee.id.substring(0, 8) + '...',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: AppIcons.calendar,
              label: 'آخر تحديث',
              value: _formatDate(employee.updatedAt),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
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
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration.copyWith(
        color: color.withValues(alpha: 0.1),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(String employeeId) {
    return FloatingActionButton(
      onPressed: () => Get.toNamed(
        AppRoutes.editEmployee,
        arguments: {'employeeId': employeeId},
      ),
      backgroundColor: AppColors.primary,
      child: const Icon(
        Icons.edit,
        color: Colors.white,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _calculateWorkDays() {
    final employee = controller.currentEmployee.value!;
    final now = DateTime.now();
    final difference = now.difference(employee.createdAt);
    return difference.inDays;
  }
}
