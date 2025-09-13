import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/announcements_banner.dart';
import '../../../../core/services/announcements_service.dart';
import '../controllers/business_owner_registration_controller.dart';

/// شاشة تسجيل مالك المنشأة متعددة الخطوات
class BusinessOwnerRegistrationScreen
    extends GetView<BusinessOwnerRegistrationController> {
  const BusinessOwnerRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() => _buildCurrentStep()),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('إنشاء حساب مالك منشأة'),
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
      case 3:
        return _buildStep4();
      default:
        return _buildStep1();
    }
  }

  /// الخطوة 1: معلومات المحل
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() {
            final announcements = Get.find<AnnouncementsService>().registration;
            return AnnouncementsBanner(
              announcements: announcements,
            );
          }),
          const SizedBox(height: 16),
          _buildStepHeader(
            step: 1,
            title: 'معلومات المحل',
            subtitle: 'أدخل معلومات المحل الأساسية',
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppDecorations.cardDecoration,
            child: Column(
              children: [
                CustomTextField(
                  controller: controller.businessNameController,
                  label: 'اسم المحل *',
                  hint: 'أدخل اسم المحل',
                  prefixIcon: AppIcons.business,
                  validator: controller.validateBusinessName,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.businessTypeController,
                  label: 'نوع النشاط *',
                  hint: 'مثل: بقالة، مطعم، محل جملة',
                  prefixIcon: AppIcons.category,
                  validator: controller.validateBusinessType,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.businessAddressController,
                  label: 'العنوان',
                  hint: 'عنوان المحل (اختياري)',
                  prefixIcon: AppIcons.location,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                _buildCurrencyDropdown(),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildNavigationButtons(
            onNext: controller.nextStep,
            nextText: 'التالي',
            showBack: false,
          ),
        ],
      ),
    );
  }

  /// الخطوة 2: معلومات المالك
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepHeader(
            step: 2,
            title: 'معلومات المالك',
            subtitle: 'أدخل معلوماتك الشخصية',
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppDecorations.cardDecoration,
            child: Column(
              children: [
                CustomTextField(
                  controller: controller.ownerNameController,
                  label: 'الاسم الكامل *',
                  hint: 'أدخل اسمك الكامل',
                  prefixIcon: AppIcons.person,
                  validator: controller.validateOwnerName,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.ownerEmailController,
                  label: 'البريد الإلكتروني *',
                  hint: 'أدخل البريد الإلكتروني',
                  prefixIcon: AppIcons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: controller.validateEmail,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.bankNameController,
                  label: 'اسم البنك',
                  hint: 'اسم البنك (اختياري)',
                  prefixIcon: AppIcons.creditCard,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.accountNumberController,
                  label: 'رقم الحساب',
                  hint: 'رقم الحساب البنكي (اختياري)',
                  prefixIcon: AppIcons.creditCard,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.phoneNumberController,
                  label: 'رقم الهاتف',
                  hint: 'رقم هاتف المحافظ الإلكترونية (اختياري)',
                  prefixIcon: AppIcons.phone,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildNavigationButtons(
            onBack: controller.previousStep,
            onNext: controller.nextStep,
            nextText: 'التالي',
          ),
        ],
      ),
    );
  }

  /// الخطوة 3: كلمة المرور والموافقة
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepHeader(
            step: 3,
            title: 'كلمة المرور والموافقة',
            subtitle: 'أدخل كلمة المرور ووافق على الشروط',
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppDecorations.cardDecoration,
            child: Column(
              children: [
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

  /// الخطوة 4: تأكيد الحساب والرقم المميز
  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepHeader(
            step: 4,
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
                  'احفظ هذا الرقم أو التقط لقطة شاشة له\nستحتاجه لتسجيل الدخول',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.warning,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // لا تعرض أي نص متعلق بالبريد في صفحة الرقم المميز
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
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
      children: List.generate(4, (index) {
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(
              right: index < 3 ? 8 : 0,
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

  Widget _buildCurrencyDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
          isExpanded: true,
          value: controller.selectedCurrency.value,
          decoration: const InputDecoration(
            labelText: 'العملة *',
            prefixIcon: const Icon(Icons.attach_money),
            border: OutlineInputBorder(),
          ),
          items: controller.currencies.map((currency) {
            return DropdownMenuItem(
              value: currency['code'],
              child: Text(
                '${currency['name']} (${currency['symbol']})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            );
          }).toList(),
          selectedItemBuilder: (context) {
            return controller.currencies.map((currency) {
              return Text(
                '${currency['name']} (${currency['symbol']})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              );
            }).toList();
          },
          onChanged: (value) => controller.selectedCurrency.value = value!,
          validator: (value) => value == null ? 'يرجى اختيار العملة' : null,
        ));
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
          child: Obx(() {
            final isDisabled = controller.isLoading.value ||
                !(Get.find<BusinessOwnerRegistrationController>().isOnline);
            return CustomButton(
              text: nextText,
              onPressed: isDisabled ? null : onNext,
              isLoading: controller.isLoading.value,
              icon: AppIcons.confirm,
            );
          }),
        ),
      ],
    );
  }
}
