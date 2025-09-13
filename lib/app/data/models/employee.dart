import 'dart:convert';
import 'package:uuid/uuid.dart';

/// أنواع الصلاحيات المتاحة للموظفين
enum Permission {
  // صلاحيات العملاء
  viewCustomers(
      'view_customers', 'عرض العملاء', 'يمكن للموظف عرض قائمة العملاء'),
  addCustomers('add_customers', 'إضافة عملاء', 'يمكن للموظف إضافة عملاء جدد'),
  editCustomers(
      'edit_customers', 'تعديل العملاء', 'يمكن للموظف تعديل بيانات العملاء'),
  deleteCustomers('delete_customers', 'حذف العملاء', 'يمكن للموظف حذف العملاء'),

  // صلاحيات الديون
  viewDebts('view_debts', 'عرض الديون', 'يمكن للموظف عرض قائمة الديون'),
  addDebts('add_debts', 'إضافة ديون', 'يمكن للموظف إضافة ديون جديدة'),
  editDebts('edit_debts', 'تعديل الديون', 'يمكن للموظف تعديل الديون'),
  deleteDebts('delete_debts', 'حذف الديون', 'يمكن للموظف حذف الديون'),

  // صلاحيات المدفوعات
  viewPayments(
      'view_payments', 'عرض المدفوعات', 'يمكن للموظف عرض قائمة المدفوعات'),
  addPayments(
      'add_payments', 'إضافة مدفوعات', 'يمكن للموظف إضافة مدفوعات جديدة'),
  editPayments(
      'edit_payments', 'تعديل المدفوعات', 'يمكن للموظف تعديل المدفوعات'),
  deletePayments(
      'delete_payments', 'حذف المدفوعات', 'يمكن للموظف حذف المدفوعات'),

  // صلاحيات التقارير
  viewReports('view_reports', 'عرض التقارير', 'يمكن للموظف عرض التقارير'),
  exportReports(
      'export_reports', 'تصدير التقارير', 'يمكن للموظف تصدير التقارير'),

  // صلاحيات الإعدادات
  manageSettings('manage_settings', 'إدارة الإعدادات',
      'يمكن للموظف إدارة إعدادات التطبيق'),
  manageEmployees('manage_employees', 'إدارة الموظفين',
      'يمكن للموظف إدارة الموظفين الآخرين');

  const Permission(this.value, this.displayName, this.description);

  final String value;
  final String displayName;
  final String description;

  static Permission? fromValue(String value) {
    for (final permission in Permission.values) {
      if (permission.value == value) {
        return permission;
      }
    }
    return null;
  }
}

/// نموذج بيانات الموظف
class Employee {
  final String id;
  final String businessOwnerId;
  final String name;
  final String uniqueId; // الرقم المميز 7 خانات
  final String? email; // البريد الإلكتروني اختياري
  final String? phone; // رقم الهاتف اختياري
  final String passwordHash;
  final String passwordSalt;
  final List<Permission> permissions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Employee({
    required this.id,
    required this.businessOwnerId,
    required this.name,
    required this.uniqueId,
    this.email,
    this.phone,
    required this.passwordHash,
    required this.passwordSalt,
    required this.permissions,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// إنشاء موظف جديد
  factory Employee.create({
    required String businessOwnerId,
    required String name,
    required String uniqueId,
    String? email,
    String? phone,
    required String passwordHash,
    required String passwordSalt,
    List<Permission>? permissions,
  }) {
    final now = DateTime.now();
    return Employee(
      id: const Uuid().v4(),
      businessOwnerId: businessOwnerId,
      name: name,
      uniqueId: uniqueId,
      email: email,
      phone: phone,
      passwordHash: passwordHash,
      passwordSalt: passwordSalt,
      permissions: permissions ?? [],
      createdAt: now,
      updatedAt: now,
    );
  }

  /// تحويل من JSON
  factory Employee.fromJson(Map<String, dynamic> json) {
    final permissionsJson = json['permissions'] as String? ?? '[]';
    final permissionsList = (jsonDecode(permissionsJson) as List<dynamic>)
        .map((e) => Permission.fromValue(e as String))
        .where((e) => e != null)
        .cast<Permission>()
        .toList();

    return Employee(
      id: json['id'] as String,
      businessOwnerId: json['business_owner_id'] as String,
      name: json['name'] as String,
      uniqueId: json['unique_id'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      passwordHash: json['password_hash'] as String,
      passwordSalt: json['password_salt'] as String,
      permissions: permissionsList,
      isActive: (json['is_active'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    final permissionsJson = jsonEncode(
      permissions.map((e) => e.value).toList(),
    );

    return {
      'id': id,
      'business_owner_id': businessOwnerId,
      'name': name,
      'unique_id': uniqueId,
      'email': email,
      'phone': phone,
      'password_hash': passwordHash,
      'password_salt': passwordSalt,
      'permissions': permissionsJson,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// تحويل إلى JSON لقاعدة البيانات
  Map<String, dynamic> toDatabaseJson() {
    return toJson();
  }

  /// إنشاء نسخة محدثة
  Employee copyWith({
    String? id,
    String? businessOwnerId,
    String? name,
    String? uniqueId,
    String? email,
    String? phone,
    String? passwordHash,
    String? passwordSalt,
    List<Permission>? permissions,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      businessOwnerId: businessOwnerId ?? this.businessOwnerId,
      name: name ?? this.name,
      uniqueId: uniqueId ?? this.uniqueId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// تحديث كلمة المرور
  Employee updatePassword(String newPasswordHash, String newPasswordSalt) {
    return copyWith(
      passwordHash: newPasswordHash,
      passwordSalt: newPasswordSalt,
      updatedAt: DateTime.now(),
    );
  }

  /// تحديث الصلاحيات
  Employee updatePermissions(List<Permission> newPermissions) {
    return copyWith(
      permissions: newPermissions,
      updatedAt: DateTime.now(),
    );
  }

  /// إضافة صلاحية
  Employee addPermission(Permission permission) {
    if (permissions.contains(permission)) {
      return this;
    }
    final newPermissions = List<Permission>.from(permissions)..add(permission);
    return copyWith(permissions: newPermissions);
  }

  /// إزالة صلاحية
  Employee removePermission(Permission permission) {
    final newPermissions = List<Permission>.from(permissions)
      ..remove(permission);
    return copyWith(permissions: newPermissions);
  }

  /// تفعيل/إلغاء تفعيل الموظف
  Employee toggleActive() {
    return copyWith(
      isActive: !isActive,
      updatedAt: DateTime.now(),
    );
  }

  /// التحقق من وجود صلاحية
  bool hasPermission(Permission permission) {
    return permissions.contains(permission);
  }

  /// التحقق من وجود أي من الصلاحيات
  bool hasAnyPermission(List<Permission> permissionsList) {
    return permissionsList
        .any((permission) => permissions.contains(permission));
  }

  /// التحقق من وجود جميع الصلاحيات
  bool hasAllPermissions(List<Permission> permissionsList) {
    return permissionsList
        .every((permission) => permissions.contains(permission));
  }

  /// الحصول على الأحرف الأولى للاسم
  String get initials {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return 'E';
  }

  /// الحصول على عدد الصلاحيات
  int get permissionsCount => permissions.length;

  /// التحقق من صحة البيانات
  bool get isValid {
    return id.isNotEmpty &&
        businessOwnerId.isNotEmpty &&
        name.isNotEmpty &&
        uniqueId.isNotEmpty &&
        passwordHash.isNotEmpty &&
        passwordSalt.isNotEmpty;
  }

  /// التحقق من اكتمال الملف الشخصي
  bool get isProfileComplete {
    return isValid && email != null && email!.isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Employee && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Employee(id: $id, name: $name, uniqueId: $uniqueId, permissions: ${permissions.length}, isActive: $isActive)';
  }
}

/// بيانات إنشاء موظف جديد
class EmployeeData {
  final String name;
  final String? email;
  final String password;
  final List<Permission> permissions;

  const EmployeeData({
    required this.name,
    this.email,
    required this.password,
    this.permissions = const [],
  });

  /// التحقق من صحة البيانات
  bool get isValid {
    return name.isNotEmpty && password.isNotEmpty && password.length >= 6;
  }

  /// الحصول على رسائل الأخطاء
  List<String> get validationErrors {
    final errors = <String>[];

    if (name.isEmpty) {
      errors.add('اسم الموظف مطلوب');
    }

    if (email != null &&
        email!.isNotEmpty &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email!)) {
      errors.add('البريد الإلكتروني غير صحيح');
    }

    if (password.isEmpty) {
      errors.add('كلمة المرور مطلوبة');
    } else if (password.length < 6) {
      errors.add('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
    }

    if (permissions.isEmpty) {
      errors.add('يجب تحديد صلاحية واحدة على الأقل');
    }

    return errors;
  }

  @override
  String toString() {
    return 'EmployeeData(name: $name, email: ${email ?? "غير محدد"}, permissions: ${permissions.length})';
  }
}
