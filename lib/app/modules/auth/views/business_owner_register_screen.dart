import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/offline_service.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/connection_status_widget.dart';
import '../../../routes/app_routes.dart';

/// شاشة إنشاء حساب جديد لمالك المنشأة - تصميم محسن بدون overflow
class BusinessOwnerRegisterScreen extends GetView<RegisterController> {
  const BusinessOwnerRegisterScreen({super.key});

  /// الحصول على نص زر التنقل السفلي حسب الخطوة
  String _getButtonText(int step) {
    switch (step) {
      case 0:
      case 1:
        return 'التالي';
      case 2:
        return 'إنشاء الحساب';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'إنشاء حساب مالك منشأة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Get.offAllNamed(AppRoutes.login);
            },
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
            )),
      ),
      body: Column(
        children: [
          // مؤشر حالة الاتصال
          const ConnectionStatusWidget(),

          // مؤشر التقدم العلوي
          _buildTopProgressIndicator(),

          // المحتوى الرئيسي
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Obx(() {
                switch (controller.currentStep.value) {
                  case 0:
                    return _buildBusinessInfoForm();
                  case 1:
                    return _buildOwnerInfoForm();
                  case 2:
                    return _buildAccountInfoForm();
                  default:
                    return const SizedBox.shrink();
                }
              }),
            ),
          ),

          // شريط التنقل السفلي
          _buildBottomNavigationBar(),
        ],
      ),
    );
  }

  /// بناء مؤشر التقدم
  Widget _buildTopProgressIndicator() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          _buildProgressStep(0, 'معلومات المنشأة'),
          _buildProgressStep(1, 'معلومات المالك'),
          _buildProgressStep(2, 'بيانات الحساب'),
        ],
      ),
    );
  }

  /// بناء خطوة التقدم
  Widget _buildProgressStep(int step, String title) {
    return Expanded(
      child: Obx(() {
        final isCurrent = controller.currentStep.value == step;
        final isCompleted = controller.currentStep.value > step;
        return Column(
          children: [
            Container(
              height: 4,
              width: double.infinity,
              color: isCurrent || isCompleted
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: isCurrent || isCompleted
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      }),
    );
  }

  /// بناء نموذج معلومات المنشأة
  Widget _buildBusinessInfoForm() {
    return Form(
      key: controller.businessInfoFormKey,
      child: Column(
        children: [
          CustomTextField(
            controller: controller.businessNameController,
            label: 'اسم المنشأة',
            hintText: 'أدخل اسم المنشأة الخاصة بك',
            prefixIcon: Icons.business_center_rounded,
            validator: controller.validateBusinessName,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.businessTypeController,
            label: 'نوع النشاط',
            hintText: 'أدخل نوع النشاط (مثال: مطعم، مقهى)',
            prefixIcon: Icons.store_rounded,
            validator: controller.validateBusinessType,
          ),
          const SizedBox(height: 16),
          // حقل اختيار العملة
          Obx(() => DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'العملة',
                  hintText: 'اختر العملة الرئيسية لمنشأتك',
                  prefixIcon: Icon(Icons.monetization_on_rounded,
                      color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                value: controller.selectedCurrency.value,
                items: controller.currencies.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: controller.updateSelectedCurrency,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'العملة مطلوبة';
                  }
                  return null;
                },
              )),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.commercialRegisterController,
            label: 'السجل التجاري',
            hintText: 'أدخل رقم السجل التجاري (اختياري)',
            prefixIcon: Icons.insert_chart_rounded,
          ),
        ],
      ),
    );
  }

  /// بناء نموذج معلومات المالك
  Widget _buildOwnerInfoForm() {
    return Form(
      key: controller.ownerInfoFormKey,
      child: Column(
        children: [
          CustomTextField(
            controller: controller.nameController,
            label: 'اسم المالك',
            hintText: 'أدخل اسمك الكامل',
            prefixIcon: Icons.person_rounded,
            validator: controller.validateOwnerName,
          ),
          const SizedBox(height: 16),
          // حقل رقم الهاتف مع رمز الدولة
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 2,
                child: CustomTextField(
                  controller: controller.phoneController,
                  label: 'رقم الهاتف',
                  hintText: 'أدخل رقم هاتفك',
                  keyboardType: TextInputType.phone,
                  validator: controller.validatePhone,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Obx(() => DropdownButtonFormField<CountryCode>(
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                      value: controller.selectedCountryCode.value,
                      items: controller.countryCodes.map((CountryCode country) {
                        return DropdownMenuItem<CountryCode>(
                          value: country,
                          child: Row(
                            children: [
                              Text(
                                country.code,
                              ),
                              const SizedBox(
                                width: 8,
                                height: 20,
                              ),
                              Text(
                                country.emoji,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: controller.updateSelectedCountryCode,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.addressController,
            label: 'العنوان',
            hintText: 'أدخل عنوانك',
            prefixIcon: Icons.location_on_rounded,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.cityController,
            label: 'المدينة',
            hintText: 'أدخل اسم المدينة',
            prefixIcon: Icons.location_city_rounded,
          ),
        ],
      ),
    );
  }

  /// بناء نموذج بيانات الحساب
  Widget _buildAccountInfoForm() {
    return Form(
      key: controller.accountInfoFormKey,
      child: Column(
        children: [
          Obx(() => CustomTextField(
                controller: controller.passwordController,
                label: 'كلمة المرور',
                hintText: 'أدخل كلمة المرور',
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: controller.isPasswordHidden.value,
                validator: controller.validatePassword,
              )),
          const SizedBox(height: 16),
          Obx(() => CustomTextField(
                controller: controller.confirmPasswordController,
                label: 'تأكيد كلمة المرور',
                hintText: 'أعد إدخال كلمة المرور',
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: controller.isConfirmPasswordHidden.value,
                validator: controller.validateConfirmPassword,
              )),
          const SizedBox(height: 24),
          _buildTermsAndConditions(),
        ],
      ),
    );
  }

  /// بناء شروط الاستخدام
  Widget _buildTermsAndConditions() {
    return Obx(() => Row(
          children: [
            Checkbox(
              value: controller.acceptTerms.value,
              onChanged: (bool? newValue) {
                controller.acceptTerms.value = newValue ?? false;
              },
              activeColor: AppColors.primary,
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'بمتابعتك، فإنك توافق على ',
                  style: AppTextStyles.bodySmall,
                  children: [
                    TextSpan(
                      text: 'شروط الاستخدام',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(
                      text: ' و ',
                      style: AppTextStyles.bodySmall,
                    ),
                    TextSpan(
                      text: 'سياسة الخصوصية',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  /// بناء شريط التنقل السفلي
  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Obx(() {
                final offlineService = Get.find<OfflineService>();
                final isOnline = offlineService.isOnline;

                return CustomButton(
                  text: _getButtonText(controller.currentStep.value),
                  onPressed: (controller.isLoading.value ||
                          (!isOnline && controller.currentStep.value == 2))
                      ? null
                      : () {
                          // التحقق من صحة البيانات في الخطوة الحالية
                          bool isValid = false;
                          switch (controller.currentStep.value) {
                            case 0:
                              isValid = controller
                                      .businessInfoFormKey.currentState
                                      ?.validate() ??
                                  false;
                              break;
                            case 1:
                              isValid = controller.ownerInfoFormKey.currentState
                                      ?.validate() ??
                                  false;
                              break;
                            case 2:
                              isValid = controller
                                      .accountInfoFormKey.currentState
                                      ?.validate() ??
                                  false;
                              break;
                          }

                          if (!isValid) {
                            Get.snackbar(
                              'خطأ في البيانات',
                              'يرجى إكمال الحقول المطلوبة بشكل صحيح',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.error,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          if (controller.currentStep.value < 2) {
                            controller.nextStep();
                          } else {
                            if (!controller.acceptTerms.value) {
                              Get.snackbar(
                                'خطأ',
                                'يجب الموافقة على شروط الاستخدام',
                                backgroundColor: AppColors.error,
                                colorText: Colors.white,
                              );
                              return;
                            }
                            // التحقق من الاتصال بالإنترنت قبل التسجيل
                            controller.register();
                          }
                        },
                  isLoading: controller.isLoading.value,
                  icon: controller.currentStep.value == 2
                      ? Icons.person_add_rounded
                      : Icons.arrow_forward_rounded,
                  type: ButtonType.filled,
                );
              }),
            ),
            if (controller.currentStep.value > 0)
              TextButton(
                onPressed: controller.previousStep,
                child: Text(
                  'الخلف',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
