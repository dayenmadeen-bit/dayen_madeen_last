import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/offline_service.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/credentials_vault_widget.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../controllers/login_controller.dart';

class AdBannerController extends GetxController {
  final List<String> imagePaths = [
    'assets/images/ad1.jpg',
    'assets/images/ad2.jpg',
    'assets/images/ad3.jpg',
    // أضف مسارات صورك المحلية هنا
  ];

  var currentIndex = 0.obs;
  late Timer timer;

  @override
  void onInit() {
    super.onInit();
    // بدء المؤقت لتغيير الصورة كل دقيقة
    timer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      if (currentIndex.value < imagePaths.length - 1) {
        currentIndex.value++;
      } else {
        currentIndex.value = 0;
      }
    });
  }

  @override
  void onClose() {
    timer.cancel();
    super.onClose();
  }
}

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AdBannerController adBannerController = Get.put(AdBannerController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.backgroundDark, AppColors.surfaceDark],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.backgroundLight
                  ],
                ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(
                  () => SizedBox(
                    height: 150, // الارتفاع المخصص لشريط الإعلانات
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            adBannerController.imagePaths[
                                adBannerController.currentIndex.value],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // شعار التطبيق
                _buildLogo(),

                const SizedBox(height: 32),

                // عنوان تسجيل الدخول
                _buildTitle(),

                const SizedBox(height: 8),

                // نص ترحيبي
                _buildWelcomeText(),

                const SizedBox(height: 24),

                // تبويبات نوع المستخدم
                _buildUserTypeTabs(),

                const SizedBox(height: 32),

                // نموذج تسجيل الدخول
                _buildLoginForm(),

                const SizedBox(height: 24),

                // خيارات إضافية
                _buildAdditionalOptions(),

                const SizedBox(height: 40),

                // معلومات التطبيق
                _buildAppInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(
          AppIcons.logo,
          size: 50,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      AppStrings.login,
      style: AppTextStyles.headlineMedium,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildWelcomeText() {
    return Text(
      'مرحباً بك في ${AppStrings.appName}',
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.textSecondaryLight,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildUserTypeTabs() {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildUserTypeTab(
                  title: 'مالك المنشأة',
                  icon: Icons.business,
                  isSelected: controller.userType.value == 'business_owner',
                  onTap: () => controller.setUserType('business_owner'),
                ),
              ),
              Expanded(
                child: _buildUserTypeTab(
                  title: 'زبون',
                  icon: Icons.person,
                  isSelected: controller.userType.value == 'client',
                  onTap: () => controller.setUserType('client'),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildUserTypeTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // حقول الإدخال
          Obx(() => controller.isOwnerLogin.value
              ? _buildOwnerLoginFields()
              : _buildCustomerLoginFields()),

          const SizedBox(height: 16),

          // وضع الأوفلاين
          _buildOfflineMode(),

          const SizedBox(height: 24),

          // زر تسجيل الدخول
          _buildLoginButton(),

          const SizedBox(height: 16),

          // تسجيل الدخول بالبصمة
          _buildBiometricLogin(),
        ],
      ),
    );
  }

  Widget _buildOwnerLoginFields() {
    return Column(
      children: [
        CustomTextField(
          controller: controller.emailController,
          label: 'الرقم المميز أو البريد الإلكتروني',
          hint: 'الرقم المميز أو البريد الإلكتروني',
          prefixIcon: AppIcons.phone,
          keyboardType: TextInputType.text,
          validator: controller.validateEmail,
        ),
        const SizedBox(height: 16),
        Obx(() => CustomTextField(
              controller: controller.passwordController,
              label: AppStrings.password,
              hint: 'أدخل كلمة المرور',
              prefixIcon: AppIcons.lock,
              obscureText: controller.isPasswordHidden.value,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isPasswordHidden.value
                      ? AppIcons.unlock
                      : AppIcons.lock,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
              validator: controller.validatePassword,
            )),
      ],
    );
  }

  Widget _buildCustomerLoginFields() {
    return Column(
      children: [
        // خزنة بيانات الاعتماد للعملاء
        CredentialsVaultWidget(
          onCredentialSelected: controller.onCredentialSelected,
          usernameController: controller.emailController,
          passwordController: controller.passwordController,
        ),

        const SizedBox(height: 16),

        CustomTextField(
          controller: controller.emailController,
          label: 'الرقم المميز أوالبريد الإلكتروني',
          hint: 'الرقم المميزأو البريد الإلكتروني',
          prefixIcon: AppIcons.phone,
          validator: controller.validateEmail,
        ),
        const SizedBox(height: 16),
        Obx(() => CustomTextField(
              controller: controller.passwordController,
              label: AppStrings.password,
              hint: 'أدخل كلمة المرور',
              prefixIcon: AppIcons.lock,
              obscureText: controller.isPasswordHidden.value,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isPasswordHidden.value
                      ? AppIcons.unlock
                      : AppIcons.lock,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
              validator: controller.validatePassword,
            )),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Obx(() => CustomButton(
          text: AppStrings.login,
          textColor: Colors.white,
          onPressed: controller.isLoading.value ? null : controller.login,
          isLoading: controller.isLoading.value,
          icon: AppIcons.confirm,
        ));
  }

  Widget _buildOfflineMode() {
    return Obx(() => Row(
          children: [
            Checkbox(
              value: controller.offlineMode.value,
              onChanged: (value) {
                controller.offlineMode.value = value ?? false;
                if (value == true) {
                  Get.find<OfflineService>().enableOfflineMode();
                } else {
                  Get.find<OfflineService>().disableOfflineMode();
                }
              },
              activeColor: AppColors.primary,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'وضع الأوفلاين',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'قراءة فقط - لا يمكن إضافة أو تعديل البيانات',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildBiometricLogin() {
    return Obx(() {
      if (controller.isBiometricAvailable.value) {
        return Column(
          children: [
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'أو',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: controller.loginWithBiometrics,
              icon: const Icon(AppIcons.fingerprint),
              label: Text(controller.biometricLoginText.value),
            ),
          ],
        );
      } else {
        return Obx(() => Column(
              children: [
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  controller.biometricLoginText.value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.warning,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ));
      }
    });
  }

  Widget _buildAdditionalOptions() {
    return Obx(() => Column(
          children: [
            // إنشاء حساب جديد - فقط لمالكي المنشآت
            if (controller.isOwnerLogin.value) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: OutlinedButton.icon(
                  onPressed: () => Get.toNamed('/business-owner-register'),
                  icon: const Icon(Icons.business_center, size: 18),
                  label: const Text('إنشاء حساب مالك منشأة'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              // زر الدعم المخصص لمالك المنشأة
              TextButton.icon(
                onPressed: () => Get.toNamed('/business-owner-support'),
                icon: const Icon(
                  Icons.headset_mic,
                  size: 18,
                  color: AppColors.secondary,
                ),
                label: Text(
                  'دعم مالك المنشأة',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],

            // التواصل والدعم - فقط للعملاء
            if (!controller.isOwnerLogin.value) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: OutlinedButton.icon(
                  onPressed: () => Get.toNamed('/customer-registration'),
                  icon: const Icon(Icons.business_center, size: 18),
                  label: const Text('إنشاء حساب جديد'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              // زر الدعم للعملاء
              TextButton.icon(
                onPressed: () => Get.toNamed('/contact-support'),
                icon: const Icon(
                  Icons.support_agent,
                  size: 18,
                  color: AppColors.info,
                ),
                label: Text(
                  'التواصل والدعم',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.info,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],


          ],
        ));
  }

  Widget _buildAppInfo() {
    return Column(
      children: [
        Text(
          AppStrings.appDescription,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'الإصدار ${AppStrings.version}',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textHintLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
