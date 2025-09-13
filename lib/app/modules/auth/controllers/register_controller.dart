import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/offline_service.dart';
import '../../../routes/app_routes.dart';

// تعريف نموذج بيانات رمز الدولة باستخدام الإيموجي
class CountryCode {
  final String code;
  final String emoji; // إيموجي العلم

  CountryCode({
    required this.code,
    required this.emoji,
  });
}

class RegisterController extends GetxController {
  // الخدمات
  final OfflineService _offlineService = Get.find<OfflineService>();

  // مفاتيح النماذج
  final GlobalKey<FormState> businessInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> ownerInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> accountInfoFormKey = GlobalKey<FormState>();

  // متحكمات النصوص
  final TextEditingController nameController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController businessTypeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController commercialRegisterController =
      TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // حالات التفاعل
  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;
  final RxBool acceptTerms = false.obs;
  final RxInt currentStep = 0.obs;

  // تحديث قائمة العملات لتشمل المزيد
  final RxList<String> currencies = [
    'SAR - الريال السعودي',
    'AED - الدرهم الإماراتي',
    'YER - الريال اليمني',
    'USD - دولار أمريكي',
    'KWD - الدينار الكويتي',
    'EGP - الجنيه المصري',
    'JOD - الدينار الأردني',
    'LBP - الليرة اللبنانية',
    'QAR - الريال القطري',
    'BHD - الدينار البحريني',
    'OMR - الريال العماني',
    'LYD - الدينار الليبي',
    'DZD - الدينار الجزائري',
    'TND - الدينار التونسي',
    'MAD - الدرهم المغربي',
    'IQD - الدينار العراقي',
    'SDG - الجنيه السوداني',
    'SYP - الليرة السورية'
  ].obs;
  final RxString selectedCurrency = 'YER - الريال اليمني'.obs;

  // تحديث قائمة رموز الدول
  final RxList<CountryCode> countryCodes = [
    CountryCode(code: '+967', emoji: '🇾🇪'),
    CountryCode(code: '+966', emoji: '🇸🇦'),
    CountryCode(code: '+971', emoji: '🇦🇪'),
    CountryCode(code: '+965', emoji: '🇰🇼'),
    CountryCode(code: '+968', emoji: '🇴🇲'),
    CountryCode(code: '+973', emoji: '🇧🇭'),
    CountryCode(code: '+974', emoji: '🇶🇦'),
    CountryCode(code: '+962', emoji: '🇯🇴'),
    CountryCode(code: '+963', emoji: '🇸🇾'),
    CountryCode(code: '+961', emoji: '🇱🇧'),
    CountryCode(code: '+964', emoji: '🇮🇶'),
    CountryCode(code: '+20', emoji: '🇪🇬'),
    CountryCode(code: '+218', emoji: '🇱🇾'),
    CountryCode(code: '+216', emoji: '🇹🇳'),
    CountryCode(code: '+213', emoji: '🇩🇿'),
    CountryCode(code: '+212', emoji: '🇲🇦'),
    CountryCode(code: '+249', emoji: '🇸🇩'),
    CountryCode(code: '+252', emoji: '🇸🇴'),
    CountryCode(code: '+253', emoji: '🇩🇯'),
    CountryCode(code: '+269', emoji: '🇰🇲'),
    CountryCode(code: '+255', emoji: '🇹🇿'), // زنجبار
    CountryCode(code: '+970', emoji: '🇵🇸'),
  ].obs;

  late Rx<CountryCode> selectedCountryCode;

  @override
  void onInit() {
    selectedCountryCode = countryCodes
        .firstWhere(
          (country) => country.code == '+967',
        )
        .obs;
    super.onInit();
  }

  @override
  void onClose() {
    nameController.dispose();
    businessNameController.dispose();
    businessTypeController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    commercialRegisterController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // دالة مساعدة للانتقال إلى الخطوة التالية
  void nextStep() {
    if (currentStep.value < 2) {
      currentStep.value++;
    }
  }

  // دالة مساعدة للانتقال إلى الخطوة السابقة
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  // التحقق من صحة المدخلات
  String? validateOwnerName(String? value) {
    if (value == null || value.isEmpty) {
      return 'اسم المالك مطلوب';
    }
    return null;
  }

  String? validateBusinessName(String? value) {
    if (value == null || value.isEmpty) {
      return 'اسم المنشأة مطلوب';
    }
    return null;
  }

  String? validateBusinessType(String? value) {
    if (value == null || value.isEmpty) {
      return 'نوع النشاط مطلوب';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.phoneRequired;
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    if (value.length < 6) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    if (value != passwordController.text) {
      return AppStrings.passwordsDoNotMatch;
    }
    return null;
  }

  // دالة تحديث العملة المختارة
  void updateSelectedCurrency(String? newValue) {
    if (newValue != null) {
      selectedCurrency.value = newValue;
    }
  }

  // دالة تحديث رمز الدولة المختار
  void updateSelectedCountryCode(CountryCode? newValue) {
    if (newValue != null) {
      selectedCountryCode.value = newValue;
    }
  }

  // تسجيل المستخدم الجديد
  Future<void> register() async {
    // التحقق من الاتصال بالإنترنت
    if (!_offlineService.isOnline) {
      Get.snackbar(
        'لا يوجد اتصال بالإنترنت',
        'يجب توفر اتصال بالإنترنت لإنشاء الحساب',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final bool isBusinessInfoValid =
        businessInfoFormKey.currentState!.validate();
    final bool isOwnerInfoValid = ownerInfoFormKey.currentState!.validate();
    final bool isAccountInfoValid = accountInfoFormKey.currentState!.validate();

    if (!isBusinessInfoValid || !isOwnerInfoValid || !isAccountInfoValid) {
      LoggerService.warning('بيانات النموذج غير صالحة');
      return;
    }

    if (!acceptTerms.value) {
      Get.snackbar(
        'خطأ',
        'يجب الموافقة على شروط الاستخدام',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      LoggerService.start('Business Owner Registration');

      // دمج رمز الدولة مع رقم الهاتف قبل الإرسال
      final fullPhoneNumber =
          selectedCountryCode.value.code + phoneController.text;

      // هنا يمكنك إرسال البيانات إلى خدمة التسجيل مع العملة ورقم الهاتف الكامل
      // final Map<String, dynamic> registrationData = {
      //   'name': nameController.text,
      //   'businessName': businessNameController.text,
      //   'businessType': businessTypeController.text,
      //   'phone': fullPhoneNumber, // استخدام الرقم الكامل هنا
      //   'address': addressController.text,
      //   'city': cityController.text,
      //   'commercialRegister': commercialRegisterController.text,
      //   'password': passwordController.text,
      //   'currency': selectedCurrency.value.split(' ')[0], // إرسال رمز العملة فقط
      // };

      // ... استدعاء الخدمة الخلفية مع registrationData

      await Future.delayed(const Duration(seconds: 2)); // محاكاة لعملية التسجيل

      LoggerService.success('Business Owner Registered Successfully');
      Get.snackbar(
        'نجاح',
        'تم إنشاء حسابك بنجاح',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

      Get.offAllNamed(AppRoutes.login);
    } catch (e, st) {
      LoggerService.error('Registration Error', error: e, stackTrace: st);
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء التسجيل: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
