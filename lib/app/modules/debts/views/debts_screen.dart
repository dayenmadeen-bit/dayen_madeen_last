import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/debts_controller.dart';
import '../../../data/models/debt.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../routes/app_routes.dart'; // <-- تمت الإضافة
import '../../../../core/services/employee_service.dart';
import '../../../../app/data/models/employee.dart';

/// شاشة قائمة الديون مع البحث والفلترة والترتيب
class DebtsScreen extends GetView<DebtsController> {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // شريط الإحصائيات
          _buildStatsBar(),

          // شريط البحث والفلاتر
          _buildSearchAndFilters(),

          // قائمة الديون
          Expanded(
            child: _buildDebtsList(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(AppStrings.debts),
      actions: [
        // زر الترتيب
        PopupMenuButton<String>(
          icon: const Icon(AppIcons.sort),
          onSelected: (value) => controller.sortDebts(value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'date',
              child: Text('ترتيب حسب التاريخ'),
            ),
            const PopupMenuItem(
              value: 'amount',
              child: Text('ترتيب حسب المبلغ'),
            ),
            const PopupMenuItem(
              value: 'customer',
              child: Text('ترتيب حسب العميل'),
            ),
            const PopupMenuItem(
              value: 'status',
              child: Text('ترتيب حسب الحالة'),
            ),
          ],
        ),

        // زر التحديث
        IconButton(
          icon: const Icon(AppIcons.refresh),
          onPressed: controller.refreshDebts,
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderLight,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'إجمالي الديون',
                  '${controller.totalDebts.value}',
                  AppIcons.debts,
                  AppColors.info,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'المبلغ الإجمالي',
                  '${controller.totalAmount.value.toStringAsFixed(2)} ر.س',
                  AppIcons.money,
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'المتبقي',
                  '${controller.remainingAmount.value.toStringAsFixed(2)} ر.س',
                  AppIcons.warning,
                  AppColors.warning,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'متأخرة',
                  '${controller.overdueDebts.value}',
                  AppIcons.error,
                  AppColors.error,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleSmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // شريط البحث
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'البحث',
                  hint: 'البحث في الديون...',
                  prefixIcon: AppIcons.search,
                  onChanged: controller.searchDebts,
                ),
              ),
              const SizedBox(width: 12),
              // زر الفلاتر
              IconButton(
                icon: const Icon(AppIcons.filter),
                onPressed: _showFiltersBottomSheet,
              ),
            ],
          ),

          // الفلاتر النشطة
          Obx(() => _buildActiveFilters()),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    final activeFilters = <Widget>[];

    // فلتر العميل
    if (controller.selectedCustomerId.value.isNotEmpty) {
      final customerName =
          controller.getCustomerName(controller.selectedCustomerId.value);
      activeFilters.add(_buildFilterChip('العميل: $customerName', () {
        controller.filterByCustomer('');
      }));
    }

    // فلتر الحالة
    if (controller.selectedStatus.value.isNotEmpty) {
      final statusName =
          AppStrings.getStatusText(controller.selectedStatus.value);
      activeFilters.add(_buildFilterChip('الحالة: $statusName', () {
        controller.filterByStatus('');
      }));
    }

    // فلتر التاريخ
    if (controller.selectedDateRange.value != null) {
      activeFilters.add(_buildFilterChip('فترة محددة', () {
        controller.filterByDateRange(null);
      }));
    }

    if (activeFilters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              children: activeFilters,
            ),
          ),
          TextButton(
            onPressed: controller.clearFilters,
            child: const Text('مسح الكل'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(
        label,
        style: AppTextStyles.bodySmall,
      ),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      deleteIconColor: AppColors.primary,
    );
  }

  Widget _buildDebtsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingWidget(
          type: LoadingType.circular,
          size: LoadingSize.large,
          message: 'جاري تحميل الديون...',
        );
      }

      if (controller.filteredDebts.isEmpty) {
        if (controller.searchQuery.value.isNotEmpty) {
          return NoSearchResultsWidget(
            searchQuery: controller.searchQuery.value,
            onClearSearch: () => controller.searchDebts(''),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            EmptyListWidget(
              type: EmptyStateType.noDebts,
              actionText: AppStrings.addDebt,
            ),
          ],
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshDebts,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.filteredDebts.length,
          itemBuilder: (context, index) {
            final debt = controller.filteredDebts[index];
            return _buildDebtCard(debt);
          },
        ),
      );
    });
  }

  Widget _buildDebtCard(Debt debt) {
    final customerName = controller.getCustomerName(debt.customerId);
    final isOverdue = debt.dueDate != null &&
        debt.dueDate!.isBefore(DateTime.now()) &&
        debt.status != AppConstants.debtStatusPaid;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDebtDetails(debt.id),
        borderRadius: BorderRadius.circular(AppDecorations.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصف الأول: العميل والمبلغ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customerName,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          debt.description ?? 'لا يوجد وصف',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${debt.amount.toStringAsFixed(2)} ر.س',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (debt.remainingAmount > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          'متبقي: ${debt.remainingAmount.toStringAsFixed(2)} ر.س',
                          style: AppTextStyles.bodySmall.copyWith(
                            color:
                                isOverdue ? AppColors.error : AppColors.warning,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // الصف الثاني: الحالة والتاريخ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // الحالة
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          _getStatusColor(debt.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            _getStatusColor(debt.status).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      AppStrings.getStatusText(debt.status),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _getStatusColor(debt.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // التاريخ
                  Row(
                    children: [
                      Icon(
                        AppIcons.calendar,
                        size: 16,
                        color: AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppConstants.formatDate(debt.createdAt),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // تحذير للديون المتأخرة
              if (isOverdue) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        AppIcons.warning,
                        size: 16,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'دين متأخر - تاريخ الاستحقاق: ${AppConstants.formatDate(debt.dueDate!)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return AppColors.success;
      case 'partially_paid':
        return AppColors.info;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  Widget _buildFloatingActionButton() {
    if (!EmployeeService.instance.hasPermission(Permission.addDebts)) {
      return const SizedBox.shrink();
    }
    return FloatingActionButton(
      onPressed: _navigateToAddDebt,
      child: const Icon(AppIcons.add),
    );
  }

  void _showFiltersBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDecorations.radiusLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'فلترة الديون',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // فلتر العميل
            Text('العميل', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedCustomerId.value.isEmpty
                      ? null
                      : controller.selectedCustomerId.value,
                  decoration: AppDecorations.getInputDecoration(
                    label: 'العميل',
                    hint: 'اختر العميل',
                    prefixIcon: AppIcons.customers,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('جميع العملاء'),
                    ),
                    ...controller.customers.map((customer) => DropdownMenuItem(
                          value: customer.id,
                          child: Text(customer.name),
                        )),
                  ],
                  onChanged: (value) =>
                      controller.filterByCustomer(value ?? ''),
                )),

            const SizedBox(height: 16),

            // فلتر الحالة
            Text('الحالة', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedStatus.value.isEmpty
                      ? null
                      : controller.selectedStatus.value,
                  decoration: AppDecorations.getInputDecoration(
                    label: 'الحالة',
                    hint: 'اختر الحالة',
                    prefixIcon: AppIcons.info,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '',
                      child: Text('جميع الحالات'),
                    ),
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text('معلق'),
                    ),
                    DropdownMenuItem(
                      value: 'partially_paid',
                      child: Text('مدفوع جزئياً'),
                    ),
                    DropdownMenuItem(
                      value: 'paid',
                      child: Text('مدفوع'),
                    ),
                    DropdownMenuItem(
                      value: 'cancelled',
                      child: Text('ملغي'),
                    ),
                  ],
                  onChanged: (value) => controller.filterByStatus(value ?? ''),
                )),

            const SizedBox(height: 24),

            // أزرار الإجراءات
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'مسح الفلاتر',
                    onPressed: () {
                      controller.clearFilters();
                      Get.back();
                    },
                    type: ButtonType.outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'تطبيق',
                    onPressed: () => Get.back(),
                    type: ButtonType.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _navigateToAddDebt() {
    Get.toNamed(AppRoutes.addDebt);
  }

  void _navigateToDebtDetails(String debtId) {
    Get.toNamed(AppRoutes.debtDetails, arguments: {'debtId': debtId});
  }
}
