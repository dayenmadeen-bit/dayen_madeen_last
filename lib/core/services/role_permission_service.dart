import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app/data/models/user_role.dart';
import 'firestore_service.dart';
import 'auth_service.dart';
import 'logger_service.dart';
import '../constants/app_strings.dart';
import '../utils/permission_notice.dart';

class RolePermissionService extends GetxService {
  static RolePermissionService get instance =>
      Get.find<RolePermissionService>();

  final FirestoreService _firestore = Get.find<FirestoreService>();

  // التحقق من الصلاحية الأساسية
  bool hasPermission(UserPermission permission) {
    final authService = Get.find<AuthService>();
    return authService.hasPermission(permission);
  }

  /// التحقق مع إشعار واجهوي عند غياب الصلاحية (لا يرمي استثناء)
  bool ensurePermissionOrNotify(UserPermission permission) {
    final ok = hasPermission(permission);
    if (!ok) {
      PermissionNotice.show(permissionDisplayName: _permissionName(permission));
    }
    return ok;
  }

  /// التحقق مع رمي استثناء موحّد عند غياب الصلاحية (للاستخدام في الخدمات/المراقبين)
  void requirePermissionOrThrow(UserPermission permission) {
    if (!hasPermission(permission)) {
      throw PermissionDeniedException(_permissionName(permission));
    }
  }

  String _permissionName(UserPermission permission) {
    // استخدام displayName إن وُجد ضمن النموذج، وإلا fallback عام
    try {
      return permission.displayName;
    } catch (_) {
      return AppStrings.permission;
    }
  }

  // التحقق من إمكانية الوصول لميزة
  bool canAccessFeature(String feature) {
    final authService = Get.find<AuthService>();
    return authService.canAccessFeature(feature);
  }

  // التحقق من الدور
  bool isRole(UserRole role) {
    final authService = Get.find<AuthService>();
    return authService.isRole(role);
  }

  // إدارة صلاحيات الموظفين
  Future<bool> updateEmployeePermissions({
    required String employeeId,
    required List<UserPermission> newPermissions,
  }) async {
    try {
      final authService = Get.find<AuthService>();

      // التحقق من أن المستخدم الحالي هو صاحب العمل
      if (!authService.isBusinessOwner) {
        LoggerService.warning('محاولة تحديث صلاحيات الموظف من غير صاحب العمل');
        return false;
      }

      // التحقق من أن الصلاحيات المطلوبة مناسبة للموظفين
      final validPermissions = newPermissions.where((permission) {
        return RolePermissions.getPermissionsForRole(UserRole.employee)
            .contains(permission);
      }).toList();

      if (validPermissions.isEmpty) {
        LoggerService.warning('لا توجد صلاحيات صالحة للموظف');
        return false;
      }

      // تحديث الصلاحيات في Firestore
      await _firestore.updateDoc(
        _firestore.usersCol().doc(employeeId),
        {
          'permissions': validPermissions.map((p) => p.value).toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      LoggerService.success('تم تحديث صلاحيات الموظف بنجاح');
      return true;
    } catch (e, st) {
      LoggerService.error('خطأ في تحديث صلاحيات الموظف',
          error: e, stackTrace: st);
      return false;
    }
  }

  // إضافة صلاحية للموظف
  Future<bool> addEmployeePermission({
    required String employeeId,
    required UserPermission permission,
  }) async {
    try {
      final authService = Get.find<AuthService>();

      if (!authService.isBusinessOwner) {
        LoggerService.warning('محاولة إضافة صلاحية للموظف من غير صاحب العمل');
        return false;
      }

      // جلب بيانات الموظف الحالية
      final employeeDoc = await _firestore.usersCol().doc(employeeId).get();
      if (!employeeDoc.exists) {
        LoggerService.warning('الموظف غير موجود');
        return false;
      }

      final employeeData = employeeDoc.data()!;
      final currentPermissions = (employeeData['permissions'] as List<dynamic>?)
              ?.map((p) => UserPermission.fromString(p as String))
              .toList() ??
          [];

      // التحقق من أن الصلاحية مناسبة للموظفين
      if (!RolePermissions.getPermissionsForRole(UserRole.employee)
          .contains(permission)) {
        LoggerService.warning('الصلاحية غير مناسبة للموظفين');
        return false;
      }

      // إضافة الصلاحية إذا لم تكن موجودة
      if (!currentPermissions.contains(permission)) {
        currentPermissions.add(permission);

        await _firestore.updateDoc(
          _firestore.usersCol().doc(employeeId),
          {
            'permissions': currentPermissions.map((p) => p.value).toList(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );

        LoggerService.success('تم إضافة الصلاحية للموظف بنجاح');
        return true;
      }

      LoggerService.info('الصلاحية موجودة بالفعل للموظف');
      return true;
    } catch (e, st) {
      LoggerService.error('خطأ في إضافة صلاحية للموظف',
          error: e, stackTrace: st);
      return false;
    }
  }

  // إزالة صلاحية من الموظف
  Future<bool> removeEmployeePermission({
    required String employeeId,
    required UserPermission permission,
  }) async {
    try {
      final authService = Get.find<AuthService>();

      if (!authService.isBusinessOwner) {
        LoggerService.warning(
            'محاولة إزالة صلاحية من الموظف من غير صاحب العمل');
        return false;
      }

      // جلب بيانات الموظف الحالية
      final employeeDoc = await _firestore.usersCol().doc(employeeId).get();
      if (!employeeDoc.exists) {
        LoggerService.warning('الموظف غير موجود');
        return false;
      }

      final employeeData = employeeDoc.data()!;
      final currentPermissions = (employeeData['permissions'] as List<dynamic>?)
              ?.map((p) => UserPermission.fromString(p as String))
              .toList() ??
          [];

      // إزالة الصلاحية
      currentPermissions.remove(permission);

      await _firestore.updateDoc(
        _firestore.usersCol().doc(employeeId),
        {
          'permissions': currentPermissions.map((p) => p.value).toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      LoggerService.success('تم إزالة الصلاحية من الموظف بنجاح');
      return true;
    } catch (e, st) {
      LoggerService.error('خطأ في إزالة صلاحية من الموظف',
          error: e, stackTrace: st);
      return false;
    }
  }

  // الحصول على صلاحيات الموظف
  Future<List<UserPermission>> getEmployeePermissions(String employeeId) async {
    try {
      final employeeDoc = await _firestore.usersCol().doc(employeeId).get();
      if (!employeeDoc.exists) {
        return [];
      }

      final employeeData = employeeDoc.data()!;
      return (employeeData['permissions'] as List<dynamic>?)
              ?.map((p) => UserPermission.fromString(p as String))
              .toList() ??
          [];
    } catch (e, st) {
      LoggerService.error('خطأ في جلب صلاحيات الموظف',
          error: e, stackTrace: st);
      return [];
    }
  }

  // التحقق من صلاحية محددة للموظف
  Future<bool> employeeHasPermission({
    required String employeeId,
    required UserPermission permission,
  }) async {
    final permissions = await getEmployeePermissions(employeeId);
    return permissions.contains(permission);
  }

  // جلب جميع الموظفين مع صلاحياتهم
  Future<List<Map<String, dynamic>>> getAllEmployeesWithPermissions() async {
    try {
      final authService = Get.find<AuthService>();

      if (!authService.isBusinessOwner) {
        LoggerService.warning('محاولة جلب الموظفين من غير صاحب العمل');
        return [];
      }

      final employeesQuery = await _firestore
          .usersCol()
          .where('role', isEqualTo: UserRole.employee.value)
          .where('isActive', isEqualTo: true)
          .get();

      return employeesQuery.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'],
          'email': data['email'],
          'phone': data['phone'],
          'uniqueId': data['uniqueId'],
          'permissions': data['permissions'] ?? [],
          'createdAt': data['createdAt'],
          'lastLoginAt': data['lastLoginAt'],
        };
      }).toList();
    } catch (e, st) {
      LoggerService.error('خطأ في جلب الموظفين مع صلاحياتهم',
          error: e, stackTrace: st);
      return [];
    }
  }

  // إنشاء صلاحيات افتراضية للموظف الجديد
  List<UserPermission> getDefaultEmployeePermissions() {
    return [
      UserPermission.viewCustomers,
      UserPermission.addDebts,
      UserPermission.addPayments,
      UserPermission.viewDebts,
      UserPermission.viewPayments,
    ];
  }

  // التحقق من صلاحيات العمليات الحساسة
  bool canPerformSensitiveOperation(String operation) {
    final authService = Get.find<AuthService>();

    switch (operation) {
      case 'delete_customer':
        return authService.hasPermission(UserPermission.manageCustomers);
      case 'modify_credit_limit':
        return authService.hasPermission(UserPermission.manageCustomers);
      case 'delete_debt':
        return authService.hasPermission(UserPermission.manageDebts);
      case 'modify_debt':
        return authService.hasPermission(UserPermission.manageDebts) ||
            authService.hasPermission(UserPermission.addDebts);
      case 'delete_payment':
        return authService.hasPermission(UserPermission.managePayments);
      case 'modify_payment':
        return authService.hasPermission(UserPermission.managePayments) ||
            authService.hasPermission(UserPermission.addPayments);
      case 'manage_employees':
        return authService.hasPermission(UserPermission.manageEmployees);
      case 'view_reports':
        return authService.hasPermission(UserPermission.viewReports);
      case 'manage_settings':
        return authService.hasPermission(UserPermission.manageSettings);
      case 'manage_subscription':
        return authService.hasPermission(UserPermission.manageSubscription);
      default:
        return false;
    }
  }

  // الحصول على قائمة الصلاحيات المتاحة حسب الدور
  List<UserPermission> getAvailablePermissionsForRole(UserRole role) {
    return RolePermissions.getPermissionsForRole(role);
  }

  // التحقق من صحة الصلاحيات
  bool validatePermissions(List<UserPermission> permissions, UserRole role) {
    final validPermissions = RolePermissions.getPermissionsForRole(role);
    return permissions
        .every((permission) => validPermissions.contains(permission));
  }

  // إنشاء تقرير الصلاحيات
  Map<String, dynamic> generatePermissionsReport() {
    final authService = Get.find<AuthService>();
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return {};
    }

    return {
      'userId': currentUser.id,
      'uniqueId': currentUser.uniqueId,
      'role': currentUser.role.displayName,
      'permissions': currentUser.permissions.map((p) => p.displayName).toList(),
      'canAccessFeatures': {
        'customers': canAccessFeature('customers'),
        'debts': canAccessFeature('debts'),
        'payments': canAccessFeature('payments'),
        'reports': canAccessFeature('reports'),
        'settings': canAccessFeature('settings'),
        'employees': canAccessFeature('employees'),
      },
      'sensitiveOperations': {
        'delete_customer': canPerformSensitiveOperation('delete_customer'),
        'modify_credit_limit':
            canPerformSensitiveOperation('modify_credit_limit'),
        'delete_debt': canPerformSensitiveOperation('delete_debt'),
        'modify_debt': canPerformSensitiveOperation('modify_debt'),
        'delete_payment': canPerformSensitiveOperation('delete_payment'),
        'modify_payment': canPerformSensitiveOperation('modify_payment'),
        'manage_employees': canPerformSensitiveOperation('manage_employees'),
        'view_reports': canPerformSensitiveOperation('view_reports'),
        'manage_settings': canPerformSensitiveOperation('manage_settings'),
        'manage_subscription':
            canPerformSensitiveOperation('manage_subscription'),
      },
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }
}
