import 'package:get/get.dart';
import 'firestore_service.dart';
import 'logger_service.dart';
import 'notification_service.dart';
import '../../app/data/models/purchase_request.dart';
import '../../app/data/models/payment_request.dart';

class RequestService extends GetxService {
  static RequestService get instance => Get.find<RequestService>();

  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // ===== طلبات المشتريات =====

  /// إنشاء طلب مشتريات جديد
  Future<String?> createPurchaseRequest({
    required String customerId,
    required String businessOwnerId,
    required String businessName,
    required String customerName,
    required String customerUniqueId,
    required String requestDetails,
    required double estimatedAmount,
    String? notes,
  }) async {
    try {
      final request = PurchaseRequest.create(
        customerId: customerId,
        businessOwnerId: businessOwnerId,
        businessName: businessName,
        customerName: customerName,
        customerUniqueId: customerUniqueId,
        requestDetails: requestDetails,
        estimatedAmount: estimatedAmount,
        notes: notes,
      );

      await _firestoreService.setDoc(
        _firestoreService.purchaseRequestsCol().doc(request.id),
        request.toJson(),
        merge: false,
      );

      // إرسال إشعار للمالك والموظفين
      await NotificationService.showPurchaseRequestNotification(
        customerName: customerName,
        businessName: businessName,
        requestDetails: requestDetails,
        requestId: request.id,
      );

      LoggerService.success('تم إنشاء طلب المشتريات: ${request.id}');
      return request.id;
    } catch (e, st) {
      LoggerService.error('خطأ في إنشاء طلب المشتريات',
          error: e, stackTrace: st);
      return null;
    }
  }

  /// الحصول على طلبات المشتريات للعميل
  Future<List<PurchaseRequest>> getCustomerPurchaseRequests(
      String customerId) async {
    try {
      final query = await _firestoreService
          .purchaseRequestsCol()
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => PurchaseRequest.fromJson(doc.data()))
          .toList();
    } catch (e, st) {
      LoggerService.error('خطأ في الحصول على طلبات المشتريات للعميل',
          error: e, stackTrace: st);
      return [];
    }
  }

  /// الحصول على طلبات المشتريات للمالك
  Future<List<PurchaseRequest>> getBusinessPurchaseRequests(
      String businessOwnerId) async {
    try {
      final query = await _firestoreService
          .purchaseRequestsCol()
          .where('businessOwnerId', isEqualTo: businessOwnerId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => PurchaseRequest.fromJson(doc.data()))
          .toList();
    } catch (e, st) {
      LoggerService.error('خطأ في الحصول على طلبات المشتريات للمالك',
          error: e, stackTrace: st);
      return [];
    }
  }

  /// الموافقة على طلب المشتريات
  Future<bool> approvePurchaseRequest(
      String requestId, String approvedBy) async {
    try {
      final requestDoc = _firestoreService.purchaseRequestsCol().doc(requestId);
      final requestData = await requestDoc.get();

      if (!requestData.exists) {
        LoggerService.warning('طلب المشتريات غير موجود: $requestId');
        return false;
      }

      final request = PurchaseRequest.fromJson(requestData.data()!);
      final updatedRequest = request.copyWith(
        status: 'approved',
        approvedBy: approvedBy,
        approvedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateDoc(requestDoc, updatedRequest.toJson());

      // إرسال إشعار للعميل
      await NotificationService.showNotification(
        title: 'تم الموافقة على طلب المشتريات',
        body: 'تم الموافقة على طلب المشتريات من ${request.businessName}',
        type: 'customer',
        data: {
          'requestId': requestId,
          'businessName': request.businessName,
        },
      );

      LoggerService.success('تم الموافقة على طلب المشتريات: $requestId');
      return true;
    } catch (e, st) {
      LoggerService.error('خطأ في الموافقة على طلب المشتريات',
          error: e, stackTrace: st);
      return false;
    }
  }

  /// رفض طلب المشتريات
  Future<bool> rejectPurchaseRequest(
      String requestId, String rejectionReason, String rejectedBy) async {
    try {
      final requestDoc = _firestoreService.purchaseRequestsCol().doc(requestId);
      final requestData = await requestDoc.get();

      if (!requestData.exists) {
        LoggerService.warning('طلب المشتريات غير موجود: $requestId');
        return false;
      }

      final request = PurchaseRequest.fromJson(requestData.data()!);
      final updatedRequest = request.copyWith(
        status: 'rejected',
        rejectionReason: rejectionReason,
        approvedBy: rejectedBy,
        approvedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateDoc(requestDoc, updatedRequest.toJson());

      // إرسال إشعار للعميل
      await NotificationService.showNotification(
        title: 'تم رفض طلب المشتريات',
        body:
            'تم رفض طلب المشتريات من ${request.businessName}. السبب: $rejectionReason',
        type: 'customer',
        data: {
          'requestId': requestId,
          'businessName': request.businessName,
          'rejectionReason': rejectionReason,
        },
      );

      LoggerService.success('تم رفض طلب المشتريات: $requestId');
      return true;
    } catch (e, st) {
      LoggerService.error('خطأ في رفض طلب المشتريات', error: e, stackTrace: st);
      return false;
    }
  }

  /// إكمال طلب المشتريات
  Future<bool> completePurchaseRequest(
      String requestId, String completedBy) async {
    try {
      final requestDoc = _firestoreService.purchaseRequestsCol().doc(requestId);
      final requestData = await requestDoc.get();

      if (!requestData.exists) {
        LoggerService.warning('طلب المشتريات غير موجود: $requestId');
        return false;
      }

      final request = PurchaseRequest.fromJson(requestData.data()!);
      final updatedRequest = request.copyWith(
        status: 'completed',
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateDoc(requestDoc, updatedRequest.toJson());

      // إرسال إشعار للعميل
      await NotificationService.showNotification(
        title: 'تم إكمال طلب المشتريات',
        body: 'تم إكمال طلب المشتريات من ${request.businessName}',
        type: 'customer',
        data: {
          'requestId': requestId,
          'businessName': request.businessName,
        },
      );

      LoggerService.success('تم إكمال طلب المشتريات: $requestId');
      return true;
    } catch (e, st) {
      LoggerService.error('خطأ في إكمال طلب المشتريات',
          error: e, stackTrace: st);
      return false;
    }
  }

  // ===== طلبات الدفع =====

  /// إنشاء طلب دفع جديد
  Future<String?> createPaymentRequest({
    required String customerId,
    required String businessOwnerId,
    required String businessName,
    required String customerName,
    required String customerUniqueId,
    required double amount,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      final request = PaymentRequest.create(
        customerId: customerId,
        businessOwnerId: businessOwnerId,
        businessName: businessName,
        customerName: customerName,
        customerUniqueId: customerUniqueId,
        amount: amount,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      await _firestoreService.setDoc(
        _firestoreService.paymentRequestsCol().doc(request.id),
        request.toJson(),
        merge: false,
      );

      // إرسال إشعار للمالك والموظفين
      await NotificationService.showPaymentRequestNotification(
        customerName: customerName,
        businessName: businessName,
        amount: amount,
        requestId: request.id,
      );

      LoggerService.success('تم إنشاء طلب الدفع: ${request.id}');
      return request.id;
    } catch (e, st) {
      LoggerService.error('خطأ في إنشاء طلب الدفع', error: e, stackTrace: st);
      return null;
    }
  }

  /// الحصول على طلبات الدفع للعميل
  Future<List<PaymentRequest>> getCustomerPaymentRequests(
      String customerId) async {
    try {
      final query = await _firestoreService
          .paymentRequestsCol()
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => PaymentRequest.fromJson(doc.data()))
          .toList();
    } catch (e, st) {
      LoggerService.error('خطأ في الحصول على طلبات الدفع للعميل',
          error: e, stackTrace: st);
      return [];
    }
  }

  /// الحصول على طلبات الدفع للمالك
  Future<List<PaymentRequest>> getBusinessPaymentRequests(
      String businessOwnerId) async {
    try {
      final query = await _firestoreService
          .paymentRequestsCol()
          .where('businessOwnerId', isEqualTo: businessOwnerId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => PaymentRequest.fromJson(doc.data()))
          .toList();
    } catch (e, st) {
      LoggerService.error('خطأ في الحصول على طلبات الدفع للمالك',
          error: e, stackTrace: st);
      return [];
    }
  }

  /// الموافقة على طلب الدفع
  Future<bool> approvePaymentRequest(
      String requestId, String approvedBy) async {
    try {
      final requestDoc = _firestoreService.paymentRequestsCol().doc(requestId);
      final requestData = await requestDoc.get();

      if (!requestData.exists) {
        LoggerService.warning('طلب الدفع غير موجود: $requestId');
        return false;
      }

      final request = PaymentRequest.fromJson(requestData.data()!);
      final updatedRequest = request.copyWith(
        status: 'approved',
        approvedBy: approvedBy,
        approvedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateDoc(requestDoc, updatedRequest.toJson());

      // إرسال إشعار للعميل
      await NotificationService.showNotification(
        title: 'تم الموافقة على طلب الدفع',
        body:
            'تم الموافقة على طلب الدفع بقيمة ${request.amount.toStringAsFixed(2)} ر.س',
        type: 'customer',
        data: {
          'requestId': requestId,
          'amount': request.amount,
        },
      );

      LoggerService.success('تم الموافقة على طلب الدفع: $requestId');
      return true;
    } catch (e, st) {
      LoggerService.error('خطأ في الموافقة على طلب الدفع',
          error: e, stackTrace: st);
      return false;
    }
  }

  /// رفض طلب الدفع
  Future<bool> rejectPaymentRequest(
      String requestId, String rejectionReason, String rejectedBy) async {
    try {
      final requestDoc = _firestoreService.paymentRequestsCol().doc(requestId);
      final requestData = await requestDoc.get();

      if (!requestData.exists) {
        LoggerService.warning('طلب الدفع غير موجود: $requestId');
        return false;
      }

      final request = PaymentRequest.fromJson(requestData.data()!);
      final updatedRequest = request.copyWith(
        status: 'rejected',
        rejectionReason: rejectionReason,
        approvedBy: rejectedBy,
        approvedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateDoc(requestDoc, updatedRequest.toJson());

      // إرسال إشعار للعميل
      await NotificationService.showNotification(
        title: 'تم رفض طلب الدفع',
        body: 'تم رفض طلب الدفع. السبب: $rejectionReason',
        type: 'customer',
        data: {
          'requestId': requestId,
          'rejectionReason': rejectionReason,
        },
      );

      LoggerService.success('تم رفض طلب الدفع: $requestId');
      return true;
    } catch (e, st) {
      LoggerService.error('خطأ في رفض طلب الدفع', error: e, stackTrace: st);
      return false;
    }
  }

  /// إكمال طلب الدفع
  Future<bool> completePaymentRequest(
      String requestId, String completedBy) async {
    try {
      final requestDoc = _firestoreService.paymentRequestsCol().doc(requestId);
      final requestData = await requestDoc.get();

      if (!requestData.exists) {
        LoggerService.warning('طلب الدفع غير موجود: $requestId');
        return false;
      }

      final request = PaymentRequest.fromJson(requestData.data()!);
      final updatedRequest = request.copyWith(
        status: 'completed',
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateDoc(requestDoc, updatedRequest.toJson());

      // إرسال إشعار للعميل
      await NotificationService.showNotification(
        title: 'تم إكمال طلب الدفع',
        body:
            'تم إكمال طلب الدفع بقيمة ${request.amount.toStringAsFixed(2)} ر.س',
        type: 'customer',
        data: {
          'requestId': requestId,
          'amount': request.amount,
        },
      );

      LoggerService.success('تم إكمال طلب الدفع: $requestId');
      return true;
    } catch (e, st) {
      LoggerService.error('خطأ في إكمال طلب الدفع', error: e, stackTrace: st);
      return false;
    }
  }

  // ===== إحصائيات =====

  /// الحصول على إحصائيات الطلبات
  Future<Map<String, int>> getRequestStats(String businessOwnerId) async {
    try {
      final purchaseRequests =
          await getBusinessPurchaseRequests(businessOwnerId);
      final paymentRequests = await getBusinessPaymentRequests(businessOwnerId);

      return {
        'totalPurchaseRequests': purchaseRequests.length,
        'pendingPurchaseRequests':
            purchaseRequests.where((r) => r.isPending).length,
        'approvedPurchaseRequests':
            purchaseRequests.where((r) => r.isApproved).length,
        'rejectedPurchaseRequests':
            purchaseRequests.where((r) => r.isRejected).length,
        'completedPurchaseRequests':
            purchaseRequests.where((r) => r.isCompleted).length,
        'totalPaymentRequests': paymentRequests.length,
        'pendingPaymentRequests':
            paymentRequests.where((r) => r.isPending).length,
        'approvedPaymentRequests':
            paymentRequests.where((r) => r.isApproved).length,
        'rejectedPaymentRequests':
            paymentRequests.where((r) => r.isRejected).length,
        'completedPaymentRequests':
            paymentRequests.where((r) => r.isCompleted).length,
      };
    } catch (e, st) {
      LoggerService.error('خطأ في الحصول على إحصائيات الطلبات',
          error: e, stackTrace: st);
      return {};
    }
  }
}
