import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
// import '../../../../core/services/secure_auth_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../routes/app_routes.dart';

class CountryCode {
  final String code;
  final String emoji; // إيموجي العلم

  CountryCode({
    required this.code,
    required this.emoji,
  });
}

class CustomerRegisterController extends GetxController {
  // مفاتيح النماذج
  final GlobalKey<FormState> customerInfoFormKey = GlobalKey<FormState>();

  // متحكمات النصوص
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // حالات التفاعل
  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;
  final RxBool acceptTerms = false.obs;

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
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> register() async {
    // التحقق من صحة النموذج أولاً
    if (!customerInfoFormKey.currentState!.validate()) {
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
      LoggerService.start('Customer Registration');

      // هنا يتم استدعاء خدمة المصادقة
      await Future.delayed(const Duration(seconds: 2)); // محاكاة لعملية التسجيل

      LoggerService.success('Customer Registered Successfully');
      Get.snackbar(
        'نجاح',
        'تم إنشاء حسابك بنجاح',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

      // الانتقال إلى شاشة تسجيل الدخول بعد النجاح
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

  void updateSelectedCountryCode(CountryCode? newValue) {
    if (newValue != null) {
      selectedCountryCode.value = newValue;
    }
  }
}
