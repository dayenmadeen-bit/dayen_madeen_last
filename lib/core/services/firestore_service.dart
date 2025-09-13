import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

/// Firestore service for data persistence and synchronization
class FirestoreService extends GetxService {
  static FirestoreService get instance => Get.find<FirestoreService>();

  late final FirebaseFirestore _db;

  @override
  void onInit() {
    _db = FirebaseFirestore.instance;
    super.onInit();
  }

  // Enable offline persistence by default
  static Future<void> enableOfflinePersistence() async {
    try {
      await FirebaseFirestore.instance
          .enablePersistence(const PersistenceSettings(synchronizeTabs: true));
    } catch (_) {
      // Ignore if already enabled or unsupported
    }
  }

  // Collections shortcuts
  CollectionReference<Map<String, dynamic>> usersCol() =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> customersCol(String ownerId) =>
      usersCol().doc(ownerId).collection('customers');
  CollectionReference<Map<String, dynamic>> employeesCol(String ownerId) =>
      usersCol().doc(ownerId).collection('employees');
  CollectionReference<Map<String, dynamic>> debtsCol(String ownerId) =>
      usersCol().doc(ownerId).collection('debts');
  CollectionReference<Map<String, dynamic>> paymentsCol(String ownerId) =>
      usersCol().doc(ownerId).collection('payments');
  CollectionReference<Map<String, dynamic>> notificationsCol(String userId) =>
      usersCol().doc(userId).collection('notifications');
  CollectionReference<Map<String, dynamic>> purchaseRequestsCol() =>
      _db.collection('purchase_requests');
  CollectionReference<Map<String, dynamic>> paymentRequestsCol() =>
      _db.collection('payment_requests');

  // Generic helpers
  Future<DocumentReference<Map<String, dynamic>>> addDoc(
      CollectionReference<Map<String, dynamic>> col,
      Map<String, dynamic> data) {
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    return col.add(data);
  }

  Future<void> setDoc(
      DocumentReference<Map<String, dynamic>> ref, Map<String, dynamic> data,
      {bool merge = true}) {
    data['updatedAt'] = FieldValue.serverTimestamp();
    if (!merge) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    return ref.set(data, SetOptions(merge: merge));
  }

  Future<void> updateDoc(
      DocumentReference<Map<String, dynamic>> ref, Map<String, dynamic> data) {
    data['updatedAt'] = FieldValue.serverTimestamp();
    return ref.update(data);
  }

  Future<void> deleteDoc(DocumentReference<Map<String, dynamic>> ref) =>
      ref.delete();

  // Batch operations
  WriteBatch batch() => _db.batch();

  // البحث عن المستخدم بالرقم المميز
  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserByUniqueId(
      String uniqueId) async {
    try {
      final querySnapshot = await usersCol()
          .where('uniqueId', isEqualTo: uniqueId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      }
      return null;
    } catch (e) {
      print('خطأ في البحث عن المستخدم بالرقم المميز: $e');
      return null;
    }
  }

  // البحث عن العميل بالرقم المميز
  Future<DocumentSnapshot<Map<String, dynamic>>?> getCustomerByUniqueId(
      String uniqueId) async {
    try {
      // البحث في جميع المستخدمين
      final querySnapshot = await usersCol()
          .where('uniqueId', isEqualTo: uniqueId)
          .where('role', isEqualTo: 'customer')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      }
      return null;
    } catch (e) {
      print('خطأ في البحث عن العميل بالرقم المميز: $e');
      return null;
    }
  }

  // البحث عن الموظف بالرقم المميز
  Future<DocumentSnapshot<Map<String, dynamic>>?> getEmployeeByUniqueId(
      String uniqueId) async {
    try {
      final querySnapshot = await usersCol()
          .where('uniqueId', isEqualTo: uniqueId)
          .where('role', isEqualTo: 'employee')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      }
      return null;
    } catch (e) {
      print('خطأ في البحث عن الموظف بالرقم المميز: $e');
      return null;
    }
  }

  // البحث عن مالك المنشأة بالرقم المميز
  Future<DocumentSnapshot<Map<String, dynamic>>?> getBusinessOwnerByUniqueId(
      String uniqueId) async {
    try {
      final querySnapshot = await usersCol()
          .where('uniqueId', isEqualTo: uniqueId)
          .where('role', isEqualTo: 'business_owner')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      }
      return null;
    } catch (e) {
      print('خطأ في البحث عن مالك المنشأة بالرقم المميز: $e');
      return null;
    }
  }

  // الحصول على جميع العملاء لمالك منشأة
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getCustomersForOwner(
      String ownerId) async {
    try {
      final querySnapshot = await customersCol(ownerId).get();
      return querySnapshot.docs;
    } catch (e) {
      print('خطأ في تحميل العملاء: $e');
      return [];
    }
  }

  // الحصول على جميع الموظفين لمالك منشأة
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getEmployeesForOwner(
      String ownerId) async {
    try {
      final querySnapshot = await employeesCol(ownerId).get();
      return querySnapshot.docs;
    } catch (e) {
      print('خطأ في تحميل الموظفين: $e');
      return [];
    }
  }

  // الحصول على جميع الديون لمالك منشأة
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getDebtsForOwner(
      String ownerId) async {
    try {
      final querySnapshot = await debtsCol(ownerId).get();
      return querySnapshot.docs;
    } catch (e) {
      print('خطأ في تحميل الديون: $e');
      return [];
    }
  }

  // الحصول على جميع المدفوعات لمالك منشأة
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getPaymentsForOwner(
      String ownerId) async {
    try {
      final querySnapshot = await paymentsCol(ownerId).get();
      return querySnapshot.docs;
    } catch (e) {
      print('خطأ في تحميل المدفوعات: $e');
      return [];
    }
  }

  // الحصول على الإشعارات للمستخدم
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getNotificationsForUser(
      String userId) async {
    try {
      final querySnapshot = await notificationsCol(userId)
          .orderBy('createdAt', descending: true)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print('خطأ في تحميل الإشعارات: $e');
      return [];
    }
  }

  // البحث في العملاء
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> searchCustomers(
      String ownerId, String query) async {
    try {
      final querySnapshot = await customersCol(ownerId)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print('خطأ في البحث في العملاء: $e');
      return [];
    }
  }

  // البحث في الموظفين
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> searchEmployees(
      String ownerId, String query) async {
    try {
      final querySnapshot = await employeesCol(ownerId)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print('خطأ في البحث في الموظفين: $e');
      return [];
    }
  }

  // إضافة عميل جديد
  Future<DocumentReference<Map<String, dynamic>>> addCustomer(
      String ownerId, Map<String, dynamic> customerData) async {
    return await addDoc(customersCol(ownerId), customerData);
  }

  // إضافة موظف جديد
  Future<DocumentReference<Map<String, dynamic>>> addEmployee(
      String ownerId, Map<String, dynamic> employeeData) async {
    return await addDoc(employeesCol(ownerId), employeeData);
  }

  // إضافة دين جديد
  Future<DocumentReference<Map<String, dynamic>>> addDebt(
      String ownerId, Map<String, dynamic> debtData) async {
    return await addDoc(debtsCol(ownerId), debtData);
  }

  // إضافة دفعة جديدة
  Future<DocumentReference<Map<String, dynamic>>> addPayment(
      String ownerId, Map<String, dynamic> paymentData) async {
    return await addDoc(paymentsCol(ownerId), paymentData);
  }

  // إضافة إشعار جديد
  Future<DocumentReference<Map<String, dynamic>>> addNotification(
      String userId, Map<String, dynamic> notificationData) async {
    return await addDoc(notificationsCol(userId), notificationData);
  }

  // تحديث عميل
  Future<void> updateCustomer(
      String ownerId, String customerId, Map<String, dynamic> data) async {
    await updateDoc(customersCol(ownerId).doc(customerId), data);
  }

  // تحديث موظف
  Future<void> updateEmployee(
      String ownerId, String employeeId, Map<String, dynamic> data) async {
    await updateDoc(employeesCol(ownerId).doc(employeeId), data);
  }

  // تحديث دين
  Future<void> updateDebt(
      String ownerId, String debtId, Map<String, dynamic> data) async {
    await updateDoc(debtsCol(ownerId).doc(debtId), data);
  }

  // تحديث دفعة
  Future<void> updatePayment(
      String ownerId, String paymentId, Map<String, dynamic> data) async {
    await updateDoc(paymentsCol(ownerId).doc(paymentId), data);
  }

  // حذف عميل
  Future<void> deleteCustomer(String ownerId, String customerId) async {
    await deleteDoc(customersCol(ownerId).doc(customerId));
  }

  // حذف موظف
  Future<void> deleteEmployee(String ownerId, String employeeId) async {
    await deleteDoc(employeesCol(ownerId).doc(employeeId));
  }

  // حذف دين
  Future<void> deleteDebt(String ownerId, String debtId) async {
    await deleteDoc(debtsCol(ownerId).doc(debtId));
  }

  // حذف دفعة
  Future<void> deletePayment(String ownerId, String paymentId) async {
    await deleteDoc(paymentsCol(ownerId).doc(paymentId));
  }

  // الحصول على إحصائيات مالك المنشأة
  Future<Map<String, dynamic>> getOwnerStats(String ownerId) async {
    try {
      final customersSnapshot = await customersCol(ownerId).get();
      final debtsSnapshot = await debtsCol(ownerId).get();
      final paymentsSnapshot = await paymentsCol(ownerId).get();

      int totalCustomers = customersSnapshot.docs.length;
      int totalDebts = debtsSnapshot.docs.length;
      int totalPayments = paymentsSnapshot.docs.length;

      double totalDebtAmount = 0;
      double totalPaymentAmount = 0;

      for (final doc in debtsSnapshot.docs) {
        final data = doc.data();
        totalDebtAmount += (data['amount'] as num?)?.toDouble() ?? 0;
      }

      for (final doc in paymentsSnapshot.docs) {
        final data = doc.data();
        totalPaymentAmount += (data['amount'] as num?)?.toDouble() ?? 0;
      }

      return {
        'totalCustomers': totalCustomers,
        'totalDebts': totalDebts,
        'totalPayments': totalPayments,
        'totalDebtAmount': totalDebtAmount,
        'totalPaymentAmount': totalPaymentAmount,
        'remainingAmount': totalDebtAmount - totalPaymentAmount,
      };
    } catch (e) {
      print('خطأ في حساب الإحصائيات: $e');
      return {
        'totalCustomers': 0,
        'totalDebts': 0,
        'totalPayments': 0,
        'totalDebtAmount': 0.0,
        'totalPaymentAmount': 0.0,
        'remainingAmount': 0.0,
      };
    }
  }
}
