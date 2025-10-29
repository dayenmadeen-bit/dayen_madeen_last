import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../app/data/models/customer.dart';
import '../../app/data/models/debt.dart';
import '../../app/data/models/payment.dart';
import '../../app/data/models/employee.dart';
import 'firebase_integration_service.dart';
import 'logger_service.dart';

/// خدمة المزامنة الفورية مع Firebase Firestore
class RealTimeSyncService extends GetxService {
  static RealTimeSyncService get instance => Get.find<RealTimeSyncService>();

  late final FirebaseIntegrationService _firebaseService;
  final Map<String, StreamSubscription> _activeStreams = {};
  
  // مراقبات البيانات الحية
  final _customers = <Customer>[].obs;
  final _debts = <Debt>[].obs;
  final _payments = <Payment>[].obs;
  final _employees = <Employee>[].obs;
  
  // حالة المزامنة
  final _isSyncing = false.obs;
  final _lastSyncTime = Rx<DateTime?>(null);
  
  List<Customer> get customers => _customers;
  List<Debt> get debts => _debts;
  List<Payment> get payments => _payments;
  List<Employee> get employees => _employees;
  bool get isSyncing => _isSyncing.value;
  DateTime? get lastSyncTime => _lastSyncTime.value;

  @override
  void onInit() {
    super.onInit();
    _firebaseService = Get.find<FirebaseIntegrationService>();
    _startRealTimeSync();
  }

  @override
  void onClose() {
    _stopAllStreams();
    super.onClose();
  }

  /// بدء المزامنة الفورية
  void _startRealTimeSync() {
    if (!_firebaseService.isInitialized) {
      LoggerService.warning('⚠️ Firebase غير مهيأ بعد، سيتم تأجيل المزامنة');
      return;
    }

    final user = _firebaseService.currentUser;
    if (user == null) {
      LoggerService.info('لا يوجد مستخدم مسجل دخول، لن يتم بدء المزامنة');
      return;
    }

    _isSyncing.value = true;
    LoggerService.info('🔄 بدء المزامنة الفورية للمستخدم: ${user.uid}');

    try {
      // مزامنة العملاء
      _startCustomersSync(user.uid);
      
      // مزامنة الديون
      _startDebtsSync(user.uid);
      
      // مزامنة المدفوعات
      _startPaymentsSync(user.uid);
      
      // مزامنة الموظفين
      _startEmployeesSync(user.uid);
      
      _lastSyncTime.value = DateTime.now();
      _isSyncing.value = false;
      
      LoggerService.success('✅ تم بدء جميع عمليات المزامنة');
    } catch (e) {
      _isSyncing.value = false;
      LoggerService.error('❌ خطأ في بدء المزامنة', error: e);
    }
  }

  /// مزامنة العملاء في الوقت الفعلي
  void _startCustomersSync(String ownerId) {
    final stream = _firebaseService.firestore
        .collection('customers')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots();

    _activeStreams['customers'] = stream.listen(
      (snapshot) {
        final customersList = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Customer.fromMap(data);
        }).toList();
        
        _customers.value = customersList;
        LoggerService.info('🔄 تم تحديث قائمة العملاء: ${customersList.length} عميل');
      },
      onError: (error) {
        LoggerService.error('خطأ في مزامنة العملاء', error: error);
      },
    );
  }

  /// مزامنة الديون في الوقت الفعلي
  void _startDebtsSync(String ownerId) {
    final stream = _firebaseService.firestore
        .collection('debts')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .limit(100) // حدود لتحسين الأداء
        .snapshots();

    _activeStreams['debts'] = stream.listen(
      (snapshot) {
        final debtsList = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Debt.fromMap(data);
        }).toList();
        
        _debts.value = debtsList;
        LoggerService.info('🔄 تم تحديث قائمة الديون: ${debtsList.length} دين');
      },
      onError: (error) {
        LoggerService.error('خطأ في مزامنة الديون', error: error);
      },
    );
  }

  /// مزامنة المدفوعات في الوقت الفعلي
  void _startPaymentsSync(String ownerId) {
    final stream = _firebaseService.firestore
        .collection('payments')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('paymentDate', descending: true)
        .limit(100)
        .snapshots();

    _activeStreams['payments'] = stream.listen(
      (snapshot) {
        final paymentsList = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Payment.fromMap(data);
        }).toList();
        
        _payments.value = paymentsList;
        LoggerService.info('🔄 تم تحديث قائمة المدفوعات: ${paymentsList.length} دفعة');
      },
      onError: (error) {
        LoggerService.error('خطأ في مزامنة المدفوعات', error: error);
      },
    );
  }

  /// مزامنة الموظفين في الوقت الفعلي
  void _startEmployeesSync(String businessOwnerId) {
    final stream = _firebaseService.firestore
        .collection('employees')
        .where('businessOwnerId', isEqualTo: businessOwnerId)
        .snapshots();

    _activeStreams['employees'] = stream.listen(
      (snapshot) {
        final employeesList = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Employee.fromMap(data);
        }).toList();
        
        _employees.value = employeesList;
        LoggerService.info('🔄 تم تحديث قائمة الموظفين: ${employeesList.length} موظف');
      },
      onError: (error) {
        LoggerService.error('خطأ في مزامنة الموظفين', error: error);
      },
    );
  }

  /// إضافة عميل جديد مع مزامنة فورية
  Future<bool> addCustomer(Customer customer) async {
    try {
      final user = _firebaseService.currentUser;
      if (user == null) throw Exception('لا يوجد مستخدم مسجل دخول');

      final customerData = customer.toMap();
      customerData['ownerId'] = user.uid;
      customerData['createdAt'] = FieldValue.serverTimestamp();
      customerData['updatedAt'] = FieldValue.serverTimestamp();

      await _firebaseService.firestore
          .collection('customers')
          .doc(customer.id)
          .set(customerData);

      LoggerService.success('✅ تم إضافة العميل: ${customer.name}');
      
      // تسجيل إحصائية
      await _firebaseService.logEvent('customer_added', {
        'customer_id': customer.id,
        'customer_name': customer.name,
      });
      
      return true;
    } catch (e) {
      LoggerService.error('❌ خطأ في إضافة العميل', error: e);
      return false;
    }
  }

  /// إضافة دين جديد مع مزامنة فورية
  Future<bool> addDebt(Debt debt) async {
    try {
      final user = _firebaseService.currentUser;
      if (user == null) throw Exception('لا يوجد مستخدم مسجل دخول');

      final debtData = debt.toMap();
      debtData['ownerId'] = user.uid;
      debtData['createdAt'] = FieldValue.serverTimestamp();
      debtData['updatedAt'] = FieldValue.serverTimestamp();

      await _firebaseService.firestore
          .collection('debts')
          .doc(debt.id)
          .set(debtData);

      LoggerService.success('✅ تم إضافة الدين بمبلغ: ${debt.amount}');
      
      // تسجيل إحصائية
      await _firebaseService.logEvent('debt_added', {
        'debt_id': debt.id,
        'amount': debt.amount,
        'customer_id': debt.customerId,
      });
      
      return true;
    } catch (e) {
      LoggerService.error('❌ خطأ في إضافة الدين', error: e);
      return false;
    }
  }

  /// إضافة دفعة جديدة مع مزامنة فورية
  Future<bool> addPayment(Payment payment) async {
    try {
      final user = _firebaseService.currentUser;
      if (user == null) throw Exception('لا يوجد مستخدم مسجل دخول');

      final paymentData = payment.toMap();
      paymentData['ownerId'] = user.uid;
      paymentData['createdAt'] = FieldValue.serverTimestamp();

      // بدء transaction لضمان تحديث الدين أيضاً
      await _firebaseService.firestore.runTransaction((transaction) async {
        // إضافة الدفعع
        transaction.set(
          _firebaseService.firestore.collection('payments').doc(payment.id),
          paymentData,
        );

        // تحديث الدين المرتبط
        final debtRef = _firebaseService.firestore
            .collection('debts')
            .doc(payment.debtId);
            
        final debtDoc = await transaction.get(debtRef);
        if (debtDoc.exists) {
          final debtData = debtDoc.data()!;
          final currentPaid = (debtData['paidAmount'] as num?)?.toDouble() ?? 0.0;
          final newPaidAmount = currentPaid + payment.amount;
          final totalAmount = (debtData['amount'] as num?)?.toDouble() ?? 0.0;
          
          // تحديد حالة الدين
          String newStatus;
          if (newPaidAmount >= totalAmount) {
            newStatus = 'paid';
          } else if (newPaidAmount > 0) {
            newStatus = 'partially_paid';
          } else {
            newStatus = 'pending';
          }
          
          transaction.update(debtRef, {
            'paidAmount': newPaidAmount,
            'remainingAmount': totalAmount - newPaidAmount,
            'status': newStatus,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      LoggerService.success('✅ تم إضافة الدفعة بمبلغ: ${payment.amount}');
      
      // تسجيل إحصائية
      await _firebaseService.logEvent('payment_added', {
        'payment_id': payment.id,
        'amount': payment.amount,
        'debt_id': payment.debtId,
        'method': payment.paymentMethod,
      });
      
      return true;
    } catch (e) {
      LoggerService.error('❌ خطأ في إضافة الدفعة', error: e);
      return false;
    }
  }

  /// حذف عنصر مع مزامنة فورية
  Future<bool> deleteItem({
    required String collection,
    required String documentId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firebaseService.firestore
          .collection(collection)
          .doc(documentId)
          .delete();

      LoggerService.success('✅ تم حذف $documentId من $collection');
      
      // تسجيل إحصائية
      await _firebaseService.logEvent('item_deleted', {
        'collection': collection,
        'document_id': documentId,
        ...?metadata,
      });
      
      return true;
    } catch (e) {
      LoggerService.error('❌ خطأ في حذف العنصر', error: e);
      return false;
    }
  }

  /// تحديث عنصر مع مزامنة فورية
  Future<bool> updateItem({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firebaseService.firestore
          .collection(collection)
          .doc(documentId)
          .update(data);

      LoggerService.success('✅ تم تحديث $documentId في $collection');
      
      // تسجيل إحصائية
      await _firebaseService.logEvent('item_updated', {
        'collection': collection,
        'document_id': documentId,
        ...?metadata,
      });
      
      return true;
    } catch (e) {
      LoggerService.error('❌ خطأ في تحديث العنصر', error: e);
      return false;
    }
  }

  /// إيقاف جميع المزامنات
  void _stopAllStreams() {
    for (final stream in _activeStreams.values) {
      stream.cancel();
    }
    _activeStreams.clear();
    LoggerService.info('✅ تم إيقاف جميع عمليات المزامنة');
  }

  /// إعادة بدء المزامنة
  void restart() {
    _stopAllStreams();
    _startRealTimeSync();
  }

  /// فرض مزامنة فورية
  Future<void> forceSync() async {
    try {
      _isSyncing.value = true;
      LoggerService.info('🔄 بدء مزامنة فورية...');
      
      // إعادة بدء جميع المزامنات
      restart();
      
      _lastSyncTime.value = DateTime.now();
      LoggerService.success('✅ تمت المزامنة الفورية');
    } catch (e) {
      LoggerService.error('❌ خطأ في المزامنة الفورية', error: e);
    } finally {
      _isSyncing.value = false;
    }
  }

  /// الحصول على إحصائيات فورية
  Map<String, int> get realTimeStats => {
    'customers_count': _customers.length,
    'debts_count': _debts.length,
    'payments_count': _payments.length,
    'employees_count': _employees.length,
    'active_streams': _activeStreams.length,
  };

  /// الحصول على إحصائيات مالية فورية
  Map<String, double> get financialStats {
    final totalDebts = _debts.fold<double>(0.0, (sum, debt) => sum + debt.amount);
    final totalPaid = _payments.fold<double>(0.0, (sum, payment) => sum + payment.amount);
    final remainingAmount = totalDebts - totalPaid;
    
    return {
      'total_debts': totalDebts,
      'total_paid': totalPaid,
      'remaining_amount': remainingAmount,
      'collection_rate': totalDebts > 0 ? (totalPaid / totalDebts) * 100 : 0.0,
    };
  }
}