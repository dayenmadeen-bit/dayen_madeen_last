import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_app_controller.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/utils/validators.dart';

class CustomerProfileScreen extends GetView<ClientAppController> {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final customer = controller.currentClient.value;
        if (customer == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // صورة الملف الشخصي
              _buildProfileHeader(customer),

              const SizedBox(height: 24),

              // الإحصائيات الشخصية
              _buildPersonalStats(),

              const SizedBox(height: 24),

              // الإجراءات
              _buildActions(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(customer) {
    return CustomCard(
      child: Column(
        children: [
          // صورة الملف الشخصي
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  customer.name.isNotEmpty
                      ? customer.name[0].toUpperCase()
                      : 'ع',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    AppIcons.checkCircle,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // اسم العميل
          Text(
            customer.name,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // معرف العميل
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'معرف العميل: ${customer.id.substring(0, 8)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(customer) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات الحساب',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'الاسم الكامل',
            customer.name,
            AppIcons.person,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'البريد الإلكتروني',
            customer.email ?? 'غير محدد',
            AppIcons.email,
            onEdit: customer.email != null
                ? () => _showEditDialog('email', customer.email!)
                : null,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'تعديل كلمة المرور',
            '**********',
            AppIcons.password,
            onEdit: () =>
                _showEditDialog('تعديل كلمة المرور', customer.password ?? ''),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'تاريخ التسجيل',
            controller.formatDate(customer.createdAt),
            AppIcons.calendar,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      {VoidCallback? onEdit}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (onEdit != null)
          IconButton(
            icon: const Icon(
              AppIcons.edit,
              size: 18,
              color: AppColors.primary,
            ),
            onPressed: onEdit,
          ),
      ],
    );
  }

  Widget _buildPersonalStats() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إحصائياتي',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => Column(
                children: [
                  _buildStatRow(
                    'إجمالي الديون',
                    controller.formatAmount(controller.totalDebts.value),
                    AppIcons.debts,
                    AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    'إجمالي المدفوعات',
                    controller.formatAmount(controller.totalPayments.value),
                    AppIcons.payments,
                    AppColors.success,
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    'الرصيد المتبقي',
                    controller.formatAmount(controller.remainingBalance.value),
                    AppIcons.balance,
                    controller.remainingBalance.value > 0
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                  const SizedBox(height: 12),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(context) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: ElevatedButton.icon(
            onPressed: controller.requestStatement,
            icon: const Icon(Icons.description, color: Colors.white),
            label: const Text(
              'طلب كشف حساب',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditDialog(String field, String currentValue) {
    final textController = TextEditingController(text: currentValue);
    String title;
    String hint;
    String? Function(String?)? validator;

    switch (field) {
      case 'email':
        title = 'تعديل البريد الإلكتروني';
        hint = 'أدخل بريدك الإلكتروني';
        validator = Validators.email;
        break;
      case 'password':
        title = 'تعديل كلمة المرور';
        hint = 'أدخل كلمة المرور القديمة';
        validator = Validators.password;
        break;
      default:
        return;
    }

    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: CustomTextField(
          controller: textController,
          label: title,
          labelText: title,
          hintText: hint,
          validator: validator,
          obscureText: field == 'password',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final newValue = textController.text.trim();
              if (newValue != currentValue) {
                _updateField(field, newValue);
              }
              Get.back();
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _updateField(String field, String value) {
    switch (field) {
      case 'name':
        controller.updateProfile(name: value);
        break;
      case 'email':
        controller.updateProfile(email: value.isEmpty ? null : value);
        break;
      case 'address':
        controller.updateProfile(address: value.isEmpty ? null : value);
        break;
    }
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.logout,
              color: AppColors.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('تسجيل الخروج'),
          ],
        ),
        content: Text(
          'هل أنت متأكد من تسجيل الخروج من التطبيق؟\n\nسيتم إنهاء جلستك الحالية والعودة إلى شاشة تسجيل الدخول.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              print('🚪 تأكيد تسجيل الخروج من الملف الشخصي');
              Get.back(); // إغلاق حوار التأكيد

              // عرض مؤشر التحميل
              Get.dialog(
                PopScope(
                  canPop: false, // منع الإغلاق بالضغط على الخلف
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                barrierDismissible: false,
              );

              try {
                // تأخير قصير لإظهار المؤشر
                await Future.delayed(const Duration(milliseconds: 300));

                print('🔄 بدء عملية تسجيل الخروج من الملف الشخصي...');

                // تسجيل الخروج
                await controller.logout();

                print('✅ انتهت عملية تسجيل الخروج من الملف الشخصي');
              } catch (e) {
                print('❌ خطأ في تسجيل الخروج من الملف الشخصي: $e');

                // إغلاق مؤشر التحميل في حالة الخطأ
                if (Get.isDialogOpen == true) {
                  Get.back();
                }

                // الانتقال لتسجيل الدخول كحل طارئ
                Get.offAllNamed('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
