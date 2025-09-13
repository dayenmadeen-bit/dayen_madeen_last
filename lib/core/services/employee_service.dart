import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app/data/models/employee.dart';
import '../../app/data/models/auth_result.dart';
import '../../app/data/models/user_role.dart';
import 'auth_service.dart';
import 'security_service.dart';
import 'firestore_service.dart';
import 'logger_service.dart';
import 'unique_id_service.dart';

/// خدمة إدارة الموظفين
class EmployeeService extends GetxService {
  static EmployeeService get instance => Get.find<EmployeeService>();

  final RxList<Employee> _employees = <Employee>[].obs;
  final RxBool _isLoading = false.obs;
  late final FirestoreService _firestoreService;
  late String _ownerDocId;

  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    try {
      _firestoreService = Get.find<FirestoreService>();
      // وثيقة المالك في users تُعرف بمعرف وثيقة المستخدم (Firebase UID)
      _ownerDocId = AuthService.instance.currentUser?.id ?? '';
      await loadEmployees();
    } catch (e) {
      LoggerService.error('خطأ في تهيئة EmployeeService', error: e);
    }
  }

  /// تحميل جميع الموظفين
  Future<void> loadEmployees() async {
    try {
      _isLoading.value = true;

      if (_ownerDocId.isEmpty) {
        LoggerService.warning('لا يوجد معرف مالك المنشأة');
        _createMockEmployees();
        return;
      }

      try {
        // تحميل الموظفين من Firestore
        final employeesSnapshot =
            await _firestoreService.getEmployeesForOwner(_ownerDocId);

        _employees.value = employeesSnapshot.map((doc) {
          final data = doc.data();
          return Employee.fromJson({
            'id': doc.id,
            ...?data,
          });
        }).toList();

        LoggerService.success(
            'تم تحميل ${_employees.length} موظف من Firestore');
      } catch (e) {
        LoggerService.error('فشل في تحميل الموظفين من Firestore', error: e);
        _createMockEmployees();
      }
    } catch (e) {
      LoggerService.error('خطأ في تحميل الموظفين', error: e);
      _createMockEmployees();
    } finally {
      _isLoading.value = false;
    }
  }

  /// إنشاء بيانات وهمية للموظفين
  void _createMockEmployees() {
    _employees.value = [
      Employee.create(
        businessOwnerId: 'owner_1',
        name: 'أحمد محمد',
        uniqueId: '1234567',
        email: 'ahmed@company.com',
        passwordHash: 'hashed_password_1',
        passwordSalt: 'salt_1',
        permissions: [
          Permission.viewCustomers,
          Permission.addCustomers,
          Permission.viewDebts,
          Permission.addDebts,
          Permission.viewPayments,
          Permission.addPayments,
        ],
      ),
      Employee.create(
        businessOwnerId: 'owner_1',
        name: 'سارة أحمد',
        uniqueId: '1234568',
        email: 'sara@company.com',
        passwordHash: 'hashed_password_2',
        passwordSalt: 'salt_2',
        permissions: [
          Permission.viewCustomers,
          Permission.viewDebts,
          Permission.viewPayments,
        ],
      ),
      Employee.create(
        businessOwnerId: 'owner_1',
        name: 'محمد علي',
        uniqueId: '1234569',
        email: 'mohammed@company.com',
        passwordHash: 'hashed_password_3',
        passwordSalt: 'salt_3',
        permissions: [
          Permission.viewCustomers,
          Permission.addCustomers,
          Permission.editCustomers,
          Permission.viewDebts,
          Permission.addDebts,
        ],
      ),
    ];
  }

  /// إضافة موظف جديد
  Future<AuthResult> addEmployee(EmployeeData employeeData) async {
    try {
      _isLoading.value = true;

      if (_ownerDocId.isEmpty) {
        return AuthResult.failure('يجب تسجيل الدخول أولاً');
      }

      // التحقق من صحة البيانات
      if (!employeeData.isValid) {
        final errors = employeeData.validationErrors.join(', ');
        return AuthResult.failure('بيانات غير صحيحة: $errors');
      }

      // التحقق من عدم وجود البريد مسبقاً
      if (employeeData.email != null && employeeData.email!.isNotEmpty) {
        final existingEmployee = _employees.firstWhereOrNull(
          (emp) => emp.email == employeeData.email,
        );
        if (existingEmployee != null) {
          return AuthResult.failure('يوجد موظف بنفس البريد الإلكتروني');
        }
      }

      // توليد رقم مميز فريد
      final uniqueIdService = Get.find<UniqueIdService>();
      final uniqueId = await uniqueIdService.generateEmployeeId();

      // تشفير كلمة المرور
      final salt = SecurityService.instance.generateSalt();
      final hashedPassword =
          SecurityService.instance.hashPassword(employeeData.password, salt);

      // إنشاء الموظف
      final employee = Employee.create(
        businessOwnerId: _ownerDocId,
        name: employeeData.name,
        uniqueId: uniqueId,
        email: employeeData.email,
        passwordHash: hashedPassword,
        passwordSalt: salt,
        permissions: employeeData.permissions,
      );

      // حفظ في Firestore
      final employeeFirestoreData = {
        'businessOwnerId': _ownerDocId,
        'name': employee.name,
        'uniqueId': employee.uniqueId,
        'email': employee.email,
        'phone': employee.phone,
        'passwordHash': employee.passwordHash,
        'passwordSalt': employee.passwordSalt,
        'permissions': employee.permissions.map((p) => p.value).toList(),
        'isActive': employee.isActive,
        'createdAt': Timestamp.fromDate(employee.createdAt),
        'updatedAt': Timestamp.fromDate(employee.updatedAt),
      };

      final docRef = await _firestoreService.addEmployee(
          _ownerDocId, employeeFirestoreData);

      // تحديث معرف الموظف
      final updatedEmployee = employee.copyWith(id: docRef.id);

      // إضافة للقائمة المحلية
      _employees.add(updatedEmployee);

      LoggerService.success('تم إضافة الموظف: ${employee.name}');
      return AuthResult.success(updatedEmployee);
    } catch (e) {
      LoggerService.error('خطأ في إضافة الموظف', error: e);
      return AuthResult.failure('خطأ في إضافة الموظف: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// تحديث بيانات موظف
  Future<AuthResult> updateEmployee(
    String employeeId, {
    String? name,
    String? email,
    List<Permission>? permissions,
    bool? isActive,
  }) async {
    try {
      _isLoading.value = true;

      final employeeIndex = _employees.indexWhere((e) => e.id == employeeId);
      if (employeeIndex == -1) {
        return AuthResult.failure('الموظف غير موجود');
      }

      final employee = _employees[employeeIndex];
      final updatedEmployee = employee.copyWith(
        name: name ?? employee.name,
        email: email ?? employee.email,
        permissions: permissions ?? employee.permissions,
        isActive: isActive ?? employee.isActive,
        updatedAt: DateTime.now(),
      );

      // تحديث في Firestore
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (permissions != null)
        updateData['permissions'] = permissions.map((p) => p.value).toList();
      if (isActive != null) updateData['isActive'] = isActive;
      updateData['updatedAt'] = Timestamp.fromDate(updatedEmployee.updatedAt);

      await _firestoreService.updateEmployee(
          _ownerDocId, employeeId, updateData);

      // تحديث في القائمة المحلية
      _employees[employeeIndex] = updatedEmployee;

      return AuthResult.success(updatedEmployee);
    } catch (e) {
      return AuthResult.failure('خطأ في تحديث الموظف: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// تحديث صلاحيات موظف
  Future<AuthResult> updateEmployeePermissions(
      String employeeId, List<Permission> permissions) async {
    return await updateEmployee(employeeId, permissions: permissions);
  }

  /// تفعيل/إلغاء تفعيل موظف
  Future<AuthResult> toggleEmployeeStatus(String employeeId) async {
    final employee = _employees.firstWhereOrNull((e) => e.id == employeeId);
    if (employee == null) {
      return AuthResult.failure('الموظف غير موجود');
    }

    return await updateEmployee(employeeId, isActive: !employee.isActive);
  }

  /// حذف موظف
  Future<AuthResult> deleteEmployee(String employeeId) async {
    try {
      _isLoading.value = true;

      // حذف من Firestore
      await _firestoreService.deleteEmployee(_ownerDocId, employeeId);

      // حذف من القائمة المحلية
      _employees.removeWhere((e) => e.id == employeeId);

      LoggerService.success('تم حذف الموظف: $employeeId');
      return AuthResult.success(null);
    } catch (e) {
      LoggerService.error('خطأ في حذف الموظف', error: e);
      return AuthResult.failure('خطأ في حذف الموظف: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// الحصول على موظف بالمعرف
  Employee? getEmployeeById(String employeeId) {
    return _employees.firstWhereOrNull((e) => e.id == employeeId);
  }

  /// الحصول على موظف بالبريد الإلكتروني
  Employee? getEmployeeByEmail(String email) {
    return _employees.firstWhereOrNull((e) => e.email == email);
  }

  /// البحث في الموظفين
  List<Employee> searchEmployees(String query) {
    if (query.isEmpty) return _employees;

    final lowerQuery = query.toLowerCase();
    return _employees.where((employee) {
      return employee.name.toLowerCase().contains(lowerQuery) ||
          (employee.email?.toLowerCase().contains(lowerQuery) ?? false) ||
          employee.uniqueId.contains(lowerQuery);
    }).toList();
  }

  /// فلترة الموظفين حسب الحالة
  List<Employee> getEmployeesByStatus(bool isActive) {
    return _employees.where((e) => e.isActive == isActive).toList();
  }

  /// الحصول على الموظفين النشطين
  List<Employee> get activeEmployees => getEmployeesByStatus(true);

  /// الحصول على الموظفين غير النشطين
  List<Employee> get inactiveEmployees => getEmployeesByStatus(false);

  /// فلترة الموظفين حسب الصلاحية
  List<Employee> getEmployeesWithPermission(Permission permission) {
    return _employees.where((e) => e.hasPermission(permission)).toList();
  }

  /// التحقق من صلاحية الموظف الحالي
  bool hasPermission(Permission permission) {
    final currentUser = AuthService.instance.currentUser;
    if (currentUser == null) return false;

    // إذا كان مالك المنشأة، له جميع الصلاحيات
    if (currentUser.role == UserRole.businessOwner) return true;

    // إذا كان موظف، التحقق من صلاحياته
    final employee = getEmployeeByEmail(currentUser.email ?? '');
    return employee?.hasPermission(permission) ?? false;
  }

  /// الحصول على إحصائيات الموظفين
  Map<String, dynamic> getEmployeeStats() {
    final total = _employees.length;
    final active = activeEmployees.length;
    final inactive = inactiveEmployees.length;

    // إحصائيات الصلاحيات
    final permissionStats = <Permission, int>{};
    for (final permission in Permission.values) {
      permissionStats[permission] =
          getEmployeesWithPermission(permission).length;
    }

    return {
      'total': total,
      'active': active,
      'inactive': inactive,
      'activePercentage': total > 0 ? (active / total) * 100 : 0,
      'permissionStats': permissionStats,
    };
  }

  /// تصدير بيانات الموظفين
  List<Map<String, dynamic>> exportEmployeesData() {
    return _employees.map((employee) {
      return {
        'الاسم': employee.name,
        'الرقم المميز': employee.uniqueId,
        'البريد الإلكتروني': employee.email ?? 'غير محدد',
        'الحالة': employee.isActive ? 'نشط' : 'غير نشط',
        'عدد الصلاحيات': employee.permissionsCount,
        'تاريخ الإضافة': employee.createdAt.toIso8601String().split('T')[0],
      };
    }).toList();
  }

  /// تحديث كامل للموظف
  Future<AuthResult> updateEmployeeFull(Employee employee) async {
    try {
      _isLoading.value = true;

      final employeeIndex = _employees.indexWhere((e) => e.id == employee.id);
      if (employeeIndex == -1) {
        return AuthResult.failure('الموظف غير موجود');
      }

      _employees[employeeIndex] = employee;
      await _saveEmployeesToFirestore(); // حفظ الموظفين في Firestore

      return AuthResult.success('تم تحديث الموظف بنجاح');
    } catch (e) {
      return AuthResult.failure('فشل في تحديث الموظف: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// مسح جميع البيانات
  Future<void> clearAllData() async {
    _employees.clear();
  }

  /// حفظ الموظفين في Firestore
  Future<void> _saveEmployeesToFirestore() async {
    try {
      final authService = Get.find<AuthService>();
      final currentUser = authService.currentUser;
      if (currentUser == null) return;

      final batch = FirebaseFirestore.instance.batch();

      for (final employee in _employees) {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.id)
            .collection('employees')
            .doc(employee.id);

        batch.set(docRef, employee.toJson());
      }

      await batch.commit();
    } catch (e) {
      print('خطأ في حفظ الموظفين في Firestore: $e');
    }
  }
}
