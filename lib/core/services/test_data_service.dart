import 'package:get/get.dart';
import '../../app/data/models/customer.dart';
import '../../app/data/models/debt.dart';
import '../../app/data/models/payment.dart';
import '../../app/data/models/employee.dart';
import '../../app/data/models/client_request.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

/// خدمة إضافة البيانات التجريبية للاختبار
class TestDataService {
  static final TestDataService _instance = TestDataService._internal();
  factory TestDataService() => _instance;
  TestDataService._internal();

  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  /// إضافة بيانات تجريبية شاملة
  Future<void> seedTestData() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        Get.snackbar('خطأ', 'يجب تسجيل الدخول أولاً');
        return;
      }

      // إضافة عملاء تجريبيين
      await _seedCustomers(currentUser.id);

      // إضافة ديون تجريبية
      await _seedDebts(currentUser.id);

      // إضافة مدفوعات تجريبية
      await _seedPayments(currentUser.id);

      // إضافة موظفين تجريبيين
      await _seedEmployees(currentUser.id);

      // إضافة طلبات تجريبية
      await _seedRequests(currentUser.id);

      // إضافة إشعارات تجريبية
      await _seedNotifications(currentUser.id);

      Get.snackbar('نجح', 'تم إضافة البيانات التجريبية بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في إضافة البيانات التجريبية: $e');
    }
  }

  /// إضافة عملاء تجريبيين
  Future<void> _seedCustomers(String ownerId) async {
    final customers = [
      Customer.create(
        businessOwnerId: ownerId,
        name: 'أحمد محمد السعيد',
        uniqueId: '1234567',
        password: 'A1234',
        creditLimit: 5000.0,
        email: 'ahmed@example.com',
      ),
      Customer.create(
        businessOwnerId: ownerId,
        name: 'فاطمة علي أحمد',
        uniqueId: '2345678',
        password: 'F1234',
        creditLimit: 3000.0,
        email: 'fatima@example.com',
      ),
      Customer.create(
        businessOwnerId: ownerId,
        name: 'محمد عبدالله النور',
        uniqueId: '3456789',
        password: 'M1234',
        creditLimit: 7500.0,
        email: 'mohammed@example.com',
      ),
      Customer.create(
        businessOwnerId: ownerId,
        name: 'نورا سعد الدين',
        uniqueId: '4567890',
        password: 'N1234',
        creditLimit: 2000.0,
        email: 'nora@example.com',
      ),
      Customer.create(
        businessOwnerId: ownerId,
        name: 'خالد إبراهيم الشامي',
        uniqueId: '5678901',
        password: 'K1234',
        creditLimit: 4000.0,
        email: 'khalid@example.com',
      ),
    ];

    for (final customer in customers) {
      await _firestoreService
          .usersCol()
          .doc(ownerId)
          .collection('customers')
          .doc(customer.id)
          .set(customer.toJson());
    }
  }

  /// إضافة ديون تجريبية
  Future<void> _seedDebts(String ownerId) async {
    final customers = await _getCustomers(ownerId);
    if (customers.isEmpty) return;

    final debts = [
      Debt.create(
        businessOwnerId: ownerId,
        customerId: customers[0].id,
        amount: 1500.0,
        description: 'شراء مواد غذائية',
        dueDate: DateTime.now().add(const Duration(days: 30)),
      ),
      Debt.create(
        businessOwnerId: ownerId,
        customerId: customers[0].id,
        amount: 800.0,
        description: 'شراء أدوات منزلية',
        dueDate: DateTime.now().add(const Duration(days: 15)),
      ),
      Debt.create(
        businessOwnerId: ownerId,
        customerId: customers[1].id,
        amount: 2200.0,
        description: 'شراء ملابس',
        dueDate: DateTime.now().add(const Duration(days: 45)),
      ),
      Debt.create(
        businessOwnerId: ownerId,
        customerId: customers[2].id,
        amount: 3200.0,
        description: 'شراء إلكترونيات',
        dueDate: DateTime.now().add(const Duration(days: 60)),
      ),
      Debt.create(
        businessOwnerId: ownerId,
        customerId: customers[3].id,
        amount: 900.0,
        description: 'شراء كتب',
        dueDate: DateTime.now().add(const Duration(days: 20)),
      ),
    ];

    for (final debt in debts) {
      await _firestoreService
          .usersCol()
          .doc(ownerId)
          .collection('debts')
          .doc(debt.id)
          .set(debt.toJson());
    }
  }

  /// إضافة مدفوعات تجريبية
  Future<void> _seedPayments(String ownerId) async {
    final customers = await _getCustomers(ownerId);
    if (customers.isEmpty) return;

    final payments = [
      Payment.create(
        businessOwnerId: ownerId,
        customerId: customers[0].id,
        debtId: 'debt_1',
        amount: 300.0,
        paymentMethod: 'نقد',
        notes: 'دفعة جزئية',
      ),
      Payment.create(
        businessOwnerId: ownerId,
        customerId: customers[1].id,
        debtId: 'debt_2',
        amount: 500.0,
        paymentMethod: 'تحويل بنكي',
        notes: 'دفعة أولى',
      ),
      Payment.create(
        businessOwnerId: ownerId,
        customerId: customers[2].id,
        debtId: 'debt_3',
        amount: 1000.0,
        paymentMethod: 'محفظة إلكترونية',
        notes: 'دفعة كاملة',
      ),
      Payment.create(
        businessOwnerId: ownerId,
        customerId: customers[3].id,
        debtId: 'debt_4',
        amount: 900.0,
        paymentMethod: 'نقد',
        notes: 'دفعة كاملة',
      ),
    ];

    for (final payment in payments) {
      await _firestoreService
          .usersCol()
          .doc(ownerId)
          .collection('payments')
          .doc(payment.id)
          .set(payment.toJson());
    }
  }

  /// إضافة موظفين تجريبيين
  Future<void> _seedEmployees(String ownerId) async {
    final employees = [
      Employee.create(
        businessOwnerId: ownerId,
        name: 'سارة أحمد',
        uniqueId: 'EMP001',
        passwordHash: 'hash1',
        passwordSalt: 'salt1',
      ),
      Employee.create(
        businessOwnerId: ownerId,
        name: 'عبدالرحمن محمد',
        uniqueId: 'EMP002',
        passwordHash: 'hash2',
        passwordSalt: 'salt2',
      ),
      Employee.create(
        businessOwnerId: ownerId,
        name: 'مريم خالد',
        uniqueId: 'EMP003',
        passwordHash: 'hash3',
        passwordSalt: 'salt3',
      ),
    ];

    for (final employee in employees) {
      await _firestoreService
          .usersCol()
          .doc(ownerId)
          .collection('employees')
          .doc(employee.id)
          .set(employee.toJson());
    }
  }

  /// إضافة طلبات تجريبية
  Future<void> _seedRequests(String ownerId) async {
    final customers = await _getCustomers(ownerId);
    if (customers.isEmpty) return;

    final requests = [
      ClientRequest.create(
        clientId: customers[0].id,
        clientName: customers[0].name,
        type: RequestType.debt,
        description: 'أرغب في شراء مواد غذائية بقيمة 500 ريال',
        amount: 500.0,
      ),
      ClientRequest.create(
        clientId: customers[1].id,
        clientName: customers[1].name,
        type: RequestType.payment,
        description: 'أرغب في سداد مبلغ 300 ريال',
        amount: 300.0,
      ),
      ClientRequest.create(
        clientId: customers[2].id,
        clientName: customers[2].name,
        type: RequestType.debt,
        description: 'أرغب في شراء هاتف ذكي بقيمة 2000 ريال',
        amount: 2000.0,
      ),
    ];

    for (final request in requests) {
      await _firestoreService
          .usersCol()
          .doc(ownerId)
          .collection('requests')
          .doc(request.id)
          .set(request.toMap());
    }
  }

  /// إضافة إشعارات تجريبية
  Future<void> _seedNotifications(String ownerId) async {
    final notifications = [
      {
        'id': 'notif_1',
        'title': 'طلب جديد من العميل',
        'body': 'أحمد محمد السعيد يطلب شراء مواد بقيمة 500 ريال',
        'type': 'request',
        'isRead': false,
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'id': 'notif_2',
        'title': 'دفعة جديدة',
        'body': 'فاطمة علي أحمد سددت مبلغ 300 ريال',
        'type': 'payment',
        'isRead': false,
        'createdAt': DateTime.now().subtract(const Duration(hours: 5)),
      },
      {
        'id': 'notif_3',
        'title': 'دين جديد',
        'body': 'تم إضافة دين جديد لمحمد عبدالله النور بقيمة 1500 ريال',
        'type': 'debt',
        'isRead': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      },
    ];

    for (final notification in notifications) {
      await _firestoreService
          .usersCol()
          .doc(ownerId)
          .collection('notifications')
          .doc(notification['id'] as String)
          .set(Map<String, dynamic>.from(notification));
    }
  }

  /// الحصول على العملاء
  Future<List<Customer>> _getCustomers(String ownerId) async {
    try {
      final query = await _firestoreService
          .usersCol()
          .doc(ownerId)
          .collection('customers')
          .limit(5)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        return Customer.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// مسح جميع البيانات التجريبية
  Future<void> clearTestData() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;

      // مسح العملاء
      final customersQuery = await _firestoreService
          .usersCol()
          .doc(currentUser.id)
          .collection('customers')
          .get();

      for (final doc in customersQuery.docs) {
        await doc.reference.delete();
      }

      // مسح الديون
      final debtsQuery = await _firestoreService
          .usersCol()
          .doc(currentUser.id)
          .collection('debts')
          .get();

      for (final doc in debtsQuery.docs) {
        await doc.reference.delete();
      }

      // مسح المدفوعات
      final paymentsQuery = await _firestoreService
          .usersCol()
          .doc(currentUser.id)
          .collection('payments')
          .get();

      for (final doc in paymentsQuery.docs) {
        await doc.reference.delete();
      }

      // مسح الموظفين
      final employeesQuery = await _firestoreService
          .usersCol()
          .doc(currentUser.id)
          .collection('employees')
          .get();

      for (final doc in employeesQuery.docs) {
        await doc.reference.delete();
      }

      // مسح الطلبات
      final requestsQuery = await _firestoreService
          .usersCol()
          .doc(currentUser.id)
          .collection('requests')
          .get();

      for (final doc in requestsQuery.docs) {
        await doc.reference.delete();
      }

      // مسح الإشعارات
      final notificationsQuery = await _firestoreService
          .usersCol()
          .doc(currentUser.id)
          .collection('notifications')
          .get();

      for (final doc in notificationsQuery.docs) {
        await doc.reference.delete();
      }

      Get.snackbar('نجح', 'تم مسح جميع البيانات التجريبية');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في مسح البيانات التجريبية: $e');
    }
  }
}


