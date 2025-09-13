import 'dart:convert';
import 'package:get/get.dart';
import 'storage_service.dart';
import 'logger_service.dart';
import 'security_service.dart';

/// نموذج بيانات الاعتماد المحفوظة
class SavedCredential {
  final String id;
  final String storeName;
  final String username;
  final String password;
  final DateTime createdAt;
  final DateTime lastUsed;

  SavedCredential({
    required this.id,
    required this.storeName,
    required this.username,
    required this.password,
    required this.createdAt,
    required this.lastUsed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeName': storeName,
      'username': username,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed.toIso8601String(),
    };
  }

  factory SavedCredential.fromJson(Map<String, dynamic> json) {
    return SavedCredential(
      id: json['id'],
      storeName: json['storeName'],
      username: json['username'],
      password: json['password'],
      createdAt: DateTime.parse(json['createdAt']),
      lastUsed: DateTime.parse(json['lastUsed']),
    );
  }

  SavedCredential copyWith({
    String? id,
    String? storeName,
    String? username,
    String? password,
    DateTime? createdAt,
    DateTime? lastUsed,
  }) {
    return SavedCredential(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      username: username ?? this.username,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }
}

/// خدمة إدارة خزنة بيانات الاعتماد
class CredentialsVaultService extends GetxService {
  static CredentialsVaultService get instance => Get.find();
  
  static const String _keyCredentials = 'saved_credentials';
  
  final RxList<SavedCredential> _savedCredentials = <SavedCredential>[].obs;
  
  List<SavedCredential> get savedCredentials => _savedCredentials;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await loadCredentials();
  }

  /// تحميل بيانات الاعتماد المحفوظة
  Future<void> loadCredentials() async {
    try {
      final String? credentialsJson = StorageService.getString(_keyCredentials);
      if (credentialsJson != null) {
        final List<dynamic> credentialsList = jsonDecode(credentialsJson);
        _savedCredentials.value = credentialsList
            .map((json) => SavedCredential.fromJson(json))
            .map((cred) => cred.copyWith(
                  // فك تشفير كلمة المرور للعرض/الاستخدام داخل التطبيق فقط
                  password: SecurityService.instance.decryptText(cred.password),
                ))
            .toList();
        
        // ترتيب حسب آخر استخدام
        _savedCredentials.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
      }
    } catch (e) {
      LoggerService.error('خطأ في تحميل بيانات الاعتماد', error: e);
    }
  }

  /// حفظ بيانات الاعتماد
  Future<void> saveCredentials() async {
    try {
      final String credentialsJson = jsonEncode(
        _savedCredentials.map((credential) => credential.toJson()).toList(),
      );
      await StorageService.setString(_keyCredentials, credentialsJson);
    } catch (e) {
      LoggerService.error('خطأ في حفظ بيانات الاعتماد', error: e);
    }
  }

  /// إضافة بيانات اعتماد جديدة
  Future<void> addCredential({
    required String storeName,
    required String username,
    required String password,
  }) async {
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    final DateTime now = DateTime.now();

    // تشفير كلمة المرور قبل التخزين
    final encryptedPassword = SecurityService.instance.encryptText(password);
    
    final SavedCredential newCredential = SavedCredential(
      id: id,
      storeName: storeName,
      username: username,
      password: encryptedPassword,
      createdAt: now,
      lastUsed: now,
    );
    
    // التحقق من عدم وجود نفس المتجر واسم المستخدم
    final existingIndex = _savedCredentials.indexWhere(
      (credential) => credential.storeName == storeName && credential.username == username,
    );
    
    if (existingIndex != -1) {
      // تحديث بيانات الاعتماد الموجودة
      _savedCredentials[existingIndex] = newCredential.copyWith(
        id: _savedCredentials[existingIndex].id,
        createdAt: _savedCredentials[existingIndex].createdAt,
      );
    } else {
      // إضافة بيانات اعتماد جديدة
      _savedCredentials.add(newCredential);
    }
    
    await saveCredentials();
  }

  /// تحديث وقت آخر استخدام
  Future<void> updateLastUsed(String credentialId) async {
    final index = _savedCredentials.indexWhere((credential) => credential.id == credentialId);
    if (index != -1) {
      _savedCredentials[index] = _savedCredentials[index].copyWith(
        lastUsed: DateTime.now(),
      );
      
      // إعادة ترتيب القائمة
      _savedCredentials.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
      
      await saveCredentials();
    }
  }

  /// حذف بيانات اعتماد
  Future<void> deleteCredential(String credentialId) async {
    _savedCredentials.removeWhere((credential) => credential.id == credentialId);
    await saveCredentials();
  }

  /// تحديث بيانات اعتماد
  Future<void> updateCredential({
    required String credentialId,
    required String storeName,
    required String username,
    required String password,
  }) async {
    final index = _savedCredentials.indexWhere((credential) => credential.id == credentialId);
    if (index != -1) {
      final encryptedPassword = SecurityService.instance.encryptText(password);
      _savedCredentials[index] = _savedCredentials[index].copyWith(
        storeName: storeName,
        username: username,
        password: encryptedPassword,
        lastUsed: DateTime.now(),
      );
      await saveCredentials();
    }
  }

  /// البحث في بيانات الاعتماد
  List<SavedCredential> searchCredentials(String query) {
    if (query.isEmpty) return _savedCredentials;
    
    return _savedCredentials.where((credential) {
      return credential.storeName.toLowerCase().contains(query.toLowerCase()) ||
             credential.username.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// مسح جميع بيانات الاعتماد
  Future<void> clearAllCredentials() async {
    _savedCredentials.clear();
    await saveCredentials();
  }
}
