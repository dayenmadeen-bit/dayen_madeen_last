import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customers_controller.dart';
import '../../../data/models/customer.dart'; // Import Customer model
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/offline_action_wrapper.dart';

class CustomerDetailsScreen extends GetView<CustomersController> {
  const CustomerDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customerId = Get.arguments?['customerId'] as String?;

    if (customerId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: const Center(
          child: Text('معرف العميل غير صحيح'),
        ),
      );
    }

    // استخدام FutureBuilder للحصول على العميل من الـ controller
    // الـ controller يستخدم بيانات وهمية الآن، لذا هذا سيعمل بشكل صحيح
    return FutureBuilder<Customer?>(
      future: controller.getCustomerById(customerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorState();
        }

        final customer = snapshot.data!;
        return Scaffold(
          appBar: _buildAppBar(customer), // تمرير العميل للشريط العلوي
          body: _buildCustomerDetails(customer),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(Customer customer) {
    return AppBar(
      title: Text(customer.name), // عرض اسم العميل في العنوان
      actions: [
        // زر تصدير كشف الحساب مباشرة
        IconButton(
          icon: const Icon(AppIcons.print),
          tooltip: 'كشف حساب PDF',
          onPressed: () {
            // استدعاء الدالة مباشرة من الـ controller
            controller.generateAndShareCustomerStatement(customer.id);
          },
        ),
        // القائمة المنسدلة للإجراءات الأخرى
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, customer),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('تعديل العميل'),
            ),
            const PopupMenuItem(
              value: 'add_debt',
              child: Text('إضافة دين'),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: OfflineActionWrapper(
                action: 'delete_customers',
                child: const Text('حذف العميل',
                    style: TextStyle(color: AppColors.error)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      appBar: AppBar(title: const Text('خطأ')),
      body: Center(
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
              'فشل في تحميل بيانات العميل',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('العودة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerDetails(Customer customer) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // بطاقة معلومات العميل
          _buildCustomerInfoCard(customer),

          const SizedBox(height: 16),

          // بطاقة الإحصائيات المالية
          _buildFinancialStatsCard(customer),

          const SizedBox(height: 16),

          // الإجراءات السريعة
          _buildQuickActions(customer),

          const SizedBox(height: 16),

          // الديون الحالية
          _buildCurrentDebts(customer),

          const SizedBox(height: 16),

          // آخر المدفوعات
          _buildRecentPayments(customer),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard(Customer customer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              customer.name.substring(0, 2),
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            customer.name,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoItem(
                icon: AppIcons.customers,
                label: 'الحالة',
                value: customer.isActive ? 'نشط' : 'غير نشط',
              ),
              _buildInfoItem(
                icon: AppIcons.creditCard,
                label: 'الرقم المميز',
                value: customer.uniqueId,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(label,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textSecondaryLight)),
        const SizedBox(height: 2),
        Text(value,
            style:
                AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildFinancialStatsCard(Customer customer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الملخص المالي',
              style: AppTextStyles.titleMedium
                  .copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  title: 'الرصيد الحالي',
                  value: '${customer.currentBalance.toStringAsFixed(2)} ر.س',
                  color: customer.currentBalance >= 0
                      ? AppColors.warning
                      : AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondaryLight)),
        const SizedBox(height: 4),
        Text(value,
            style: AppTextStyles.bodyLarge
                .copyWith(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQuickActions(Customer customer) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: AppIcons.add,
            label: 'إضافة دين',
            onTap: () => _addDebt(customer.id),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: AppIcons.payments,
            label: 'تسجيل دفعة',
            onTap: () => _addPayment(customer.id),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.cardDecoration.copyWith(
            border:
                Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(label,
                style: AppTextStyles.bodySmall
                    .copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentDebts(Customer customer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الديون الحالية',
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.bold)),
              TextButton(
                  onPressed: () => _viewAllDebts(customer.id),
                  child: const Text('عرض الكل')),
            ],
          ),
          const SizedBox(height: 16),
          const Center(child: Text('لا توجد ديون حالياً (بيانات وهمية)')),
        ],
      ),
    );
  }

  Widget _buildRecentPayments(Customer customer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('آخر المدفوعات',
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.bold)),
              TextButton(
                  onPressed: () => _viewAllPayments(customer.id),
                  child: const Text('عرض الكل')),
            ],
          ),
          const SizedBox(height: 16),
          const Center(child: Text('لا توجد مدفوعات حالياً (بيانات وهمية)')),
        ],
      ),
    );
  }

  void _addDebt(String customerId) {
    Get.toNamed(AppRoutes.addDebt, arguments: {'customerId': customerId});
  }

  void _addPayment(String customerId) {
    Get.toNamed(AppRoutes.addPayment, arguments: {'customerId': customerId});
  }

  void _viewAllDebts(String customerId) {
    Get.toNamed(AppRoutes.debts, arguments: {'customerId': customerId});
  }

  void _viewAllPayments(String customerId) {
    Get.toNamed(AppRoutes.payments, arguments: {'customerId': customerId});
  }

  void _handleMenuAction(String value, Customer customer) {
    switch (value) {
      case 'edit':
        controller.editCustomer(customer);
        break;
      case 'add_debt':
        _addDebt(customer.id);
        break;
      case 'delete':
        controller.deleteCustomer(customer.id);
        break;
    }
  }
}
