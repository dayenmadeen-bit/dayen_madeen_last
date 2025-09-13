import 'dart:async';
import '../../app/data/models/client_request.dart';
import '../../app/data/models/customer.dart';
import '../../app/data/models/debt.dart';
import '../../app/data/models/payment.dart';
import '../constants/client_constants.dart';

/// خدمة إدارة الزبائن - تطبق مبادئ Clean Architecture
class ClientService {
  static final ClientService _instance = ClientService._internal();
  factory ClientService() => _instance;
  ClientService._internal();

  static ClientService get instance => _instance;

  // ===== إدارة الطلبات =====

  /// إرسال طلب دين جديد
  Future<ClientRequest> submitDebtRequest({
    required String clientId,
    required String clientName,
    required double amount,
    required String description,
  }) async {
    try {
      // محاكاة تأخير الشبكة
      await Future.delayed(const Duration(milliseconds: 1000));

      // إنشاء طلب جديد
      final request = ClientRequest.create(
        clientId: clientId,
        clientName: clientName,
        type: RequestType.debt,
        amount: amount,
        description: description,
      );

      // هنا سيتم إرسال الطلب إلى الخادم
      // await _apiService.submitRequest(request);

      return request;
    } catch (e) {
      throw ClientServiceException(ClientConstants.debtRequestErrorMessage);
    }
  }

  /// إرسال طلب سداد
  Future<ClientRequest> submitPaymentRequest({
    required String clientId,
    required String clientName,
    required double amount,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      // محاكاة تأخير الشبكة
      await Future.delayed(const Duration(milliseconds: 1000));

      // إنشاء طلب جديد
      final request = ClientRequest.create(
        clientId: clientId,
        clientName: clientName,
        type: RequestType.payment,
        amount: amount,
        description:
            'طلب سداد - $paymentMethod${notes != null ? ' - $notes' : ''}',
      );

      // هنا سيتم إرسال الطلب إلى الخادم
      // await _apiService.submitRequest(request);

      return request;
    } catch (e) {
      throw ClientServiceException(ClientConstants.paymentRequestErrorMessage);
    }
  }

  /// تحميل طلبات الزبون
  Future<List<ClientRequest>> loadClientRequests(String clientId) async {
    try {
      // محاكاة تأخير الشبكة
      await Future.delayed(const Duration(milliseconds: 800));

      // هنا سيتم تحميل الطلبات من الخادم
      // final requests = await _apiService.getClientRequests(clientId);

      // بيانات وهمية للاختبار
      return _generateMockRequests(clientId);
    } catch (e) {
      throw ClientServiceException(ClientConstants.loadRequestsErrorMessage);
    }
  }

  /// تحميل ديون الزبون
  Future<List<Debt>> loadClientDebts(String clientId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));

      // بيانات وهمية
      return [
        Debt.create(
          businessOwnerId: 'owner_1',
          customerId: clientId,
          amount: 1500.0,
          description: 'فاتورة شراء مواد غذائية',
          dueDate: DateTime.now().add(const Duration(days: 15)),
        ),
        Debt.create(
          businessOwnerId: 'owner_1',
          customerId: clientId,
          amount: 800.0,
          description: 'فاتورة خدمات صيانة',
          dueDate: DateTime.now().add(const Duration(days: 7)),
        ),
      ];
    } catch (e) {
      throw ClientServiceException('فشل في تحميل الديون');
    }
  }

  /// تحميل مدفوعات الزبون
  Future<List<Payment>> loadClientPayments(String clientId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));

      // بيانات وهمية
      return [
        Payment.create(
          businessOwnerId: 'owner_1',
          customerId: clientId,
          debtId: 'debt_1',
          amount: 500.0,
          paymentMethod: 'نقداً',
          notes: 'دفعة جزئية',
        ),
        Payment.create(
          businessOwnerId: 'owner_1',
          customerId: clientId,
          debtId: 'debt_2',
          amount: 800.0,
          paymentMethod: 'تحويل بنكي',
          notes: 'دفعة كاملة',
        ),
      ];
    } catch (e) {
      throw ClientServiceException('فشل في تحميل المدفوعات');
    }
  }

  /// تحميل معلومات الزبون
  Future<Customer> loadClientInfo(String clientId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));

      // بيانات وهمية
      return Customer.create(
        businessOwnerId: 'owner_1',
        name: 'أحمد محمد السعيد',
        uniqueId: '1234567',
        password: "A1234",
        creditLimit: 5000.0,
      );
    } catch (e) {
      throw ClientServiceException('فشل في تحميل معلومات الزبون');
    }
  }

  // ===== دوال مساعدة خاصة =====

  /// إنشاء طلبات وهمية للاختبار
  List<ClientRequest> _generateMockRequests(String clientId) {
    return [
      ClientRequest.create(
        clientId: clientId,
        clientName: 'أحمد محمد السعيد',
        type: RequestType.debt,
        amount: 1200.0,
        description: 'طلب دين لشراء مواد غذائية',
      ).copyWith(
        status: RequestStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ClientRequest.create(
        clientId: clientId,
        clientName: 'أحمد محمد السعيد',
        type: RequestType.payment,
        amount: 500.0,
        description: 'سداد دفعة جزئية - تحويل بنكي',
      ).copyWith(
        status: RequestStatus.approved,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        processedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      ClientRequest.create(
        clientId: clientId,
        clientName: 'أحمد محمد السعيد',
        type: RequestType.debt,
        amount: 3000.0,
        description: 'طلب دين لشراء معدات',
      ).copyWith(
        status: RequestStatus.rejected,
        rejectionReason: 'تجاوز الحد الائتماني المسموح',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        processedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  // ===== دوال التحليل والإحصائيات =====

  /// حساب إحصائيات الطلبات
  ClientRequestStatistics calculateRequestStatistics(
      List<ClientRequest> requests) {
    final pending =
        requests.where((r) => r.status == RequestStatus.pending).length;
    final approved =
        requests.where((r) => r.status == RequestStatus.approved).length;
    final rejected =
        requests.where((r) => r.status == RequestStatus.rejected).length;

    return ClientRequestStatistics(
      total: requests.length,
      pending: pending,
      approved: approved,
      rejected: rejected,
    );
  }

  /// حساب الإحصائيات المالية
  ClientFinancialSummary calculateFinancialSummary({
    required List<Debt> debts,
    required List<Payment> payments,
  }) {
    final totalDebts = debts.fold(0.0, (sum, debt) => sum + debt.amount);
    final totalPayments =
        payments.fold(0.0, (sum, payment) => sum + payment.amount);
    final remainingBalance = totalDebts - totalPayments;
    final pendingDebts = debts.where((debt) => debt.status == 'pending').length;

    return ClientFinancialSummary(
      totalDebts: totalDebts,
      totalPayments: totalPayments,
      remainingBalance: remainingBalance,
      pendingDebtsCount: pendingDebts,
    );
  }

  /// فلترة الطلبات حسب الحالة
  List<ClientRequest> filterRequestsByStatus(
    List<ClientRequest> requests,
    String status,
  ) {
    if (status == 'all') return requests;

    return requests.where((request) => request.status.name == status).toList();
  }
}

/// استثناء خدمة الزبائن
class ClientServiceException implements Exception {
  final String message;
  ClientServiceException(this.message);

  @override
  String toString() => 'ClientServiceException: $message';
}

/// إحصائيات طلبات الزبون
class ClientRequestStatistics {
  final int total;
  final int pending;
  final int approved;
  final int rejected;

  ClientRequestStatistics({
    required this.total,
    required this.pending,
    required this.approved,
    required this.rejected,
  });
}

/// ملخص مالي للزبون
class ClientFinancialSummary {
  final double totalDebts;
  final double totalPayments;
  final double remainingBalance;
  final int pendingDebtsCount;

  ClientFinancialSummary({
    required this.totalDebts,
    required this.totalPayments,
    required this.remainingBalance,
    required this.pendingDebtsCount,
  });
}
