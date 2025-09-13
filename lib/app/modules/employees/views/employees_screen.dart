import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/offline_action_wrapper.dart';
import '../../../widgets/custom_search_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/announcements_banner.dart';
import '../../../../core/services/announcements_service.dart';
import '../controllers/employees_controller.dart';

class EmployeesScreen extends GetView<EmployeesController> {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'الموظفين',
        actions: [
          OfflineActionWrapper(
            action: 'view_employees',
            showMessage: false,
            child: IconButton(
              icon: Icon(AppIcons.analytics),
              onPressed: controller.showEmployeeStats,
              tooltip: 'الإحصائيات',
            ),
          ),
          OfflineActionWrapper(
            action: 'export_employees',
            child: IconButton(
              icon: Icon(AppIcons.export),
              onPressed: controller.exportEmployeesData,
              tooltip: 'تصدير',
            ),
          ),
          OfflineActionWrapper(
            action: 'update_employees_permissions',
            child: IconButton(
              icon: Icon(Icons.security),
              onPressed: controller.showPermissionsManagement,
              tooltip: 'إدارة الصلاحيات',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: GetX<AnnouncementsService>(builder: (svc) {
              return AnnouncementsBanner(
                announcements: svc.employeeHome,
              );
            }),
          ),
          // شريط البحث والفلاتر
          _buildSearchAndFilters(),

          // الإحصائيات السريعة
          _buildQuickStats(),

          // قائمة الموظفين
          Expanded(
            child: _buildEmployeesList(),
          ),
        ],
      ),
      floatingActionButton: OfflineFloatingActionButton(
        action: 'add_employees',
        onPressed: controller.goToAddEmployee,
        icon: AppIcons.personAdd,
        tooltip: 'إضافة موظف',
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // شريط البحث
          CustomSearchBar(
            controller: controller.searchController,
            hintText: 'البحث في الموظفين...',
            onClear: controller.clearSearch,
          ),

          const SizedBox(height: 12),

          // فلاتر الحالة
          Row(
            children: [
              Expanded(
                child: _buildFilterChip('الكل', 'all'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip('النشطين', 'active'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip('غير النشطين', 'inactive'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == value;
      return FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => controller.changeFilter(value),
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      );
    });
  }

  Widget _buildQuickStats() {
    return GetBuilder<EmployeesController>(
      builder: (controller) {
        final stats = controller.employeeStats;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'الإجمالي',
                  '${stats['total']}',
                  AppIcons.people,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'النشطين',
                  '${stats['active']}',
                  AppIcons.checkCircle,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'غير النشطين',
                  '${stats['inactive']}',
                  AppIcons.block,
                  AppColors.warning,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeesList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final employees = controller.filteredEmployees;

      if (employees.isEmpty) {
        return EmptyStateWidget(
          type: EmptyStateType.noData,
          icon: AppIcons.people,
          title: controller.searchQuery.value.isNotEmpty
              ? 'لا توجد نتائج'
              : 'لا يوجد موظفين',
          subtitle: controller.searchQuery.value.isNotEmpty
              ? 'لم يتم العثور على موظفين مطابقين للبحث'
              : 'ابدأ بإضافة موظفين جدد لفريق العمل',
          actionText: 'إضافة موظف',
          onActionPressed: controller.goToAddEmployee,
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshEmployees,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: employees.length,
          itemBuilder: (context, index) {
            final employee = employees[index];
            return _buildEmployeeCard(employee);
          },
        ),
      );
    });
  }

  Widget _buildEmployeeCard(employee) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => controller.goToEmployeeDetails(employee),
        onLongPress: () => controller.showEmployeeOptions(employee),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // صورة الموظف أو الأحرف الأولى
              CircleAvatar(
                radius: 24,
                backgroundColor: employee.isActive
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.textSecondary.withValues(alpha: 0.2),
                child: Text(
                  employee.initials,
                  style: TextStyle(
                    color: employee.isActive
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // معلومات الموظف
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            employee.name,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: employee.isActive
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        // حالة الموظف
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: employee.isActive
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            employee.isActive ? 'نشط' : 'غير نشط',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: employee.isActive
                                  ? AppColors.success
                                  : AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      employee.email,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 2),
                    Text(
                      'الرقم المميز: ${employee.uniqueId}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // الصلاحيات
                    Row(
                      children: [
                        Icon(
                          AppIcons.security,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${employee.permissionsCount} صلاحية',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const Spacer(),

                        // تاريخ الإضافة
                        Text(
                          'أُضيف ${_formatDate(employee.createdAt)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // زر الخيارات
              IconButton(
                icon: Icon(
                  AppIcons.moreVert,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => controller.showEmployeeOptions(employee),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
