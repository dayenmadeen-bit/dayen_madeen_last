import 'package:uuid/uuid.dart';

/// نموذج بيانات مالك المنشأة
class BusinessOwner {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final String passwordSalt;
  final String? phone;
  final String? businessName;
  final String? address;
  final String? profileImagePath;
  final String userType;
  final bool isActive;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BusinessOwner({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.passwordSalt,
    this.phone,
    this.businessName,
    this.address,
    this.profileImagePath,
    this.userType = 'business_owner',
    this.isActive = true,
    this.emailVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// إنشاء مالك منشأة جديد
  factory BusinessOwner.create({
    required String name,
    required String email,
    required String passwordHash,
    required String passwordSalt,
    String? phone,
    String? businessName,
    String? address,
    String? profileImagePath,
  }) {
    final now = DateTime.now();
    return BusinessOwner(
      id: const Uuid().v4(),
      name: name,
      email: email,
      passwordHash: passwordHash,
      passwordSalt: passwordSalt,
      phone: phone,
      businessName: businessName,
      address: address,
      profileImagePath: profileImagePath,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// تحويل من JSON
  factory BusinessOwner.fromJson(Map<String, dynamic> json) {
    return BusinessOwner(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      passwordHash: json['password_hash'] as String,
      passwordSalt: json['password_salt'] as String,
      phone: json['phone'] as String?,
      businessName: json['business_name'] as String?,
      address: json['address'] as String?,
      profileImagePath: json['profile_image_path'] as String?,
      userType: json['user_type'] as String? ?? 'business_owner',
      isActive: (json['is_active'] as int? ?? 1) == 1,
      emailVerified: (json['email_verified'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'password_salt': passwordSalt,
      'phone': phone,
      'business_name': businessName,
      'address': address,
      'profile_image_path': profileImagePath,
      'user_type': userType,
      'is_active': isActive ? 1 : 0,
      'email_verified': emailVerified ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// تحويل إلى JSON لقاعدة البيانات
  Map<String, dynamic> toDatabaseJson() {
    return toJson();
  }

  /// إنشاء نسخة محدثة
  BusinessOwner copyWith({
    String? id,
    String? name,
    String? email,
    String? passwordHash,
    String? passwordSalt,
    String? phone,
    String? businessName,
    String? address,
    String? profileImagePath,
    String? userType,
    bool? isActive,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusinessOwner(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      phone: phone ?? this.phone,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      userType: userType ?? this.userType,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// تحديث كلمة المرور
  BusinessOwner updatePassword(String newPasswordHash, String newPasswordSalt) {
    return copyWith(
      passwordHash: newPasswordHash,
      passwordSalt: newPasswordSalt,
      updatedAt: DateTime.now(),
    );
  }

  /// تحديث الملف الشخصي
  BusinessOwner updateProfile({
    String? name,
    String? phone,
    String? businessName,
    String? address,
    String? profileImagePath,
  }) {
    return copyWith(
      name: name,
      phone: phone,
      businessName: businessName,
      address: address,
      profileImagePath: profileImagePath,
      updatedAt: DateTime.now(),
    );
  }

  /// تفعيل البريد الإلكتروني
  BusinessOwner verifyEmail() {
    return copyWith(
      emailVerified: true,
      updatedAt: DateTime.now(),
    );
  }

  /// تفعيل/إلغاء تفعيل الحساب
  BusinessOwner toggleActive() {
    return copyWith(
      isActive: !isActive,
      updatedAt: DateTime.now(),
    );
  }

  /// الحصول على الاسم المعروض
  String get displayName {
    if (businessName != null && businessName!.isNotEmpty) {
      return businessName!;
    }
    return name;
  }

  /// الحصول على الأحرف الأولى للاسم
  String get initials {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return 'BO';
  }

  /// التحقق من صحة البيانات
  bool get isValid {
    return id.isNotEmpty &&
        name.isNotEmpty &&
        email.isNotEmpty &&
        passwordHash.isNotEmpty &&
        passwordSalt.isNotEmpty;
  }

  /// التحقق من اكتمال الملف الشخصي
  bool get isProfileComplete {
    return isValid &&
        phone != null &&
        phone!.isNotEmpty &&
        businessName != null &&
        businessName!.isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BusinessOwner && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BusinessOwner(id: $id, name: $name, email: $email, businessName: $businessName, isActive: $isActive)';
  }
}

/// بيانات إنشاء مالك منشأة جديد
class BusinessOwnerData {
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? businessName;
  final String? address;

  const BusinessOwnerData({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.businessName,
    this.address,
  });

  /// التحقق من صحة البيانات
  bool get isValid {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        password.length >= 6;
  }

  /// الحصول على رسائل الأخطاء
  List<String> get validationErrors {
    final errors = <String>[];
    
    if (name.isEmpty) {
      errors.add('الاسم مطلوب');
    }
    
    if (email.isEmpty) {
      errors.add('البريد الإلكتروني مطلوب');
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      errors.add('البريد الإلكتروني غير صحيح');
    }
    
    if (password.isEmpty) {
      errors.add('كلمة المرور مطلوبة');
    } else if (password.length < 6) {
      errors.add('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
    }
    
    return errors;
  }

  @override
  String toString() {
    return 'BusinessOwnerData(name: $name, email: $email, businessName: $businessName)';
  }
}
