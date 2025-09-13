import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/customer.dart';
import '../controllers/customers_controller.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/offline_action_wrapper.dart';
import '../../../widgets/loading_widget.dart';

/// شاشة تعديل بيانات العميل
class EditCustomerScreen extends GetView<CustomersController> {
  const EditCustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customer = Get.arguments as Customer?;

    if (customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: const Center(
          child: Text('بيانات العميل غير صحيحة'),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(customer),
      body: _buildBody(customer),
    );
  }

  PreferredSizeWidget _buildAppBar(Customer customer) {
    return AppBar(
      title: Text('تعديل ${customer.name}'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _showDeleteConfirmation(customer),
          tooltip: 'حذف العميل',
        ),
      ],
    );
  }

  Widget _buildBody(Customer customer) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingWidget(
          type: LoadingType.circular,
          size: LoadingSize.large,
          message: 'جاري الحفظ...',
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: EditCustomerForm(customer: customer),
      );
    });
  }

  void _showDeleteConfirmation(Customer customer) {
    Get.dialog(
      AlertDialog(
        title: const Text('حذف العميل'),
        content: Text(
            'هل أنت متأكد من حذف العميل "${customer.name}"؟\nلا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // إغلاق الحوار
              controller.deleteCustomer(customer.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

/// نموذج تعديل العميل
class EditCustomerForm extends StatefulWidget {
  final Customer customer;

  const EditCustomerForm({
    super.key,
    required this.customer,
  });

  @override
  State<EditCustomerForm> createState() => _EditCustomerFormState();
}

class _EditCustomerFormState extends State<EditCustomerForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _creditLimitController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // تهيئة المتحكمات بالقيم الحالية
    _nameController = TextEditingController(text: widget.customer.name);
    _creditLimitController =
        TextEditingController(text: widget.customer.creditLimit.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // بطاقة معلومات العميل الحالية
          _buildCustomerInfoCard(),

          const SizedBox(height: 24),

          // المعلومات الأساسية
          _buildBasicInfoSection(),

          const SizedBox(height: 24),

          // معلومات الاتصال
          _buildContactInfoSection(),

          const SizedBox(height: 24),

          // الحد الائتماني
          _buildCreditLimitSection(),

          const SizedBox(height: 32),

          // أزرار الحفظ والإلغاء
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration.copyWith(
        color: AppColors.primary.withValues(alpha: 0.1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,
            child: Text(
              widget.customer.name.isNotEmpty
                  ? widget.customer.name[0].toUpperCase()
                  : 'ع',
              style: AppTextStyles.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.customer.name,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'لا يوجد رقم هاتف',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.customer.isActive
                        ? AppColors.success
                        : AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.customer.isActive ? 'نشط' : 'غير نشط',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'الرصيد الحالي',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              Text(
                '${widget.customer.currentBalance.toStringAsFixed(0)} ر.س',
                style: AppTextStyles.titleMedium.copyWith(
                  color: widget.customer.currentBalance > 0
                      ? AppColors.error
                      : AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المعلومات الأساسية',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _nameController,
            label: 'اسم العميل',
            hint: 'أدخل اسم العميل الكامل',
            prefixIcon: AppIcons.person,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'اسم العميل مطلوب';
              }
              if (value.trim().length < 2) {
                return 'اسم العميل يجب أن يكون أكثر من حرفين';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _usernameController,
            label: 'اسم المستخدم',
            hint: 'أدخل اسم المستخدم للدخول',
            prefixIcon: AppIcons.person,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'اسم المستخدم مطلوب';
              }
              if (value.trim().length < 3) {
                return 'اسم المستخدم يجب أن يكون أكثر من 3 أحرف';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات الاتصال',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _phoneController,
            label: 'رقم الهاتف',
            hint: 'أدخل رقم الهاتف (اختياري)',
            prefixIcon: AppIcons.phone,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildCreditLimitSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الحد الائتماني',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _creditLimitController,
            label: 'الحد الائتماني (ر.س)',
            hint: 'أدخل الحد الائتماني للعميل',
            prefixIcon: AppIcons.money,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الحد الائتماني مطلوب';
              }
              final limit = double.tryParse(value);
              if (limit == null || limit < 0) {
                return 'أدخل حد ائتماني صحيح';
              }
              return null;
            },
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
            text: 'إلغاء',
            onPressed: () => Get.back(),
            type: ButtonType.outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OfflineActionButton(
            action: 'edit_customers',
            text: 'حفظ التغييرات',
            onPressed: _isLoading ? null : _saveChanges,
            icon: AppIcons.confirm,
          ),
        ),
      ],
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final controller = Get.find<CustomersController>();

      // إنشاء العميل المحدث
      final updatedCustomer = widget.customer.copyWith(
        name: _nameController.text.trim(),
        creditLimit: double.parse(_creditLimitController.text),
        updatedAt: DateTime.now(),
      );

      // حفظ التغييرات باستخدام الـ Controller
      final success = await controller.updateCustomer(updatedCustomer);

      if (success) {
        // العودة للشاشة السابقة
        Get.back();
      }
    } catch (e) {
      Get.snackbar(
        'خطأ ❌',
        'فشل في حفظ التغييرات: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
