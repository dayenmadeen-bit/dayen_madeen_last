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
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/offline_action_wrapper.dart';
import '../../../widgets/error_widget.dart';
import '../controllers/debts_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/services/notification_service.dart';

/// شاشة تعديل الدين مع التحقق من الصحة
class EditDebtScreen extends GetView<DebtsController> {
  const EditDebtScreen({super.key});

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
      appBar: AppBar(
        title: const Text(AppStrings.editDebt),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _handleBackPress(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: EditDebtForm(debtId: debtId),
      ),
    );
  }

  void _handleBackPress() {
    CancelConfirmationDialog.show(
      context: Get.context!,
      message:
          'هل أنت متأكد من إلغاء تعديل الدين؟ ستفقد جميع التغييرات غير المحفوظة.',
    ).then((confirmed) {
      if (confirmed == true) {
        Get.back();
      }
    });
  }
}

class EditDebtForm extends StatefulWidget {
  final String debtId;

  const EditDebtForm({
    super.key,
    required this.debtId,
  });

  @override
  State<EditDebtForm> createState() => _EditDebtFormState();
}

class _EditDebtFormState extends State<EditDebtForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _pickedImage;

  String? _selectedCustomerId;
  DateTime? _selectedDueDate;
  bool _isLoading = false;
  Debt? _originalDebt;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadDebtData();
  }

  void _loadDebtData() {
    final debt = Get.find<DebtsController>().getDebtById(widget.debtId);
    if (debt != null) {
      _originalDebt = debt;
      _amountController.text = debt.amount.toString();
      _descriptionController.text = debt.description ?? '';
      _notesController.text = debt.notes ?? '';
      _selectedCustomerId = debt.customerId;
      _selectedDueDate = debt.dueDate;

      // مراقبة التغييرات
      _amountController.addListener(_checkForChanges);
      _descriptionController.addListener(_checkForChanges);
      _notesController.addListener(_checkForChanges);
    }
  }

  void _checkForChanges() {
    if (_originalDebt == null) return;

    final hasChanges =
        _amountController.text != _originalDebt!.amount.toString() ||
            _descriptionController.text != _originalDebt!.description ||
            _notesController.text != (_originalDebt!.notes ?? '') ||
            _selectedCustomerId != _originalDebt!.customerId ||
            _selectedDueDate != _originalDebt!.dueDate ||
            _pickedImage != null; // إضافة تغيير الصورة

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_originalDebt == null) {
      return const SimpleErrorWidget(
        message: 'الدين غير موجود أو تم حذفه',
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // تحذير إذا كان الدين مدفوع جزئياً
          if (_originalDebt!.paidAmount > 0) _buildPaymentWarning(),

          // معلومات الدين الأساسية
          _buildSectionTitle('معلومات الدين'),
          const SizedBox(height: 16),

          // اختيار العميل
          _buildCustomerSelector(),

          const SizedBox(height: 16),

          // مبلغ الدين
          AmountTextField(
            controller: _amountController,
            label: AppStrings.debtAmount,
            hint: 'أدخل مبلغ الدين',
            validator: _validateAmount,
          ),

          const SizedBox(height: 16),

          // وصف الدين
          CustomTextField(
            controller: _descriptionController,
            label: AppStrings.debtDescription,
            hint: 'أدخل وصف الدين (أو ارفق صورة)',
            prefixIcon: AppIcons.description,
            maxLines: 3,
            maxLength: AppConstants.maxDescriptionLength,
            validator: _validateDescription,
            textInputAction: TextInputAction.done,
          ),

          const SizedBox(height: 24),

          // إرفاق صورة (اختياري)
          _buildImageAttachment(),

          const SizedBox(height: 24),

          // تفاصيل إضافية
          _buildSectionTitle('تفاصيل إضافية'),
          const SizedBox(height: 16),

          // تاريخ الاستحقاق
          _buildDueDateSelector(),

          const SizedBox(height: 16),

          // ملاحظات إضافية
          CustomTextField(
            controller: _notesController,
            label: 'ملاحظات إضافية',
            hint: 'أدخل أي ملاحظات إضافية (اختياري)',
            prefixIcon: AppIcons.notes,
            maxLines: 3,
            maxLength: AppConstants.maxNotesLength,
            textInputAction: TextInputAction.done,
          ),

          const SizedBox(height: 24),

          // معلومات العميل المحدد
          _buildCustomerInfo(),

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
                  action: 'edit_debts',
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

  Widget _buildPaymentWarning() {
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
                  'تحذير: دين مدفوع جزئياً',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'تم دفع ${_originalDebt!.paidAmount.toStringAsFixed(2)} ر.س من هذا الدين. تعديل المبلغ قد يؤثر على الحسابات.',
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
    return GetBuilder<DebtsController>(
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
                  _checkForChanges();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDueDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تاريخ الاستحقاق (اختياري)',
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDueDate,
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
                    _selectedDueDate != null
                        ? AppConstants.formatDate(_selectedDueDate!)
                        : 'اختر تاريخ الاستحقاق',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _selectedDueDate != null
                          ? AppColors.textPrimaryLight
                          : AppColors.textHintLight,
                    ),
                  ),
                ),
                if (_selectedDueDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _selectedDueDate = null;
                        _checkForChanges();
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfo() {
    if (_selectedCustomerId == null) {
      return const SizedBox.shrink();
    }

    return GetBuilder<DebtsController>(
      builder: (controller) {
        final customer = controller.customers.firstWhereOrNull(
          (c) => c.id == _selectedCustomerId,
        );

        if (customer == null) {
          return const SizedBox.shrink();
        }

        final newAmount = double.tryParse(_amountController.text) ?? 0.0;
        final originalAmount = _originalDebt?.amount ?? 0.0;
        final amountDifference = newAmount - originalAmount;
        final newBalance = customer.currentBalance + amountDifference;
        final isOverLimit = newBalance > customer.creditLimit;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isOverLimit
                ? AppColors.error.withValues(alpha: 0.1)
                : AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDecorations.radiusLarge),
            border: Border.all(
              color: isOverLimit
                  ? AppColors.error.withValues(alpha: 0.3)
                  : AppColors.info.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isOverLimit ? AppIcons.warning : AppIcons.info,
                    color: isOverLimit ? AppColors.error : AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'معلومات العميل',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildCustomerInfoRow('الرصيد الحالي',
                  '${customer.currentBalance.toStringAsFixed(2)} ر.س'),
              _buildCustomerInfoRow('حد الائتمان',
                  '${customer.creditLimit.toStringAsFixed(2)} ر.س'),
              if (amountDifference != 0) ...[
                const Divider(),
                _buildCustomerInfoRow(
                  'تغيير المبلغ',
                  '${amountDifference > 0 ? '+' : ''}${amountDifference.toStringAsFixed(2)} ر.س',
                  color: amountDifference > 0
                      ? AppColors.warning
                      : AppColors.success,
                ),
                _buildCustomerInfoRow(
                  'الرصيد الجديد',
                  '${newBalance.toStringAsFixed(2)} ر.س',
                  isHighlight: true,
                  color: isOverLimit ? AppColors.error : AppColors.success,
                ),
              ],
              if (isOverLimit) ...[
                const SizedBox(height: 8),
                Text(
                  '⚠️ تحذير: هذا التعديل يتجاوز حد الائتمان للعميل',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
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

  Widget _buildCustomerInfoRow(String label, String value,
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
      return 'مبلغ الدين مطلوب';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'مبلغ الدين غير صحيح';
    }

    if (amount <= 0) {
      return 'مبلغ الدين يجب أن يكون أكبر من صفر';
    }

    if (amount > AppConstants.maxAmount) {
      return 'مبلغ الدين كبير جداً';
    }

    // التحقق من المدفوعات الموجودة
    if (_originalDebt != null && amount < _originalDebt!.paidAmount) {
      return 'لا يمكن أن يكون المبلغ أقل من المبلغ المدفوع (${_originalDebt!.paidAmount.toStringAsFixed(2)} ر.س)';
    }

    return null;
  }

  String? _validateDescription(String? value) {
    // إذا لا توجد صورة، يصبح الوصف مطلوباً
    if (_pickedImage == null) {
      if (value == null || value.trim().isEmpty) {
        return 'وصف الدين مطلوب في حال عدم إرفاق صورة';
      }
      if (value.trim().length < 3) {
        return 'وصف الدين قصير جداً';
      }
    }
    return null;
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _selectedDueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar', 'SA'),
    );

    if (date != null) {
      setState(() {
        _selectedDueDate = date;
        _checkForChanges();
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate() || _originalDebt == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedDebt = _originalDebt!.copyWith(
        customerId: _selectedCustomerId!,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text.trim(),
        dueDate: _selectedDueDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        updatedAt: DateTime.now(),
      );

      final success = await Get.find<DebtsController>().updateDebt(updatedDebt);

      if (success) {
        // إشعار تعديل الدين
        await NotificationService.showNotification(
          title: 'تم تعديل الدين',
          body:
              'تم تعديل دين بقيمة ${updatedDebt.amount.toStringAsFixed(2)} ر.س',
          type: 'debt',
        );
        Get.back();
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحديث الدين: ${e.toString()}',
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

  Widget _buildImageAttachment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'صورة مرفقة (اختياري)',
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(AppIcons.image),
              label: const Text('اختيار صورة'),
            ),
            const SizedBox(width: 12),
            if (_pickedImage != null)
              Expanded(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_pickedImage!.path),
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'إزالة الصورة',
                      onPressed: () {
                        setState(() {
                          _pickedImage = null;
                          _checkForChanges();
                        });
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final xfile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (xfile != null) {
      setState(() {
        _pickedImage = xfile;
        _checkForChanges();
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
