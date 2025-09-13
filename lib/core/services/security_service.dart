import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:get/get.dart';
import 'storage_service.dart';

/// خدمة الأمان والمصادقة
class SecurityService extends GetxService {
  static SecurityService get instance => Get.find<SecurityService>();

  final LocalAuthentication _localAuth = LocalAuthentication();

  // مفاتيح التخزين
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyPasswordHash = 'password_hash';
  static const String _keyPasswordSalt = 'password_salt';
  static const String _keyEncryptionKey = 'encryption_key';
  static const String _keyFailedAttempts = 'failed_attempts';
  static const String _keyLastFailedAttempt = 'last_failed_attempt';
  static const String _keyLockoutUntil = 'lockout_until';

  // إعدادات الأمان
  static const int maxFailedAttempts = 5;
  static const int lockoutDurationMinutes = 30;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeSecurity();
  }

  /// تهيئة خدمة الأمان
  Future<void> _initializeSecurity() async {
    // إنشاء مفتاح التشفير إذا لم يكن موجوداً
    if (StorageService.getString(_keyEncryptionKey) == null) {
      await _generateEncryptionKey();
    }
  }

  /// التحقق من توفر المصادقة البيومترية
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// الحصول على أنواع المصادقة البيومترية المتاحة
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// تفعيل المصادقة البيومترية
  Future<bool> enableBiometric() async {
    try {
      if (!await isBiometricAvailable()) {
        return false;
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'يرجى التحقق من هويتك لتفعيل المصادقة البيومترية',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        await StorageService.setBool(_keyBiometricEnabled, true);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// إلغاء تفعيل المصادقة البيومترية
  Future<void> disableBiometric() async {
    await StorageService.setBool(_keyBiometricEnabled, false);
  }

  /// التحقق من تفعيل المصادقة البيومترية
  bool get isBiometricEnabled {
    return StorageService.getBool(_keyBiometricEnabled) ?? false;
  }

  /// المصادقة البيومترية
  Future<bool> authenticateWithBiometric() async {
    try {
      if (!isBiometricEnabled || !await isBiometricAvailable()) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: 'يرجى التحقق من هويتك للوصول إلى التطبيق',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  /// تعيين كلمة مرور
  Future<void> setPassword(String password) async {
    final salt = _generateSalt();
    final hash = _hashPassword(password, salt);

    await StorageService.setString(_keyPasswordHash, hash);
    await StorageService.setString(_keyPasswordSalt, salt);
  }

  /// التحقق من كلمة المرور
  Future<bool> verifyPassword(String password) async {
    // التحقق من القفل
    if (await isLockedOut()) {
      return false;
    }

    final storedHash = StorageService.getString(_keyPasswordHash);
    final salt = StorageService.getString(_keyPasswordSalt);

    if (storedHash == null || salt == null) {
      return false;
    }

    final hash = _hashPassword(password, salt);
    final isValid = hash == storedHash;

    if (isValid) {
      await _resetFailedAttempts();
    } else {
      await _recordFailedAttempt();
    }

    return isValid;
  }

  /// التحقق من وجود كلمة مرور
  bool get hasPassword {
    return StorageService.getString(_keyPasswordHash) != null;
  }

  /// تشفير النص
  String encryptText(String text) {
    final key = StorageService.getString(_keyEncryptionKey) ?? '';
    final bytes = utf8.encode(text);
    final keyBytes = utf8.encode(key);

    final encrypted = <int>[];
    for (int i = 0; i < bytes.length; i++) {
      encrypted.add(bytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return base64.encode(encrypted);
  }

  /// فك تشفير النص
  String decryptText(String encryptedText) {
    try {
      final key = StorageService.getString(_keyEncryptionKey) ?? '';
      final encrypted = base64.decode(encryptedText);
      final keyBytes = utf8.encode(key);

      final decrypted = <int>[];
      for (int i = 0; i < encrypted.length; i++) {
        decrypted.add(encrypted[i] ^ keyBytes[i % keyBytes.length]);
      }

      return utf8.decode(decrypted);
    } catch (e) {
      return '';
    }
  }

  /// التحقق من حالة القفل
  Future<bool> isLockedOut() async {
    final lockoutUntilString = StorageService.getString(_keyLockoutUntil);
    if (lockoutUntilString == null) return false;

    final lockoutUntil = DateTime.tryParse(lockoutUntilString);
    if (lockoutUntil == null) return false;

    return DateTime.now().isBefore(lockoutUntil);
  }

  /// الحصول على وقت انتهاء القفل
  Future<DateTime?> getLockoutEndTime() async {
    final lockoutUntilString = StorageService.getString(_keyLockoutUntil);
    if (lockoutUntilString == null) return null;

    return DateTime.tryParse(lockoutUntilString);
  }

  /// الحصول على عدد المحاولات الفاشلة
  int get failedAttempts {
    return StorageService.getInt(_keyFailedAttempts) ?? 0;
  }

  /// إعادة تعيين المحاولات الفاشلة
  Future<void> _resetFailedAttempts() async {
    await StorageService.remove(_keyFailedAttempts);
    await StorageService.remove(_keyLastFailedAttempt);
    await StorageService.remove(_keyLockoutUntil);
  }

  /// تسجيل محاولة فاشلة
  Future<void> _recordFailedAttempt() async {
    final currentAttempts = failedAttempts + 1;
    await StorageService.setInt(_keyFailedAttempts, currentAttempts);
    await StorageService.setString(_keyLastFailedAttempt, DateTime.now().toIso8601String());

    if (currentAttempts >= maxFailedAttempts) {
      final lockoutUntil = DateTime.now().add(const Duration(minutes: lockoutDurationMinutes));
      await StorageService.setString(_keyLockoutUntil, lockoutUntil.toIso8601String());
    }
  }

  /// إنشاء مفتاح التشفير
  Future<void> _generateEncryptionKey() async {
    final random = Random.secure();
    final key = List.generate(32, (index) => random.nextInt(256));
    await StorageService.setString(_keyEncryptionKey, base64.encode(key));
  }

  /// إنشاء salt عشوائي
  String _generateSalt() {
    final random = Random.secure();
    final salt = List.generate(16, (index) => random.nextInt(256));
    return base64.encode(salt);
  }

  /// إنشاء salt عشوائي (public)
  String generateSalt() {
    return _generateSalt();
  }

  /// تشفير كلمة المرور
  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// تشفير كلمة المرور (public)
  String hashPassword(String password, String salt) {
    return _hashPassword(password, salt);
  }

  /// الحصول على معلومات الأمان
  Future<Map<String, dynamic>> getSecurityInfo() async {
    final locked = await isLockedOut();
    return {
      'hasBiometric': isBiometricEnabled,
      'hasPassword': hasPassword,
      'failedAttempts': failedAttempts,
      'isLockedOut': locked,
      'maxFailedAttempts': maxFailedAttempts,
      'lockoutDurationMinutes': lockoutDurationMinutes,
    };
  }
}
