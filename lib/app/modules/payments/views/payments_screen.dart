import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/payments_controller.dart';
import '../../../data/models/payment.dart';
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

/// شاشة قائمة المدفوعات مع البحث والفلترة والترتيب
class PaymentsScreen extends GetView<PaymentsController> {
  const PaymentsScreen({super.key});

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

          // قائمة المدفوعات
          Expanded(
            child: _buildPaymentsList(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(AppStrings.payments),
      actions: [
        // زر الترتيب
        PopupMenuButton<String>(
          icon: const Icon(AppIcons.sort),
          onSelected: (value) => controller.sortPayments(value),
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
              value: 'method',
              child: Text('ترتيب حسب طريقة الدفع'),
            ),
          ],
        ),

        // زر التحديث
        IconButton(
          icon: const Icon(AppIcons.refresh),
          onPressed: controller.refreshPayments,
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderLight,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // الصف الأول: الإحصائيات العامة
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'إجمالي المدفوعات',
                      '${controller.totalPayments.value}',
                      AppIcons.payments,
                      AppColors.success,
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
                      'مدفوعات اليوم',
                      '${controller.todayPayments.value}',
                      AppIcons.calendar,
                      AppColors.info,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'مبلغ اليوم',
                      '${controller.todayAmount.value.toStringAsFixed(2)} ر.س',
                      AppIcons.time,
                      AppColors.warning,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // الصف الثاني: طرق الدفع
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentMethodStat(
                      'نقدي',
                      controller.cashPayments.value,
                      AppIcons.money,
                      AppColors.success,
                    ),
                  ),
                  Expanded(
                    child: _buildPaymentMethodStat(
                      'بطاقة',
                      controller.cardPayments.value,
                      AppIcons.card,
                      AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: _buildPaymentMethodStat(
                      'تحويل',
                      controller.bankPayments.value,
                      AppIcons.bank,
                      AppColors.info,
                    ),
                  ),
                ],
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

  Widget _buildPaymentMethodStat(
      String title, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${amount.toStringAsFixed(0)} ر.س',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                  hint: 'البحث في المدفوعات...',
                  prefixIcon: AppIcons.search,
                  onChanged: controller.searchPayments,
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

    // فلتر الدين
    if (controller.selectedDebtId.value.isNotEmpty) {
      final debtDescription =
          controller.getDebtDescription(controller.selectedDebtId.value);
      activeFilters.add(_buildFilterChip('الدين: $debtDescription', () {
        controller.filterByDebt('');
      }));
    }

    // فلتر طريقة الدفع
    if (controller.selectedPaymentMethod.value.isNotEmpty) {
      final methodName = AppStrings.getPaymentMethodText(
          controller.selectedPaymentMethod.value);
      activeFilters.add(_buildFilterChip('الطريقة: $methodName', () {
        controller.filterByPaymentMethod('');
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
      backgroundColor: AppColors.success.withValues(alpha: 0.1),
      deleteIconColor: AppColors.success,
    );
  }

  Widget _buildPaymentsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingWidget(
          type: LoadingType.circular,
          size: LoadingSize.large,
          message: 'جاري تحميل المدفوعات...',
        );
      }

      if (controller.filteredPayments.isEmpty) {
        if (controller.searchQuery.value.isNotEmpty) {
          return NoSearchResultsWidget(
            searchQuery: controller.searchQuery.value,
            onClearSearch: () => controller.searchPayments(''),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            EmptyListWidget(
              type: EmptyStateType.noPayments,
              actionText: AppStrings.addPayment,
            ),
          ],
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshPayments,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.filteredPayments.length,
          itemBuilder: (context, index) {
            final payment = controller.filteredPayments[index];
            return _buildPaymentCard(payment);
          },
        ),
      );
    });
  }

  Widget _buildPaymentCard(Payment payment) {
    final customerName = controller.getCustomerName(payment.customerId);
    final debtDescription = controller.getDebtDescription(payment.debtId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToPaymentDetails(payment.id),
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
                          debtDescription,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${payment.amount.toStringAsFixed(2)} ر.س',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getPaymentMethodColor(payment.paymentMethod)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getPaymentMethodColor(payment.paymentMethod)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          AppStrings.getPaymentMethodText(
                              payment.paymentMethod),
                          style: AppTextStyles.bodySmall.copyWith(
                            color:
                                _getPaymentMethodColor(payment.paymentMethod),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // الصف الثاني: التاريخ والملاحظات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                        AppConstants.formatDate(payment.paymentDate),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),

                  // أيقونة الملاحظات إذا وجدت
                  if (payment.notes != null && payment.notes!.isNotEmpty)
                    Icon(
                      AppIcons.notes,
                      size: 16,
                      color: AppColors.info,
                    ),
                ],
              ),

              // الملاحظات إذا وجدت
              if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        AppIcons.notes,
                        size: 16,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          payment.notes!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.info,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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

  Color _getPaymentMethodColor(String method) {
    switch (method) {
      case 'cash':
        return AppColors.success;
      case 'card':
        return AppColors.primary;
      case 'bank':
        return AppColors.info;
      default:
        return AppColors.warning;
    }
  }

  Widget _buildFloatingActionButton() {
    if (!EmployeeService.instance.hasPermission(Permission.addPayments)) {
      return const SizedBox.shrink();
    }
    return FloatingActionButton(
      heroTag: "payments_fab", // إضافة heroTag فريد
      onPressed: _navigateToAddPayment,
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
              'فلترة المدفوعات',
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

            // فلتر طريقة الدفع
            Text('طريقة الدفع', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedPaymentMethod.value.isEmpty
                      ? null
                      : controller.selectedPaymentMethod.value,
                  decoration: AppDecorations.getInputDecoration(
                    label: 'طريقة الدفع',
                    hint: 'اختر طريقة الدفع',
                    prefixIcon: AppIcons.payments,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '',
                      child: Text('جميع الطرق'),
                    ),
                    DropdownMenuItem(
                      value: 'cash',
                      child: Text('نقدي'),
                    ),
                    DropdownMenuItem(
                      value: 'card',
                      child: Text('بطاقة'),
                    ),
                    DropdownMenuItem(
                      value: 'bank',
                      child: Text('تحويل بنكي'),
                    ),
                    DropdownMenuItem(
                      value: 'other',
                      child: Text('أخرى'),
                    ),
                  ],
                  onChanged: (value) =>
                      controller.filterByPaymentMethod(value ?? ''),
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

  void _navigateToAddPayment() {
    Get.toNamed(AppRoutes.addPayment);
  }

  void _navigateToPaymentDetails(String paymentId) {
    Get.toNamed(AppRoutes.paymentDetails, arguments: {'paymentId': paymentId});
  }
}
