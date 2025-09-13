import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../data/models/debt.dart';
import '../../../widgets/confirmation_dialog.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/error_widget.dart';
import '../../../widgets/offline_action_wrapper.dart';
import '../controllers/debts_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../../core/services/employee_service.dart';
import '../../../../app/data/models/employee.dart';

/// شاشة تفاصيل الدين مع الإحصائيات والإجراءات
class DebtDetailsScreen extends GetView<DebtsController> {
  const DebtDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final debtId = Get.arguments?['debtId'] as String?;

    if (debtId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: const SimpleErrorWidget(
          message: 'معرف الدين غير صحيح',
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(debtId),
      body: _buildDebtDetails(debtId),
      floatingActionButton: _buildFloatingActionButton(debtId),
    );
  }

  PreferredSizeWidget _buildAppBar(String debtId) {
    return AppBar(
      title: const Text(AppStrings.debtDetails),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, debtId),
          itemBuilder: (context) => [
            if (EmployeeService.instance.hasPermission(Permission.editDebts))
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(AppIcons.edit),
                  title: Text('تعديل الدين'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            if (EmployeeService.instance.hasPermission(Permission.addPayments))
              const PopupMenuItem(
                value: 'add_payment',
                child: ListTile(
                  leading: Icon(AppIcons.payments),
                  title: Text('إضافة دفعة'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: OfflineActionWrapper(
                action: 'delete_debts',
                showMessage: true,
                child: const ListTile(
                  leading: Icon(AppIcons.delete, color: Colors.red),
                  title: Text('حذف الدين', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDebtDetails(String debtId) {
    return Obx(() {
      final debt = controller.getDebtById(debtId);

      if (debt == null) {
        return const SimpleErrorWidget(
          message: 'الدين غير موجود أو تم حذفه',
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة معلومات الدين الأساسية
            _buildDebtInfoCard(debt),

            const SizedBox(height: 16),

            // بطاقة الإحصائيات المالية
            _buildFinancialStatsCard(debt),

            const SizedBox(height: 16),

            // بطاقة معلومات العميل
            _buildCustomerInfoCard(debt),

            const SizedBox(height: 16),

            // الإجراءات السريعة
            _buildQuickActions(debt),

            const SizedBox(height: 16),

            // تاريخ المدفوعات (إذا وجدت)
            _buildPaymentHistory(debt),

            const SizedBox(height: 16),

            // ملاحظات إضافية
            if (debt.notes != null && debt.notes!.isNotEmpty)
              _buildNotesCard(debt),
          ],
        ),
      );
    });
  }

  Widget _buildDebtInfoCard(Debt debt) {
    final customerName = controller.getCustomerName(debt.customerId);
    final isOverdue = debt.dueDate != null &&
        debt.dueDate!.isBefore(DateTime.now()) &&
        debt.status != AppConstants.debtStatusPaid;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان والحالة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'معلومات الدين',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(debt.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getStatusColor(debt.status).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  AppStrings.getStatusText(debt.status),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _getStatusColor(debt.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // العميل
          _buildInfoRow(
            'العميل',
            customerName,
            AppIcons.customers,
            onTap: () => _navigateToCustomerDetails(debt.customerId),
          ),

          // الوصف
          _buildInfoRow(
            'الوصف',
            debt.description ?? 'لا يوجد وصف',
            AppIcons.description,
          ),

          // تاريخ الإنشاء
          _buildInfoRow(
            'تاريخ الإنشاء',
            AppConstants.formatDate(debt.createdAt),
            AppIcons.calendar,
          ),

          // تاريخ الاستحقاق
          if (debt.dueDate != null)
            _buildInfoRow(
              'تاريخ الاستحقاق',
              AppConstants.formatDate(debt.dueDate!),
              AppIcons.time,
              valueColor: isOverdue ? AppColors.error : null,
            ),

          // تحذير للديون المتأخرة
          if (isOverdue) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.warning,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'هذا الدين متأخر عن موعد الاستحقاق',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
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

  Widget _buildFinancialStatsCard(Debt debt) {
    final paymentPercentage =
        debt.amount > 0 ? (debt.paidAmount / debt.amount) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الملخص المالي',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // المبلغ الإجمالي
          _buildAmountRow(
            'المبلغ الإجمالي',
            debt.amount,
            AppColors.primary,
            isLarge: true,
          ),

          const SizedBox(height: 12),

          // المبلغ المدفوع
          _buildAmountRow(
            'المبلغ المدفوع',
            debt.paidAmount,
            AppColors.success,
          ),

          const SizedBox(height: 12),

          // المبلغ المتبقي
          _buildAmountRow(
            'المبلغ المتبقي',
            debt.remainingAmount,
            debt.remainingAmount > 0 ? AppColors.warning : AppColors.success,
          ),

          const SizedBox(height: 20),

          // شريط التقدم
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'نسبة السداد',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${paymentPercentage.toStringAsFixed(1)}%',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: paymentPercentage / 100,
                backgroundColor: AppColors.borderLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  paymentPercentage == 100
                      ? AppColors.success
                      : AppColors.primary,
                ),
                minHeight: 8,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard(Debt debt) {
    return GetBuilder<DebtsController>(
      builder: (controller) {
        final customer = controller.customers.firstWhereOrNull(
          (c) => c.id == debt.customerId,
        );

        if (customer == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'معلومات العميل',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CustomButton(
                    text: 'عرض التفاصيل',
                    onPressed: () => _navigateToCustomerDetails(customer.id),
                    type: ButtonType.outlined,
                    size: ButtonSize.small,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildCustomerStatItem(
                      'الرصيد الحالي',
                      '${customer.currentBalance.toStringAsFixed(2)} ر.س',
                      customer.currentBalance > 0
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                  ),
                  Expanded(
                    child: _buildCustomerStatItem(
                      'حد الائتمان',
                      '${customer.creditLimit.toStringAsFixed(2)} ر.س',
                      AppColors.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildCustomerStatItem(
                      'الائتمان المتاح',
                      '${customer.availableCredit.toStringAsFixed(2)} ر.س',
                      AppColors.success,
                    ),
                  ),
                  Expanded(
                    child: _buildCustomerStatItem(
                      'نسبة الاستخدام',
                      '${customer.creditUtilizationPercentage.toStringAsFixed(1)}%',
                      _getUtilizationColor(
                          customer.creditUtilizationPercentage),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(Debt debt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإجراءات السريعة',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (debt.remainingAmount > 0) ...[
                Expanded(
                  child: OfflineActionButton(
                    action: 'add_payments',
                    text: 'إضافة دفعة',
                    onPressed: () => _addPayment(debt.id),
                    icon: AppIcons.payments,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: OfflineActionButton(
                  action: 'edit_debts',
                  text: 'تعديل الدين',
                  onPressed: () => _editDebt(debt.id),
                  icon: AppIcons.edit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory(Debt debt) {
    // هنا يمكن إضافة تاريخ المدفوعات عندما يتم تطوير وحدة المدفوعات
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تاريخ المدفوعات',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (debt.paidAmount > 0)
                TextButton(
                  onPressed: () => _viewAllPayments(debt.id),
                  child: const Text('عرض الكل'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (debt.paidAmount == 0)
            Text(
              'لا توجد مدفوعات لهذا الدين بعد',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            )
          else
            Text(
              'تم دفع ${debt.paidAmount.toStringAsFixed(2)} ر.س من أصل ${debt.amount.toStringAsFixed(2)} ر.س',
              style: AppTextStyles.bodyMedium,
            ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(Debt debt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملاحظات إضافية',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            debt.notes!,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: valueColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textHintLight,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, Color color,
      {bool isLarge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isLarge
              ? AppTextStyles.titleMedium
              : AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} ر.س',
          style: isLarge
              ? AppTextStyles.titleLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                )
              : AppTextStyles.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
        ),
      ],
    );
  }

  Widget _buildCustomerStatItem(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(String debtId) {
    return Obx(() {
      final debt = controller.getDebtById(debtId);

      if (debt == null || debt.remainingAmount <= 0) {
        return const SizedBox.shrink();
      }

      return FloatingActionButton.extended(
        heroTag: "debt_details_fab", // إضافة heroTag فريد
        onPressed: () => _addPayment(debtId),
        icon: const Icon(AppIcons.payments),
        label: const Text('إضافة دفعة'),
      );
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return AppColors.success;
      case 'partially_paid':
        return AppColors.info;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  Color _getUtilizationColor(double percentage) {
    if (percentage >= 90) return AppColors.error;
    if (percentage >= 70) return AppColors.warning;
    return AppColors.success;
  }

  void _handleMenuAction(String action, String debtId) {
    switch (action) {
      case 'edit':
        _editDebt(debtId);
        break;
      case 'add_payment':
        _addPayment(debtId);
        break;
      case 'delete':
        _deleteDebt(debtId);
        break;
    }
  }

  void _editDebt(String debtId) {
    Get.toNamed('/edit-debt', arguments: {'debtId': debtId});
  }

  void _addPayment(String debtId) {
    Get.toNamed('/add-payment', arguments: {'debtId': debtId});
  }

  void _deleteDebt(String debtId) {
    DeleteConfirmationDialog.show(
      context: Get.context!,
      title: 'حذف الدين',
      message:
          'هل أنت متأكد من حذف هذا الدين؟ سيتم حذف جميع البيانات المرتبطة به.',
    ).then((confirmed) {
      if (confirmed == true) {
        controller.deleteDebt(debtId).then((success) {
          if (success) {
            Get.back(); // العودة لقائمة الديون
          }
        });
      }
    });
  }

  void _navigateToCustomerDetails(String customerId) {
    Get.toNamed('/customer-details', arguments: {'customerId': customerId});
  }

  void _viewAllPayments(String debtId) {
    Get.toNamed(AppRoutes.payments, arguments: {'debtId': debtId});
  }
}
