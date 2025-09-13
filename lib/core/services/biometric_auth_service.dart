import 'package:get/get.dart';
import 'storage_service.dart';
import 'logger_service.dart';
import 'security_service.dart';
import 'auth_service.dart';

/// خدمة المصادقة البيومترية المتقدمة
class BiometricAuthService extends GetxService {
  static BiometricAuthService get instance => Get.find<BiometricAuthService>();

  final SecurityService _securityService = Get.find<SecurityService>();
  final AuthService _authService = Get.find<AuthService>();

  // مفاتيح التخزين للحسابات المختلفة
  static const String _businessOwnerKey = 'biometric_business_owner';
  static const String _employeeKey = 'biometric_employee';
  static const String _customerKey = 'biometric_customer';

  @override
  void onInit() {
    super.onInit();
    LoggerService.info('تم تهيئة خدمة المصادقة البيومترية');
  }

  /// حفظ بيانات اعتماد مالك المنشأة للمصادقة البيومترية
  Future<bool> saveBusinessOwnerCredentials({
    required String uniqueId,
    required String password,
    required String userType,
  }) async {
    try {
      // تشفير البيانات
      final encryptedUniqueId = _securityService.encryptText(uniqueId);
      final encryptedPassword = _securityService.encryptText(password);

      // حفظ البيانات مع نوع المستخدم
      await StorageService.setString(
          '${_businessOwnerKey}_unique_id', encryptedUniqueId);
      await StorageService.setString(
          '${_businessOwnerKey}_password', encryptedPassword);
      await StorageService.setString(
          '${_businessOwnerKey}_user_type', userType);
      await StorageService.setString(
          '${_businessOwnerKey}_timestamp', DateTime.now().toIso8601String());

      LoggerService.success('تم حفظ بيانات مالك المنشأة للمصادقة البيومترية');
      return true;
    } catch (e) {
      LoggerService.error('فشل في حفظ بيانات مالك المنشأة', error: e);
      return false;
    }
  }

  /// حفظ بيانات اعتماد الموظف للمصادقة البيومترية
  Future<bool> saveEmployeeCredentials({
    required String uniqueId,
    required String password,
    required String userType,
    required String ownerId,
  }) async {
    try {
      // تشفير البيانات
      final encryptedUniqueId = _securityService.encryptText(uniqueId);
      final encryptedPassword = _securityService.encryptText(password);

      // حفظ البيانات مع معرف المالك
      await StorageService.setString(
          '${_employeeKey}_unique_id', encryptedUniqueId);
      await StorageService.setString(
          '${_employeeKey}_password', encryptedPassword);
      await StorageService.setString('${_employeeKey}_user_type', userType);
      await StorageService.setString('${_employeeKey}_owner_id', ownerId);
      await StorageService.setString(
          '${_employeeKey}_timestamp', DateTime.now().toIso8601String());

      LoggerService.success('تم حفظ بيانات الموظف للمصادقة البيومترية');
      return true;
    } catch (e) {
      LoggerService.error('فشل في حفظ بيانات الموظف', error: e);
      return false;
    }
  }

  /// حفظ بيانات اعتماد الزبون للمصادقة البيومترية
  Future<bool> saveCustomerCredentials({
    required String uniqueId,
    required String password,
    required String userType,
    required String businessOwnerId,
  }) async {
    try {
      // تشفير البيانات
      final encryptedUniqueId = _securityService.encryptText(uniqueId);
      final encryptedPassword = _securityService.encryptText(password);

      // حفظ البيانات مع معرف مالك المنشأة
      await StorageService.setString(
          '${_customerKey}_unique_id', encryptedUniqueId);
      await StorageService.setString(
          '${_customerKey}_password', encryptedPassword);
      await StorageService.setString('${_customerKey}_user_type', userType);
      await StorageService.setString(
          '${_customerKey}_business_owner_id', businessOwnerId);
      await StorageService.setString(
          '${_customerKey}_timestamp', DateTime.now().toIso8601String());

      LoggerService.success('تم حفظ بيانات الزبون للمصادقة البيومترية');
      return true;
    } catch (e) {
      LoggerService.error('فشل في حفظ بيانات الزبون', error: e);
      return false;
    }
  }

  /// تسجيل الدخول بالبصمة حسب نوع المستخدم
  Future<Map<String, dynamic>?> loginWithBiometric({
    required String userType, // 'owner', 'employee', 'customer'
  }) async {
    try {
      // التحقق من تفعيل البصمة
      if (!_securityService.isBiometricEnabled) {
        LoggerService.warning('المصادقة البيومترية غير مفعلة');
        return null;
      }

      // التحقق من البصمة
      final isAuthenticated =
          await _securityService.authenticateWithBiometric();
      if (!isAuthenticated) {
        LoggerService.warning('فشل في التحقق من البصمة');
        return null;
      }

      // الحصول على البيانات المحفوظة حسب نوع المستخدم
      Map<String, dynamic>? credentials;
      switch (userType) {
        case 'owner':
          credentials = await _getBusinessOwnerCredentials();
          break;
        case 'employee':
          credentials = await _getEmployeeCredentials();
          break;
        case 'customer':
          credentials = await _getCustomerCredentials();
          break;
        default:
          LoggerService.error('نوع المستخدم غير صحيح: $userType');
          return null;
      }

      if (credentials == null) {
        LoggerService.warning('لا توجد بيانات محفوظة لنوع المستخدم: $userType');
        return null;
      }

      // تسجيل الدخول باستخدام البيانات المحفوظة
      final loginResult = await _authService.signInWithUniqueId(
        credentials['uniqueId'],
        credentials['password'],
      );

      if (loginResult) {
        LoggerService.success('تم تسجيل الدخول بالبصمة بنجاح: $userType');
        return {
          'success': true,
          'userType': userType,
          'uniqueId': credentials['uniqueId'],
        };
      } else {
        LoggerService.error('فشل في تسجيل الدخول بالبصمة');
        return null;
      }
    } catch (e, st) {
      LoggerService.error('خطأ في تسجيل الدخول بالبصمة',
          error: e, stackTrace: st);
      return null;
    }
  }

  /// الحصول على بيانات مالك المنشأة المحفوظة
  Future<Map<String, dynamic>?> _getBusinessOwnerCredentials() async {
    try {
      final encryptedUniqueId =
          StorageService.getString('${_businessOwnerKey}_unique_id');
      final encryptedPassword =
          StorageService.getString('${_businessOwnerKey}_password');

      if (encryptedUniqueId == null || encryptedPassword == null) {
        return null;
      }

      final uniqueId = _securityService.decryptText(encryptedUniqueId);
      final password = _securityService.decryptText(encryptedPassword);

      if (uniqueId.isEmpty || password.isEmpty) {
        return null;
      }

      return {
        'uniqueId': uniqueId,
        'password': password,
        'userType': 'owner',
      };
    } catch (e) {
      LoggerService.error('فشل في استرجاع بيانات مالك المنشأة', error: e);
      return null;
    }
  }

  /// الحصول على بيانات الموظف المحفوظة
  Future<Map<String, dynamic>?> _getEmployeeCredentials() async {
    try {
      final encryptedUniqueId =
          StorageService.getString('${_employeeKey}_unique_id');
      final encryptedPassword =
          StorageService.getString('${_employeeKey}_password');

      if (encryptedUniqueId == null || encryptedPassword == null) {
        return null;
      }

      final uniqueId = _securityService.decryptText(encryptedUniqueId);
      final password = _securityService.decryptText(encryptedPassword);

      if (uniqueId.isEmpty || password.isEmpty) {
        return null;
      }

      return {
        'uniqueId': uniqueId,
        'password': password,
        'userType': 'employee',
        'ownerId': StorageService.getString('${_employeeKey}_owner_id'),
      };
    } catch (e) {
      LoggerService.error('فشل في استرجاع بيانات الموظف', error: e);
      return null;
    }
  }

  /// الحصول على بيانات الزبون المحفوظة
  Future<Map<String, dynamic>?> _getCustomerCredentials() async {
    try {
      final encryptedUniqueId =
          StorageService.getString('${_customerKey}_unique_id');
      final encryptedPassword =
          StorageService.getString('${_customerKey}_password');

      if (encryptedUniqueId == null || encryptedPassword == null) {
        return null;
      }

      final uniqueId = _securityService.decryptText(encryptedUniqueId);
      final password = _securityService.decryptText(encryptedPassword);

      if (uniqueId.isEmpty || password.isEmpty) {
        return null;
      }

      return {
        'uniqueId': uniqueId,
        'password': password,
        'userType': 'customer',
        'businessOwnerId':
            StorageService.getString('${_customerKey}_business_owner_id'),
      };
    } catch (e) {
      LoggerService.error('فشل في استرجاع بيانات الزبون', error: e);
      return null;
    }
  }

  /// التحقق من وجود بيانات محفوظة لنوع معين
  bool hasStoredCredentials(String userType) {
    switch (userType) {
      case 'owner':
        return StorageService.getString('${_businessOwnerKey}_unique_id') !=
            null;
      case 'employee':
        return StorageService.getString('${_employeeKey}_unique_id') != null;
      case 'customer':
        return StorageService.getString('${_customerKey}_unique_id') != null;
      default:
        return false;
    }
  }

  /// حذف البيانات المحفوظة لنوع معين
  Future<void> clearStoredCredentials(String userType) async {
    try {
      switch (userType) {
        case 'owner':
          await StorageService.remove('${_businessOwnerKey}_unique_id');
          await StorageService.remove('${_businessOwnerKey}_password');
          await StorageService.remove('${_businessOwnerKey}_user_type');
          await StorageService.remove('${_businessOwnerKey}_timestamp');
          break;
        case 'employee':
          await StorageService.remove('${_employeeKey}_unique_id');
          await StorageService.remove('${_employeeKey}_password');
          await StorageService.remove('${_employeeKey}_user_type');
          await StorageService.remove('${_employeeKey}_owner_id');
          await StorageService.remove('${_employeeKey}_timestamp');
          break;
        case 'customer':
          await StorageService.remove('${_customerKey}_unique_id');
          await StorageService.remove('${_customerKey}_password');
          await StorageService.remove('${_customerKey}_user_type');
          await StorageService.remove('${_customerKey}_business_owner_id');
          await StorageService.remove('${_customerKey}_timestamp');
          break;
      }
      LoggerService.success('تم حذف البيانات المحفوظة: $userType');
    } catch (e) {
      LoggerService.error('فشل في حذف البيانات المحفوظة', error: e);
    }
  }

  /// الحصول على جميع أنواع الحسابات المحفوظة
  List<String> getStoredAccountTypes() {
    final types = <String>[];

    if (hasStoredCredentials('owner')) {
      types.add('owner');
    }
    if (hasStoredCredentials('employee')) {
      types.add('employee');
    }
    if (hasStoredCredentials('customer')) {
      types.add('customer');
    }

    return types;
  }

  /// الحصول على معلومات الحسابات المحفوظة
  Map<String, Map<String, dynamic>> getStoredAccountsInfo() {
    final accounts = <String, Map<String, dynamic>>{};

    try {
      // معلومات مالك المنشأة
      if (hasStoredCredentials('owner')) {
        final timestamp =
            StorageService.getString('${_businessOwnerKey}_timestamp');
        accounts['owner'] = {
          'type': 'مالك منشأة',
          'timestamp': timestamp,
          'hasCredentials': true,
        };
      }

      // معلومات الموظف
      if (hasStoredCredentials('employee')) {
        final timestamp = StorageService.getString('${_employeeKey}_timestamp');
        accounts['employee'] = {
          'type': 'موظف',
          'timestamp': timestamp,
          'hasCredentials': true,
        };
      }

      // معلومات الزبون
      if (hasStoredCredentials('customer')) {
        final timestamp = StorageService.getString('${_customerKey}_timestamp');
        accounts['customer'] = {
          'type': 'زبون',
          'timestamp': timestamp,
          'hasCredentials': true,
        };
      }
    } catch (e) {
      LoggerService.error('فشل في الحصول على معلومات الحسابات', error: e);
    }

    return accounts;
  }
}
