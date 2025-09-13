import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../data/models/payment.dart';
import '../../../widgets/confirmation_dialog.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/error_widget.dart';
import '../../../widgets/offline_action_wrapper.dart';
import '../controllers/payments_controller.dart';
import '../../../../core/services/employee_service.dart';
import '../../../../app/data/models/employee.dart';

/// شاشة تفاصيل الدفعة مع إيصال الدفع
class PaymentDetailsScreen extends GetView<PaymentsController> {
  const PaymentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final paymentId = Get.arguments?['paymentId'] as String?;

    if (paymentId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: const SimpleErrorWidget(
          message: 'معرف الدفعة غير صحيح',
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(paymentId),
      body: _buildPaymentDetails(paymentId),
      floatingActionButton: _buildFloatingActionButton(paymentId),
    );
  }

  PreferredSizeWidget _buildAppBar(String paymentId) {
    return AppBar(
      title: const Text(AppStrings.paymentDetails),
      actions: [
        // زر طباعة/مشاركة الإيصال
        IconButton(
          icon: const Icon(AppIcons.print),
          onPressed: () => _printReceipt(paymentId),
        ),

        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, paymentId),
          itemBuilder: (context) => [
            if (EmployeeService.instance.hasPermission(Permission.editPayments))
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(AppIcons.edit),
                  title: Text('تعديل الدفعة'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            const PopupMenuItem(
              value: 'copy',
              child: ListTile(
                leading: Icon(AppIcons.copy),
                title: Text('نسخ التفاصيل'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: OfflineActionWrapper(
                action: 'delete_payments',
                showMessage: true,
                child: const ListTile(
                  leading: Icon(AppIcons.delete, color: Colors.red),
                  title:
                      Text('حذف الدفعة', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentDetails(String paymentId) {
    return Obx(() {
      final payment = controller.getPaymentById(paymentId);

      if (payment == null) {
        return const SimpleErrorWidget(
          message: 'الدفعة غير موجودة أو تم حذفها',
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // إيصال الدفع
            _buildPaymentReceipt(payment),

            const SizedBox(height: 16),

            // تفاصيل الدفعة
            _buildPaymentInfoCard(payment),

            const SizedBox(height: 16),

            // معلومات العميل
            _buildCustomerInfoCard(payment),

            const SizedBox(height: 16),

            // معلومات الدين المرتبط (إن وجد)
            if (payment.debtId.isNotEmpty) _buildLinkedDebtCard(payment),

            const SizedBox(height: 16),

            // الإجراءات السريعة
            _buildQuickActions(payment),

            const SizedBox(height: 16),

            // ملاحظات إضافية
            if (payment.notes != null && payment.notes!.isNotEmpty)
              _buildNotesCard(payment),
          ],
        ),
      );
    });
  }

  Widget _buildPaymentReceipt(Payment payment) {
    final customerName = controller.getCustomerName(payment.customerId);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.cardDecoration.copyWith(
        color: AppColors.success.withValues(alpha: 0.05),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // رأس الإيصال
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إيصال دفع',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    'رقم الإيصال: ${payment.id.substring(0, 8).toUpperCase()}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppIcons.success,
                  color: AppColors.success,
                  size: 32,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // المبلغ الرئيسي
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'المبلغ المدفوع',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${payment.amount.toStringAsFixed(2)} ر.س',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // تفاصيل الإيصال
          _buildReceiptRow('العميل', customerName),
          _buildReceiptRow(
              'التاريخ', AppConstants.formatDate(payment.paymentDate)),
          _buildReceiptRow('طريقة الدفع',
              AppStrings.getPaymentMethodText(payment.paymentMethod)),
          if (payment.debtId.isNotEmpty)
            _buildReceiptRow(
                'الدين', controller.getDebtDescription(payment.debtId)),

          const SizedBox(height: 20),

          // توقيع رقمي
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  AppIcons.verified,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'تم التحقق من الدفعة رقمياً',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard(Payment payment) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل الدفعة',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'معرف الدفعة',
            payment.id,
            AppIcons.info,
            onTap: () => _copyToClipboard(payment.id, 'تم نسخ معرف الدفعة'),
          ),
          _buildInfoRow(
            'المبلغ',
            '${payment.amount.toStringAsFixed(2)} ر.س',
            AppIcons.money,
          ),
          _buildInfoRow(
            'طريقة الدفع',
            AppStrings.getPaymentMethodText(payment.paymentMethod),
            _getPaymentMethodIcon(payment.paymentMethod),
          ),
          _buildInfoRow(
            'تاريخ الدفعة',
            AppConstants.formatDate(payment.paymentDate),
            AppIcons.calendar,
          ),
          _buildInfoRow(
            'تاريخ الإنشاء',
            AppConstants.formatDateTime(payment.createdAt),
            AppIcons.time,
          ),
          if (payment.updatedAt != payment.createdAt)
            _buildInfoRow(
              'آخر تحديث',
              AppConstants.formatDateTime(payment.updatedAt),
              AppIcons.edit,
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard(Payment payment) {
    return GetBuilder<PaymentsController>(
      builder: (controller) {
        final customer = controller.customers.firstWhereOrNull(
          (c) => c.id == payment.customerId,
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
              _buildInfoRow(
                'اسم العميل',
                customer.name,
                AppIcons.customers,
                onTap: () => _navigateToCustomerDetails(customer.id),
              ),
              _buildInfoRow(
                'رقم الهاتف',
                'غير محدد',
                AppIcons.phone,
                onTap: null,
              ),
              _buildInfoRow(
                'الرصيد الحالي',
                '${customer.currentBalance.toStringAsFixed(2)} ر.س',
                AppIcons.money,
                valueColor: customer.currentBalance > 0
                    ? AppColors.warning
                    : AppColors.success,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLinkedDebtCard(Payment payment) {
    return GetBuilder<PaymentsController>(
      builder: (controller) {
        final debt = controller.debts.firstWhereOrNull(
          (d) => d.id == payment.debtId,
        );

        if (debt == null) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.cardDecoration.copyWith(
              color: AppColors.warning.withValues(alpha: 0.1),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.warning,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 12),
                Text(
                  'الدين المرتبط غير موجود أو تم حذفه',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          );
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
                    'الدين المرتبط',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CustomButton(
                    text: 'عرض التفاصيل',
                    onPressed: () => _navigateToDebtDetails(debt.id),
                    type: ButtonType.outlined,
                    size: ButtonSize.small,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'وصف الدين',
                debt.description ?? 'لا يوجد وصف',
                AppIcons.debts,
                onTap: () => _navigateToDebtDetails(debt.id),
              ),
              _buildInfoRow(
                'المبلغ الإجمالي',
                '${debt.amount.toStringAsFixed(2)} ر.س',
                AppIcons.money,
              ),
              _buildInfoRow(
                'المبلغ المدفوع',
                '${debt.paidAmount.toStringAsFixed(2)} ر.س',
                AppIcons.success,
                valueColor: AppColors.success,
              ),
              _buildInfoRow(
                'المبلغ المتبقي',
                '${debt.remainingAmount.toStringAsFixed(2)} ر.س',
                AppIcons.warning,
                valueColor: debt.remainingAmount > 0
                    ? AppColors.warning
                    : AppColors.success,
              ),
              _buildInfoRow(
                'حالة الدين',
                AppStrings.getStatusText(debt.status),
                AppIcons.info,
                valueColor: _getStatusColor(debt.status),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(Payment payment) {
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
              Expanded(
                child: CustomButton(
                  text: 'طباعة الإيصال',
                  onPressed: () => _printReceipt(payment.id),
                  type: ButtonType.primary,
                  icon: AppIcons.print,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'تعديل الدفعة',
                  onPressed: () => _editPayment(payment.id),
                  type: ButtonType.outlined,
                  icon: AppIcons.edit,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'نسخ التفاصيل',
                  onPressed: () => _copyPaymentDetails(payment),
                  type: ButtonType.outlined,
                  icon: AppIcons.copy,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'مشاركة الإيصال',
                  onPressed: () => _shareReceipt(payment),
                  type: ButtonType.outlined,
                  icon: AppIcons.share,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(Payment payment) {
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              payment.notes!,
              style: AppTextStyles.bodyMedium,
            ),
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
                Icon(
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

  Widget _buildFloatingActionButton(String paymentId) {
    return FloatingActionButton.extended(
      heroTag: "payment_details_fab", // إضافة heroTag فريد
      onPressed: () => _printReceipt(paymentId),
      icon: const Icon(AppIcons.print),
      label: const Text('طباعة الإيصال'),
      backgroundColor: AppColors.success,
    );
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'cash':
        return AppIcons.money;
      case 'card':
        return AppIcons.card;
      case 'bank':
        return AppIcons.bank;
      default:
        return AppIcons.other;
    }
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

  void _handleMenuAction(String action, String paymentId) {
    switch (action) {
      case 'edit':
        _editPayment(paymentId);
        break;
      case 'copy':
        final payment = controller.getPaymentById(paymentId);
        if (payment != null) {
          _copyPaymentDetails(payment);
        }
        break;
      case 'delete':
        _deletePayment(paymentId);
        break;
    }
  }

  void _editPayment(String paymentId) {
    Get.toNamed('/edit-payment', arguments: {'paymentId': paymentId});
  }

  void _deletePayment(String paymentId) {
    DeleteConfirmationDialog.show(
      context: Get.context!,
      title: 'حذف الدفعة',
      message:
          'هل أنت متأكد من حذف هذه الدفعة؟ سيتم تحديث الدين المرتبط تلقائياً.',
    ).then((confirmed) {
      if (confirmed == true) {
        controller.deletePayment(paymentId).then((success) {
          if (success) {
            Get.back(); // العودة لقائمة المدفوعات
          }
        });
      }
    });
  }

  void _printReceipt(String paymentId) {
    // هنا يمكن إضافة وظيفة الطباعة الفعلية
    Get.snackbar(
      'طباعة الإيصال',
      'سيتم إضافة وظيفة الطباعة قريباً',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  void _copyPaymentDetails(Payment payment) {
    final customerName = controller.getCustomerName(payment.customerId);
    final debtDescription = controller.getDebtDescription(payment.debtId);

    final details = '''
إيصال دفع
رقم الإيصال: ${payment.id.substring(0, 8).toUpperCase()}
العميل: $customerName
المبلغ: ${payment.amount.toStringAsFixed(2)} ر.س
طريقة الدفع: ${AppStrings.getPaymentMethodText(payment.paymentMethod)}
التاريخ: ${AppConstants.formatDate(payment.paymentDate)}
الدين: $debtDescription
${payment.notes != null ? 'ملاحظات: ${payment.notes}' : ''}
    '''
        .trim();

    _copyToClipboard(details, 'تم نسخ تفاصيل الدفعة');
  }

  void _shareReceipt(Payment payment) {
    // هنا يمكن إضافة وظيفة المشاركة الفعلية
    Get.snackbar(
      'مشاركة الإيصال',
      'سيتم إضافة وظيفة المشاركة قريباً',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'تم النسخ',
      message,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  void _navigateToCustomerDetails(String customerId) {
    Get.toNamed('/customer-details', arguments: {'customerId': customerId});
  }

  void _navigateToDebtDetails(String debtId) {
    Get.toNamed('/debt-details', arguments: {'debtId': debtId});
  }
}
