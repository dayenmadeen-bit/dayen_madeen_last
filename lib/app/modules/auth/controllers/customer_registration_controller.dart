import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/unique_id_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../data/models/user_role.dart';

/// كنترولر تسجيل العملاء مع دعم الحسابات المؤقتة والدائمة
class CustomerRegistrationController extends GetxController {
  // Controllers للحقول
  final uniqueIdController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // حالات التحكم
  var currentStep = 0.obs;
  var isLoading = false.obs;
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var acceptPrivacyPolicy = false.obs;
  var accountType = ''.obs; // 'new' أو 'linked'
  var generatedUniqueId = ''.obs;

  // الخدمات
  late final AuthService _authService;
  late final UniqueIdService _uniqueIdService;
  late final FirestoreService _firestoreService;

  @override
  void onInit() {
    super.onInit();
    _authService = Get.find<AuthService>();
    _uniqueIdService = Get.find<UniqueIdService>();
    _firestoreService = Get.find<FirestoreService>();
  }

  @override
  void onClose() {
    uniqueIdController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // تعيين نوع الحساب
  void setAccountType(String type) {
    accountType.value = type;
    if (type == 'new') {
      uniqueIdController.clear();
    }
  }

  // التنقل بين الخطوات
  void nextStep() {
    if (currentStep.value < 2) {
      if (_validateCurrentStep()) {
        currentStep.value++;
      }
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  // التحقق من صحة الخطوة الحالية
  bool _validateCurrentStep() {
    switch (currentStep.value) {
      case 0:
        return accountType.value.isNotEmpty;
      case 1:
        return _validateStep2();
      default:
        return true;
    }
  }

  // التحقق من الخطوة 2 (البيانات)
  bool _validateStep2() {
    if (accountType.value == 'linked') {
      if (uniqueIdController.text.trim().isEmpty) {
        _showErrorMessage('يرجى إدخال الرقم المميز');
        return false;
      }
      if (!_uniqueIdService.isValidUniqueId(uniqueIdController.text.trim())) {
        _showErrorMessage('الرقم المميز غير صحيح (يجب أن يكون 7 خانات)');
        return false;
      }
    }

    if (nameController.text.trim().isEmpty) {
      _showErrorMessage('يرجى إدخال الاسم الكامل');
      return false;
    }

    // البريد الإلكتروني إلزامي
    if (emailController.text.trim().isEmpty) {
      _showErrorMessage('البريد الإلكتروني مطلوب');
      return false;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      _showErrorMessage('البريد الإلكتروني غير صحيح');
      return false;
    }

    if (passwordController.text.isEmpty) {
      _showErrorMessage('يرجى إدخال كلمة المرور');
      return false;
    }

    if (passwordController.text.length < 6) {
      _showErrorMessage('كلمة المرور قصيرة جداً (6 أحرف على الأقل)');
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showErrorMessage('كلمة المرور غير متطابقة');
      return false;
    }

    if (!acceptPrivacyPolicy.value) {
      _showErrorMessage('يرجى الموافقة على سياسة الخصوصية');
      return false;
    }

    return true;
  }

  // تبديل إظهار/إخفاء كلمة المرور
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  // إكمال التسجيل
  Future<void> completeRegistration() async {
    try {
      isLoading.value = true;

      String uniqueId;

      if (accountType.value == 'linked') {
        // استخدام الرقم المميز الموجود
        uniqueId = uniqueIdController.text.trim();

        // التحقق من وجود الرقم المميز وحالته مؤقت
        final existingUser =
            await _uniqueIdService.findUserByUniqueId(uniqueId);
        if (existingUser == null) {
          _showErrorMessage('الرقم المميز غير موجود');
          return;
        }

        final hasPassword =
            (existingUser['passwordHash'] as String?)?.isNotEmpty == true;
        if (hasPassword) {
          _showErrorMessage('هذا الرقم مرتبط بحساب مُفعَّل بالفعل');
          return;
        }

        // تحديث بيانات الحساب المؤقت إلى حساب كامل
        await _updateExistingCustomer(uniqueId);
      } else {
        // إذا وُجد بريد، يجب التحقق قبل توليد الرقم وحفظ الحساب
        if (emailController.text.trim().isNotEmpty) {
          // إرسال رابط التحقق
          try {
            await _authService.sendEmailVerification();
          } catch (e) {
            LoggerService.warning('فشل إرسال تحقق البريد: $e');
          }
        }

        // إنشاء رقم مميز جديد بعد خطوة التحقق (أو بدون بريد)
        uniqueId = await _uniqueIdService.generateUniqueId();
        generatedUniqueId.value = uniqueId;

        // إنشاء حساب جديد
        await _createNewCustomer(uniqueId);

        // إنشاء حساب Firebase إذا أُدخل بريد
        if (emailController.text.trim().isNotEmpty) {
          try {
            await _authService.signUp(
              email: emailController.text.trim(),
              password: passwordController.text,
              name: nameController.text.trim(),
              phone: '',
              role: UserRole.customer,
              metadata: {
                'uniqueId': uniqueId,
                'accountType': accountType.value,
              },
            );
          } catch (e) {
            LoggerService.warning('فشل إنشاء حساب Firebase: $e');
          }
        }
      }

      // حفظ البيانات محلياً
      await StorageService.setString('user_unique_id', uniqueId);
      await StorageService.setString('user_role', UserRole.customer.value);

      _showSuccessMessage('تم إنشاء الحساب بنجاح!');

      // الانتقال للخطوة الأخيرة
      currentStep.value = 2;
    } catch (e) {
      LoggerService.error('خطأ في إنشاء الحساب', error: e);
      _showErrorMessage('حدث خطأ في إنشاء الحساب');
    } finally {
      isLoading.value = false;
    }
  }

  // إنشاء عميل جديد
  Future<void> _createNewCustomer(String uniqueId) async {
    final customerData = {
      'uniqueId': uniqueId,
      'name': nameController.text.trim(),
      'email': emailController.text.trim().isEmpty
          ? null
          : emailController.text.trim(),
      'passwordHash': passwordController.text, // سيتم تشفيرها لاحقاً
      'role': UserRole.customer.value,
      'isActive': true,
      'emailVerified': false,
      'isTemporary': false,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    };

    final userRef = await _firestoreService.addDoc(
      _firestoreService.usersCol(),
      customerData,
    );

    // تحديث المعرف في البيانات
    await userRef.update({'id': userRef.id});

    try {
      await _uniqueIdService.markUniqueIdUsed(uniqueId,
          userDocId: userRef.id, role: UserRole.customer.value);
    } catch (_) {}
  }

  // تحديث عميل موجود
  Future<void> _updateExistingCustomer(String uniqueId) async {
    final userQuery = await _firestoreService
        .usersCol()
        .where('uniqueId', isEqualTo: uniqueId)
        .limit(1)
        .get();

    if (userQuery.docs.isNotEmpty) {
      final userDoc = userQuery.docs.first;
      await userDoc.reference.update({
        'name': nameController.text.trim(),
        'email': emailController.text.trim().isEmpty
            ? null
            : emailController.text.trim(),
        'passwordHash': passwordController.text, // سيتم تشفيرها لاحقاً
        'emailVerified': false,
        'isTemporary': false,
        'updatedAt': DateTime.now(),
      });
    }
  }

  // التحقق من صحة البيانات
  String? validateUniqueId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال الرقم المميز';
    }
    if (!_uniqueIdService.isValidUniqueId(value.trim())) {
      return 'الرقم المميز غير صحيح (يجب أن يكون 7 خانات)';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال الاسم الكامل';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور قصيرة جداً (6 أحرف على الأقل)';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى تأكيد كلمة المرور';
    }
    if (value != passwordController.text) {
      return 'كلمة المرور غير متطابقة';
    }
    return null;
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
