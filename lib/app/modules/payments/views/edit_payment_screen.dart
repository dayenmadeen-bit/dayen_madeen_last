import 'package:flutter/material.dart';
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
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/offline_action_wrapper.dart';
import '../../../widgets/error_widget.dart';
import '../controllers/payments_controller.dart';

/// شاشة تعديل الدفعة مع التحقق من الصحة
class EditPaymentScreen extends GetView<PaymentsController> {
  const EditPaymentScreen({super.key});

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
      appBar: AppBar(
        title: const Text(AppStrings.editPayment),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _handleBackPress(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: EditPaymentForm(paymentId: paymentId),
      ),
    );
  }

  void _handleBackPress() {
    CancelConfirmationDialog.show(
      context: Get.context!,
      message:
          'هل أنت متأكد من إلغاء تعديل الدفعة؟ ستفقد جميع التغييرات غير المحفوظة.',
    ).then((confirmed) {
      if (confirmed == true) {
        Get.back();
      }
    });
  }
}

class EditPaymentForm extends StatefulWidget {
  final String paymentId;

  const EditPaymentForm({
    super.key,
    required this.paymentId,
  });

  @override
  State<EditPaymentForm> createState() => _EditPaymentFormState();
}

class _EditPaymentFormState extends State<EditPaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCustomerId;
  String? _selectedDebtId;
  String _selectedPaymentMethod = AppConstants.paymentMethodCash;
  DateTime _selectedPaymentDate = DateTime.now();
  bool _isLoading = false;
  Payment? _originalPayment;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentData();
  }

  void _loadPaymentData() {
    final payment =
        Get.find<PaymentsController>().getPaymentById(widget.paymentId);
    if (payment != null) {
      _originalPayment = payment;
      _amountController.text = payment.amount.toString();
      _notesController.text = payment.notes ?? '';
      _selectedCustomerId = payment.customerId;
      _selectedDebtId = payment.debtId;
      _selectedPaymentMethod = payment.paymentMethod;
      _selectedPaymentDate = payment.paymentDate;

      // مراقبة التغييرات
      _amountController.addListener(_checkForChanges);
      _notesController.addListener(_checkForChanges);
    }
  }

  void _checkForChanges() {
    if (_originalPayment == null) return;

    final hasChanges =
        _amountController.text != _originalPayment!.amount.toString() ||
            _notesController.text != (_originalPayment!.notes ?? '') ||
            _selectedCustomerId != _originalPayment!.customerId ||
            _selectedDebtId != _originalPayment!.debtId ||
            _selectedPaymentMethod != _originalPayment!.paymentMethod ||
            _selectedPaymentDate != _originalPayment!.paymentDate;

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_originalPayment == null) {
      return const SimpleErrorWidget(
        message: 'الدفعة غير موجودة أو تم حذفها',
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // تحذير حول تعديل الدفعة
          _buildEditWarning(),

          // معلومات الدفعة الأساسية
          _buildSectionTitle('معلومات الدفعة'),
          const SizedBox(height: 16),

          // اختيار العميل
          _buildCustomerSelector(),

          const SizedBox(height: 16),

          // اختيار الدين (اختياري)
          _buildDebtSelector(),

          const SizedBox(height: 16),

          // مبلغ الدفعة
          AmountTextField(
            controller: _amountController,
            label: AppStrings.paymentAmount,
            hint: 'أدخل مبلغ الدفعة',
            validator: _validateAmount,
          ),

          const SizedBox(height: 24),

          // تفاصيل الدفعة
          _buildSectionTitle('تفاصيل الدفعة'),
          const SizedBox(height: 16),

          // طريقة الدفع
          _buildPaymentMethodSelector(),

          const SizedBox(height: 16),

          // تاريخ الدفعة
          _buildPaymentDateSelector(),

          const SizedBox(height: 16),

          // ملاحظات إضافية
          CustomTextField(
            controller: _notesController,
            label: 'ملاحظات إضافية',
            hint: 'أدخل أي ملاحظات حول الدفعة (اختياري)',
            prefixIcon: AppIcons.notes,
            maxLines: 3,
            maxLength: AppConstants.maxNotesLength,
            textInputAction: TextInputAction.done,
          ),

          const SizedBox(height: 24),

          // معلومات الدين المحدد
          _buildDebtInfo(),

          const SizedBox(height: 24),

          // معلومات التغييرات
          if (_hasChanges) _buildChangesInfo(),

          const SizedBox(height: 32),

          // أزرار الحفظ والإلغاء
          Row(
            children: [
              Expanded(
                child: CancelButton(
                  onPressed: () => _handleCancel(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OfflineActionButton(
                  action: 'edit_payments',
                  text: 'حفظ',
                  onPressed: _hasChanges && !_isLoading ? _saveChanges : null,
                  icon: AppIcons.confirm,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEditWarning() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDecorations.radiusLarge),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.warning,
            color: AppColors.warning,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تحذير: تعديل الدفعة',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'تعديل الدفعة سيؤثر على حالة الدين المرتبط ورصيد العميل. تأكد من صحة البيانات.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCustomerSelector() {
    return GetBuilder<PaymentsController>(
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'العميل *',
              style: AppTextStyles.labelMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCustomerId,
              decoration: AppDecorations.getInputDecoration(
                label: 'العميل',
                hint: 'اختر العميل',
                prefixIcon: AppIcons.customers,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يجب اختيار العميل';
                }
                return null;
              },
              items: controller.customers.map((customer) {
                return DropdownMenuItem<String>(
                  value: customer.id,
                  child: Text(customer.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCustomerId = value;
                  // إعادة تعيين الدين المحدد إذا تغير العميل
                  if (_selectedDebtId != null) {
                    final debt = controller.debts.firstWhereOrNull(
                      (d) => d.id == _selectedDebtId,
                    );
                    if (debt != null && debt.customerId != value) {
                      _selectedDebtId = null;
                    }
                  }
                  _checkForChanges();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDebtSelector() {
    return GetBuilder<PaymentsController>(
      builder: (controller) {
        // فلترة الديون حسب العميل المحدد
        final availableDebts = controller.debts.where((debt) {
          return _selectedCustomerId != null &&
              debt.customerId == _selectedCustomerId &&
              (debt.remainingAmount > 0 || debt.id == _selectedDebtId);
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الدين (اختياري)',
              style: AppTextStyles.labelMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedDebtId,
              decoration: AppDecorations.getInputDecoration(
                label: 'الدين',
                hint: _selectedCustomerId == null
                    ? 'اختر العميل أولاً'
                    : availableDebts.isEmpty
                        ? 'لا توجد ديون متاحة'
                        : 'اختر الدين أو اتركه فارغاً للدفعة المستقلة',
                prefixIcon: AppIcons.debts,
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('دفعة مستقلة (غير مرتبطة بدين)'),
                ),
                ...availableDebts.map((debt) {
                  return DropdownMenuItem<String>(
                    value: debt.id,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          debt.description ?? 'لا يوجد وصف',
                          style: AppTextStyles.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'متبقي: ${debt.remainingAmount.toStringAsFixed(2)} ر.س',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: _selectedCustomerId == null
                  ? null
                  : (value) {
                      setState(() {
                        _selectedDebtId = value;
                        _checkForChanges();
                      });
                    },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طريقة الدفع *',
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedPaymentMethod,
          decoration: AppDecorations.getInputDecoration(
            label: 'طريقة الدفع',
            hint: 'اختر طريقة الدفع',
            prefixIcon: AppIcons.payments,
          ),
          items: const [
            DropdownMenuItem(
              value: 'cash',
              child: Row(
                children: [
                  Icon(AppIcons.money, size: 20),
                  SizedBox(width: 8),
                  Text('نقدي'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'card',
              child: Row(
                children: [
                  Icon(AppIcons.card, size: 20),
                  SizedBox(width: 8),
                  Text('بطاقة ائتمان/خصم'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'bank',
              child: Row(
                children: [
                  Icon(AppIcons.bank, size: 20),
                  SizedBox(width: 8),
                  Text('تحويل بنكي'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'other',
              child: Row(
                children: [
                  Icon(AppIcons.other, size: 20),
                  SizedBox(width: 8),
                  Text('أخرى'),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = value!;
              _checkForChanges();
            });
          },
        ),
      ],
    );
  }

  Widget _buildPaymentDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تاريخ الدفعة *',
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectPaymentDate,
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppConstants.formatDate(_selectedPaymentDate),
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

  Widget _buildDebtInfo() {
    if (_selectedDebtId == null) {
      return const SizedBox.shrink();
    }

    return GetBuilder<PaymentsController>(
      builder: (controller) {
        final debt = controller.debts.firstWhereOrNull(
          (d) => d.id == _selectedDebtId,
        );

        if (debt == null) {
          return const SizedBox.shrink();
        }

        final newAmount = double.tryParse(_amountController.text) ?? 0.0;
        final originalAmount = _originalPayment?.amount ?? 0.0;
        final amountDifference = newAmount - originalAmount;
        final newRemainingAmount = debt.remainingAmount - amountDifference;
        final isOverPayment =
            newAmount > (debt.remainingAmount + originalAmount);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isOverPayment
                ? AppColors.warning.withValues(alpha: 0.1)
                : AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDecorations.radiusLarge),
            border: Border.all(
              color: isOverPayment
                  ? AppColors.warning.withValues(alpha: 0.3)
                  : AppColors.info.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isOverPayment ? AppIcons.warning : AppIcons.info,
                    color: isOverPayment ? AppColors.warning : AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'معلومات الدين',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDebtInfoRow('وصف الدين', debt.description ?? 'لا يوجد وصف'),
              _buildDebtInfoRow(
                  'المبلغ الإجمالي', '${debt.amount.toStringAsFixed(2)} ر.س'),
              _buildDebtInfoRow('المبلغ المدفوع',
                  '${debt.paidAmount.toStringAsFixed(2)} ر.س'),
              _buildDebtInfoRow('المبلغ المتبقي',
                  '${debt.remainingAmount.toStringAsFixed(2)} ر.س'),
              if (amountDifference != 0) ...[
                const Divider(),
                _buildDebtInfoRow(
                  'تغيير المبلغ',
                  '${amountDifference > 0 ? '+' : ''}${amountDifference.toStringAsFixed(2)} ر.س',
                  color: amountDifference > 0
                      ? AppColors.success
                      : AppColors.warning,
                ),
                _buildDebtInfoRow(
                  'المبلغ المتبقي الجديد',
                  '${newRemainingAmount.toStringAsFixed(2)} ر.س',
                  isHighlight: true,
                  color: newRemainingAmount <= 0
                      ? AppColors.success
                      : AppColors.primary,
                ),
                if (newRemainingAmount <= 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.success,
                          color: AppColors.success,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'سيتم إغلاق هذا الدين بالكامل',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
              if (isOverPayment) ...[
                const SizedBox(height: 8),
                Text(
                  '⚠️ تحذير: مبلغ الدفعة أكبر من المبلغ المتبقي للدين',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDebtInfoRow(String label, String value,
      {bool isHighlight = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangesInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDecorations.radiusLarge),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.info,
            color: AppColors.info,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'لديك تغييرات غير محفوظة. اضغط على "حفظ" لحفظ التغييرات.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'مبلغ الدفعة مطلوب';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'مبلغ الدفعة غير صحيح';
    }

    if (amount <= 0) {
      return 'مبلغ الدفعة يجب أن يكون أكبر من صفر';
    }

    if (amount > AppConstants.maxAmount) {
      return 'مبلغ الدفعة كبير جداً';
    }

    return null;
  }

  Future<void> _selectPaymentDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedPaymentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'SA'),
    );

    if (date != null) {
      setState(() {
        _selectedPaymentDate = date;
        _checkForChanges();
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate() || _originalPayment == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedPayment = _originalPayment!.copyWith(
        customerId: _selectedCustomerId!,
        amount: double.parse(_amountController.text),
        paymentMethod: _selectedPaymentMethod,
        paymentDate: _selectedPaymentDate,
        debtId: _selectedDebtId,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        updatedAt: DateTime.now(),
      );

      final success =
          await Get.find<PaymentsController>().updatePayment(updatedPayment);

      if (success) {
        Get.back();
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحديث الدفعة: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleCancel() {
    if (_hasChanges) {
      CancelConfirmationDialog.show(
        context: context,
        message:
            'هل أنت متأكد من إلغاء التعديل؟ ستفقد جميع التغييرات غير المحفوظة.',
      ).then((confirmed) {
        if (confirmed == true) {
          Get.back();
        }
      });
    } else {
      Get.back();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
