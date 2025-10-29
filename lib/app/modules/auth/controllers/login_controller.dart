import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:local_auth/local_auth.dart'; // تم إضافة هذا السطر

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/credentials_vault_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/offline_service.dart'; // ✅ تم إضافته
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
  var rememberMe = false.obs; // ✅ محتفظ به للتوافق مع الكود الموجود
  var offlineMode = false.obs; // ✅ وضع الأوفلاين
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

    // ✅ تهيئة وضع الأوفلاين
    _initializeOfflineMode();
    
    _checkBiometricAvailability();
    _loadSavedCredentials();
  }

  // ✅ تهيئة وضع الأوفلاين
  Future<void> _initializeOfflineMode() async {
    try {
      // تسجيل خدمة الأوفلاين إذا لم تكن مسجلة
      if (!Get.isRegistered<OfflineService>()) {
        Get.put(OfflineService(), permanent: true);
      }

      // تحميل الإعداد المحفوظ
      final savedOfflineMode = StorageService.getBool('offline_mode') ?? false;
      offlineMode.value = savedOfflineMode;
      
      // تفعيل وضع الأوفلاين إذا كان محفوظاً
      if (savedOfflineMode) {
        Get.find<OfflineService>().enableOfflineMode();
      }
      
      LoggerService.info('تم تهيئة وضع الأوفلاين: $savedOfflineMode');
    } catch (e) {
      LoggerService.error('خطأ في تهيئة وضع الأوفلاين', error: e);
    }
  }

  // ✅ تبديل وضع الأوفلاين
  Future<void> toggleOfflineMode(bool enabled) async {
    try {
      offlineMode.value = enabled;
      await StorageService.setBool('offline_mode', enabled);
      
      if (enabled) {
        Get.find<OfflineService>().enableOfflineMode();
        LoggerService.info('تم تفعيل وضع الأوفلاين');
        _showInfoMessage('تم تفعيل وضع الأوفلاين - قراءة فقط');
      } else {
        Get.find<OfflineService>().disableOfflineMode();
        LoggerService.info('تم إلغاء وضع الأوفلاين');
      }
    } catch (e) {
      LoggerService.error('خطأ في تبديل وضع الأوفلاين', error: e);
      _showErrorMessage('خطأ في تغيير وضع الأوفلاين');
    }
  }

  // ✅ فحص وضع الأوفلاين
  bool get isOfflineMode => offlineMode.value;

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
    final savedRememberMe = StorageService.getBool('remember_me') ?? false;
    rememberMe.value = savedRememberMe;
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

      // ✅ فحص وضع الأوفلاين أولاً
      if (offlineMode.value) {
        // في وضع الأوفلاين، نحاول تسجيل الدخول من البيانات المحفوظة محلياً
        final offlineLoginResult = await _tryOfflineLogin();
        if (offlineLoginResult) {
          _handleSuccessfulLogin('تم تسجيل الدخول في وضع الأوفلاين ✅\n(قراءة فقط)');
          return;
        } else {
          _showErrorMessage('فشل تسجيل الدخول في وضع الأوفلاين\nلا توجد بيانات محفوظة محلياً');
          return;
        }
      }

      // تسجيل الدخول العادي (عبر الإنترنت)
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
        _handleSuccessfulLogin('تم تسجيل الدخول بنجاح ✅');
      } else {
        _showErrorMessage('بيانات تسجيل الدخول غير صحيحة');
      }
    } catch (e) {
      _showErrorMessage('حدث خطأ غير متوقع');
      LoggerService.error('خطأ في تسجيل الدخول', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ محاولة تسجيل الدخول في وضع الأوفلاين
  Future<bool> _tryOfflineLogin() async {
    try {
      final offlineService = Get.find<OfflineService>();
      final email = emailController.text.trim();
      final password = passwordController.text;
      
      // محاولة تسجيل الدخول من البيانات المحفوظة
      final result = await offlineService.attemptOfflineLogin(email, password);
      return result;
    } catch (e) {
      LoggerService.error('خطأ في تسجيل الدخول الأوفلاين', error: e);
      return false;
    }
  }

  // ✅ معالجة تسجيل الدخول الناجح
  Future<void> _handleSuccessfulLogin(String message) async {
    _showSuccessMessage(message);

    // حفظ بيانات الدخول إذا كان المستخدم يريد ذلك
    if (rememberMe.value) {
      await _saveCredentials();
    }

    // حفظ وضع الأوفلاين
    await StorageService.setBool('offline_mode', offlineMode.value);

    // التوجيه حسب نوع المستخدم
    if (userType.value == 'business_owner') {
      LoggerService.navigation('تسجيل الدخول', AppRoutes.home);
      Get.offAllNamed(AppRoutes.home);
    } else {
      LoggerService.navigation('تسجيل الدخول', AppRoutes.clientDashboard);
      Get.offAllNamed(AppRoutes.clientDashboard);
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
        _showErrorMessage('
البصمة غير مفعلة في إعدادات التطبيق. يرجى تفعيلها أولاً من إعدادات الأمان.');
        isLoading.value = false;
        return;
      }

      // تحقق من توفر البصمة على الجهاز
      final isAvailable = await SecurityService.instance.isBiometricAvailable();
      if (!isAvailable) {
        _showErrorMessage('جهازك لا يدعم المصادقة البيومترية أو لم يتم منح الأذونات.');
        isLoading.value = false;
        return;
      }

      // التحقق من البصمة عبر SecurityService
      final isAuthenticated = await SecurityService.instance.authenticateWithBiometric();
      if (!isAuthenticated) {
        _showErrorMessage('فشل في التحقق بالبصمة أو تم إلغاء العملية من قبل المستخدم.');
        isLoading.value = false;
        return;
      }

      bool loginSuccess = false;
      if (userType.value == 'business_owner') {
        final lastEmail = StorageService.getString('last_email');
        if (lastEmail == null || lastEmail.isEmpty) {
          _showErrorMessage('لا يوجد بريد محفوظ للبصمة. سجّل دخولاً مرة واحدة بالبريد مع تفعيل "تذكرني".');
          isLoading.value = false;
          return;
        }
        final result = await AuthService.instance.loginWithBiometric();
        loginSuccess = result.isSuccess;
      } else {
        final lastUsername = StorageService.getString('last_username');
        if (lastUsername == null || lastUsername.isEmpty) {
          _showErrorMessage('لا يوجد اسم مستخدم محفوظ للبصمة. سجّل دخولاً مرة واحدة باسم المستخدم مع تفعيل "تذكرني".');
          isLoading.value = false;
          return;
        }
        final result = await AuthService.instance.loginClientWithBiometric();
        loginSuccess = result.isSuccess;
      }

      if (loginSuccess) {
        await _handleSuccessfulLogin('تم تسجيل الدخول بالبصمة بنجاح ✅');
      } else {
        _showErrorMessage('فشل تسجيل الدخول بالبصمة. يرجى المحاولة مرة أخرى.');
      }
    } catch (e) {
      _showErrorMessage('حدث خطأ أثناء التحقق بالبصمة');
      LoggerService.error('خطأ في تسجيل الدخول بالبصمة', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  // نسيت كلمة المرور
  void forgotPassword() {
    if (isOwnerLogin.value) {
      Get.toNamed(AppRoutes.forgotPassword);
    } else {
      Get.dialog(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.help_outline, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              const Text('نسيت كلمة المرور'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('يمكنك التواصل مع مالك المنشأة لإعادة تعيين كلمة المرور.'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('لا يمكن للعملاء إعادة تعيين كلمة المرور بأنفسهم'),
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
              icon: const Icon(Icons.support_agent, size: 18),
              label: const Text('التواصل والدعم'),
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
        content: const Text('هل تريد المتابعة بدون تسجيل الدخول؟\nستكون الميزات محدودة.'),
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
        final email = emailController.text.trim();
        final password = passwordController.text;

        if (email.isNotEmpty && password.isNotEmpty) {
          final success = await SecureAuthService.saveBusinessOwnerCredentialsForBiometric(
            email: email,
            password: password,
          );

          if (success) {
            await StorageService.setString('last_email', email);
            await StorageService.setBool('remember_me', true);
            LoggerService.info('تم حفظ بيانات اعتماد مالك المنشأة للمصادقة البيومترية');
          }
        }
      } else {
        final username = usernameController.text.trim();
        final password = passwordController.text;

        if (username.isNotEmpty && password.isNotEmpty) {
          final success = await SecureAuthService.saveClientCredentialsForBiometric(
            username: username,
            password: password,
          );

          if (success) {
            await StorageService.setString('last_username', username);
            await StorageService.setBool('remember_me', true);
            LoggerService.info('تم حفظ بيانات اعتماد الزبون للمصادقة البيومترية');
          }
        }
      }
    } catch (e) {
      LoggerService.error('خطأ في حفظ بيانات الاعتماد', error: e);
    }
    await _checkBiometricAvailability();
  }

  // التحقق من صحة تسجيل دخول مالك المنشأة
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

  // التحقق من صحة تسجيل دخول الزبون
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

  // ✅ إظهار رسالة معلوماتية
  void _showInfoMessage(String message) {
    Get.snackbar(
      'معلومة',
      message,
      backgroundColor: AppColors.info,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }
}