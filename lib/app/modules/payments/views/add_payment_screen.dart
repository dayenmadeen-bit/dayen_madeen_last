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
import '../controllers/payments_controller.dart';
import '../../../../core/services/auth_service.dart';
import '../../home/controllers/home_controller.dart';
import '../../../../core/services/notification_service.dart';

/// شاشة إضافة دفعة جديدة مع ربطها بالدين
class AddPaymentScreen extends GetView<PaymentsController> {
  const AddPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.addPayment),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _handleBackPress(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: AddPaymentForm(),
      ),
    );
  }

  void _handleBackPress() {
    CancelConfirmationDialog.show(
      context: Get.context!,
      message:
          'هل أنت متأكد من إلغاء إضافة الدفعة؟ ستفقد جميع البيانات المدخلة.',
    ).then((confirmed) {
      if (confirmed == true) {
        Get.back();
      }
    });
  }
}

class AddPaymentForm extends StatefulWidget {
  const AddPaymentForm({super.key});

  @override
  State<AddPaymentForm> createState() => _AddPaymentFormState();
}

class _AddPaymentFormState extends State<AddPaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCustomerId;
  String? _selectedDebtId;
  String _selectedPaymentMethod = AppConstants.paymentMethodCash;
  DateTime _selectedPaymentDate = DateTime.now();
  bool _isLoading = false;

  // معرف الدين المرسل من الشاشة السابقة (إن وجد)
  String? _preselectedDebtId;

  @override
  void initState() {
    super.initState();
    _preselectedDebtId = Get.arguments?['debtId'] as String?;
    _initializeData();
  }

  void _initializeData() {
    // تحميل البيانات إذا لم تكن محملة
    if (Get.find<PaymentsController>().customers.isEmpty) {
      Get.find<PaymentsController>().loadCustomers();
    }
    if (Get.find<PaymentsController>().debts.isEmpty) {
      Get.find<PaymentsController>().loadDebts();
    }

    // إذا كان هناك دين محدد مسبقاً
    if (_preselectedDebtId != null) {
      _selectedDebtId = _preselectedDebtId;
      final debt = Get.find<PaymentsController>().debts.firstWhereOrNull(
            (d) => d.id == _preselectedDebtId,
          );
      if (debt != null) {
        _selectedCustomerId = debt.customerId;
        _amountController.text = debt.remainingAmount.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                  action: 'add_payments',
                  text: 'حفظ',
                  onPressed: _isLoading ? null : _savePayment,
                  isLoading: _isLoading,
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
        if (controller.customers.isEmpty) {
          return Container(
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
                        'لا يوجد عملاء',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'يجب إضافة عميل أولاً قبل تسجيل المدفوعات',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                CustomButton(
                  text: 'إضافة عميل',
                  onPressed: () => Get.toNamed('/add-customer'),
                  type: ButtonType.outlined,
                  size: ButtonSize.small,
                ),
              ],
            ),
          );
        }

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
                      _amountController.clear();
                    }
                  }
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
        // فلترة الديون حسب العميل المحدد والديون غير المدفوعة بالكامل
        final availableDebts = controller.debts.where((debt) {
          return _selectedCustomerId != null &&
              debt.customerId == _selectedCustomerId &&
              debt.remainingAmount > 0;
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
                        // تعبئة المبلغ تلقائياً إذا تم اختيار دين
                        if (value != null) {
                          final debt = controller.debts.firstWhereOrNull(
                            (d) => d.id == value,
                          );
                          if (debt != null) {
                            _amountController.text =
                                debt.remainingAmount.toString();
                          }
                        } else {
                          _amountController.clear();
                        }
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

        final paymentAmount = double.tryParse(_amountController.text) ?? 0.0;
        final isOverPayment = paymentAmount > debt.remainingAmount;
        final newRemainingAmount = debt.remainingAmount - paymentAmount;

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
              if (paymentAmount > 0) ...[
                const Divider(),
                _buildDebtInfoRow(
                  'المبلغ بعد الدفعة',
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
      });
    }
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final payment = Payment.create(
        customerId: _selectedCustomerId!,
        businessOwnerId:
            AuthService.instance.currentUser?.id ?? 'unknown_owner',
        amount: double.parse(_amountController.text),
        paymentMethod: _selectedPaymentMethod,
        paymentDate: _selectedPaymentDate,
        debtId: _selectedDebtId ?? '',
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      final success = await Get.find<PaymentsController>().addPayment(payment);

      if (success) {
        // تحديث الإحصائيات في الصفحة الرئيسية فوراً
        if (Get.isRegistered<BusinessOwnerHomeController>()) {
          await Get.find<BusinessOwnerHomeController>().updateStatistics();
        }

        // إشعار الدفعة الجديدة
        final paymentsController = Get.find<PaymentsController>();
        final customer = paymentsController.customers.firstWhereOrNull(
          (c) => c.id == _selectedCustomerId,
        );
        if (customer != null) {
          await NotificationService.showPaymentNotification(
            customerName: customer.name,
            amount: payment.amount,
            paymentMethod: _selectedPaymentMethod,
            paymentId: payment.id,
          );
        }

        Get.back();
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إضافة الدفعة: ${e.toString()}',
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
    // التحقق من وجود بيانات مدخلة
    final hasData = _amountController.text.isNotEmpty ||
        _notesController.text.isNotEmpty ||
        _selectedCustomerId != null ||
        _selectedDebtId != null ||
        _selectedPaymentMethod != AppConstants.paymentMethodCash ||
        _selectedPaymentDate != DateTime.now();

    if (hasData) {
      CancelConfirmationDialog.show(
        context: context,
        message:
            'هل أنت متأكد من إلغاء إضافة الدفعة؟ ستفقد جميع البيانات المدخلة.',
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
