import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../controllers/customer_app_controller.dart';

/// شاشة طلب سداد - الزبون
class RequestPaymentScreen extends GetView<ClientAppController> {
  const RequestPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'طلب سداد',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBalanceCard(),
          const SizedBox(height: 24),
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildPaymentForm(),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'رصيدك الحالي',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            '${controller.remainingBalance.value.toStringAsFixed(2)} ر.س',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            controller.remainingBalance.value > 0 
                ? 'لديك مبلغ مستحق للسداد'
                : 'لا توجد مبالغ مستحقة',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.success,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'كيفية السداد',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'أدخل المبلغ المراد سداده وأرفق إيصال التحويل. سيتم مراجعة طلبك والموافقة عليه خلال 24 ساعة.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm() {
    return RequestPaymentForm();
  }
}

/// نموذج طلب السداد
class RequestPaymentForm extends StatefulWidget {
  @override
  State<RequestPaymentForm> createState() => _RequestPaymentFormState();
}

class _RequestPaymentFormState extends State<RequestPaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedPaymentMethod = 'bank_transfer';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'value': 'bank_transfer',
      'title': 'تحويل بنكي',
      'icon': Icons.account_balance,
    },
    {
      'value': 'cash',
      'title': 'نقداً',
      'icon': Icons.money,
    },
    {
      'value': 'mobile_payment',
      'title': 'محفظة إلكترونية',
      'icon': Icons.phone_android,
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Text(
            'تفاصيل السداد',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // مبلغ السداد
          CustomTextField(
            controller: _amountController,
            label: 'مبلغ السداد (ر.س)',
            hint: 'أدخل المبلغ المراد سداده',
            prefixIcon: Icons.attach_money,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'مبلغ السداد مطلوب';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'أدخل مبلغ صحيح';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // طريقة الدفع
          Text(
            'طريقة الدفع',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          ..._paymentMethods.map((method) => _buildPaymentMethodTile(method)),
          
          const SizedBox(height: 20),
          
          // ملاحظات
          CustomTextField(
            controller: _notesController,
            label: 'ملاحظات (اختياري)',
            hint: 'أضف أي ملاحظات إضافية',
            prefixIcon: Icons.note,
            maxLines: 3,
          ),
          
          const SizedBox(height: 20),
          
          // رفع إيصال (مستقبلياً)
          _buildAttachmentSection(),
          
          const SizedBox(height: 32),
          
          // أزرار الإجراءات
          Row(
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
                child: CustomButton(
                  text: 'إرسال طلب السداد',
                  onPressed: _isLoading ? null : _submitPaymentRequest,
                  type: ButtonType.primary,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(Map<String, dynamic> method) {
    final isSelected = _selectedPaymentMethod == method['value'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method['value'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              method['icon'],
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                method['title'],
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_file,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'إرفاق إيصال السداد',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'يمكنك إرفاق صورة إيصال التحويل أو السداد لتسريع عملية المراجعة (قريباً)',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: null, // سيتم تفعيله لاحقاً
            icon: const Icon(Icons.camera_alt),
            label: const Text('اختيار صورة'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPaymentRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final controller = Get.find<ClientAppController>();
      
      // إرسال طلب السداد
      await controller.requestPayment(
        amount: double.parse(_amountController.text),
        paymentMethod: _getPaymentMethodText(_selectedPaymentMethod),
        notes: _notesController.text.trim(),
      );

      // إظهار رسالة نجاح
      Get.snackbar(
        'تم الإرسال ✅',
        'تم إرسال طلب السداد بنجاح. ستحصل على إشعار عند المراجعة.',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      // العودة للشاشة السابقة
      Get.back();

    } catch (e) {
      Get.snackbar(
        'خطأ ❌',
        'فشل في إرسال الطلب: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
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

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'bank_transfer':
        return 'تحويل بنكي';
      case 'cash':
        return 'نقداً';
      case 'mobile_payment':
        return 'محفظة إلكترونية';
      default:
        return 'غير محدد';
    }
  }
}
