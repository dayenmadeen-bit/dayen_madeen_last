import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customers_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../routes/app_routes.dart'; // <-- تمت الإضافة
import '../../../../core/services/employee_service.dart';
import '../../../../app/data/models/employee.dart';

class CustomersScreen extends GetView<CustomersController> {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // شريط البحث والفلترة
          _buildSearchAndFilter(context),

          // قائمة العملاء
          Expanded(
            child: Obx(() => controller.isLoading.value
                ? _buildLoadingState()
                : controller.filteredCustomers.isEmpty
                    ? _buildEmptyState()
                    : _buildCustomersList()),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(AppStrings.customers),
      actions: [
        // زر استيراد العملاء
        IconButton(
          icon: const Icon(Icons.file_upload_outlined),
          onPressed: () => Get.toNamed(AppRoutes.importCustomers),
          tooltip: 'استيراد العملاء',
        ),

        // إحصائيات سريعة
        Obx(() => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  '${controller.filteredCustomers.length} عميل',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )),

        // قائمة الخيارات
        PopupMenuButton<String>(
          onSelected: controller.handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'sort_name',
              child: Text('ترتيب حسب الاسم'),
            ),
            const PopupMenuItem(
              value: 'sort_balance',
              child: Text('ترتيب حسب الرصيد'),
            ),
            const PopupMenuItem(
              value: 'sort_date',
              child: Text('ترتيب حسب التاريخ'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'export',
              child: Text('تصدير البيانات'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
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
          SearchTextField(
            controller: controller.searchController,
            hint: 'البحث في العملاء...',
            onChanged: controller.onSearchChanged,
            onClear: controller.clearSearch,
          ),

          const SizedBox(height: 12),

          // فلاتر سريعة
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  label: 'الكل',
                  isSelected: controller.selectedFilter.value == 'all',
                  onTap: () => controller.setFilter('all'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  label: 'نشط',
                  isSelected: controller.selectedFilter.value == 'active',
                  onTap: () => controller.setFilter('active'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  label: 'لديه ديون',
                  isSelected: controller.selectedFilter.value == 'has_debts',
                  onTap: () => controller.setFilter('has_debts'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondaryLight,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.customers,
            size: 80,
            color: AppColors.textHintLight,
          ),
          const SizedBox(height: 16),
          Text(
            controller.searchController.text.isNotEmpty
                ? 'لا توجد نتائج للبحث'
                : AppStrings.noCustomers,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.searchController.text.isNotEmpty
                ? 'جرب البحث بكلمات أخرى'
                : 'ابدأ بإضافة عميل جديد',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHintLight,
            ),
          ),
          const SizedBox(height: 24),
          if (controller.searchController.text.isEmpty &&
              EmployeeService.instance.hasPermission(Permission.addCustomers))
            ElevatedButton.icon(
              onPressed: controller.addCustomer,
              icon: const Icon(AppIcons.add),
              label: const Text(AppStrings.addCustomer),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomersList() {
    return RefreshIndicator(
      onRefresh: controller.refreshCustomers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredCustomers.length,
        itemBuilder: (context, index) {
          final customer = controller.filteredCustomers[index];
          return _buildCustomerCard(customer);
        },
      ),
    );
  }

  Widget _buildCustomerCard(customer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppDecorations.cardDecoration,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        // صورة العميل أو الأحرف الأولى
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            customer.initials,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // معلومات العميل
        title: Text(
          customer.name,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'الرصيد: ${customer.currentBalance.toStringAsFixed(2)} ر.س',
              style: AppTextStyles.bodyMedium.copyWith(
                color: customer.currentBalance > 0
                    ? AppColors.warning
                    : AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'الرقم المميز: ${customer.uniqueId}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        // حالة العميل وقائمة الإجراءات
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(customer.creditStatus)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    customer.creditStatus,
                    style: AppTextStyles.caption.copyWith(
                      color: _getStatusColor(customer.creditStatus),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),

            // قائمة الإجراءات
            PopupMenuButton<String>(
              onSelected: (value) => _handleCustomerAction(value, customer),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 18),
                      SizedBox(width: 8),
                      Text('عرض التفاصيل'),
                    ],
                  ),
                ),
                if (EmployeeService.instance
                    .hasPermission(Permission.editCustomers))
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('تعديل'),
                      ],
                    ),
                  ),
                if (EmployeeService.instance.hasPermission(Permission.addDebts))
                  const PopupMenuItem(
                    value: 'add_debt',
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 18),
                        SizedBox(width: 8),
                        Text('إضافة دين'),
                      ],
                    ),
                  ),
              ],
              icon: Icon(
                Icons.more_vert,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),

        onTap: () => _navigateToCustomerDetails(customer),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'جيد':
        return AppColors.success;
      case 'استخدام عالي':
        return AppColors.warning;
      case 'قريب من الحد':
      case 'تجاوز الحد':
        return AppColors.error;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  Widget _buildFloatingActionButton() {
    if (!EmployeeService.instance.hasPermission(Permission.addCustomers)) {
      return const SizedBox.shrink();
    }
    return FloatingActionButton(
      heroTag: "customers_fab", // إضافة heroTag فريد
      onPressed: controller.addCustomer,
      backgroundColor: AppColors.primary,
      child: const Icon(
        AppIcons.add,
        color: Colors.white,
      ),
    );
  }

  // الانتقال إلى تفاصيل العميل
  void _navigateToCustomerDetails(customer) {
    Get.toNamed(AppRoutes.customerDetails,
        arguments: {'customerId': customer.id});
  }

  // معالجة إجراءات العميل
  void _handleCustomerAction(String action, customer) {
    switch (action) {
      case 'view':
        _navigateToCustomerDetails(customer);
        break;
      case 'edit':
        controller.editCustomer(customer);
        break;
      case 'add_debt':
        Get.toNamed(AppRoutes.addDebt, arguments: {'customerId': customer.id});
        break;
    }
  }
}
