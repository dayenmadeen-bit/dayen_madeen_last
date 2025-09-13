import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../data/models/customer.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/offline_action_wrapper.dart';
import '../controllers/customers_controller.dart';
import '../../../../core/services/auth_service.dart';

class AddCustomerScreen extends GetView<CustomersController> {
  const AddCustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.addCustomer),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: AddCustomerForm(),
      ),
    );
  }
}

class AddCustomerForm extends StatefulWidget {
  const AddCustomerForm({super.key});

  @override
  State<AddCustomerForm> createState() => _AddCustomerFormState();
}

class _AddCustomerFormState extends State<AddCustomerForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _uniqueIdController = TextEditingController();

  // نوع إنشاء العميل
  bool _isPreExistingAccount = false; // عميل بحساب مسبق أم عميل جديد

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // تعيين حد ائتمان افتراضي
    _creditLimitController.text = '1000.00';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // نوع العميل
          _buildSectionTitle('نوع العميل'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  value: false,
                  groupValue: _isPreExistingAccount,
                  onChanged: (v) =>
                      setState(() => _isPreExistingAccount = v ?? false),
                  title: const Text('عميل جديد'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  value: true,
                  groupValue: _isPreExistingAccount,
                  onChanged: (v) =>
                      setState(() => _isPreExistingAccount = v ?? false),
                  title: const Text('عميل بحساب مسبق'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),

          // معلومات العميل الأساسية
          _buildSectionTitle('معلومات العميل'),
          const SizedBox(height: 16),

          if (_isPreExistingAccount) ...[
            CustomTextField(
              controller: _uniqueIdController,
              label: 'الرقم المميز للعميل *',
              hint: 'أدخل الرقم المميز (7 خانات)',
              prefixIcon: Icons.confirmation_number,
              keyboardType: TextInputType.number,
              validator: _validateUniqueId,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
          ],

          CustomTextField(
            controller: _nameController,
            label: 'اسم العميل *',
            hint: 'أدخل اسم العميل الكامل',
            prefixIcon: AppIcons.profile,
            validator: _validateName,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 16),

          CustomTextField(
            controller: _emailController,
            label: 'البريد الإلكتروني',
            hint: 'أدخل البريد الإلكتروني (اختياري)',
            prefixIcon: AppIcons.email,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 16),

          CustomTextField(
            controller: _addressController,
            label: 'العنوان',
            hint: 'أدخل عنوان العميل (اختياري)',
            prefixIcon: AppIcons.location,
            maxLines: 2,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 24),

          // الإعدادات المالية
          _buildSectionTitle('الإعدادات المالية'),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _creditLimitController,
            label: 'حد الائتمان (ر.س) *',
            hint: 'أدخل حد الائتمان',
            prefixIcon: AppIcons.money,
            keyboardType: TextInputType.number,
            validator: _validateCreditLimit,
          ),

          const SizedBox(height: 8),

          Text(
            'حد الائتمان هو أقصى مبلغ يمكن للعميل اقتراضه',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),

          const SizedBox(height: 32),

          // أزرار الحفظ والإلغاء
          Row(
            children: [
              Expanded(
                child: CancelButton(
                  onPressed: () => Get.back(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OfflineActionButton(
                  action: 'add_customers',
                  text: 'حفظ',
                  onPressed: _isLoading ? null : _saveCustomer,
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
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'اسم العميل مطلوب';
    }
    if (value.trim().length < 2) {
      return 'اسم العميل قصير جداً';
    }
    return null;
  }

  String? _validateUniqueId(String? value) {
    if (!_isPreExistingAccount) return null;
    final v = value?.trim() ?? '';
    if (v.length != 7 || int.tryParse(v) == null) {
      return 'الرقم المميز غير صالح (7 خانات رقمية)';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // البريد الإلكتروني اختياري
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  String? _validateCreditLimit(String? value) {
    if (value == null || value.isEmpty) {
      return 'حد الائتمان مطلوب';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'حد الائتمان غير صحيح';
    }

    if (amount < 0) {
      return 'حد الائتمان لا يمكن أن يكون سالباً';
    }

    if (amount > 100000) {
      return 'حد الائتمان مرتفع جداً';
    }

    return null;
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // إنشاء العميل حسب السيناريو
      final isTemp = !_isPreExistingAccount;
      final uniqueId = _isPreExistingAccount
          ? _uniqueIdController.text.trim()
          : _generateUniqueId();

      final customer = Customer.create(
        businessOwnerId:
            AuthService.instance.currentUser?.id ?? 'unknown_owner',
        name: _nameController.text.trim(),
        uniqueId: uniqueId,
        password: _passwordController.text.trim().isEmpty
            ? '123456'
            : _passwordController.text.trim(),
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        creditLimit: double.parse(_creditLimitController.text),
        isTemporary: isTemp,
      );

      // حفظ العميل باستخدام الـ Controller
      final controller = Get.find<CustomersController>();
      final success = await controller.addNewCustomer(customer);

      if (!success) {
        return; // الـ Controller سيعرض رسالة الخطأ
      }

      // العودة للشاشة السابقة (الـ Controller سيعرض رسالة النجاح)
      Get.back();
    } catch (e) {
      // إظهار رسالة خطأ
      Get.snackbar(
        'خطأ',
        'فشل في إضافة العميل: ${e.toString()}',
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

  // توليد رقم مميز للعميل
  String _generateUniqueId() {
    final now = DateTime.now();
    return now.millisecondsSinceEpoch.toString().substring(8);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }
}
