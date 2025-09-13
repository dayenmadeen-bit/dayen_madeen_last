import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'storage_service.dart';
import 'security_service.dart';

/// خدمة المصادقة الآمنة
class SecureAuthService {
  static const String _businessOwnersKey = 'business_owners';
  static const String _customersKey = 'customers_auth';

  /// تسجيل مالك منشأة جديد
  static Future<bool> registerBusinessOwner({
    required String email,
    required String password,
    required String name,
    String? businessName,
    String? phone,
  }) async {
    try {
      // التحقق من عدم وجود البريد الإلكتروني مسبقاً
      if (await _isEmailExists(email)) {
        return false;
      }

      // تشفير كلمة المرور
      final hashedPassword = _hashPassword(password);

      // إنشاء بيانات مالك المنشأة
      final businessOwner = {
        'id': _generateId(),
        'email': email.toLowerCase().trim(),
        'password': hashedPassword,
        'name': name.trim(),
        'businessName': businessName?.trim(),
        'phone': phone?.trim(),
        'createdAt': DateTime.now().toIso8601String(),
        'isActive': true,
      };

      // حفظ البيانات
      final owners = await _getBusinessOwners();
      owners.add(businessOwner);
      await StorageService.setString(_businessOwnersKey, jsonEncode(owners));

      return true;
    } catch (e) {
      return false;
    }
  }

  /// تسجيل دخول مالك المنشأة
  static Future<Map<String, dynamic>?> loginBusinessOwner({
    required String email,
    required String password,
  }) async {
    try {
      final owners = await _getBusinessOwners();
      final hashedPassword = _hashPassword(password);

      for (final owner in owners) {
        if (owner['email'] == email.toLowerCase().trim() &&
            owner['password'] == hashedPassword &&
            owner['isActive'] == true) {

          // تحديث آخر تسجيل دخول
          owner['lastLogin'] = DateTime.now().toIso8601String();
          await StorageService.setString(_businessOwnersKey, jsonEncode(owners));

          // إرجاع بيانات المستخدم (بدون كلمة المرور)
          final userInfo = Map<String, dynamic>.from(owner);
          userInfo.remove('password');
          return userInfo;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // ===== إدارة بيانات الاعتماد للمصادقة البيومترية =====

  /// حفظ بيانات اعتماد مالك المنشأة للمصادقة البيومترية
  static Future<bool> saveBusinessOwnerCredentialsForBiometric({
    required String email,
    required String password,
  }) async {
    try {
      // التحقق من صحة بيانات الاعتماد أولاً
      final userInfo = await loginBusinessOwner(email: email, password: password);
      if (userInfo == null) {
        return false;
      }

      // تشفير البيانات باستخدام SecurityService
      final securityService = SecurityService.instance;
      final encryptedEmail = securityService.encryptText(email);
      final encryptedPassword = securityService.encryptText(password);

      // حفظ البيانات المشفرة
      await StorageService.setString('biometric_business_owner_email', encryptedEmail);
      await StorageService.setString('biometric_business_owner_password', encryptedPassword);
      await StorageService.setString('biometric_business_owner_id', userInfo['id']);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// استرجاع بيانات اعتماد مالك المنشأة المحفوظة للمصادقة البيومترية
  static Future<Map<String, String>?> getBusinessOwnerCredentialsForBiometric() async {
    try {
      final encryptedEmail = StorageService.getString('biometric_business_owner_email');
      final encryptedPassword = StorageService.getString('biometric_business_owner_password');
      final ownerId = StorageService.getString('biometric_business_owner_id');

      if (encryptedEmail == null || encryptedPassword == null || ownerId == null) {
        return null;
      }

      // فك تشفير البيانات
      final securityService = SecurityService.instance;
      final email = securityService.decryptText(encryptedEmail);
      final password = securityService.decryptText(encryptedPassword);

      if (email.isEmpty || password.isEmpty) {
        return null;
      }

      return {
        'email': email,
        'password': password,
        'id': ownerId,
      };
    } catch (e) {
      return null;
    }
  }

  /// التحقق من وجود بيانات اعتماد محفوظة لمالك المنشأة
  static Future<bool> hasBusinessOwnerBiometricCredentials() async {
    try {
      final credentials = await getBusinessOwnerCredentialsForBiometric();
      return credentials != null;
    } catch (e) {
      return false;
    }
  }

  /// حذف بيانات اعتماد مالك المنشأة المحفوظة للمصادقة البيومترية
  static Future<void> clearBusinessOwnerBiometricCredentials() async {
    try {
      await StorageService.remove('biometric_business_owner_email');
      await StorageService.remove('biometric_business_owner_password');
      await StorageService.remove('biometric_business_owner_id');
    } catch (e) {
      // تجاهل الأخطاء في الحذف
    }
  }

  /// تسجيل دخول مالك المنشأة باستخدام البصمة
  static Future<Map<String, dynamic>?> loginBusinessOwnerWithBiometric() async {
    try {
      // التحقق من وجود بيانات محفوظة
      final credentials = await getBusinessOwnerCredentialsForBiometric();
      if (credentials == null) {
        return null;
      }

      // تسجيل الدخول باستخدام البيانات المحفوظة
      return await loginBusinessOwner(
        email: credentials['email']!,
        password: credentials['password']!,
      );
    } catch (e) {
      return null;
    }
  }

  /// حفظ بيانات اعتماد الزبون للمصادقة البيومترية
  static Future<bool> saveClientCredentialsForBiometric({
    required String username,
    required String password,
  }) async {
    try {
      // التحقق من صحة بيانات الاعتماد أولاً
      final userInfo = await loginCustomer(username: username, password: password, businessOwnerId: 'mock_owner_id'); // Assuming mock_owner_id for now
      if (userInfo == null) {
        return false;
      }

      // تشفير البيانات باستخدام SecurityService
      final securityService = SecurityService.instance;
      final encryptedUsername = securityService.encryptText(username);
      final encryptedPassword = securityService.encryptText(password);

      // حفظ البيانات المشفرة
      await StorageService.setString('biometric_client_username', encryptedUsername);
      await StorageService.setString('biometric_client_password', encryptedPassword);
      await StorageService.setString('biometric_client_id', userInfo['id']);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// استرجاع بيانات اعتماد الزبون المحفوظة للمصادقة البيومترية
  static Future<Map<String, dynamic>?> getClientCredentialsForBiometric() async {
    try {
      final encryptedUsername = StorageService.getString('biometric_client_username');
      final encryptedPassword = StorageService.getString('biometric_client_password');
      final clientId = StorageService.getString('biometric_client_id');

      if (encryptedUsername == null || encryptedPassword == null || clientId == null) {
        return null;
      }

      // فك تشفير البيانات
      final securityService = SecurityService.instance;
      final username = securityService.decryptText(encryptedUsername);
      final password = securityService.decryptText(encryptedPassword);

      if (username.isEmpty || password.isEmpty) {
        return null;
      }

      return {
        'username': username,
        'password': password,
        'id': clientId,
      };
    } catch (e) {
      return null;
    }
  }

  /// تسجيل دخول العميل باستخدام البصمة
  static Future<Map<String, dynamic>?> loginClientWithBiometric() async {
    try {
      // التحقق من وجود بيانات محفوظة
      final credentials = await getClientCredentialsForBiometric();
      if (credentials == null) {
        return null;
      }

      // تسجيل الدخول باستخدام البيانات المحفوظة
      return await loginCustomer(
        username: credentials['username']!,
        password: credentials['password']!,
        businessOwnerId: 'mock_owner_id', // Assuming mock_owner_id for now
      );
    } catch (e) {
      return null;
    }
  }

  /// تسجيل عميل جديد
  static Future<bool> registerCustomer({
    required String username,
    required String password,
    required String businessOwnerId,
    String? fullName,
    String? phone,
  }) async {
    try {
      // التحقق من عدم وجود اسم المستخدم مسبقاً
      if (await _isUsernameExists(username, businessOwnerId)) {
        return false;
      }

      // تشفير كلمة المرور
      final hashedPassword = _hashPassword(password);

      // إنشاء بيانات العميل
      final customer = {
        'id': _generateId(),
        'username': username.toLowerCase().trim(),
        'password': hashedPassword,
        'fullName': fullName?.trim(),
        'phone': phone?.trim(),
        'businessOwnerId': businessOwnerId,
        'createdAt': DateTime.now().toIso8601String(),
        'isActive': true,
      };

      // حفظ البيانات
      final customers = await _getCustomers();
      customers.add(customer);
      await StorageService.setString(_customersKey, jsonEncode(customers));

      return true;
    } catch (e) {
      return false;
    }
  }

  /// تسجيل دخول العميل
  static Future<Map<String, dynamic>?> loginCustomer({
    required String username,
    required String password,
    required String businessOwnerId,
  }) async {
    try {
      final customers = await _getCustomers();
      final hashedPassword = _hashPassword(password);

      for (final customer in customers) {
        if (customer['username'] == username.toLowerCase().trim() &&
            customer['password'] == hashedPassword &&
            customer['businessOwnerId'] == businessOwnerId &&
            customer['isActive'] == true) {

          // تحديث آخر تسجيل دخول
          customer['lastLogin'] = DateTime.now().toIso8601String();
          await StorageService.setString(_customersKey, jsonEncode(customers));

          // إرجاع بيانات المستخدم (بدون كلمة المرور)
          final userInfo = Map<String, dynamic>.from(customer);
          userInfo.remove('password');
          return userInfo;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// تغيير كلمة المرور
  static Future<bool> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
    required bool isBusinessOwner,
  }) async {
    try {
      final oldHashedPassword = _hashPassword(oldPassword);
      final newHashedPassword = _hashPassword(newPassword);

      if (isBusinessOwner) {
        final owners = await _getBusinessOwners();
        final ownerIndex = owners.indexWhere((o) =>
          o['id'] == userId && o['password'] == oldHashedPassword);

        if (ownerIndex != -1) {
          owners[ownerIndex]['password'] = newHashedPassword;
          owners[ownerIndex]['updatedAt'] = DateTime.now().toIso8601String();
          await StorageService.setString(_businessOwnersKey, jsonEncode(owners));
          return true;
        }
      } else {
        final customers = await _getCustomers();
        final customerIndex = customers.indexWhere((c) =>
          c['id'] == userId && c['password'] == oldHashedPassword);

        if (customerIndex != -1) {
          customers[customerIndex]['password'] = newHashedPassword;
          customers[customerIndex]['updatedAt'] = DateTime.now().toIso8601String();
          await StorageService.setString(_customersKey, jsonEncode(customers));
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// إنشاء بيانات تجريبية للاختبار
  static Future<void> createTestData() async {
    // إنشاء مالك منشأة تجريبي
    await registerBusinessOwner(
      email: 'othman@gmail.com',
      password: '123456',
      name: 'عثمان',
      businessName: 'متجر عثمان',
      phone: '0501234567',
    );

    // الحصول على معرف مالك المنشأة
    final owners = await _getBusinessOwners();
    final ownerId = owners.first['id'];

    // إنشاء عميل تجريبي
    await registerCustomer(
      username: 'othman',
      password: '123456',
      businessOwnerId: ownerId,
      fullName: 'عثمان العميل',
      phone: '0507654321',
    );
  }

  // الدوال المساعدة الخاصة
  static Future<List<Map<String, dynamic>>> _getBusinessOwners() async {
    final data = StorageService.getString(_businessOwnersKey);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  static Future<List<Map<String, dynamic>>> _getCustomers() async {
    final data = StorageService.getString(_customersKey);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  static Future<bool> _isEmailExists(String email) async {
    final owners = await _getBusinessOwners();
    return owners.any((owner) => owner['email'] == email.toLowerCase().trim());
  }

  static Future<bool> _isUsernameExists(String username, String businessOwnerId) async {
    final customers = await _getCustomers();
    return customers.any((customer) =>
      customer['username'] == username.toLowerCase().trim() &&
      customer['businessOwnerId'] == businessOwnerId);
  }

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password + 'dayen_madeen_salt_2024');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}${1000 + Random().nextInt(9000)}';
  }
}
