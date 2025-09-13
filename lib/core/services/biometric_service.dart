import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
// import 'package:local_auth_android/local_auth_android.dart';
// import 'package:local_auth_ios/local_auth_ios.dart';
import 'storage_service.dart';
import 'logger_service.dart';

class BiometricService extends GetxService {
  static BiometricService get instance => Get.find<BiometricService>();

  final LocalAuthentication _localAuth = LocalAuthentication();

  // متغيرات الحالة
  final RxBool _isAvailable = false.obs;
  final RxBool _isEnabled = false.obs;
  final RxList<BiometricType> _availableBiometrics = <BiometricType>[].obs;

  // Getters
  bool get isAvailable => _isAvailable.value;
  bool get isEnabled => _isEnabled.value;
  List<BiometricType> get availableBiometrics => _availableBiometrics;

  @override
  void onInit() {
    super.onInit();
    _checkBiometricAvailability();
    _loadBiometricStatus();
  }

  // التحقق من توفر البصمة
  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      _isAvailable.value = isAvailable;

      if (isAvailable) {
        final availableBiometrics = await _localAuth.getAvailableBiometrics();
        _availableBiometrics.value = availableBiometrics;
        LoggerService.info('البصمة متوفرة: $availableBiometrics');
      } else {
        LoggerService.warning('البصمة غير متوفرة على هذا الجهاز');
      }
    } catch (e, st) {
      LoggerService.error('خطأ في التحقق من توفر البصمة',
          error: e, stackTrace: st);
      _isAvailable.value = false;
    }
  }

  // تحميل حالة البصمة المحفوظة
  void _loadBiometricStatus() {
    _isEnabled.value = StorageService.getBool('biometric_enabled') ?? false;
  }

  // تفعيل البصمة
  Future<bool> enableBiometric() async {
    try {
      if (!_isAvailable.value) {
        LoggerService.warning('البصمة غير متوفرة على هذا الجهاز');
        return false;
      }

      // التحقق من البصمة أولاً
      final isAuthenticated = await _authenticateWithBiometric(
        reason: 'تفعيل المصادقة بالبصمة',
      );

      if (isAuthenticated) {
        await StorageService.setBool('biometric_enabled', true);
        _isEnabled.value = true;
        LoggerService.success('تم تفعيل البصمة بنجاح');
        return true;
      } else {
        LoggerService.warning('فشل في التحقق من البصمة');
        return false;
      }
    } catch (e, st) {
      LoggerService.error('خطأ في تفعيل البصمة', error: e, stackTrace: st);
      return false;
    }
  }

  // إلغاء تفعيل البصمة
  Future<bool> disableBiometric() async {
    try {
      await StorageService.setBool('biometric_enabled', false);
      _isEnabled.value = false;
      LoggerService.success('تم إلغاء تفعيل البصمة بنجاح');
      return true;
    } catch (e, st) {
      LoggerService.error('خطأ في إلغاء تفعيل البصمة',
          error: e, stackTrace: st);
      return false;
    }
  }

  // التحقق من البصمة
  Future<bool> authenticateWithBiometric({String? reason}) async {
    try {
      if (!_isAvailable.value) {
        LoggerService.warning('البصمة غير متوفرة على هذا الجهاز');
        return false;
      }

      if (!_isEnabled.value) {
        LoggerService.warning('البصمة غير مفعلة');
        return false;
      }

      return await _authenticateWithBiometric(
        reason: reason ?? 'تأكيد الهوية',
      );
    } catch (e, st) {
      LoggerService.error('خطأ في التحقق من البصمة', error: e, stackTrace: st);
      return false;
    }
  }

  // التحقق من البصمة (دالة داخلية)
  Future<bool> _authenticateWithBiometric({required String reason}) async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
        // authMessages: const [
        //   AndroidAuthMessages(
        //     signInTitle: 'تسجيل الدخول بالبصمة',
        //     cancelButton: 'إلغاء',
        //     goToSettingsButton: 'الإعدادات',
        //     goToSettingsDescription: 'يرجى تفعيل البصمة في الإعدادات',
        //     deviceCredentialsRequiredTitle: 'مطلوب تفعيل البصمة',
        //     deviceCredentialsRequiredDescription:
        //         'يرجى تفعيل البصمة في الإعدادات',
        //   ),
        //   IOSAuthMessages(
        //     cancelButton: 'إلغاء',
        //     goToSettingsButton: 'الإعدادات',
        //     goToSettingsDescription: 'يرجى تفعيل البصمة في الإعدادات',
        //     lockOut: 'البصمة معطلة مؤقتاً',
        //   ),
        // ],
      );

      if (isAuthenticated) {
        LoggerService.success('تم التحقق من البصمة بنجاح');
      } else {
        LoggerService.warning('فشل في التحقق من البصمة');
      }

      return isAuthenticated;
    } catch (e, st) {
      LoggerService.error('خطأ في التحقق من البصمة', error: e, stackTrace: st);
      return false;
    }
  }

  // التحقق من حالة البصمة
  Future<bool> isBiometricEnabled() async {
    return StorageService.getBool('biometric_enabled') ?? false;
  }

  // الحصول على نوع البصمة المتاح
  String getBiometricTypeName() {
    if (_availableBiometrics.isEmpty) return 'غير متوفر';

    if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'بصمة الإصبع';
    } else if (_availableBiometrics.contains(BiometricType.face)) {
      return 'التعرف على الوجه';
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return 'بصمة القزحية';
    } else {
      return 'المصادقة البيومترية';
    }
  }

  // التحقق من إمكانية استخدام البصمة
  bool canUseBiometric() {
    return _isAvailable.value && _isEnabled.value;
  }

  // إعادة تحميل حالة البصمة
  Future<void> refreshBiometricStatus() async {
    await _checkBiometricAvailability();
    _loadBiometricStatus();
  }

  // الحصول على إعدادات البصمة
  Map<String, dynamic> getBiometricSettings() {
    return {
      'isAvailable': _isAvailable.value,
      'isEnabled': _isEnabled.value,
      'availableTypes': _availableBiometrics.map((e) => e.toString()).toList(),
      'typeName': getBiometricTypeName(),
    };
  }
}
