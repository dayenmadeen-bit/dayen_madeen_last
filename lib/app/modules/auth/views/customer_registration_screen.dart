import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../controllers/customer_registration_controller.dart';

/// شاشة تسجيل العملاء مع دعم الحسابات المؤقتة والدائمة
class CustomerRegistrationScreen
    extends GetView<CustomerRegistrationController> {
  const CustomerRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() => _buildCurrentStep()),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('إنشاء حساب عميل'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildCurrentStep() {
    switch (controller.currentStep.value) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return _buildStep1();
    }
  }

  /// الخطوة 1: اختيار نوع الحساب
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepHeader(
            step: 1,
            title: 'اختر نوع الحساب',
            subtitle: 'كيف تريد إنشاء حسابك؟',
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppDecorations.cardDecoration,
            child: Column(
              children: [
                // خيار الحساب الجديد
                _buildAccountTypeOption(
                  title: 'إنشاء حساب جديد',
                  subtitle: 'ليس مرتبط بأي محل',
                  icon: Icons.person_add,
                  isSelected: controller.accountType.value == 'new',
                  onTap: () => controller.setAccountType('new'),
                ),
                const SizedBox(height: 16),

                const Divider(),
                const SizedBox(height: 16),

                // خيار الحساب المرتبط
                _buildAccountTypeOption(
                  title: 'حساب مرتبط بمحلات مسبقاً',
                  subtitle: 'لديك رقم مميز من محل سابق',
                  icon: Icons.link,
                  isSelected: controller.accountType.value == 'linked',
                  onTap: () => controller.setAccountType('linked'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildNavigationButtons(
            onNext: controller.nextStep,
            nextText: 'التالي',
            showBack: false,
            isNextEnabled: controller.accountType.value.isNotEmpty,
          ),
        ],
      ),
    );
  }

  /// الخطوة 2: إدخال البيانات
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepHeader(
            step: 2,
            title: 'معلومات الحساب',
            subtitle: 'أدخل بياناتك الشخصية',
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppDecorations.cardDecoration,
            child: Column(
              children: [
                // حقل الرقم المميز (للمرتبط فقط)
                if (controller.accountType.value == 'linked') ...[
                  CustomTextField(
                    controller: controller.uniqueIdController,
                    label: 'الرقم المميز *',
                    hint: 'أدخل الرقم المميز (7 خانات)',
                    prefixIcon: AppIcons.creditCard,
                    keyboardType: TextInputType.number,
                    validator: controller.validateUniqueId,
                  ),
                  const SizedBox(height: 16),
                ],

                CustomTextField(
                  controller: controller.nameController,
                  label: 'الاسم الكامل *',
                  hint: 'أدخل اسمك الكامل',
                  prefixIcon: AppIcons.person,
                  validator: controller.validateName,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: controller.emailController,
                  label: 'البريد الإلكتروني *',
                  hint: 'أدخل البريد الإلكتروني',
                  prefixIcon: AppIcons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: controller.validateEmail,
                ),
                const SizedBox(height: 16),

                Obx(() => CustomTextField(
                      controller: controller.passwordController,
                      label: 'كلمة المرور *',
                      hint: 'أدخل كلمة المرور',
                      prefixIcon: AppIcons.lock,
                      obscureText: controller.isPasswordHidden.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordHidden.value
                              ? AppIcons.visibilityOff
                              : AppIcons.visibility,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                      validator: controller.validatePassword,
                    )),
                const SizedBox(height: 16),

                Obx(() => CustomTextField(
                      controller: controller.confirmPasswordController,
                      label: 'تأكيد كلمة المرور *',
                      hint: 'أعد إدخال كلمة المرور',
                      prefixIcon: AppIcons.lock,
                      obscureText: controller.isConfirmPasswordHidden.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isConfirmPasswordHidden.value
                              ? AppIcons.visibilityOff
                              : AppIcons.visibility,
                        ),
                        onPressed: controller.toggleConfirmPasswordVisibility,
                      ),
                      validator: controller.validateConfirmPassword,
                    )),
                const SizedBox(height: 24),

                _buildPrivacyPolicyCheckbox(),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildNavigationButtons(
            onBack: controller.previousStep,
            onNext: controller.nextStep,
            nextText: 'إنشاء الحساب',
          ),
        ],
      ),
    );
  }

  /// الخطوة 3: تأكيد الحساب والرقم المميز
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepHeader(
            step: 3,
            title: 'تم إنشاء الحساب',
            subtitle: 'احفظ الرقم المميز الخاص بك',
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppDecorations.cardDecoration,
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'تم إنشاء حسابك بنجاح!',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'الرقم المميز الخاص بك:',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Obx(() => Text(
                        controller.generatedUniqueId.value,
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      )),
                ),
                const SizedBox(height: 16),
                Text(
                  'احفظ هذا الرقم أو التقط لقطة شاشة له\nستحتاجه لربط حسابك مع أصحاب المحلات',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.warning,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'تم إرسال رابط التحقق إلى بريدك الإلكتروني',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.info,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildNavigationButtons(
            onNext: controller.completeRegistration,
            nextText: 'متابعة',
            showBack: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTypeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? AppColors.primary : AppColors.textSecondaryLight,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHeader({
    required int step,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$step',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildProgressIndicator(step),
      ],
    );
  }

  Widget _buildProgressIndicator(int currentStep) {
    return Row(
      children: List.generate(3, (index) {
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(
              right: index < 2 ? 8 : 0,
            ),
            decoration: BoxDecoration(
              color: index < currentStep
                  ? AppColors.primary
                  : AppColors.textSecondaryLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPrivacyPolicyCheckbox() {
    return Obx(() => Row(
          children: [
            Checkbox(
              value: controller.acceptPrivacyPolicy.value,
              onChanged: (value) =>
                  controller.acceptPrivacyPolicy.value = value ?? false,
              activeColor: AppColors.primary,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _showTermsDialog(
                  onAgree: () => controller.acceptPrivacyPolicy.value = true,
                ),
                child: Text.rich(
                  TextSpan(
                    text: 'أوافق على ',
                    style: AppTextStyles.bodyMedium,
                    children: [
                      TextSpan(
                        text: 'سياسة الخصوصية',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: ' و '),
                      TextSpan(
                        text: 'شروط الاستخدام',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  void _showTermsDialog({required VoidCallback onAgree}) {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          title: const Text('سياسة الخصوصية وشروط الاستخدام'),
          content: SizedBox(
            width: double.maxFinite,
            height: 320,
            child: ListView(
              children: const [
                Text(
                  '• مقدمة: هذا التطبيق موجَّه للدول العربية لإدارة الديون والمدفوعات بين المالك والزبائن.\n\n'
                  '• جمع البيانات: قد نجمع الاسم، البريد (اختياري)، المعرّف المميز، وبيانات التعاملات.\n\n'
                  '• الاستخدام: تستخدم البيانات لأغراض تشغيل النظام، المزامنة عبر السحابة، والإشعارات.\n\n'
                  '• الحفظ والأمان: يتم حفظ البيانات عبر خدمات Firebase مع طبقات أمان مناسبة.\n\n'
                  '• حقوق المستخدم: لك الحق في تصحيح بياناتك وطلب حذفها وفق الأنظمة المحلية.\n\n'
                  '• القيود: يمنع إساءة الاستخدام أو محاولة الوصول غير المصرح به.\n\n'
                  '• الإشعارات: قد نرسل إشعارات تتعلق بالديون والمدفوعات والتحديثات.\n\n'
                  '• التعديلات: قد نقوم بتعديل الشروط وسنبلغ بالتغييرات الهامة داخل التطبيق.',
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('لا أوافق'),
            ),
            ElevatedButton(
              onPressed: () {
                onAgree();
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavigationButtons({
    VoidCallback? onBack,
    required VoidCallback onNext,
    required String nextText,
    bool showBack = true,
    bool isNextEnabled = true,
  }) {
    return Row(
      children: [
        if (showBack) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: onBack,
              child: const Text('السابق'),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: CustomButton(
            text: nextText,
            onPressed: isNextEnabled ? onNext : null,
            isLoading: controller.isLoading.value,
            icon: AppIcons.confirm,
          ),
        ),
      ],
    );
  }
}
