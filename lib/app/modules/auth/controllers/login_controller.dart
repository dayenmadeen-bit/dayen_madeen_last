import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:local_auth/local_auth.dart'; // تم إضافة هذا السطر

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/credentials_vault_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/secure_auth_service.dart';
import '../../../../core/services/security_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../routes/app_routes.dart';
import '../../../../app/data/models/auth_result.dart';

class LoginController extends GetxController {
  // Controllers للحقول
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // حالات التحكم
  var isLoading = false.obs;
  var isPasswordHidden = true.obs;
  var rememberMe = false.obs;
  var offlineMode = false.obs; // وضع الأوفلاين
  var isOwnerLogin = true.obs;
  var userType = 'business_owner'.obs; // نوع المستخدم الجديد

  // المصادقة البيومترية
  var isBiometricAvailable = false.obs;
  var biometricLoginText = AppStrings.loginWithFingerprint.obs;

  @override
  void onInit() {
    super.onInit();

    // تسجيل خدمة خزنة بيانات الاعتماد إذا لم تكن مسجلة
    if (!Get.isRegistered<CredentialsVaultService>()) {
      Get.put(CredentialsVaultService(), permanent: true);
    }

    _checkBiometricAvailability();
    _loadSavedCredentials();
  }

  // فحص توفر المصادقة البيومترية وتفعيلها حسب الإعدادات
  Future<void> _checkBiometricAvailability() async {
    try {
      final deviceSupportsBiometric =
          await SecurityService.instance.isBiometricAvailable();
      final isEnabledInSettings =
          StorageService.getBool('biometric_enabled') ?? false;

      if (deviceSupportsBiometric && isEnabledInSettings) {
        isBiometricAvailable.value = true;
        biometricLoginText.value = 'تسجيل الدخول باستخدام البصمة';
      } else {
        isBiometricAvailable.value = false;
        if (!deviceSupportsBiometric) {
          biometricLoginText.value = 'جهازك لا يدعم المصادقة بالبصمة';
        } else if (!isEnabledInSettings) {
          biometricLoginText.value = 'البصمة غير مفعلة في الإعدادات';
        }
      }
    } catch (e) {
      isBiometricAvailable.value = false;
      biometricLoginText.value = 'خطأ في فحص البصمة';
    }
  }

  // تحميل بيانات الدخول المحفوظة
  void _loadSavedCredentials() {
    // يمكن إضافة منطق تحميل البيانات المحفوظة هنا
  }

  // تبديل نوع تسجيل الدخول
  void setOwnerLogin(bool isOwner) {
    isOwnerLogin.value = isOwner;
    _clearFields();
  }

  // تغيير نوع المستخدم
  void setUserType(String type) {
    userType.value = type;
    isOwnerLogin.value = type == 'business_owner';
    _clearFields();
    // إعادة فحص توفر البصمة حسب نوع المستخدم الجديد
    _checkBiometricAvailability();
  }

  // مسح الحقول
  void _clearFields() {
    emailController.clear();
    usernameController.clear();
    passwordController.clear();
  }

  // تبديل إظهار/إخفاء كلمة المرور
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // التحقق من صحة البريد الإلكتروني
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.required;
    }
    if (!GetUtils.isEmail(value)) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  // التحقق من صحة اسم المستخدم
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.required;
    }
    if (value.length < 3) {
      return 'اسم المستخدم قصير جداً';
    }
    return null;
  }

  // التحقق من صحة كلمة المرور
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.required;
    }
    if (value.length < 6) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  // تسجيل الدخول
  Future<void> login() async {
    if (isLoading.value) return;

    // التحقق من صحة البيانات
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      // محاكاة تسجيل الدخول بناءً على نوع المستخدم
      await Future.delayed(const Duration(milliseconds: 1500));

      bool loginSuccess = false;

      if (userType.value == 'business_owner') {
        // تسجيل دخول مالك المنشأة
        loginSuccess = await _validateBusinessOwnerLogin();
      } else {
        // تسجيل دخول الزبون
        loginSuccess = await _validateClientLogin();
      }

      if (loginSuccess) {
        // نجح تسجيل الدخول
        String successMessage = 'تم تسجيل الدخول بنجاح ✅';
        if (offlineMode.value) {
          successMessage += '\n(وضع الأوفلاين - قراءة فقط)';
        }
        _showSuccessMessage(successMessage);

        // حفظ بيانات الدخول إذا كان المستخدم يريد ذلك
        if (rememberMe.value) {
          await _saveCredentials();
        }

        // حفظ وضع الأوفلاين
        if (offlineMode.value) {
          await StorageService.setBool('offline_mode', true);
        }

        // التوجيه حسب نوع المستخدم
        if (userType.value == 'business_owner') {
          // مالك المنشأة يذهب إلى لوحة التحكم
          LoggerService.navigation('تسجيل الدخول', AppRoutes.home);
          Get.offAllNamed(AppRoutes.home);
        } else {
          // الزبون يذهب إلى لوحة تحكم الزبون
          LoggerService.navigation('تسجيل الدخول', AppRoutes.clientDashboard);
          Get.offAllNamed(AppRoutes.clientDashboard);
        }
      } else {
        // فشل تسجيل الدخول
        _showErrorMessage('بيانات تسجيل الدخول غير صحيحة');
      }
    } catch (e) {
      _showErrorMessage('حدث خطأ غير متوقع');
    } finally {
      isLoading.value = false;
    }
  }

  // التحقق من صحة النموذج
  bool _validateForm() {
    if (isOwnerLogin.value) {
      final emailError = validateEmail(emailController.text);
      if (emailError != null) {
        _showErrorMessage(emailError);
        return false;
      }
    } else {
      final usernameError = validateUsername(usernameController.text);
      if (usernameError != null) {
        _showErrorMessage(usernameError);
        return false;
      }
    }

    final passwordError = validatePassword(passwordController.text);
    if (passwordError != null) {
      _showErrorMessage(passwordError);
      return false;
    }

    return true;
  }

  // تسجيل الدخول بالبصمة
  Future<void> loginWithBiometrics() async {
    try {
      isLoading.value = true;
      // تحقق من تفعيل البصمة
      final isEnabled = StorageService.getBool('biometric_enabled') ?? false;
      if (!isEnabled) {
        _showErrorMessage(
            'البصمة غير مفعلة في إعدادات التطبيق. يرجى تفعيلها أولاً من إعدادات الأمان.');
        isLoading.value = false;
        return;
      }

      // تحقق من توفر البصمة على الجهاز
      final isAvailable = await SecurityService.instance.isBiometricAvailable();
      if (!isAvailable) {
        _showErrorMessage(
            'جهازك لا يدعم المصادقة البيومترية أو لم يتم منح الأذونات.');
        isLoading.value = false;
        return;
      }

      // التحقق من البصمة عبر SecurityService
      final isAuthenticated =
          await SecurityService.instance.authenticateWithBiometric();
      if (!isAuthenticated) {
        _showErrorMessage(
            'فشل في التحقق بالبصمة أو تم إلغاء العملية من قبل المستخدم.');
        isLoading.value = false;
        return;
      }

      // لمالك المنشأة: نستخدم last_email لتسجيل الدخول مباشرة من Firestore
      bool loginSuccess = false;
      if (userType.value == 'business_owner') {
        final lastEmail = StorageService.getString('last_email');
        if (lastEmail == null || lastEmail.isEmpty) {
          _showErrorMessage(
              'لا يوجد بريد محفوظ للبصمة. سجّل دخولاً مرة واحدة بالبريد مع تفعيل "تذكرني".');
          isLoading.value = false;
          return;
        }
        // تخطي إدخال البريد وكلمة المرور — الاعتماد على جلسة محفوظة أو إنشاء جلسة جديدة من Firestore
        final result = await AuthService.instance.loginWithBiometric();
        loginSuccess = result.isSuccess;
      } else {
        // البصمة متاحة لمالك المنشأة والزبون
        final lastUsername = StorageService.getString(
            'last_username'); // افتراض وجود last_username للزبون
        if (lastUsername == null || lastUsername.isEmpty) {
          _showErrorMessage(
              'لا يوجد اسم مستخدم محفوظ للبصمة. سجّل دخولاً مرة واحدة باسم المستخدم مع تفعيل "تذكرني".');
          isLoading.value = false;
          return;
        }
        final result = await AuthService.instance
            .loginClientWithBiometric(); // دالة جديدة للزبون
        loginSuccess = result.isSuccess;
      }

      if (loginSuccess) {
        _showSuccessMessage('تم تسجيل الدخول بالبصمة بنجاح ✅');

        // التوجيه حسب نوع المستخدم
        if (userType.value == 'business_owner') {
          LoggerService.navigation('تسجيل الدخول بالبصمة', AppRoutes.home);
          Get.offAllNamed(AppRoutes.home);
        } else {
          LoggerService.navigation(
              'تسجيل الدخول بالبصمة', AppRoutes.clientDashboard);
          Get.offAllNamed(AppRoutes.clientDashboard);
        }
      } else {
        _showErrorMessage('فشل تسجيل الدخول بالبصمة. يرجى المحاولة مرة أخرى.');
      }
    } catch (e) {
      _showErrorMessage('حدث خطأ أثناء التحقق بالبصمة');
    } finally {
      isLoading.value = false;
    }
  }

  // نسيت كلمة المرور
  void forgotPassword() {
    if (isOwnerLogin.value) {
      // لمالك المنشأة - الانتقال إلى شاشة استعادة كلمة المرور
      Get.toNamed(AppRoutes.forgotPassword);
    } else {
      // للعملاء - إظهار رسالة للتواصل مع مالك المنشأة
      Get.dialog(
        AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.help_outline,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text('نسيت كلمة المرور'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'يمكنك التواصل مع مالك المنشأة لإعادة تعيين كلمة المرور.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'لا يمكن للعملاء إعادة تعيين كلمة المرور بأنفسهم',
                        style: TextStyle(
                          color: AppColors.info,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('موافق'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
                contactSupport();
              },
              icon: Icon(Icons.support_agent, size: 18),
              label: const Text('التواصل والدعم'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    }
  }

  // إنشاء حساب جديد
  void createAccount() {
    Get.dialog(
      AlertDialog(
        title: const Text('إنشاء حساب جديد'),
        content: const Text('سيتم إضافة هذه الميزة قريباً'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  /// الانتقال لشاشة التواصل والدعم
  void contactSupport() {
    Get.toNamed(AppRoutes.contactSupport);
  }

  /// معالجة اختيار بيانات اعتماد من الخزنة
  void onCredentialSelected(String username, String password) {
    usernameController.text = username;
    passwordController.text = password;
  }

  // المتابعة كضيف
  void continueAsGuest() {
    Get.dialog(
      AlertDialog(
        title: const Text('المتابعة كضيف'),
        content: const Text(
            'هل تريد المتابعة بدون تسجيل الدخول؟\nستكون الميزات محدودة.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed(AppRoutes.home);
            },
            child: const Text('متابعة'),
          ),
        ],
      ),
    );
  }

  // حفظ بيانات الدخول
  Future<void> _saveCredentials() async {
    try {
      if (userType.value == 'business_owner') {
        // حفظ بيانات مالك المنشأة للمصادقة البيومترية
        final email = emailController.text.trim();
        final password = passwordController.text;

        if (email.isNotEmpty && password.isNotEmpty) {
          final success =
              await SecureAuthService.saveBusinessOwnerCredentialsForBiometric(
            email: email,
            password: password,
          );

          if (success) {
            await StorageService.setString('last_email', email);
            await StorageService.setBool('remember_me', true);
            LoggerService.info(
                'تم حفظ بيانات اعتماد مالك المنشأة للمصادقة البيومترية');
          }
        }
      } else {
        // للعملاء - يمكن استخدام الخدمة الموجودة
        // يمكن إضافة منطق حفظ بيانات العملاء هنا إذا لزم الأمر
        final username = usernameController.text.trim();
        final password = passwordController.text;

        if (username.isNotEmpty && password.isNotEmpty) {
          final success =
              await SecureAuthService.saveClientCredentialsForBiometric(
            username: username,
            password: password,
          );

          if (success) {
            await StorageService.setString('last_username', username);
            await StorageService.setBool('remember_me', true);
            LoggerService.info(
                'تم حفظ بيانات اعتماد الزبون للمصادقة البيومترية');
          }
        }
      }
    } catch (e) {
      LoggerService.error('خطأ في حفظ بيانات الاعتماد', error: e);
    }
    // إعادة فحص توفر البصمة بعد الحفظ
    await _checkBiometricAvailability();
  }

  // التحقق من صحة تسجيل دخول مالك المنشأة (باستخدام Firestore عبر AuthService)
  Future<bool> _validateBusinessOwnerLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    final result = await AuthService.instance.loginWithEmail(
      LoginCredentials(
        email: email,
        password: password,
        rememberMe: rememberMe.value,
      ),
    );

    return result.isSuccess;
  }

  // التحقق من صحة تسجيل دخول الزبون (Firestore عبر AuthService)
  Future<bool> _validateClientLogin() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    final result = await AuthService.instance.loginClient(
      LoginCredentials(email: username, password: password),
    );

    return result.isSuccess;
  }

  // إظهار رسالة نجاح
  void _showSuccessMessage(String message) {
    Get.snackbar(
      AppStrings.success,
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  // إظهار رسالة خطأ
  void _showErrorMessage(String message) {
    Get.snackbar(
      AppStrings.error,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  // @override
  // void onClose() {
  //   emailController.dispose();
  //   usernameController.dispose();
  //   passwordController.dispose();
  //   super.onClose();
  // }
}
