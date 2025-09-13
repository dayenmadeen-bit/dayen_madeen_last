import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_app_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../data/models/payment.dart';
import 'package:intl/intl.dart';

/// شاشة مدفوعات الزبون
class ClientPaymentsScreen extends GetView<ClientAppController> {
  const ClientPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'مدفوعاتي',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.success,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.refreshData,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppColors.success,
        child: Column(
          children: [
            _buildSummaryCard(),
            _buildQuickStats(),
            _buildFilterSection(),
            Expanded(child: _buildPaymentsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Obx(() => Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.success,
                AppColors.success.withValues(alpha: 0.8),
                AppColors.success.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    'إجمالي المدفوعات',
                    '${(controller.totalDebts.value * 0.6).toStringAsFixed(0)} ر.س',
                    AppIcons.payments,
                  ),
                  _buildSummaryItem(
                    'عدد المدفوعات',
                    '${controller.clientPayments.length}',
                    AppIcons.receipt,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      AppIcons.balance,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'الرصيد المتبقي: ${controller.remainingBalance.value.toStringAsFixed(2)} ر.س',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildQuickStats() {
    return Obx(() => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'إجمالي المدفوعات',
                  '${(controller.totalDebts.value * 0.6).toStringAsFixed(0)} ر.س',
                  AppIcons.payments,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'عدد المدفوعات',
                  '${controller.clientPayments.length}',
                  AppIcons.receipt,
                  AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'آخر دفعة',
                  controller.clientPayments.isNotEmpty
                      ? DateFormat('dd/MM')
                          .format(controller.clientPayments.first.paymentDate)
                      : 'لا يوجد',
                  AppIcons.schedule,
                  AppColors.primary,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.titleSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('الكل', null),
            const SizedBox(width: 8),
            _buildFilterChip('نقداً', 'cash'),
            const SizedBox(width: 8),
            _buildFilterChip('بطاقة', 'card'),
            const SizedBox(width: 8),
            _buildFilterChip('تحويل بنكي', 'bank'),
            const SizedBox(width: 8),
            _buildFilterChip('شيك', 'check'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? method) {
    return FilterChip(
      label: Text(label),
      selected: false,
      onSelected: (selected) {
        // منطق الفلترة
      },
      selectedColor: AppColors.success.withValues(alpha: 0.2),
      checkmarkColor: AppColors.success,
    );
  }

  Widget _buildPaymentsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final payments = controller.clientPayments;

      if (payments.isEmpty) {
        return EmptyStateWidget(
          type: EmptyStateType.noData,
          icon: AppIcons.payments,
          title: 'لا توجد مدفوعات',
          message: 'لم يتم تسجيل أي مدفوعات لحسابك حتى الآن',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          return _buildPaymentCard(payment);
        },
      );
    });
  }

  Widget _buildPaymentCard(Payment payment) {
    final methodColor = _getPaymentMethodColor(payment.paymentMethod);
    final methodIcon = _getPaymentMethodIcon(payment.paymentMethod);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: methodColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    methodIcon,
                    color: methodColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getPaymentMethodName(payment.paymentMethod),
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'دفعة #${payment.id.substring(0, 8)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${payment.amount.toStringAsFixed(0)} ر.س',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'تاريخ الدفع: ${DateFormat('dd/MM/yyyy HH:mm').format(payment.paymentDate)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (payment.notes != null && payment.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'ملاحظات: ${payment.notes}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
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
      case 'check':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'cash':
        return AppIcons.money;
      case 'card':
        return AppIcons.card;
      case 'bank':
        return AppIcons.bank;
      case 'check':
        return AppIcons.receipt;
      default:
        return AppIcons.payments;
    }
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'cash':
        return 'نقداً';
      case 'card':
        return 'بطاقة ائتمان';
      case 'bank':
        return 'تحويل بنكي';
      case 'check':
        return 'شيك';
      default:
        return 'طريقة أخرى';
    }
  }

  void _showFilterOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
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
            const SizedBox(height: 20),
            Text(
              'طريقة الدفع',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip('الكل', null),
                _buildFilterChip('نقداً', 'cash'),
                _buildFilterChip('بطاقة', 'card'),
                _buildFilterChip('تحويل بنكي', 'bank'),
                _buildFilterChip('شيك', 'check'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // تطبيق الفلاتر
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    child: const Text(
                      'تطبيق',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
