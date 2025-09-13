import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_app_controller.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_icons.dart';

class CustomerPaymentsScreen extends GetView<ClientAppController> {
  const CustomerPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدفوعاتي'),
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
          // فترة التقرير
          _buildDateRangeHeader(),

          // إحصائيات المدفوعات
          _buildPaymentStats(),

          // قائمة المدفوعات
          Expanded(
            child: _buildPaymentsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: الانتقال إلى شاشة طلب سداد
          Get.toNamed('/payment-request');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDateRangeHeader() {
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
      child: Row(
        children: [
          Icon(
            AppIcons.calendar,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Obx(() => Text(
                  'من ${controller.formatDate(controller.fromDate.value)} إلى ${controller.formatDate(controller.toDate.value)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                )),
          ),
          CustomButton(
            text: 'تغيير',
            onPressed: controller.selectDateRange,
            type: ButtonType.outlined,
            size: ButtonSize.small,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final filteredPayments = controller.getPaymentsByPeriod(
          controller.fromDate.value,
          controller.toDate.value,
        );

        final totalAmount = filteredPayments.fold<double>(
          0.0,
          (sum, payment) => sum + payment.amount,
        );

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'عدد المدفوعات',
                '${filteredPayments.length}',
                AppIcons.payments,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'إجمالي المبلغ',
                controller.formatAmount(totalAmount),
                AppIcons.money,
                AppColors.success,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return CustomCard(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final payments = controller.getPaymentsByPeriod(
        controller.fromDate.value,
        controller.toDate.value,
      );

      if (payments.isEmpty) {
        return EmptyStateWidget(
          type: EmptyStateType.noData,
          icon: AppIcons.payments,
          title: 'لا توجد مدفوعات',
          subtitle: 'لم يتم تسجيل أي مدفوعات في الفترة المحددة',
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final payment = payments[index];
            return _buildPaymentCard(payment);
          },
        ),
      );
    });
  }

  Widget _buildPaymentCard(payment) {
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
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  AppIcons.checkCircle,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'دفعة ${controller.formatAmount(payment.amount)}',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'تاريخ الدفع: ${controller.formatDate(payment.paymentDate)}',
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
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'مدفوع',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // تفاصيل الدفعة
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  'طريقة الدفع:',
                  _getPaymentMethodText(payment.paymentMethod),
                  _getPaymentMethodIcon(payment.paymentMethod),
                ),
                if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'ملاحظات:',
                    payment.notes!,
                    AppIcons.notes,
                  ),
                ],
                const SizedBox(height: 8),
                _buildDetailRow(
                  'وقت التسجيل:',
                  _formatDateTime(payment.createdAt),
                  AppIcons.time,
                ),
              ],
            ),
          ),

          // معلومات الدين المرتبط (إذا وجد)
          if (payment.debtId != null) ...[
            const SizedBox(height: 12),
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
                    AppIcons.link,
                    color: AppColors.info,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'مرتبط بدين محدد',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'cash':
        return 'نقداً';
      case 'card':
        return 'بطاقة ائتمانية';
      case 'bank':
        return 'تحويل بنكي';
      case 'other':
        return 'طريقة أخرى';
      default:
        return 'غير محدد';
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'cash':
        return AppIcons.money;
      case 'card':
        return AppIcons.creditCard;
      case 'bank':
        return AppIcons.bank;
      case 'other':
        return AppIcons.other;
      default:
        return AppIcons.payment;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${controller.formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
