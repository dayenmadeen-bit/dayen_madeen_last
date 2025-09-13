enum UserRole {
  businessOwner('business_owner', 'صاحب العمل'),
  employee('employee', 'موظف'),
  customer('customer', 'عميل');

  const UserRole(this.value, this.displayName);
  final String value;
  final String displayName;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.customer,
    );
  }
}

enum UserPermission {
  // صلاحيات أصحاب الأعمال
  manageBusiness('manage_business', 'إدارة العمل'),
  manageEmployees('manage_employees', 'إدارة الموظفين'),
  manageCustomers('manage_customers', 'إدارة العملاء'),
  manageDebts('manage_debts', 'إدارة الديون'),
  managePayments('manage_payments', 'إدارة الدفعات'),
  viewReports('view_reports', 'عرض التقارير'),
  manageSettings('manage_settings', 'إدارة الإعدادات'),
  manageSubscription('manage_subscription', 'إدارة الاشتراك'),

  // صلاحيات الموظفين
  addDebts('add_debts', 'إضافة ديون'),
  addPayments('add_payments', 'إضافة دفعات'),
  viewCustomers('view_customers', 'عرض العملاء'),
  editCustomerInfo('edit_customer_info', 'تعديل معلومات العملاء'),
  viewDebts('view_debts', 'عرض الديون'),
  viewPayments('view_payments', 'عرض الدفعات'),

  // صلاحيات العملاء
  viewOwnDebts('view_own_debts', 'عرض ديونه'),
  makePayments('make_payments', 'الدفع');

  const UserPermission(this.value, this.displayName);
  final String value;
  final String displayName;

  static UserPermission fromString(String value) {
    return UserPermission.values.firstWhere(
      (permission) => permission.value == value,
      orElse: () => UserPermission.viewOwnDebts,
    );
  }
}

class RolePermissions {
  static const Map<UserRole, List<UserPermission>> rolePermissions = {
    UserRole.businessOwner: [
      UserPermission.manageBusiness,
      UserPermission.manageEmployees,
      UserPermission.manageCustomers,
      UserPermission.manageDebts,
      UserPermission.managePayments,
      UserPermission.viewReports,
      UserPermission.manageSettings,
      UserPermission.manageSubscription,
    ],
    UserRole.employee: [
      UserPermission.addDebts,
      UserPermission.addPayments,
      UserPermission.viewCustomers,
      UserPermission.editCustomerInfo,
      UserPermission.viewDebts,
      UserPermission.viewPayments,
    ],
    UserRole.customer: [
      UserPermission.viewOwnDebts,
      UserPermission.makePayments,
    ],
  };

  static List<UserPermission> getPermissionsForRole(UserRole role) {
    return rolePermissions[role] ?? [];
  }

  static bool hasPermission(UserRole role, UserPermission permission) {
    final permissions = getPermissionsForRole(role);
    return permissions.contains(permission);
  }

  static bool canAccessFeature(UserRole role, String feature) {
    switch (feature) {
      case 'customers':
        return hasPermission(role, UserPermission.manageCustomers) ||
            hasPermission(role, UserPermission.viewCustomers);
      case 'debts':
        return hasPermission(role, UserPermission.manageDebts) ||
            hasPermission(role, UserPermission.addDebts) ||
            hasPermission(role, UserPermission.viewDebts);
      case 'payments':
        return hasPermission(role, UserPermission.managePayments) ||
            hasPermission(role, UserPermission.addPayments) ||
            hasPermission(role, UserPermission.viewPayments);
      case 'reports':
        return hasPermission(role, UserPermission.viewReports);
      case 'settings':
        return hasPermission(role, UserPermission.manageSettings);
      case 'employees':
        return hasPermission(role, UserPermission.manageEmployees);
      default:
        return false;
    }
  }
}
