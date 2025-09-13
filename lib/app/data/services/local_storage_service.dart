import '../../../core/services/storage_service.dart';
import '../models/user.dart';
import '../models/customer.dart';
import '../models/debt.dart';
import '../models/payment.dart';
import '../models/subscription.dart';

class LocalStorageService {
  // منع إنشاء instance من الكلاس
  LocalStorageService._();

  // مفاتيح التخزين
  static const String _keyUsers = 'users';
  static const String _keyCustomers = 'customers';
  static const String _keyDebts = 'debts';
  static const String _keyPayments = 'payments';
  static const String _keySubscriptions = 'subscriptions';
  static const String _keyCurrentUser = 'current_user';

  // ===== إدارة المستخدمين =====

  // حفظ مستخدم
  static Future<void> saveUser(User user) async {
    final users = await getAllUsers();
    final existingIndex = users.indexWhere((u) => u.id == user.id);

    if (existingIndex != -1) {
      users[existingIndex] = user;
    } else {
      users.add(user);
    }

    await _saveUsers(users);
  }

  // الحصول على جميع المستخدمين
  static Future<List<User>> getAllUsers() async {
    final usersJson = StorageService.getList(_keyUsers) ?? [];
    return usersJson.map((json) => User.fromJson(json)).toList();
  }

  // الحصول على مستخدم بالمعرف
  static Future<User?> getUserById(String id) async {
    final users = await getAllUsers();
    try {
      return users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  // الحصول على مستخدم بالبريد الإلكتروني
  static Future<User?> getUserByEmail(String email) async {
    final users = await getAllUsers();
    try {
      return users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  // حذف مستخدم
  static Future<void> deleteUser(String id) async {
    final users = await getAllUsers();
    users.removeWhere((user) => user.id == id);
    await _saveUsers(users);
  }

  // حفظ قائمة المستخدمين
  static Future<void> _saveUsers(List<User> users) async {
    final usersJson = users.map((user) => user.toJson()).toList();
    await StorageService.setList(_keyUsers, usersJson);
  }

  // ===== إدارة المستخدم الحالي =====

  // حفظ المستخدم الحالي
  static Future<void> saveCurrentUser(User user) async {
    await StorageService.setMap(_keyCurrentUser, user.toJson());
  }

  // الحصول على المستخدم الحالي
  static Future<User?> getCurrentUser() async {
    final userJson = StorageService.getMap(_keyCurrentUser);
    if (userJson != null) {
      return User.fromJson(userJson);
    }
    return null;
  }

  // حذف المستخدم الحالي
  static Future<void> clearCurrentUser() async {
    await StorageService.remove(_keyCurrentUser);
  }

  // حفظ بيانات المستخدم (alias)
  static Future<void> saveUserData(User user) async {
    await saveCurrentUser(user);
  }

  // الحصول على بيانات المستخدم (alias)
  static Future<User?> getUserData() async {
    return await getCurrentUser();
  }

  // مسح بيانات المستخدم (alias)
  static Future<void> clearUserData() async {
    await clearCurrentUser();
  }

  // ===== إدارة العملاء =====

  // حفظ عميل
  static Future<void> saveCustomer(Customer customer) async {
    final customers = await getAllCustomers();
    final existingIndex = customers.indexWhere((c) => c.id == customer.id);

    if (existingIndex != -1) {
      customers[existingIndex] = customer;
    } else {
      customers.add(customer);
    }

    await _saveCustomers(customers);
  }

  // تحديث عميل (alias)
  static Future<void> updateCustomer(Customer customer) async {
    await saveCustomer(customer);
  }

  // الحصول على جميع العملاء
  static Future<List<Customer>> getAllCustomers() async {
    final customersJson = StorageService.getList(_keyCustomers) ?? [];
    return customersJson.map((json) => Customer.fromJson(json)).toList();
  }

  // الحصول على عملاء مالك منشأة
  static Future<List<Customer>> getCustomersByOwnerId(String ownerId) async {
    final customers = await getAllCustomers();
    return customers
        .where((customer) => customer.businessOwnerId == ownerId)
        .toList();
  }

  // الحصول على عميل بالمعرف
  static Future<Customer?> getCustomerById(String id) async {
    final customers = await getAllCustomers();
    try {
      return customers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }

  // الحصول على عميل باسم المستخدم
  static Future<Customer?> getCustomerByUsername(String username) async {
    final customers = await getAllCustomers();
    try {
      return customers.firstWhere((customer) => customer.name == username);
    } catch (e) {
      return null;
    }
  }

  // حذف عميل
  static Future<void> deleteCustomer(String id) async {
    final customers = await getAllCustomers();
    customers.removeWhere((customer) => customer.id == id);
    await _saveCustomers(customers);
  }

  // حفظ قائمة العملاء
  static Future<void> _saveCustomers(List<Customer> customers) async {
    final customersJson =
        customers.map((customer) => customer.toJson()).toList();
    await StorageService.setList(_keyCustomers, customersJson);
  }

  // ===== إدارة الديون =====

  // حفظ دين
  static Future<void> saveDebt(Debt debt) async {
    final debts = await getAllDebts();
    final existingIndex = debts.indexWhere((d) => d.id == debt.id);

    if (existingIndex != -1) {
      debts[existingIndex] = debt;
    } else {
      debts.add(debt);
    }

    await _saveDebts(debts);
  }

  // تحديث دين (alias)
  static Future<void> updateDebt(Debt debt) async {
    await saveDebt(debt);
  }

  // تحديث دفعة
  static Future<void> updatePayment(Payment payment) async {
    await savePayment(payment);
  }

  // الحصول على جميع الديون
  static Future<List<Debt>> getAllDebts() async {
    final debtsJson = StorageService.getList(_keyDebts) ?? [];
    return debtsJson.map((json) => Debt.fromJson(json)).toList();
  }

  // الحصول على ديون عميل
  static Future<List<Debt>> getDebtsByCustomerId(String customerId) async {
    final debts = await getAllDebts();
    return debts.where((debt) => debt.customerId == customerId).toList();
  }

  // الحصول على ديون مالك منشأة
  static Future<List<Debt>> getDebtsByOwnerId(String ownerId) async {
    final debts = await getAllDebts();
    return debts.where((debt) => debt.businessOwnerId == ownerId).toList();
  }

  // الحصول على دين بالمعرف
  static Future<Debt?> getDebtById(String id) async {
    final debts = await getAllDebts();
    try {
      return debts.firstWhere((debt) => debt.id == id);
    } catch (e) {
      return null;
    }
  }

  // حذف دين
  static Future<void> deleteDebt(String id) async {
    final debts = await getAllDebts();
    debts.removeWhere((debt) => debt.id == id);
    await _saveDebts(debts);
  }

  // حفظ قائمة الديون
  static Future<void> _saveDebts(List<Debt> debts) async {
    final debtsJson = debts.map((debt) => debt.toJson()).toList();
    await StorageService.setList(_keyDebts, debtsJson);
  }

  // ===== إدارة المدفوعات =====

  // حفظ دفعة
  static Future<void> savePayment(Payment payment) async {
    final payments = await getAllPayments();
    final existingIndex = payments.indexWhere((p) => p.id == payment.id);

    if (existingIndex != -1) {
      payments[existingIndex] = payment;
    } else {
      payments.add(payment);
    }

    await _savePayments(payments);
  }

  // الحصول على جميع المدفوعات
  static Future<List<Payment>> getAllPayments() async {
    final paymentsJson = StorageService.getList(_keyPayments) ?? [];
    return paymentsJson.map((json) => Payment.fromJson(json)).toList();
  }

  // الحصول على مدفوعات دين
  static Future<List<Payment>> getPaymentsByDebtId(String debtId) async {
    final payments = await getAllPayments();
    return payments.where((payment) => payment.debtId == debtId).toList();
  }

  // الحصول على مدفوعات عميل
  static Future<List<Payment>> getPaymentsByCustomerId(
      String customerId) async {
    final payments = await getAllPayments();
    return payments
        .where((payment) => payment.customerId == customerId)
        .toList();
  }

  // الحصول على مدفوعات مالك منشأة
  static Future<List<Payment>> getPaymentsByOwnerId(String ownerId) async {
    final payments = await getAllPayments();
    return payments
        .where((payment) => payment.businessOwnerId == ownerId)
        .toList();
  }

  // الحصول على دفعة بالمعرف
  static Future<Payment?> getPaymentById(String id) async {
    final payments = await getAllPayments();
    try {
      return payments.firstWhere((payment) => payment.id == id);
    } catch (e) {
      return null;
    }
  }

  // حذف دفعة
  static Future<void> deletePayment(String id) async {
    final payments = await getAllPayments();
    payments.removeWhere((payment) => payment.id == id);
    await _savePayments(payments);
  }

  // حفظ قائمة المدفوعات
  static Future<void> _savePayments(List<Payment> payments) async {
    final paymentsJson = payments.map((payment) => payment.toJson()).toList();
    await StorageService.setList(_keyPayments, paymentsJson);
  }

  // ===== إدارة الاشتراكات =====

  // حفظ اشتراك
  static Future<void> saveSubscription(Subscription subscription) async {
    final subscriptions = await getAllSubscriptions();
    final existingIndex =
        subscriptions.indexWhere((s) => s.id == subscription.id);

    if (existingIndex != -1) {
      subscriptions[existingIndex] = subscription;
    } else {
      subscriptions.add(subscription);
    }

    await _saveSubscriptions(subscriptions);
  }

  // الحصول على جميع الاشتراكات
  static Future<List<Subscription>> getAllSubscriptions() async {
    final subscriptionsJson = StorageService.getList(_keySubscriptions) ?? [];
    return subscriptionsJson
        .map((json) => Subscription.fromJson(json))
        .toList();
  }

  // الحصول على اشتراك بمعرف الجهاز
  static Future<Subscription?> getSubscriptionByDeviceId(
      String deviceId) async {
    final subscriptions = await getAllSubscriptions();
    try {
      return subscriptions.firstWhere((sub) => sub.deviceId == deviceId);
    } catch (e) {
      return null;
    }
  }

  // الحصول على اشتراك بالمعرف
  static Future<Subscription?> getSubscriptionById(String id) async {
    final subscriptions = await getAllSubscriptions();
    try {
      return subscriptions.firstWhere((sub) => sub.id == id);
    } catch (e) {
      return null;
    }
  }

  // حذف اشتراك
  static Future<void> deleteSubscription(String id) async {
    final subscriptions = await getAllSubscriptions();
    subscriptions.removeWhere((sub) => sub.id == id);
    await _saveSubscriptions(subscriptions);
  }

  // حفظ قائمة الاشتراكات
  static Future<void> _saveSubscriptions(
      List<Subscription> subscriptions) async {
    final subscriptionsJson = subscriptions.map((sub) => sub.toJson()).toList();
    await StorageService.setList(_keySubscriptions, subscriptionsJson);
  }

  // ===== عمليات شاملة =====

  // حذف جميع البيانات
  static Future<void> clearAllData() async {
    await StorageService.remove(_keyUsers);
    await StorageService.remove(_keyCustomers);
    await StorageService.remove(_keyDebts);
    await StorageService.remove(_keyPayments);
    await StorageService.remove(_keySubscriptions);
    await StorageService.remove(_keyCurrentUser);
  }

  // تصدير جميع البيانات
  static Future<Map<String, dynamic>> exportAllData() async {
    return {
      'users': await getAllUsers(),
      'customers': await getAllCustomers(),
      'debts': await getAllDebts(),
      'payments': await getAllPayments(),
      'subscriptions': await getAllSubscriptions(),
      'currentUser': await getCurrentUser(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  // استيراد البيانات
  static Future<bool> importData(Map<String, dynamic> data) async {
    try {
      // حذف البيانات الحالية
      await clearAllData();

      // استيراد البيانات الجديدة
      if (data['users'] != null) {
        final users =
            (data['users'] as List).map((json) => User.fromJson(json)).toList();
        await _saveUsers(users);
      }

      if (data['customers'] != null) {
        final customers = (data['customers'] as List)
            .map((json) => Customer.fromJson(json))
            .toList();
        await _saveCustomers(customers);
      }

      if (data['debts'] != null) {
        final debts =
            (data['debts'] as List).map((json) => Debt.fromJson(json)).toList();
        await _saveDebts(debts);
      }

      if (data['payments'] != null) {
        final payments = (data['payments'] as List)
            .map((json) => Payment.fromJson(json))
            .toList();
        await _savePayments(payments);
      }

      if (data['subscriptions'] != null) {
        final subscriptions = (data['subscriptions'] as List)
            .map((json) => Subscription.fromJson(json))
            .toList();
        await _saveSubscriptions(subscriptions);
      }

      if (data['currentUser'] != null) {
        final currentUser = User.fromJson(data['currentUser']);
        await saveCurrentUser(currentUser);
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
