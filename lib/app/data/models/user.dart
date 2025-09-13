import 'user_role.dart';

class User {
  final String id;
  final String uniqueId; // الرقم المميز 7 أرقام
  final String? email; // البريد الإلكتروني اختياري
  final String name;
  final String? profileImageUrl;
  final String? businessName; // اسم العمل (لأصحاب الأعمال)
  final UserRole role;
  final List<UserPermission> permissions;
  final bool isActive;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? metadata; // بيانات إضافية حسب الدور

  User({
    required this.id,
    required this.uniqueId,
    this.email,
    required this.name,
    this.profileImageUrl,
    this.businessName,
    required this.role,
    required this.permissions,
    this.isActive = true,
    this.isEmailVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.metadata,
  });

  // إنشاء مستخدم جديد
  factory User.create({
    required String uniqueId,
    String? email,
    required String name,
    required UserRole role,
    String? businessName,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return User(
      id: _generateId(),
      uniqueId: uniqueId,
      email: email,
      name: name,
      businessName: businessName,
      role: role,
      permissions: RolePermissions.getPermissionsForRole(role),
      createdAt: now,
      updatedAt: now,
      metadata: metadata,
    );
  }

  // نسخ مع تعديل
  User copyWith({
    String? id,
    String? uniqueId,
    String? email,
    String? name,
    String? profileImageUrl,
    String? businessName,
    UserRole? role,
    List<UserPermission>? permissions,
    bool? isActive,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      uniqueId: uniqueId ?? this.uniqueId,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      businessName: businessName ?? this.businessName,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uniqueId': uniqueId,
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'businessName': businessName,
      'role': role.value,
      'permissions': permissions.map((p) => p.value).toList(),
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  // إنشاء من JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      uniqueId: json['uniqueId'] as String,
      email: json['email'] as String?,
      name: json['name'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      businessName: json['businessName'] as String?,
      role: UserRole.fromString(json['role'] as String),
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((p) => UserPermission.fromString(p as String))
              .toList() ??
          [],
      isActive: json['isActive'] as bool? ?? true,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : (json['createdAt'] as DateTime? ?? DateTime.now()),
      updatedAt: json['updatedAt'] is String
          ? DateTime.parse(json['updatedAt'] as String)
          : (json['updatedAt'] as DateTime? ?? DateTime.now()),
      lastLoginAt: json['lastLoginAt'] != null
          ? (json['lastLoginAt'] is String
              ? DateTime.parse(json['lastLoginAt'] as String)
              : json['lastLoginAt'] as DateTime?)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // التحقق من الصلاحية
  bool hasPermission(UserPermission permission) {
    return permissions.contains(permission);
  }

  // التحقق من إمكانية الوصول لميزة
  bool canAccessFeature(String feature) {
    return RolePermissions.canAccessFeature(role, feature);
  }

  // التحقق من صحة البيانات
  bool get isValid {
    return id.isNotEmpty &&
        uniqueId.isNotEmpty &&
        name.isNotEmpty &&
        role != UserRole.customer; // العملاء لهم نموذج منفصل
  }

  // الحصول على الأحرف الأولى للاسم
  String get initials {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  // تحديث آخر تسجيل دخول
  User updateLastLogin() {
    return copyWith(lastLoginAt: DateTime.now());
  }

  // تفعيل/إلغاء تفعيل المستخدم
  User toggleActive() {
    return copyWith(isActive: !isActive);
  }

  // تحديث معلومات المستخدم
  User updateInfo({
    String? name,
    String? email,
    String? profileImageUrl,
    String? businessName,
  }) {
    return copyWith(
      name: name,
      email: email,
      profileImageUrl: profileImageUrl,
      businessName: businessName,
    );
  }

  // تحديث الصلاحيات
  User updatePermissions(List<UserPermission> newPermissions) {
    return copyWith(permissions: newPermissions);
  }

  // الحصول على ملخص المستخدم
  Map<String, dynamic> getSummary() {
    return {
      'id': id,
      'uniqueId': uniqueId,
      'name': name,
      'email': email,
      'businessName': businessName,
      'role': role.displayName,
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'permissionsCount': permissions.length,
    };
  }

  // تصدير بيانات المستخدم
  Map<String, dynamic> exportData() {
    return {
      ...toJson(),
      'permissionsCount': permissions.length,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  // توليد معرف فريد
  static String _generateId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond / 1000).round()}';
  }

  // مقارنة المستخدمين
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, uniqueId: $uniqueId, name: $name, role: ${role.displayName})';
  }
}
