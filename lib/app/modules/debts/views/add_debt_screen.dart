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
import '../../home/controllers/home_controller.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/notification_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../controllers/debts_controller.dart';

/// شاشة إضافة دين جديد مع التحقق من الصحة
class AddDebtScreen extends GetView<DebtsController> {
  const AddDebtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.addDebt),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _handleBackPress(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: AddDebtForm(),
      ),
    );
  }

  void _handleBackPress() {
    // التحقق من وجود تغييرات غير محفوظة
    CancelConfirmationDialog.show(
      context: Get.context!,
      message:
          'هل أنت متأكد من إلغاء إضافة الدين؟ ستفقد جميع البيانات المدخلة.',
    ).then((confirmed) {
      if (confirmed == true) {
        Get.back();
      }
    });
  }
}

class AddDebtForm extends StatefulWidget {
  const AddDebtForm({super.key});

  @override
  State<AddDebtForm> createState() => _AddDebtFormState();
}

class _AddDebtFormState extends State<AddDebtForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _pickedImage;

  String? _selectedCustomerId;
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // تحميل العملاء إذا لم يتم تحميلهم
    if (Get.find<DebtsController>().customers.isEmpty) {
      Get.find<DebtsController>().loadCustomers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
            // مبدئياً مطلوب إذا لم تكن هناك صورة (سيُفعّل لاحقاً عند إضافة التقاط صورة)
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

          // تاريخ الاستحقاق (اختياري)
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
                  action: 'add_debts',
                  text: 'حفظ',
                  onPressed: _isLoading ? null : _saveDebt,
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
    return GetBuilder<DebtsController>(
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
                        'يجب إضافة عميل أولاً قبل تسجيل الديون',
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
      });
    }
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

        final amount = double.tryParse(_amountController.text) ?? 0.0;
        final newBalance = customer.currentBalance + amount;
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
              _buildCustomerInfoRow('الائتمان المتاح',
                  '${customer.availableCredit.toStringAsFixed(2)} ر.س'),
              if (amount > 0) ...[
                const Divider(),
                _buildCustomerInfoRow(
                  'الرصيد بعد الدين',
                  '${newBalance.toStringAsFixed(2)} ر.س',
                  isHighlight: true,
                  color: isOverLimit ? AppColors.error : AppColors.success,
                ),
              ],
              if (isOverLimit) ...[
                const SizedBox(height: 8),
                Text(
                  '⚠️ تحذير: هذا المبلغ يتجاوز حد الائتمان للعميل',
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
      });
    }
  }

  Future<void> _saveDebt() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final debt = Debt.create(
        customerId: _selectedCustomerId!,
        businessOwnerId:
            AuthService.instance.currentUser?.id ?? 'unknown_owner',
        amount: double.parse(_amountController.text),
        description: _descriptionController.text.trim(),
        dueDate: _selectedDueDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      final success = await Get.find<DebtsController>().addDebt(debt);

      if (success) {
        // تحديث الإحصائيات في الصفحة الرئيسية فوراً
        if (Get.isRegistered<BusinessOwnerHomeController>()) {
          await Get.find<BusinessOwnerHomeController>().updateStatistics();
        }

        // إرسال إشعار للعميل بإنشاء الدين
        final debtsController = Get.find<DebtsController>();
        final customer = debtsController.customers
            .firstWhereOrNull((c) => c.id == _selectedCustomerId);
        if (customer != null) {
          await NotificationService.showDebtReminderNotification(
            customerName: customer.name,
            amount: debt.amount,
            dueDate:
                debt.dueDate ?? DateTime.now().add(const Duration(days: 30)),
            debtId: debt.id,
          );
        }

        Get.back();
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إضافة الدين: ${e.toString()}',
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
        _descriptionController.text.isNotEmpty ||
        _notesController.text.isNotEmpty ||
        _selectedCustomerId != null ||
        _selectedDueDate != null;

    if (hasData) {
      CancelConfirmationDialog.show(
        context: context,
        message:
            'هل أنت متأكد من إلغاء إضافة الدين؟ ستفقد جميع البيانات المدخلة.',
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
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
