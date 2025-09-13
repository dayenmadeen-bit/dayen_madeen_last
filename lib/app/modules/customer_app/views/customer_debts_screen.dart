import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_app_controller.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_icons.dart';

class CustomerDebtsScreen extends GetView<ClientAppController> {
  const CustomerDebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ديوني'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // فلاتر الحالة
          _buildStatusFilters(),

          // قائمة الديون
          Expanded(
            child: _buildDebtsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: الانتقال إلى شاشة طلب دين
          Get.toNamed('/debt-request');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatusFilters() {
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('الكل', null),
            const SizedBox(width: 8),
            _buildFilterChip('معلق', 'pending'),
            const SizedBox(width: 8),
            _buildFilterChip('مدفوع جزئياً', 'partial'),
            const SizedBox(width: 8),
            _buildFilterChip('مدفوع', 'paid'),
            const SizedBox(width: 8),
            _buildFilterChip('متأخر', 'overdue'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    return Obx(() {
      final debts = status == null
          ? controller.clientDebts
          : controller.getDebtsByStatus(status);

      return FilterChip(
        label: Text('$label (${debts.length})'),
        selected: false, // يمكن إضافة منطق التحديد هنا
        onSelected: (_) {
          // يمكن إضافة منطق الفلترة هنا
        },
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
      );
    });
  }

  Widget _buildDebtsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final debts = controller.clientDebts;

      if (debts.isEmpty) {
        return EmptyStateWidget(
          type: EmptyStateType.noData,
          icon: AppIcons.debts,
          title: 'لا توجد ديون',
          subtitle: 'لم يتم تسجيل أي ديون لحسابك حتى الآن',
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: debts.length,
          itemBuilder: (context, index) {
            final debt = debts[index];
            return _buildDebtCard(debt);
          },
        ),
      );
    });
  }

  Widget _buildDebtCard(debt) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (debt.status) {
      case 'pending':
        statusColor = AppColors.warning;
        statusText = 'معلق';
        statusIcon = AppIcons.pending;
        break;
      case 'partial':
        statusColor = AppColors.info;
        statusText = 'مدفوع جزئياً';
        statusIcon = AppIcons.partial;
        break;
      case 'paid':
        statusColor = AppColors.success;
        statusText = 'مدفوع';
        statusIcon = AppIcons.checkCircle;
        break;
      case 'overdue':
        statusColor = AppColors.error;
        statusText = 'متأخر';
        statusIcon = AppIcons.warning;
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = 'غير محدد';
        statusIcon = AppIcons.help;
    }

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس البطاقة
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      debt.description ?? 'دين بدون وصف',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'تاريخ الإنشاء: ${controller.formatDate(debt.createdAt)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // تفاصيل المبالغ
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildAmountRow(
                  'المبلغ الإجمالي:',
                  controller.formatAmount(debt.amount),
                  AppColors.primary,
                ),
                const SizedBox(height: 8),
                _buildAmountRow(
                  'المبلغ المدفوع:',
                  controller.formatAmount(debt.paidAmount),
                  AppColors.success,
                ),
                const SizedBox(height: 8),
                _buildAmountRow(
                  'المبلغ المتبقي:',
                  controller.formatAmount(debt.remainingAmount),
                  debt.remainingAmount > 0
                      ? AppColors.error
                      : AppColors.success,
                ),
              ],
            ),
          ),

          // تاريخ الاستحقاق
          if (debt.dueDate != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  AppIcons.calendar,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'تاريخ الاستحقاق: ${controller.formatDate(debt.dueDate!)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (debt.dueDate!.isBefore(DateTime.now()) &&
                    debt.status != 'paid')
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'متأخر',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],

          // شريط التقدم للديون المدفوعة جزئياً
          if (debt.status == 'partial') ...[
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'نسبة السداد',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${((debt.paidAmount / debt.amount) * 100).toStringAsFixed(1)}%',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: debt.paidAmount / debt.amount,
                  backgroundColor: AppColors.outline.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, String amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          amount,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
