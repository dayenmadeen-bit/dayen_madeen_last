import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/unique_id_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/offline_service.dart';
import '../../../widgets/unique_id_popup.dart'; // ✅ إضافة ويجت عرض الرقم المميز
import '../../../routes/app_routes.dart';
import '../../../data/models/user_role.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// كنترولر تسجيل مالك المنشأة متعدد الخطوات
class BusinessOwnerRegistrationController extends GetxController {
  // Controllers للحقول
  final businessNameController = TextEditingController();
  final businessTypeController = TextEditingController();
  final businessAddressController = TextEditingController();
  final ownerNameController = TextEditingController();
  final ownerEmailController = TextEditingController();
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // حالات التحكم
  var currentStep = 0.obs;
  var isLoading = false.obs;
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var acceptPrivacyPolicy = false.obs;
  var selectedCurrency = 'SAR'.obs;
  var generatedUniqueId = ''.obs;

  // قائمة العملات
  final List<Map<String, String>> currencies = [
    {'code': 'YER', 'name': 'الريال اليمني', 'symbol': 'ر.ي'},
    {'code': 'SAR', 'name': 'الريال السعودي', 'symbol': 'ر.س'},
    {'code': 'AED', 'name': 'الدرهم الإماراتي', 'symbol': 'د.إ'},
    {'code': 'KWD', 'name': 'الدينار الكويتي', 'symbol': 'د.ك'},
    {'code': 'QAR', 'name': 'الريال القطري', 'symbol': 'ر.ق'},
    {'code': 'BHD', 'name': 'الدينار البحريني', 'symbol': 'د.ب'},
    {'code': 'OMR', 'name': 'الريال العماني', 'symbol': 'ر.ع'},
    {'code': 'JOD', 'name': 'الدينار الأردني', 'symbol': 'د.أ'},
    {'code': 'LBP', 'name': 'الليرة اللبنانية', 'symbol': 'ل.ل'},
    {'code': 'SYP', 'name': 'الليرة السورية', 'symbol': 'ل.س'},
    {'code': 'IQD', 'name': 'الدينار العراقي', 'symbol': 'ع.د'},
    {'code': 'EGP', 'name': 'الجنيه المصري', 'symbol': 'ج.م'},
    {'code': 'SDG', 'name': 'الجنيه السوداني', 'symbol': 'ج.س'},
    {'code': 'LYD', 'name': 'الدينار الليبي', 'symbol': 'د.ل'},
    {'code': 'TND', 'name': 'الدينار التونسي', 'symbol': 'د.ت'},
    {'code': 'DZD', 'name': 'الدينار الجزائري', 'symbol': 'د.ج'},
    {'code': 'MAD', 'name': 'الدرهم المغربي', 'symbol': 'د.م'},
    {'code': 'MUR', 'name': 'روبية موريتانية (قديمة/أوقية)', 'symbol': 'أ.م'},
    {'code': 'MRU', 'name': 'الأوقية الموريتانية', 'symbol': 'أ.م'},
    {'code': 'SOS', 'name': 'الشلن الصومالي', 'symbol': 'ش.ص'},
    {'code': 'DJF', 'name': 'الفرنك الجيبوتي', 'symbol': 'ف.ج'},
    {'code': 'SHP', 'name': 'الجنيه الفلسطيني/الشيكل', 'symbol': '₪'},
    {'code': 'USD', 'name': 'الدولار الأمريكي', 'symbol': '\$'},
  ];

  // الخدمات
  late final UniqueIdService _uniqueIdService;
  late final FirestoreService _firestoreService;
  late final OfflineService _offlineService;

  bool get isOnline => _offlineService.isOnline;

  @override
  void onInit() {
    super.onInit();
    _uniqueIdService = Get.find<UniqueIdService>();
    _firestoreService = Get.find<FirestoreService>();
    _offlineService = Get.find<OfflineService>();
  }

  @override
  void onClose() {
    businessNameController.dispose();
    businessTypeController.dispose();
    businessAddressController.dispose();
    ownerNameController.dispose();
    ownerEmailController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // التنقل بين الخطوات
  void nextStep() {
    if (currentStep.value < 3) {
      if (_validateCurrentStep()) {
        // ✅ إذا كنا في الخطوة 2 (كلمة المرور)، ابدأ عملية التسجيل
        if (currentStep.value == 2) {
          _performRegistration();
        } else {
          currentStep.value++;
        }
      }
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  // ✅ أداء عملية التسجيل وعرض الرقم المميز
  Future<void> _performRegistration() async {
    try {
      // تحقق من توفر الإنترنت قبل البدء
      if (!_offlineService.isOnline) {
        _showErrorMessage('يجب توفر اتصال بالإنترنت لإكمال إنشاء الحساب');
        return;
      }

      isLoading.value = true;

      final String email = ownerEmailController.text.trim();
      final String password = passwordController.text;
      final String ownerName = ownerNameController.text.trim();
      final String businessName = businessNameController.text.trim();

      // إذا تم إدخال بريد إلكتروني: يجب أن يكون مُتحققاً قبل توليد الرقم المميز والدخول لصفحة عرضه
      if (email.isNotEmpty) {
        final auth = firebase_auth.FirebaseAuth.instance;
        firebase_auth.User? fbUser = auth.currentUser;

        // إنشاء/تسجيل الدخول للحساب بالبريد لإرسال رابط التحقق إن لزم
        if (fbUser == null || (fbUser.email != null && fbUser.email != email)) {
          try {
            final methods = await auth.fetchSignInMethodsForEmail(email);
            if (methods.isNotEmpty) {
              final cred = await auth.signInWithEmailAndPassword(
                email: email,
                password: password,
              );
              fbUser = cred.user;
            } else {
              final cred = await auth.createUserWithEmailAndPassword(
                email: email,
                password: password,
              );
              fbUser = cred.user;
            }
          } on firebase_auth.FirebaseAuthException catch (e) {
            _showErrorMessage('
تعذر استخدام البريد الإلكتروني: ${e.message ?? e.code}');
            return;
          }
        }

        // تأكد من حالة التحقق
        await fbUser?.reload();
        if (fbUser != null && !(fbUser.emailVerified)) {
          try {
            await fbUser.sendEmailVerification();
          } catch (_) {}
          // الانتقال إلى صفحة التحقق من البريد
          final verified = await Get.toNamed('/email-verification',
              arguments: {'email': email});
          if (verified != true) {
            _showErrorMessage(
                'لم يتم التحقق من البريد الإلكتروني بعد. يرجى التحقق والمتابعة.');
            return;
          }
        }
      }

      // توليد الرقم المميز
      final uniqueId = await _uniqueIdService.generateBusinessOwnerId();
      generatedUniqueId.value = uniqueId;

      // إنشاء بيانات المالك
      final businessOwnerData = {
        'uniqueId': uniqueId,
        'name': ownerName,
        'email': email.isEmpty ? null : email,
        'businessName': businessName,
        'businessType': businessTypeController.text.trim(),
        'businessAddress': businessAddressController.text.trim().isEmpty
            ? null
            : businessAddressController.text.trim(),
        'currency': selectedCurrency.value,
        'bankName': bankNameController.text.trim().isEmpty
            ? null
            : bankNameController.text.trim(),
        'accountNumber': accountNumberController.text.trim().isEmpty
            ? null
            : accountNumberController.text.trim(),
        'phoneNumber': phoneNumberController.text.trim().isEmpty
            ? null
            : phoneNumberController.text.trim(),
        'passwordHash': password, // سيتم تشفيرها لاحقاً
        'role': UserRole.businessOwner.value,
        'isActive': true,
        'emailVerified': email.isEmpty
            ? false
            : (firebase_auth.FirebaseAuth.instance.currentUser?.emailVerified ??
                false),
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      };

      // حفظ البيانات في Firestore
      String createdDocId;
      if (email.isNotEmpty &&
          (firebase_auth.FirebaseAuth.instance.currentUser?.emailVerified ??
              false)) {
        final uid = firebase_auth.FirebaseAuth.instance.currentUser!.uid;
        await _firestoreService.setDoc(
          _firestoreService.usersCol().doc(uid),
          {
            ...businessOwnerData,
            'id': uid,
          },
          merge: false,
        );
        createdDocId = uid;
      } else {
        final userRef = await _firestoreService.addDoc(
          _firestoreService.usersCol(),
          businessOwnerData,
        );
        await userRef.update({'id': userRef.id});
        createdDocId = userRef.id;
      }

      try {
        await _uniqueIdService.markUniqueIdUsed(uniqueId,
            userDocId: createdDocId, role: UserRole.businessOwner.value);
      } catch (_) {}

      // حفظ الرقم المميز محلياً
      await StorageService.setString('user_unique_id', uniqueId);
      await StorageService.setString('user_role', UserRole.businessOwner.value);

      _showSuccessMessage('تم إنشاء الحساب بنجاح!');

      // ✅ عرض الرقم المميز في نافذة منبثقة جميلة
      UniqueIdPopup.showUniqueIdDialog(
        uniqueId: uniqueId,
        userType: 'business_owner',
        userEmail: email.isEmpty ? null : email,
        userName: ownerName,
        onContinue: () {
          // الانتقال لشاشة تسجيل الدخول
          Get.offAllNamed(AppRoutes.login);
        },
      );

      LoggerService.success('تم تسجيل مالك منشأة جديد: $uniqueId');
      
    } catch (e) {
      LoggerService.error('خطأ في إنشاء الحساب', error: e);
      _showErrorMessage('حدث خطأ في إنشاء الحساب');
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ إكمال التسجيل (لن يتم استخدامه لأن العملية تمت في _performRegistration)
  Future<void> completeRegistration() async {
    // لن يتم استخدام هضا الآن بعد التعديل
    // لأن العملية تمت في _performRegistration وتم عرض الرقم المميز هناك
  }

  // التحقق من صحة الخطوة الحالية
  bool _validateCurrentStep() {
    switch (currentStep.value) {
      case 0:
        return _validateStep1();
      case 1:
        return _validateStep2();
      case 2:
        return _validateStep3();
      default:
        return true;
    }
  }

  // التحقق من الخطوة 1 (معلومات المحل)
  bool _validateStep1() {
    if (businessNameController.text.trim().isEmpty) {
      _showErrorMessage('يرجى إدخال اسم المحل');
      return false;
    }
    if (businessTypeController.text.trim().isEmpty) {
      _showErrorMessage('يرجى إدخال نوع النشاط');
      return false;
    }
    return true;
  }

  // التحقق من الخطوة 2 (معلومات المالك)
  bool _validateStep2() {
    if (ownerNameController.text.trim().isEmpty) {
      _showErrorMessage('يرجى إدخال الاسم الكامل');
      return false;
    }
    // البريد الإلكتروني إلزامي
    if (ownerEmailController.text.trim().isEmpty) {
      _showErrorMessage('البريد الإلكتروني مطلوب');
      return false;
    }
    if (!GetUtils.isEmail(ownerEmailController.text.trim())) {
      _showErrorMessage('البريد الإلكتروني غير صحيح');
      return false;
    }
    if (bankNameController.text.isNotEmpty &&
        accountNumberController.text.isEmpty) {
      _showErrorMessage('يرجى إدخال رقم الحساب إذا أدخلت اسم البنك');
      return false;
    }
    if (accountNumberController.text.isNotEmpty &&
        bankNameController.text.isEmpty) {
      _showErrorMessage('يرجى إدخال اسم البنك إذا أدخلت رقم الحساب');
      return false;
    }
    return true;
  }

  // التحقق من الخطوة 3 (كلمة المرور)
  bool _validateStep3() {
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

  // التحقق من صحة البيانات
  String? validateBusinessName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال اسم المحل';
    }
    return null;
  }

  String? validateBusinessType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال نوع النشاط';
    }
    return null;
  }

  String? validateOwnerName(String? value) {
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