import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/client_constants.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../controllers/customer_app_controller.dart';

/// شاشة طلب دين جديد - الزبون
class RequestDebtScreen extends GetView<ClientAppController> {
  const RequestDebtScreen({super.key});

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
        'طلب دين جديد',
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
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildRequestForm(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.info,
            color: AppColors.info,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'معلومات مهمة',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'سيتم إرسال طلبك إلى مالك المنشأة للمراجعة والموافقة. ستحصل على إشعار عند اتخاذ قرار بشأن طلبك.',
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

  Widget _buildRequestForm() {
    return RequestDebtForm();
  }
}

/// نموذج طلب الدين
class RequestDebtForm extends StatefulWidget {
  @override
  State<RequestDebtForm> createState() => _RequestDebtFormState();
}

class _RequestDebtFormState extends State<RequestDebtForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
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
            'تفاصيل الطلب',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // مبلغ الدين
          CustomTextField(
            controller: _amountController,
            label: 'مبلغ الدين المطلوب (ر.س)',
            hint: 'أدخل المبلغ المطلوب',
            prefixIcon: AppIcons.money,
            keyboardType: TextInputType.number,
            validator: ClientConstants.validateAmount,
          ),
          
          const SizedBox(height: 20),
          
          // وصف الطلب
          CustomTextField(
            controller: _descriptionController,
            label: 'وصف الطلب',
            hint: 'اكتب سبب طلب الدين (مثال: شراء مواد غذائية)',
            prefixIcon: AppIcons.description,
            maxLines: 4,
            validator: ClientConstants.validateDescription,
          ),
          
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
                  text: 'إرسال الطلب',
                  onPressed: _isLoading ? null : _submitRequest,
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

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final controller = Get.find<ClientAppController>();
      
      // إرسال طلب الدين
      await controller.requestDebt(
        amount: double.parse(_amountController.text),
        description: _descriptionController.text.trim(),
      );

      // إظهار رسالة نجاح
      Get.snackbar(
        'تم الإرسال ✅',
        'تم إرسال طلب الدين بنجاح. ستحصل على إشعار عند المراجعة.',
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
}
