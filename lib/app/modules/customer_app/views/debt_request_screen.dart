import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../controllers/debt_request_controller.dart';

/// شاشة طلب دين للزبون
class DebtRequestScreen extends GetView<DebtRequestController> {
  const DebtRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('طلب دين'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildForm(),
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        children: [
          Icon(
            Icons.add_circle,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'طلب دين جديد',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'أدخل تفاصيل الأشياء التي تريد شراءها بالدين',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'تفاصيل الطلب',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: controller.itemsController,
            label: 'الأشياء المطلوبة *',
            hint: 'مثال: 2 كيلو أرز، 1 لتر زيت، 3 علب حليب',
            prefixIcon: Icons.shopping_cart,
            maxLines: 3,
            validator: controller.validateItems,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.estimatedAmountController,
            label: 'المبلغ المقدر *',
            hint: 'أدخل المبلغ المقدر بالريال',
            prefixIcon: Icons.attach_money,
            keyboardType: TextInputType.number,
            validator: controller.validateAmount,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.notesController,
            label: 'ملاحظات إضافية',
            hint: 'أي ملاحظات أو تفاصيل إضافية',
            prefixIcon: AppIcons.note,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Obx(() => CustomButton(
                text: 'إرسال الطلب',
                onPressed: controller.isLoading.value
                    ? null
                    : controller.submitRequest,
                isLoading: controller.isLoading.value,
                icon: AppIcons.send,
              )),
        ),
      ],
    );
  }
}


