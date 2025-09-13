import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/security_service.dart';
import '../../../../core/constants/app_colors.dart';

/// كنترولر شاشة الإعدادات للزبون
class CustomerSettingsController extends GetxController {
  // حالات التحكم
  var userName = ''.obs;
  var uniqueId = ''.obs;
  var email = ''.obs;
  var isDarkMode = false.obs;
  var isFingerprintEnabled = false.obs;

  // الخدمات
  late final AuthService _authService;
  late final SecurityService _securityService;

  @override
  void onInit() {
    super.onInit();
    _authService = Get.find<AuthService>();
    _securityService = Get.find<SecurityService>();
    loadUserData();
    loadSettings();
  }

  // تحميل بيانات المستخدم
  void loadUserData() {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      userName.value = currentUser.name;
      uniqueId.value = currentUser.uniqueId;
      email.value = currentUser.email ?? 'غير محدد';
    }
  }

  // تحميل الإعدادات
  void loadSettings() {
    // تحميل إعدادات الوضع الداكن
    isDarkMode.value = Get.isDarkMode;
    isFingerprintEnabled.value = _securityService.isBiometricEnabled;
  }

  // تبديل الوضع الداكن
  void toggleTheme(bool value) {
    isDarkMode.value = value;
    // تطبيق تغيير الوضع الداكن
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  // تبديل البصمة
  void toggleFingerprint(bool value) async {
    try {
      // تطبيق منطق البصمة
      if (value) {
        bool authenticated = await _securityService.authenticateWithBiometric();
        if (authenticated) {
          await _securityService.enableBiometric();
          isFingerprintEnabled.value = true;
          _showSuccessMessage('تم تفعيل البصمة بنجاح');
        } else {
          _showErrorMessage('فشل تفعيل البصمة');
        }
      } else {
        await _securityService.disableBiometric();
        isFingerprintEnabled.value = false;
        _showSuccessMessage('تم إلغاء تفعيل البصمة');
      }
    } catch (e) {
      LoggerService.error('خطأ في تبديل البصمة', error: e);
      _showErrorMessage('حدث خطأ في تغيير إعدادات البصمة');
    }
  }

  // تعديل الاسم
  void editName() {
    final nameController = TextEditingController(text: userName.value);

    Get.dialog(
      AlertDialog(
        title: const Text('تغيير الاسم'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'الاسم الجديد',
            hintText: 'أدخل الاسم الجديد',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                _showErrorMessage('يرجى إدخال اسم صحيح');
                return;
              }

              try {
                await _updateUserName(nameController.text.trim());
                Get.back();
                _showSuccessMessage('تم تغيير الاسم بنجاح');
              } catch (e) {
                _showErrorMessage('حدث خطأ في تغيير الاسم');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  // تحديث اسم المستخدم
  Future<void> _updateUserName(String newName) async {
    // تحديث الاسم في قاعدة البيانات
    // يمكن إضافة منطق تحديث الاسم هنا لاحقاً
    userName.value = newName;

    // إرسال إشعار للمحلات المرتبطة
    // يمكن إضافة منطق إرسال الإشعارات هنا لاحقاً
  }

  // تعديل البريد الإلكتروني
  void editEmail() {
    Get.toNamed('/email-verification', arguments: {
      'email': email.value,
      'context': 'change_email',
    });
  }

  // تغيير كلمة المرور
  void changePassword() {
    final oldPasswordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الحالية',
                hintText: 'أدخل كلمة المرور الحالية',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Get.back();
                Get.toNamed('/forgot-password');
              },
              child: const Text('نسيت كلمة المرور؟'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (oldPasswordController.text.isEmpty) {
                _showErrorMessage('يرجى إدخال كلمة المرور الحالية');
                return;
              }

              try {
                // التحقق من كلمة المرور الحالية
                final isValid =
                    await _verifyCurrentPassword(oldPasswordController.text);
                if (!isValid) {
                  _showErrorMessage('كلمة المرور الحالية غير صحيحة');
                  return;
                }

                Get.back();
                _showNewPasswordDialog();
              } catch (e) {
                _showErrorMessage('حدث خطأ في التحقق من كلمة المرور');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('تحقق'),
          ),
        ],
      ),
    );
  }

  // التحقق من كلمة المرور الحالية
  Future<bool> _verifyCurrentPassword(String password) async {
    // التحقق من كلمة المرور الحالية
    // يمكن إضافة منطق التحقق من كلمة المرور هنا لاحقاً
    return true;
  }

  // عرض حوار كلمة المرور الجديدة
  void _showNewPasswordDialog() {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('كلمة المرور الجديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                hintText: 'أدخل كلمة المرور الجديدة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'تأكيد كلمة المرور',
                hintText: 'أعد إدخال كلمة المرور الجديدة',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text.isEmpty) {
                _showErrorMessage('يرجى إدخال كلمة المرور الجديدة');
                return;
              }

              if (newPasswordController.text.length < 6) {
                _showErrorMessage('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
                return;
              }

              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                _showErrorMessage('كلمة المرور غير متطابقة');
                return;
              }

              try {
                await _updatePassword(newPasswordController.text);
                Get.back();
                _showSuccessMessage('تم تغيير كلمة المرور بنجاح');
              } catch (e) {
                _showErrorMessage('حدث خطأ في تغيير كلمة المرور');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  // تحديث كلمة المرور
  Future<void> _updatePassword(String newPassword) async {
    // تحديث كلمة المرور في قاعدة البيانات
    // يمكن إضافة منطق تحديث كلمة المرور هنا لاحقاً
  }

  // إظهار رسائل النجاح والخطأ
  void _showSuccessMessage(String message) {
    Get.snackbar(
      'نجح ✅',
      message,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      snackPosition: SnackPosition.TOP,
    );
  }

  void _showErrorMessage(String message) {
    Get.snackbar(
      'خطأ ❌',
      message,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error, color: Colors.white),
      snackPosition: SnackPosition.TOP,
    );
  }
}


