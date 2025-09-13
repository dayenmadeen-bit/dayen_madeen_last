import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/employee_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/unique_id_service.dart';
import '../../../data/models/employee.dart';
import '../../../routes/app_routes.dart';
import '../../../../core/services/offline_service.dart';

class EmployeesController extends GetxController {
  final EmployeeService _employeeService = EmployeeService.instance;

  // حالات التفاعل
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'all'.obs;

  // متحكمات النصوص
  final TextEditingController searchController = TextEditingController();

  // متحكمات إضافة/تعديل الموظف
  final GlobalKey<FormState> addEmployeeFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> editEmployeeFormKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();

  // الموظف الحالي (للتعديل والتفاصيل)
  final Rx<Employee?> currentEmployee = Rx<Employee?>(null);

  // الصلاحيات المختارة
  final RxList<Permission> selectedPermissions = <Permission>[].obs;
  // قوالب أدوار سريعة
  final List<String> rolePresets = const ['viewer', 'accountant', 'manager'];
  final RxString selectedRolePreset = 'viewer'.obs;

  // حالة الموظف (نشط/غير نشط)
  final RxBool isEmployeeActive = true.obs;

  // قوائم الموظفين
  List<Employee> get allEmployees => _employeeService.employees;
  List<Employee> get activeEmployees => _employeeService.activeEmployees;
  List<Employee> get inactiveEmployees => _employeeService.inactiveEmployees;

  // الموظفين المفلترين
  List<Employee> get filteredEmployees {
    List<Employee> employees;

    // تطبيق فلتر الحالة
    switch (selectedFilter.value) {
      case 'active':
        employees = activeEmployees;
        break;
      case 'inactive':
        employees = inactiveEmployees;
        break;
      default:
        employees = allEmployees;
    }

    // تطبيق البحث
    if (searchQuery.value.isNotEmpty) {
      employees = _employeeService.searchEmployees(searchQuery.value);
    }

    return employees;
  }

  // الإحصائيات
  Map<String, dynamic> get employeeStats => _employeeService.getEmployeeStats();

  @override
  void onInit() {
    super.onInit();
    loadEmployees();

    // مراقبة تغييرات البحث
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    emailController.dispose();
    positionController.dispose();
    salaryController.dispose();
    super.onClose();
  }

  /// تحميل الموظفين
  Future<void> loadEmployees() async {
    isLoading.value = true;
    await _employeeService.loadEmployees();
    isLoading.value = false;
  }

  /// تحديث القائمة
  Future<void> refreshEmployees() async {
    await loadEmployees();
  }

  /// تغيير الفلتر
  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  /// مسح البحث
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  /// الانتقال لإضافة موظف جديد
  void goToAddEmployee() {
    _clearEmployeeForm();
    Get.toNamed(AppRoutes.addEmployee);
  }

  /// الانتقال لتفاصيل الموظف
  void goToEmployeeDetails(dynamic employeeOrId) {
    String employeeId;
    if (employeeOrId is Employee) {
      employeeId = employeeOrId.id;
    } else {
      employeeId = employeeOrId.toString();
    }
    Get.toNamed(AppRoutes.employeeDetails,
        arguments: {'employeeId': employeeId});
  }

  /// الانتقال لتعديل الموظف
  void goToEditEmployee(dynamic employeeOrId) {
    String employeeId;
    if (employeeOrId is Employee) {
      employeeId = employeeOrId.id;
    } else {
      employeeId = employeeOrId.toString();
    }
    Get.toNamed(AppRoutes.editEmployee, arguments: {'employeeId': employeeId});
  }

  /// تفعيل/إلغاء تفعيل موظف
  Future<void> toggleEmployeeStatus(Employee employee) async {
    try {
      final result = await _employeeService.toggleEmployeeStatus(employee.id);

      if (result.isSuccess) {
        Get.snackbar(
          'تم بنجاح',
          employee.isActive ? 'تم إلغاء تفعيل الموظف' : 'تم تفعيل الموظف',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: AppColors.onSuccess,
        );
      } else {
        Get.snackbar(
          'خطأ',
          result.error ?? 'فشل في تحديث حالة الموظف',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
      );
    }
  }

  /// حذف موظف
  Future<void> deleteEmployee(Employee employee) async {
    // تأكيد الحذف
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
            'هل أنت متأكد من حذف الموظف "${employee.name}"؟\nلا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await _employeeService.deleteEmployee(employee.id);

      if (result.isSuccess) {
        Get.snackbar(
          'تم الحذف',
          'تم حذف الموظف بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: AppColors.onSuccess,
        );
      } else {
        Get.snackbar(
          'خطأ',
          result.error ?? 'فشل في حذف الموظف',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.onError,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
      );
    }
  }

  /// عرض خيارات الموظف
  void showEmployeeOptions(Employee employee) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // مقبض السحب
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 16),

            // عنوان
            Text(
              employee.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // الخيارات
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('عرض التفاصيل'),
              onTap: () {
                Get.back();
                goToEmployeeDetails(employee);
              },
            ),

            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('تعديل'),
              onTap: () {
                Get.back();
                goToEditEmployee(employee);
              },
            ),

            ListTile(
              leading: Icon(
                employee.isActive ? Icons.block : Icons.check_circle,
                color:
                    employee.isActive ? AppColors.warning : AppColors.success,
              ),
              title: Text(employee.isActive ? 'إلغاء التفعيل' : 'تفعيل'),
              onTap: () {
                Get.back();
                toggleEmployeeStatus(employee);
              },
            ),

            ListTile(
              leading: Icon(Icons.delete, color: AppColors.error),
              title: Text('حذف', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Get.back();
                // احترام وضع الأوفلاين
                final offline = Get.find<OfflineService>();
                if (!offline.canPerformActionWithMessage('delete_employees')) {
                  return;
                }
                deleteEmployee(employee);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// تصدير بيانات الموظفين
  Future<void> exportEmployeesData() async {
    try {
      final data = _employeeService.exportEmployeesData();

      // هنا يمكن إضافة منطق التصدير الفعلي
      // مثل إنشاء ملف Excel أو CSV

      Get.snackbar(
        'تم التصدير',
        'تم تصدير بيانات ${data.length} موظف',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.onSuccess,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تصدير البيانات: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.onError,
      );
    }
  }

  /// عرض إحصائيات الموظفين
  void showEmployeeStats() {
    final stats = employeeStats;

    Get.dialog(
      AlertDialog(
        title: const Text('إحصائيات الموظفين'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إجمالي الموظفين: ${stats['total']}'),
            Text('الموظفين النشطين: ${stats['active']}'),
            Text('الموظفين غير النشطين: ${stats['inactive']}'),
            Text(
                'نسبة النشطين: ${stats['activePercentage'].toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  // ===== دوال إدارة الموظفين المحسنة =====

  /// تطبيق الفلاتر على قائمة الموظفين
  void _applyFilters() {
    // هذه الدالة تحدث القائمة المفلترة
    // يتم استدعاؤها تلقائياً عند تغيير البيانات
    update();
  }

  /// تحميل بيانات الموظف للتعديل
  void loadEmployeeForEdit(String employeeId) {
    final employee = allEmployees.firstWhereOrNull((e) => e.id == employeeId);
    if (employee != null) {
      currentEmployee.value = employee;
      _fillEmployeeForm(employee);
    }
  }

  /// تحميل تفاصيل الموظف
  Future<void> loadEmployeeDetails(String employeeId) async {
    try {
      isLoading.value = true;
      final employee = allEmployees.firstWhereOrNull((e) => e.id == employeeId);
      currentEmployee.value = employee;
    } finally {
      isLoading.value = false;
    }
  }

  /// تبديل صلاحية
  void togglePermission(Permission permission) {
    if (selectedPermissions.contains(permission)) {
      selectedPermissions.remove(permission);
    } else {
      selectedPermissions.add(permission);
    }
  }

  /// تطبيق قالب صلاحيات جاهز
  void applyRolePreset(String preset) {
    selectedRolePreset.value = preset;
    switch (preset) {
      case 'viewer':
        selectedPermissions.assignAll([
          Permission.viewCustomers,
          Permission.viewDebts,
          Permission.viewPayments,
          Permission.viewReports,
        ]);
        break;
      case 'accountant':
        selectedPermissions.assignAll([
          Permission.viewCustomers,
          Permission.viewDebts,
          Permission.viewPayments,
          Permission.addPayments,
          Permission.editPayments,
          Permission.deletePayments,
          Permission.viewReports,
          Permission.exportReports,
        ]);
        break;
      case 'manager':
        selectedPermissions.assignAll(Permission.values
            .where((p) => p != Permission.manageEmployees)
            .toList());
        break;
      default:
        break;
    }
  }

  /// تبديل حالة الموظف في النموذج
  void toggleEmployeeActiveStatus(bool value) {
    isEmployeeActive.value = value;
  }

  /// حفظ موظف جديد
  Future<void> saveEmployee() async {
    if (!addEmployeeFormKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      // إنشاء كلمة مرور مشفرة وملح
      final passwordSalt = 'salt_${DateTime.now().millisecondsSinceEpoch}';
      final passwordHash = passwordController.text; // سيتم تشفيرها في الخدمة

      // الحصول على معرّف المالك الحالي
      final ownerId = AuthService.instance.currentUser?.id ?? 'unknown_owner';

      // توليد رقم مميز للموظف مع فحص التكرار عبر UniqueIdService
      final uniqueId = await UniqueIdService.instance.generateEmployeeId();

      final employee = Employee.create(
        businessOwnerId: ownerId,
        name: nameController.text.trim(),
        uniqueId: uniqueId,
        email: emailController.text.trim().isEmpty
            ? '${nameController.text.trim().replaceAll(' ', '_')}@company.com'
            : emailController.text.trim(),
        passwordHash: passwordHash,
        passwordSalt: passwordSalt,
        permissions: selectedPermissions.toList(),
      );

      // حفظ الموظف محلياً (مؤقتاً حتى يتم تطوير الخدمة)
      allEmployees.add(employee);
      _applyFilters();

      _showSuccessMessage('تم إضافة الموظف بنجاح');
      Get.back();
      _clearEmployeeForm();
    } catch (e) {
      _showErrorMessage('فشل في إضافة الموظف: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// تحديث بيانات الموظف
  Future<void> updateEmployee() async {
    if (!editEmployeeFormKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final updatedEmployee = Employee(
        id: currentEmployee.value!.id,
        businessOwnerId: currentEmployee.value!.businessOwnerId,
        name: nameController.text.trim(),
        uniqueId: currentEmployee.value!.uniqueId,
        email: emailController.text.trim().isEmpty
            ? currentEmployee.value!.email
            : emailController.text.trim(),
        passwordHash: currentEmployee.value!.passwordHash,
        passwordSalt: currentEmployee.value!.passwordSalt,
        permissions: selectedPermissions.toList(),
        isActive: isEmployeeActive.value,
        createdAt: currentEmployee.value!.createdAt,
        updatedAt: DateTime.now(),
      );

      // تحديث الموظف في القائمة المحلية
      final index = allEmployees.indexWhere((e) => e.id == updatedEmployee.id);
      if (index != -1) {
        allEmployees[index] = updatedEmployee;
        _applyFilters();
      }

      currentEmployee.value = updatedEmployee;
      _showSuccessMessage('تم تحديث بيانات الموظف بنجاح');
      Get.back();
    } catch (e) {
      _showErrorMessage('فشل في تحديث بيانات الموظف: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// حذف الموظف الحالي
  Future<void> deleteCurrentEmployee() async {
    if (currentEmployee.value == null) return;

    try {
      isLoading.value = true;

      // حذف الموظف من القائمة المحلية
      allEmployees.removeWhere((e) => e.id == currentEmployee.value!.id);
      _applyFilters();

      _showSuccessMessage('تم حذف الموظف بنجاح');
      Get.back(); // العودة من صفحة التفاصيل
      Get.back(); // العودة من صفحة التعديل إذا كانت مفتوحة
    } catch (e) {
      _showErrorMessage('فشل في حذف الموظف: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// تنظيف نموذج الموظف
  void _clearEmployeeForm() {
    nameController.clear();
    usernameController.clear();
    passwordController.clear();
    phoneController.clear();
    emailController.clear();
    positionController.clear();
    salaryController.clear();
    selectedPermissions.clear();
    isEmployeeActive.value = true;
    currentEmployee.value = null;
  }

  /// ملء نموذج الموظف بالبيانات الحالية
  void _fillEmployeeForm(Employee employee) {
    nameController.text = employee.name;
    usernameController.text =
        employee.email?.split('@')[0] ?? ''; // استخراج اسم المستخدم من البريد
    phoneController.text = ''; // لا يوجد phone في Employee model
    emailController.text = employee.email ?? '';
    positionController.text = 'موظف'; // قيمة افتراضية
    salaryController.text = '3000'; // قيمة افتراضية
    selectedPermissions.assignAll(employee.permissions);
    isEmployeeActive.value = employee.isActive;
  }

  /// إظهار رسالة نجاح
  void _showSuccessMessage(String message) {
    Get.snackbar(
      'تم بنجاح ✅',
      message,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      snackPosition: SnackPosition.TOP,
    );
  }

  /// إظهار رسالة خطأ
  void _showErrorMessage(String message) {
    Get.snackbar(
      'خطأ ❌',
      message,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error, color: Colors.white),
      snackPosition: SnackPosition.TOP,
    );
  }

  // إظهار إدارة الصلاحيات
  void showPermissionsManagement() {
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.9,
          height: Get.height * 0.7,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إدارة صلاحيات الموظفين',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildPermissionsList(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('إغلاق'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // قائمة الصلاحيات
  Widget _buildPermissionsList() {
    return ListView.builder(
      itemCount: allEmployees.length,
      itemBuilder: (context, index) {
        final employee = allEmployees[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                employee.name.substring(0, 1),
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(employee.name),
            subtitle: Text('الصلاحيات: ${employee.permissions.length}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editEmployeePermissions(employee),
                  tooltip: 'تعديل الصلاحيات',
                ),
                IconButton(
                  icon: Icon(
                    employee.isActive ? Icons.visibility : Icons.visibility_off,
                    color:
                        employee.isActive ? AppColors.success : AppColors.error,
                  ),
                  onPressed: () => _toggleEmployeeStatus(employee),
                  tooltip: employee.isActive ? 'إلغاء تفعيل' : 'تفعيل',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // تعديل صلاحيات الموظف
  void _editEmployeePermissions(Employee employee) {
    selectedPermissions.assignAll(employee.permissions);
    currentEmployee.value = employee;

    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.8,
          height: Get.height * 0.6,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تعديل صلاحيات ${employee.name}',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildPermissionsCheckboxes(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveEmployeePermissions,
                    child: const Text('حفظ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // مربعات اختيار الصلاحيات
  Widget _buildPermissionsCheckboxes() {
    return ListView(
      children: Permission.values.map((permission) {
        return Obx(() => CheckboxListTile(
              title: Text(permission.displayName),
              subtitle: Text(permission.description),
              value: selectedPermissions.contains(permission),
              onChanged: (value) {
                if (value == true) {
                  selectedPermissions.add(permission);
                } else {
                  selectedPermissions.remove(permission);
                }
              },
            ));
      }).toList(),
    );
  }

  // حفظ صلاحيات الموظف
  void _saveEmployeePermissions() {
    if (currentEmployee.value != null) {
      final updatedEmployee = currentEmployee.value!.copyWith(
        permissions: selectedPermissions.toList(),
        updatedAt: DateTime.now(),
      );

      _employeeService.updateEmployeeFull(updatedEmployee);
      _showSuccessMessage('تم تحديث صلاحيات الموظف بنجاح');
      Get.back();
    }
  }

  // تبديل حالة الموظف
  void _toggleEmployeeStatus(Employee employee) {
    final updatedEmployee = employee.copyWith(
      isActive: !employee.isActive,
      updatedAt: DateTime.now(),
    );

    _employeeService.updateEmployeeFull(updatedEmployee);
    _showSuccessMessage(updatedEmployee.isActive
        ? 'تم تفعيل الموظف بنجاح'
        : 'تم إلغاء تفعيل الموظف بنجاح');
  }
}
