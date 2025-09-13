import 'package:dayen_madeen/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_register_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';

/// شاشة إنشاء حساب جديد للزبون
class CustomerRegisterScreen extends GetView<CustomerRegisterController> {
  const CustomerRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'إنشاء حساب زبون جديد',
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
        leading: IconButton(onPressed: (){
          Get.offAllNamed(AppRoutes.login);
        }, icon: Icon(Icons.arrow_back_ios_rounded ,color: Colors.white,)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: controller.customerInfoFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'رقم الهاتف مطلوب';
                            }
                            if (value.length < 9) {
                              return 'رقم الهاتف يجب أن يتكون من 9 أرقام على الأقل';
                            }
                            return null;
                          }, prefixIcon: Icons.phone_rounded, labelText: ''
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
                                Text(country.code,) ,
                                const SizedBox(width: 8,height: 20,),
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
                Obx(
                      () => CustomTextField(
                    controller: controller.passwordController,
                    labelText: 'كلمة المرور',
                    hintText: 'أدخل كلمة المرور',
                    prefixIcon: Icons.lock_rounded,
                    isPassword: controller.isPasswordHidden.value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'كلمة المرور مطلوبة';
                      }
                      if (value.length < 8) {
                        return 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';
                      }
                      return null;
                    }, label: '',
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                      () => CustomTextField(
                    controller: controller.confirmPasswordController,
                    labelText: 'تأكيد كلمة المرور',
                    hintText: 'أعد إدخال كلمة المرور',
                    prefixIcon: Icons.lock_rounded,
                    isPassword: controller.isConfirmPasswordHidden.value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'تأكيد كلمة المرور مطلوب';
                      }
                      if (value != controller.passwordController.text) {
                        return 'كلمة المرور غير متطابقة';
                      }
                      return null;
                    }, label: '',
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                      () => CheckboxListTile(
                    title: Text(
                      'أوافق على شروط الاستخدام',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                    ),
                    value: controller.acceptTerms.value,
                    onChanged: (bool? value) {
                      controller.acceptTerms.value = value!;
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 24),
                Obx(() => CustomButton(
                  text: 'إنشاء حساب',
                  onPressed: controller.isLoading.value ? null : controller.register,
                  isLoading: controller.isLoading.value,
                  icon: Icons.person_add_rounded,
                  type: ButtonType.filled,
                )),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لديك حساب بالفعل؟ ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.offAllNamed(AppRoutes.login),
                      child: Text(
                        'سجل دخولك',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
