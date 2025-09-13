import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reports_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../../../routes/app_routes.dart';
import '../../../../core/services/pdf_service.dart';

/// شاشة التقرير اليومي مع الإحصائيات التفصيلية
class DailyReportScreen extends StatelessWidget {
  const DailyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ReportsController controller = Get.find();

    return Scaffold(
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(
            type: LoadingType.circular,
            size: LoadingSize.large,
            message: 'جاري تحميل التقرير اليومي...',
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس التقرير
              _buildReportHeader(),
              
              const SizedBox(height: 24),
              
              // إحصائيات اليوم
              _buildTodayStats(controller),
              
              const SizedBox(height: 24),
              
              // مقارنة مع الأمس
              _buildYesterdayComparison(controller),
              
              const SizedBox(height: 24),
              
              // تفاصيل المدفوعات اليومية
              _buildTodayPaymentsDetails(controller),
              
              const SizedBox(height: 24),
              
              // تفاصيل الديون اليومية
              _buildTodayDebtsDetails(controller),
              
              const SizedBox(height: 24),
              
              // أزرار الإجراءات
              _buildActionButtons(controller),
            ],
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(ReportsController controller) {
    return AppBar(
      title: const Text('التقرير اليومي'),
      actions: [
        IconButton(
          icon: const Icon(AppIcons.print),
          onPressed: () => _printReport(controller),
        ),
        IconButton(
          icon: const Icon(AppIcons.share),
          onPressed: () => _shareReport(controller),
        ),
        IconButton(
          icon: const Icon(AppIcons.refresh),
          onPressed: controller.refreshData,
        ),
      ],
    );
  }

  Widget _buildReportHeader() {
    final today = DateTime.now();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration.copyWith(
        color: AppColors.primary.withValues(alpha: 0.05),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppIcons.calendar,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التقرير اليومي',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppConstants.formatDate(today),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'محدث',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStats(ReportsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائيات اليوم',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // الصف الأول: المدفوعات والديون
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'مدفوعات اليوم',
                '${controller.todayPayments.value}',
                '${controller.todayPaymentsAmount.value.toStringAsFixed(2)} ر.س',
                AppIcons.payments,
                AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'ديون اليوم',
                '${controller.todayDebts.value}',
                '${controller.todayDebtsAmount.value.toStringAsFixed(2)} ر.س',
                AppIcons.debts,
                AppColors.warning,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // الصف الثاني: الصافي والنشاط
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'الصافي اليومي',
                _getTodayNetAmount(controller),
                _getTodayNetStatus(controller),
                AppIcons.analytics,
                _getTodayNetColor(controller),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'النشاط اليومي',
                '${controller.todayPayments.value + controller.todayDebts.value}',
                'عملية',
                AppIcons.activity,
                AppColors.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String mainValue,
    String subValue,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration.copyWith(
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              
              const SizedBox(width: 8),
              
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            mainValue,
            style: AppTextStyles.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            subValue,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYesterdayComparison(ReportsController controller) {
    // حساب إحصائيات الأمس
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayStart = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final yesterdayEnd = yesterdayStart.add(const Duration(days: 1));
    
    final yesterdayPayments = controller.allPayments.where((payment) {
      return payment.paymentDate.isAfter(yesterdayStart) && 
             payment.paymentDate.isBefore(yesterdayEnd);
    }).toList();
    
    final yesterdayDebts = controller.allDebts.where((debt) {
      return debt.createdAt.isAfter(yesterdayStart) && 
             debt.createdAt.isBefore(yesterdayEnd);
    }).toList();
    
    final yesterdayPaymentsAmount = yesterdayPayments.fold(0.0, (sum, p) => sum + p.amount);
    final yesterdayDebtsAmount = yesterdayDebts.fold(0.0, (sum, d) => sum + d.amount);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مقارنة مع الأمس',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.cardDecoration,
          child: Column(
            children: [
              _buildComparisonRow(
                'المدفوعات',
                controller.todayPaymentsAmount.value,
                yesterdayPaymentsAmount,
                AppIcons.payments,
              ),
              
              const SizedBox(height: 12),
              
              _buildComparisonRow(
                'الديون',
                controller.todayDebtsAmount.value,
                yesterdayDebtsAmount,
                AppIcons.debts,
              ),
              
              const SizedBox(height: 12),
              
              _buildComparisonRow(
                'الصافي',
                controller.todayPaymentsAmount.value - controller.todayDebtsAmount.value,
                yesterdayPaymentsAmount - yesterdayDebtsAmount,
                AppIcons.analytics,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonRow(
    String label,
    double todayValue,
    double yesterdayValue,
    IconData icon,
  ) {
    final difference = todayValue - yesterdayValue;
    final percentageChange = yesterdayValue != 0 ? (difference / yesterdayValue) * 100 : 0.0;
    final isPositive = difference >= 0;
    
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium,
          ),
        ),
        
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${todayValue.toStringAsFixed(2)} ر.س',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            if (difference != 0) ...[
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isPositive ? AppColors.success : AppColors.error,
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${percentageChange.abs().toStringAsFixed(1)}%',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isPositive ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTodayPaymentsDetails(ReportsController controller) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    final todayPayments = controller.allPayments.where((payment) {
      return payment.paymentDate.isAfter(todayStart) && 
             payment.paymentDate.isBefore(todayEnd);
    }).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'مدفوعات اليوم',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (todayPayments.isNotEmpty)
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.payments),
                child: const Text('عرض الكل'),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        if (todayPayments.isEmpty)
          _buildEmptyState('لا توجد مدفوعات اليوم', AppIcons.payments)
        else
          Container(
            decoration: AppDecorations.cardDecoration,
            child: Column(
              children: todayPayments.take(5).map((payment) {
                return _buildPaymentItem(payment, controller);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildTodayDebtsDetails(ReportsController controller) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    final todayDebts = controller.allDebts.where((debt) {
      return debt.createdAt.isAfter(todayStart) && 
             debt.createdAt.isBefore(todayEnd);
    }).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ديون اليوم',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (todayDebts.isNotEmpty)
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.debts),
                child: const Text('عرض الكل'),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        if (todayDebts.isEmpty)
          _buildEmptyState('لا توجد ديون اليوم', AppIcons.debts)
        else
          Container(
            decoration: AppDecorations.cardDecoration,
            child: Column(
              children: todayDebts.take(5).map((debt) {
                return _buildDebtItem(debt, controller);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentItem(payment, ReportsController controller) {
    final customerName = controller.getCustomerName(payment.customerId);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              AppIcons.payments,
              color: AppColors.success,
              size: 16,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.getPaymentMethodText(payment.paymentMethod),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          
          Text(
            '${payment.amount.toStringAsFixed(2)} ر.س',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtItem(debt, ReportsController controller) {
    final customerName = controller.getCustomerName(debt.customerId);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              AppIcons.debts,
              color: AppColors.warning,
              size: 16,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  debt.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          Text(
            '${debt.amount.toStringAsFixed(2)} ر.س',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: AppDecorations.cardDecoration,
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.textHintLight,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHintLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ReportsController controller) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'طباعة التقرير',
            onPressed: () => _printReport(controller),
            type: ButtonType.outlined,
            icon: AppIcons.print,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: 'مشاركة التقرير',
            onPressed: () => _shareReport(controller),
            type: ButtonType.primary,
            icon: AppIcons.share,
          ),
        ),
      ],
    );
  }

  String _getTodayNetAmount(ReportsController controller) {
    final net = controller.todayPaymentsAmount.value - controller.todayDebtsAmount.value;
    return '${net.abs().toStringAsFixed(2)} ر.س';
  }

  String _getTodayNetStatus(ReportsController controller) {
    final net = controller.todayPaymentsAmount.value - controller.todayDebtsAmount.value;
    if (net > 0) return 'ربح';
    if (net < 0) return 'خسارة';
    return 'متوازن';
  }

  Color _getTodayNetColor(ReportsController controller) {
    final net = controller.todayPaymentsAmount.value - controller.todayDebtsAmount.value;
    if (net > 0) return AppColors.success;
    if (net < 0) return AppColors.error;
    return AppColors.info;
  }

  void _printReport(ReportsController controller) async {
    Get.dialog(const LoadingWidget(message: 'جاري إنشاء التقرير...'));
    try {
      final pdfData = await PdfService.generateDailyReportPdf(controller);
      await PdfService.printPdf(pdfData);
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar('خطأ', 'فشلت طباعة التقرير: ${e.toString()}');
    } finally {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }

  void _shareReport(ReportsController controller) async {
    Get.dialog(const LoadingWidget(message: 'جاري إنشاء التقرير...'));
    try {
      final pdfData = await PdfService.generateDailyReportPdf(controller);
      final fileName = 'daily_report_${DateTime.now().toIso8601String()}.pdf';
      await PdfService.sharePdf(pdfData, fileName);
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar('خطأ', 'فشلت مشاركة التقرير: ${e.toString()}');
    } finally {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }
}
