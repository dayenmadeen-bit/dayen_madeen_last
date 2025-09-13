import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../controllers/reports_controller.dart';

/// شاشة التقرير المخصص مع فترة زمنية محددة
class CustomReportScreen extends GetView<ReportsController> {
  const CustomReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // إعدادات التقرير
            _buildReportSettings(),
            
            const SizedBox(height: 24),
            
            // عرض التقرير
            Obx(() => _buildReportContent()),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('التقرير المخصص'),
      actions: [
        Obx(() {
          if (controller.isGeneratingReport.value) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );
          }
          
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(AppIcons.print),
                onPressed: _printReport,
              ),
              IconButton(
                icon: const Icon(AppIcons.share),
                onPressed: _shareReport,
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildReportSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إعدادات التقرير',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // اختيار الفترة الزمنية
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(
                  'من تاريخ',
                  controller.selectedStartDate.value,
                  (date) => controller.selectedStartDate.value = date,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateSelector(
                  'إلى تاريخ',
                  controller.selectedEndDate.value,
                  (date) => controller.selectedEndDate.value = date,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // فترات سريعة
          Text(
            'فترات سريعة',
            style: AppTextStyles.labelMedium,
          ),
          
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickPeriodChip('آخر 7 أيام', 7),
              _buildQuickPeriodChip('آخر 30 يوم', 30),
              _buildQuickPeriodChip('آخر 3 أشهر', 90),
              _buildQuickPeriodChip('آخر 6 أشهر', 180),
              _buildQuickPeriodChip('آخر سنة', 365),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // زر إنشاء التقرير
          SizedBox(
            width: double.infinity,
            child: Obx(() => CustomButton(
              text: controller.isGeneratingReport.value 
                  ? 'جاري إنشاء التقرير...' 
                  : 'إنشاء التقرير',
              onPressed: controller.isGeneratingReport.value 
                  ? null 
                  : _generateReport,
              type: ButtonType.primary,
              icon: controller.isGeneratingReport.value 
                  ? null 
                  : AppIcons.analytics,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime selectedDate, Function(DateTime) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(selectedDate, onDateSelected),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppDecorations.radiusLarge),
              border: Border.all(
                color: AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.calendar,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppConstants.formatDate(selectedDate),
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textHintLight,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPeriodChip(String label, int days) {
    return ActionChip(
      label: Text(
        label,
        style: AppTextStyles.bodySmall,
      ),
      onPressed: () => _setQuickPeriod(days),
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      side: BorderSide(
        color: AppColors.primary.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildReportContent() {
    if (controller.isGeneratingReport.value) {
      return const LoadingWidget(
        type: LoadingType.circular,
        size: LoadingSize.large,
        message: 'جاري إنشاء التقرير المخصص...',
      );
    }
    
    // عرض التقرير إذا تم إنشاؤه
    return FutureBuilder<Map<String, dynamic>>(
      future: _getCustomReport(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyReport();
        }
        
        final report = snapshot.data!;
        return _buildGeneratedReport(report);
      },
    );
  }

  Widget _buildEmptyReport() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: AppDecorations.cardDecoration,
      child: Center(
        child: Column(
          children: [
            Icon(
              AppIcons.analytics,
              color: AppColors.textHintLight,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'اختر الفترة الزمنية واضغط على "إنشاء التقرير"',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textHintLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم عرض تقرير مفصل للفترة المحددة',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratedReport(Map<String, dynamic> report) {
    final period = report['period'] as Map<String, dynamic>;
    final debts = report['debts'] as Map<String, dynamic>;
    final payments = report['payments'] as Map<String, dynamic>;
    final customers = report['customers'] as Map<String, dynamic>;
    final dailyBreakdown = report['dailyBreakdown'] as List<Map<String, dynamic>>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // رأس التقرير
        _buildReportHeader(period),
        
        const SizedBox(height: 24),
        
        // ملخص الإحصائيات
        _buildReportSummary(debts, payments, customers),
        
        const SizedBox(height: 24),
        
        // تفصيل الديون
        _buildDebtsBreakdown(debts),
        
        const SizedBox(height: 24),
        
        // تفصيل المدفوعات
        _buildPaymentsBreakdown(payments),
        
        const SizedBox(height: 24),
        
        // التفصيل اليومي
        _buildDailyBreakdown(dailyBreakdown),
        
        const SizedBox(height: 24),
        
        // أزرار الإجراءات
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildReportHeader(Map<String, dynamic> period) {
    final startDate = period['startDate'] as DateTime;
    final endDate = period['endDate'] as DateTime;
    final days = period['days'] as int;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration.copyWith(
        color: AppColors.info.withValues(alpha: 0.05),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppIcons.analytics,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التقرير المخصص',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppConstants.formatDate(startDate)} - ${AppConstants.formatDate(endDate)}',
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
                  '$days يوم',
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

  Widget _buildReportSummary(
    Map<String, dynamic> debts,
    Map<String, dynamic> payments,
    Map<String, dynamic> customers,
  ) {
    final debtsCount = debts['count'] as int;
    final debtsAmount = debts['totalAmount'] as double;
    final paymentsCount = payments['count'] as int;
    final paymentsAmount = payments['totalAmount'] as double;
    final net = paymentsAmount - debtsAmount;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ملخص الإحصائيات',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'الديون',
                '$debtsCount',
                '${debtsAmount.toStringAsFixed(2)} ر.س',
                AppIcons.debts,
                AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'المدفوعات',
                '$paymentsCount',
                '${paymentsAmount.toStringAsFixed(2)} ر.س',
                AppIcons.payments,
                AppColors.success,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'الصافي',
                net >= 0 ? 'ربح' : 'خسارة',
                '${net.abs().toStringAsFixed(2)} ر.س',
                AppIcons.analytics,
                net >= 0 ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'العملاء',
                '${customers['withDebts']}',
                'عميل نشط',
                AppIcons.customers,
                AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
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
            style: AppTextStyles.titleMedium.copyWith(
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

  Widget _buildDebtsBreakdown(Map<String, dynamic> debts) {
    final byStatus = debts['byStatus'] as Map<String, dynamic>;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفصيل الديون حسب الحالة',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildStatusRow('مدفوع', byStatus['paid'] as int, AppColors.success),
          _buildStatusRow('جزئي', byStatus['partiallyPaid'] as int, AppColors.info),
          _buildStatusRow('معلق', byStatus['pending'] as int, AppColors.warning),
          _buildStatusRow('ملغي', byStatus['cancelled'] as int, AppColors.error),
        ],
      ),
    );
  }

  Widget _buildPaymentsBreakdown(Map<String, dynamic> payments) {
    final byMethod = payments['byMethod'] as Map<String, dynamic>;
    final total = byMethod.values.fold(0.0, (sum, amount) => sum + (amount as double));
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفصيل المدفوعات حسب الطريقة',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (total > 0) ...[
            _buildPaymentMethodRow('نقدي', byMethod['cash'] as double, total, AppColors.success),
            _buildPaymentMethodRow('بطاقة', byMethod['card'] as double, total, AppColors.primary),
            _buildPaymentMethodRow('تحويل', byMethod['bank'] as double, total, AppColors.info),
            _buildPaymentMethodRow('أخرى', byMethod['other'] as double, total, AppColors.warning),
          ] else
            Center(
              child: Text(
                'لا توجد مدفوعات في هذه الفترة',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textHintLight,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String status, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Text(
              status,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          
          Text(
            '$count',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodRow(String method, double amount, double total, Color color) {
    final percentage = total > 0 ? (amount / total) * 100 : 0.0;
    
    if (amount == 0) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                method,
                style: AppTextStyles.bodyMedium,
              ),
              Text(
                '${amount.toStringAsFixed(0)} ر.س (${percentage.toStringAsFixed(1)}%)',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 6),
          
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

  Widget _buildDailyBreakdown(List<Map<String, dynamic>> dailyData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التفصيل اليومي',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (dailyData.isEmpty)
            Center(
              child: Text(
                'لا توجد بيانات يومية',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textHintLight,
                ),
              ),
            )
          else
            ...dailyData.take(7).map((day) {
              final date = day['date'] as DateTime;
              final paymentsAmount = day['paymentsAmount'] as double;
              final debtsAmount = day['debtsAmount'] as double;
              final net = paymentsAmount - debtsAmount;
              
              return _buildDailyItem(date, paymentsAmount, debtsAmount, net);
            }).toList(),
          
          if (dailyData.length > 7) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                'وعرض ${dailyData.length - 7} يوم إضافي...',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDailyItem(DateTime date, double payments, double debts, double net) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              AppConstants.formatDate(date),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${payments.toStringAsFixed(0)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          
          Text(
            'صافي: ${net.toStringAsFixed(0)} ر.س',
            style: AppTextStyles.bodySmall.copyWith(
              color: net >= 0 ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'طباعة التقرير',
            onPressed: _printReport,
            type: ButtonType.outlined,
            icon: AppIcons.print,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: 'مشاركة التقرير',
            onPressed: _shareReport,
            type: ButtonType.primary,
            icon: AppIcons.share,
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(DateTime currentDate, Function(DateTime) onDateSelected) async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: currentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'SA'),
    );
    
    if (date != null) {
      onDateSelected(date);
    }
  }

  void _setQuickPeriod(int days) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    
    controller.selectedStartDate.value = startDate;
    controller.selectedEndDate.value = endDate;
  }

  Future<void> _generateReport() async {
    await controller.generateCustomReport(
      controller.selectedStartDate.value,
      controller.selectedEndDate.value,
    );
  }

  Future<Map<String, dynamic>> _getCustomReport() async {
    return await controller.generateCustomReport(
      controller.selectedStartDate.value,
      controller.selectedEndDate.value,
    );
  }

  void _printReport() {
    Get.snackbar(
      'طباعة التقرير',
      'سيتم إضافة وظيفة الطباعة قريباً',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  void _shareReport() {
    Get.snackbar(
      'مشاركة التقرير',
      'سيتم إضافة وظيفة المشاركة قريباً',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
}
