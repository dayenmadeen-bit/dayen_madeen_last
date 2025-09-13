import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/services/security_service.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/theme_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../routes/app_routes.dart';

/// كنترولر إدارة الإعدادات
class SettingsController extends GetxController {
  // ===== المتغيرات التفاعلية =====

  // حالة التحميل
  final isLoading = false.obs;

  // معلومات المستخدم
  final userName = ''.obs;
  final userEmail = ''.obs;
  final businessName = ''.obs;

  // إعدادات التطبيق
  final isDarkMode = false.obs;
  final isNotificationsEnabled = true.obs;
  final isBiometricEnabled = false.obs;

  // إحصائيات التطبيق
  final totalCustomers = 0.obs;
  final totalDebts = 0.obs;
  final totalPayments = 0.obs;
  final storageUsed = '0 KB'.obs;

  // معلومات الجهاز
  final deviceId = ''.obs;
  final appVersion = ''.obs;

  // ===== نماذج التحكم =====

  // نموذج تعديل الملف الشخصي
  final editProfileFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final businessNameController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  final profileImage = Rx<File?>(null);
  final isSaving = false.obs;

  // نموذج تغيير كلمة المرور
  final changePasswordFormKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final hideCurrentPassword = true.obs;
  final hideNewPassword = true.obs;
  final hideConfirmPassword = true.obs;
  final passwordStrength = 0.obs;
  final isChangingPassword = false.obs;

  // نموذج التواصل
  final contactFormKey = GlobalKey<FormState>();
  final contactNameController = TextEditingController();
  final contactEmailController = TextEditingController();
  final contactSubjectController = TextEditingController();
  final contactMessageController = TextEditingController();
  final isSendingMessage = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  // ===== تحميل الإعدادات =====

  Future<void> _loadSettings() async {
    try {
      isLoading.value = true;

      // تحميل معلومات المستخدم
      await _loadUserInfo();

      // تحميل إعدادات التطبيق
      await _loadAppSettings();

      // تحميل الإحصائيات
      await _loadStatistics();

      // تحميل معلومات الجهاز
      await _loadDeviceInfo();
    } catch (e) {
      _showErrorMessage('فشل في تحميل الإعدادات');
    } finally {
      isLoading.value = false;
    }
  }

  // تحميل معلومات المستخدم
  Future<void> _loadUserInfo() async {
    final user = AuthService.instance.currentUser;
    if (user != null) {
      userName.value = user.name;
      userEmail.value = user.email ?? '';
      businessName.value = user.businessName ?? '';
    }
  }

  // تحميل إعدادات التطبيق
  Future<void> _loadAppSettings() async {
    // إعدادات الثيم
    isDarkMode.value = ThemeService.isDarkMode;

    // إعدادات الإشعارات
    isNotificationsEnabled.value =
        StorageService.getBool('notifications_enabled') ?? true;

    // إعدادات البصمة
    isBiometricEnabled.value =
        StorageService.getBool('biometric_enabled') ?? false;
  }

  // تحميل الإحصائيات
  Future<void> _loadStatistics() async {
    final customers = await LocalStorageService.getAllCustomers();
    final debts = await LocalStorageService.getAllDebts();
    final payments = await LocalStorageService.getAllPayments();

    totalCustomers.value = customers.length;
    totalDebts.value = debts.length;
    totalPayments.value = payments.length;

    // حساب حجم التخزين المستخدم
    final storageSize = StorageService.getStorageSize();
    storageUsed.value = _formatStorageSize(storageSize);
  }

  // تحميل معلومات الجهاز
  Future<void> _loadDeviceInfo() async {
    deviceId.value = await DeviceService.getDeviceId();
    appVersion.value =
        '${AppConstants.appVersion} (${AppConstants.appBuildNumber})';
  }

  // ===== إدارة الإعدادات =====

  // تبديل الثيم
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    ThemeService.changeTheme(
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
    );
  }

  // تبديل الإشعارات
  Future<void> toggleNotifications() async {
    isNotificationsEnabled.value = !isNotificationsEnabled.value;
    await StorageService.setBool(
        'notifications_enabled', isNotificationsEnabled.value);

    if (isNotificationsEnabled.value) {
      _showSuccessMessage('تم تفعيل الإشعارات');
    } else {
      _showSuccessMessage('تم إيقاف الإشعارات');
    }
  }

  // تبديل البصمة
  Future<void> toggleBiometric() async {
    if (!isBiometricEnabled.value) {
      // تفعيل البصمة - التحقق من التوفر أولاً
      final isAvailable = await SecurityService.instance.isBiometricAvailable();
      if (!isAvailable) {
        _showErrorMessage('المصادقة البيومترية غير متوفرة على هذا الجهاز');
        return;
      }

      // طلب المصادقة
      final isAuthenticated = await SecurityService.instance.enableBiometric();

      if (isAuthenticated) {
        isBiometricEnabled.value = true;
        await StorageService.setBool('biometric_enabled', true);

        // حفظ بريد مالك المنشأة الحالي لاستخدامه في تسجيل الدخول بالبصمة لاحقاً
        final email = userEmail.value.trim();
        if (email.isNotEmpty) {
          await StorageService.setString('last_email', email);
        }

        _showSuccessMessage('تم تفعيل المصادقة البيومترية');
      } else {
        _showErrorMessage(
            'فشل في تفعيل المصادقة البيومترية. تأكد من بصمة الجهاز أو الأذونات.');
      }
    } else {
      // إيقاف البصمة
      isBiometricEnabled.value = false;
      await StorageService.setBool('biometric_enabled', false);
      _showSuccessMessage('تم إيقاف المصادقة البيومترية');
    }
  }

  // ===== التنقل =====

  // الانتقال لإعدادات الملف الشخصي
  void goToProfileSettings() {
    Get.toNamed(AppRoutes.profile);
  }

  // الانتقال لإعدادات الأمان
  void goToSecuritySettings() {
    Get.toNamed('/security-settings');
  }

  // الانتقال لإعدادات الإشعارات
  void goToNotificationSettings() {
    Get.toNamed(AppRoutes.notifications);
  }

  // الانتقال لمعلومات التطبيق
  void goToAbout() {
    Get.toNamed(AppRoutes.about);
  }

  // الانتقال للمساعدة
  void goToHelp() {
    Get.toNamed(AppRoutes.help);
  }

  // ===== العمليات =====

  // تصدير البيانات
  Future<void> exportData() async {
    try {
      isLoading.value = true;
      _showInfoMessage('سيتم إضافة وظيفة تصدير البيانات قريباً');
    } catch (e) {
      _showErrorMessage('فشل في تصدير البيانات');
    } finally {
      isLoading.value = false;
    }
  }

  // مسح جميع البيانات
  Future<void> clearAllData() async {
    final confirmed = await _showConfirmationDialog(
      'مسح جميع البيانات',
      'سيتم حذف جميع البيانات نهائياً. هذا الإجراء لا يمكن التراجع عنه. هل أنت متأكد؟',
    );

    if (!confirmed) return;

    try {
      isLoading.value = true;

      // مسح جميع البيانات
      await LocalStorageService.clearAllData();
      await StorageService.clear();

      _showSuccessMessage('تم مسح جميع البيانات');

      // تسجيل الخروج والعودة لشاشة تسجيل الدخول
      await AuthService.instance.logout();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _showErrorMessage('فشل في مسح البيانات');
    } finally {
      isLoading.value = false;
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    final confirmed = await _showConfirmationDialog(
      'تسجيل الخروج',
      'هل أنت متأكد من تسجيل الخروج؟',
    );

    if (!confirmed) return;

    try {
      await AuthService.instance.logout();
      Get.offAllNamed(AppRoutes.login);
      _showSuccessMessage('تم تسجيل الخروج بنجاح');
    } catch (e) {
      _showErrorMessage('فشل في تسجيل الخروج');
    }
  }

  // ===== الدوال المساعدة =====

  // تنسيق حجم التخزين
  String _formatStorageSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  // عرض حوار التأكيد
  Future<bool> _showConfirmationDialog(String title, String message) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // عرض رسالة نجاح
  void _showSuccessMessage(String message) {
    Get.snackbar(
      'نجح',
      message,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  // عرض رسالة خطأ
  void _showErrorMessage(String message) {
    Get.snackbar(
      'خطأ',
      message,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  // عرض رسالة معلومات
  void _showInfoMessage(String message) {
    Get.snackbar(
      'معلومات',
      message,
      backgroundColor: AppColors.info,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  // تحديث الإعدادات
  Future<void> refreshSettings() async {
    await _loadSettings();
  }

  // ===== حفظ الملف الشخصي =====

  /// حفظ بيانات الملف الشخصي
  Future<void> saveProfile({
    required String name,
    required String email,
    required String businessName,
    String? phone,
    String? address,
  }) async {
    try {
      isLoading.value = true;

      // إذا تم تغيير البريد الإلكتروني، اذهب لتدفق التحقق قبل الحفظ النهائي
      final oldEmail = userEmail.value.trim();
      final newEmail = email.trim();
      if (oldEmail.isNotEmpty && newEmail.isNotEmpty && oldEmail != newEmail) {
        // خزّن القيم مؤقتاً ثم وجّه لصفحة تحقق البريد
        nameController.text = name;
        emailController.text = newEmail;
        businessNameController.text = businessName;
        phoneController.text = phone ?? '';
        addressController.text = address ?? '';

        isLoading.value = false;
        Get.toNamed(AppRoutes.emailVerification, arguments: {
          'email': newEmail,
          'onVerifiedRoute': AppRoutes.settings,
          'context': 'change_email',
        });
        return;
      }

      // تحديث البيانات المحلية
      userName.value = name;
      userEmail.value = email;
      this.businessName.value = businessName;

      // حفظ البيانات في التخزين المحلي
      await StorageService.setString('user_name', name);
      await StorageService.setString('user_email', email);
      await StorageService.setString('business_name', businessName);

      if (phone != null) {
        await StorageService.setString('user_phone', phone);
      }

      if (address != null) {
        await StorageService.setString('user_address', address);
      }

      // إظهار رسالة نجاح
      _showSuccessMessage('تم حفظ البيانات بنجاح ✅');
    } catch (e) {
      // إظهار رسالة خطأ
      _showErrorMessage('فشل في حفظ البيانات: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ===== دوال تعديل الملف الشخصي =====

  /// اختيار صورة الملف الشخصي
  Future<void> pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        profileImage.value = File(image.path);
      }
    } catch (e) {
      _showErrorMessage('حدث خطأ أثناء اختيار الصورة');
    }
  }

  // ===== دوال تغيير كلمة المرور =====

  /// تبديل إظهار كلمة المرور الحالية
  void toggleCurrentPasswordVisibility() {
    hideCurrentPassword.value = !hideCurrentPassword.value;
  }

  /// تبديل إظهار كلمة المرور الجديدة
  void toggleNewPasswordVisibility() {
    hideNewPassword.value = !hideNewPassword.value;
  }

  /// تبديل إظهار تأكيد كلمة المرور
  void toggleConfirmPasswordVisibility() {
    hideConfirmPassword.value = !hideConfirmPassword.value;
  }

  /// تحديث قوة كلمة المرور
  void onNewPasswordChanged(String password) {
    passwordStrength.value = _calculatePasswordStrength(password);
  }

  /// حساب قوة كلمة المرور
  int _calculatePasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    return strength > 4 ? 4 : strength;
  }

  /// الحصول على نص قوة كلمة المرور
  String getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'ضعيفة';
      case 2:
        return 'متوسطة';
      case 3:
        return 'قوية';
      case 4:
        return 'قوية جداً';
      default:
        return 'ضعيفة';
    }
  }

  /// الحصول على لون قوة كلمة المرور
  Color getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.info;
      case 4:
        return AppColors.success;
      default:
        return AppColors.error;
    }
  }

  /// تغيير كلمة المرور
  Future<void> changePassword() async {
    if (!changePasswordFormKey.currentState!.validate()) return;

    try {
      isChangingPassword.value = true;

      // محاكاة تغيير كلمة المرور
      await Future.delayed(const Duration(seconds: 2));

      // مسح الحقول
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      Get.back();
      _showSuccessMessage('تم تغيير كلمة المرور بنجاح');
    } catch (e) {
      _showErrorMessage('حدث خطأ أثناء تغيير كلمة المرور');
    } finally {
      isChangingPassword.value = false;
    }
  }

  // ===== دوال التواصل =====

  /// إرسال رسالة التواصل
  Future<void> sendContactMessage() async {
    if (!contactFormKey.currentState!.validate()) return;

    try {
      isSendingMessage.value = true;

      // محاكاة إرسال الرسالة
      await Future.delayed(const Duration(seconds: 2));

      // مسح الحقول
      contactNameController.clear();
      contactEmailController.clear();
      contactSubjectController.clear();
      contactMessageController.clear();

      _showSuccessMessage('تم إرسال رسالتك بنجاح. سنتواصل معك قريباً');
    } catch (e) {
      _showErrorMessage('حدث خطأ أثناء إرسال الرسالة');
    } finally {
      isSendingMessage.value = false;
    }
  }

  @override
  void onClose() {
    // تنظيف الموارد
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    businessNameController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    contactNameController.dispose();
    contactEmailController.dispose();
    contactSubjectController.dispose();
    contactMessageController.dispose();
    super.onClose();
  }
}
