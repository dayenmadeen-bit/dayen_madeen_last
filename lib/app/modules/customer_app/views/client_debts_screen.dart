import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_app_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../data/models/debt.dart';
import 'package:intl/intl.dart';

/// شاشة ديون الزبون
class ClientDebtsScreen extends GetView<ClientAppController> {
  const ClientDebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'ديوني',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primary,
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
        color: AppColors.primary,
        child: Column(
          children: [
            _buildSummaryCard(),
            _buildQuickStats(),
            _buildFilterTabs(),
            Expanded(child: _buildDebtsList()),
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
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.primary.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
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
                'إجمالي الديون',
                '${controller.totalDebts.value.toStringAsFixed(0)} ر.س',
                AppIcons.debts,
              ),
              _buildSummaryItem(
                'عدد الديون',
                '${controller.clientDebts.length}',
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
              'إجمالي الديون',
              '${controller.totalDebts.value.toStringAsFixed(0)} ر.س',
              AppIcons.debts,
              AppColors.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'المدفوع',
              '${(controller.totalDebts.value * 0.6).toStringAsFixed(0)} ر.س',
              AppIcons.payments,
              AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'المتبقي',
              '${controller.remainingBalance.value.toStringAsFixed(0)} ر.س',
              AppIcons.balance,
              AppColors.warning,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('الكل', null),
            const SizedBox(width: 8),
            _buildFilterChip('مسدد', 'paid'),
            const SizedBox(width: 8),
            _buildFilterChip('جزئي', 'partial'),
            const SizedBox(width: 8),
            _buildFilterChip('معلق', 'pending'),
            const SizedBox(width: 8),
            _buildFilterChip('متأخر', 'overdue'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    return FilterChip(
      label: Text(label),
      selected: false,
      onSelected: (selected) {
        // منطق الفلترة
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildDebtsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final debts = controller.clientDebts;

      if (debts.isEmpty) {
        return EmptyStateWidget(
          type: EmptyStateType.noData,
          icon: AppIcons.debts,
          title: 'لا توجد ديون',
          message: 'لم يتم تسجيل أي ديون لحسابك حتى الآن',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: debts.length,
        itemBuilder: (context, index) {
          final debt = debts[index];
          return _buildDebtCard(debt);
        },
      );
    });
  }

  Widget _buildDebtCard(Debt debt) {
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    AppIcons.debts,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    debt.description ?? 'دين بدون وصف',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${debt.amount.toStringAsFixed(0)} ر.س',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            if (debt.dueDate != null)
              Text(
                'تاريخ الاستحقاق: ${DateFormat('dd/MM/yyyy').format(debt.dueDate!)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
