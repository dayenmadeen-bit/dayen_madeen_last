import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../widgets/loading_widget.dart';
import '../controllers/reports_controller.dart';

/// شاشة التقارير الرئيسية مع أنواع التقارير المختلفة
class ReportsScreen extends GetView<ReportsController> {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(
            type: LoadingType.circular,
            size: LoadingSize.large,
            message: 'جاري تحميل البيانات...',
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الإحصائيات السريعة
              _buildQuickStats(),

              const SizedBox(height: 24),

              // أنواع التقارير
              _buildReportTypes(),

              const SizedBox(height: 24),

              // أفضل العملاء
              _buildTopCustomers(),
            ],
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(AppStrings.reports),
      actions: [
        IconButton(
          icon: const Icon(AppIcons.refresh),
          onPressed: controller.refreshData,
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإحصائيات السريعة',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        // الصف الأول
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'إجمالي العملاء',
                '${controller.totalCustomers.value}',
                AppIcons.customers,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'العملاء النشطون',
                '${controller.activeCustomers.value}',
                AppIcons.customers,
                AppColors.success,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // الصف الثاني
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'إجمالي الديون',
                '${controller.totalDebts.value}',
                AppIcons.debts,
                AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'الديون المتأخرة',
                '${controller.overdueDebts.value}',
                AppIcons.error,
                AppColors.error,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // الصف الثالث
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'إجمالي المدفوعات',
                '${controller.totalPaymentsAmount.value.toStringAsFixed(0)} ر.س',
                AppIcons.payments,
                AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'المبلغ المتبقي',
                '${controller.remainingDebtsAmount.value.toStringAsFixed(0)} ر.س',
                AppIcons.money,
                AppColors.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration.copyWith(
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
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

  Widget _buildReportTypes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أنواع التقارير',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        // التقرير اليومي
        _buildReportTypeCard(
          'التقرير اليومي',
          'عرض إحصائيات اليوم الحالي مع التفاصيل',
          AppIcons.calendar,
          AppColors.primary,
          () => Get.toNamed('/daily-report'),
        ),

        const SizedBox(height: 12),

        // التقرير الشهري
        _buildReportTypeCard(
          'التقرير الشهري',
          'عرض إحصائيات الشهر الحالي مع الرسوم البيانية',
          AppIcons.analytics,
          AppColors.success,
          () => Get.toNamed('/monthly-report'),
        ),

        const SizedBox(height: 12),

        // التقرير المخصص
        _buildReportTypeCard(
          'التقرير المخصص',
          'إنشاء تقرير لفترة زمنية محددة',
          AppIcons.settings,
          AppColors.info,
          () => Get.toNamed('/custom-report'),
        ),
      ],
    );
  }

  Widget _buildReportTypeCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDecorations.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textHintLight,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الرسوم البيانية السريعة',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // طرق الدفع
            Expanded(
              child: _buildPaymentMethodsChart(),
            ),

            const SizedBox(width: 16),

            // حالات الديون
            Expanded(
              child: _buildDebtStatusChart(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsChart() {
    final total = controller.cashPayments.value +
        controller.cardPayments.value +
        controller.bankPayments.value +
        controller.otherPayments.value;

    if (total == 0) {
      return _buildEmptyChart('طرق الدفع', 'لا توجد مدفوعات');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'طرق الدفع',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildChartItem(
            'نقدي',
            controller.cashPayments.value,
            total,
            AppColors.success,
          ),
          _buildChartItem(
            'بطاقة',
            controller.cardPayments.value,
            total,
            AppColors.primary,
          ),
          _buildChartItem(
            'تحويل',
            controller.bankPayments.value,
            total,
            AppColors.info,
          ),
          if (controller.otherPayments.value > 0)
            _buildChartItem(
              'أخرى',
              controller.otherPayments.value,
              total,
              AppColors.warning,
            ),
        ],
      ),
    );
  }

  Widget _buildDebtStatusChart() {
    final total = controller.paidDebts.value +
        controller.pendingDebts.value +
        controller.partiallyPaidDebts.value +
        controller.cancelledDebts.value;

    if (total == 0) {
      return _buildEmptyChart('حالات الديون', 'لا توجد ديون');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حالات الديون',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildChartItem(
            'مدفوع',
            controller.paidDebts.value.toDouble(),
            total.toDouble(),
            AppColors.success,
          ),
          _buildChartItem(
            'جزئي',
            controller.partiallyPaidDebts.value.toDouble(),
            total.toDouble(),
            AppColors.info,
          ),
          _buildChartItem(
            'معلق',
            controller.pendingDebts.value.toDouble(),
            total.toDouble(),
            AppColors.warning,
          ),
          if (controller.cancelledDebts.value > 0)
            _buildChartItem(
              'ملغي',
              controller.cancelledDebts.value.toDouble(),
              total.toDouble(),
              AppColors.error,
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String title, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Icon(
                  AppIcons.info,
                  color: AppColors.textHintLight,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textHintLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartItem(
      String label, double value, double total, Color color) {
    final percentage = total > 0 ? (value / total) * 100 : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall,
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildTopCustomers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أفضل العملاء',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // أفضل العملاء بالديون
            Expanded(
              child: _buildTopCustomersList(
                'أكثر ديوناً',
                controller.topCustomersByDebts,
                AppColors.warning,
              ),
            ),

            const SizedBox(width: 16),

            // أفضل العملاء بالمدفوعات
            Expanded(
              child: _buildTopCustomersList(
                'أكثر دفعاً',
                controller.topCustomersByPayments,
                AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopCustomersList(
    String title,
    List<Map<String, dynamic>> customers,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (customers.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    AppIcons.customers,
                    color: AppColors.textHintLight,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لا توجد بيانات',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textHintLight,
                    ),
                  ),
                ],
              ),
            )
          else
            ...customers.take(5).map((customer) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        customer['customerName'] as String,
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${(customer['amount'] as double).toStringAsFixed(0)} ر.س',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
