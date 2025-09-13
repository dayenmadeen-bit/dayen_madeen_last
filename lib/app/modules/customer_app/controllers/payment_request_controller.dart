import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/constants/app_colors.dart';

/// كنترولر شاشة طلب سداد للزبون
class PaymentRequestController extends GetxController {
  // Controllers
  final amountController = TextEditingController();
  final notesController = TextEditingController();

  // حالات التحكم
  var isLoading = false.obs;
  var selectedPaymentMethod = ''.obs;
  var currentBalance = 0.0.obs;
  Map<String, dynamic>? storeData;

  // بيانات المحل
  String get currency => storeData?['currency'] ?? 'ر.س';
  String get bankName => storeData?['bankName'] ?? 'غير محدد';
  String get accountNumber => storeData?['accountNumber'] ?? 'غير محدد';
  String get walletNumber => storeData?['walletNumber'] ?? 'غير محدد';

  // الخدمات
  late final FirestoreService _firestoreService;
  late final AuthService _authService;

  @override
  void onInit() {
    super.onInit();
    _firestoreService = Get.find<FirestoreService>();
    _authService = Get.find<AuthService>();
    storeData = Get.arguments as Map<String, dynamic>?;
    loadCurrentBalance();
  }

  @override
  void onClose() {
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }

  // تحميل الرصيد الحالي
  Future<void> loadCurrentBalance() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null || storeData == null) return;

      // حساب الرصيد الحالي (الديون - المدفوعات)
      final debtsQuery = await _firestoreService
          .usersCol()
          .doc(storeData!['id'])
          .collection('debts')
          .where('customerId', isEqualTo: currentUser.id)
          .get();

      final paymentsQuery = await _firestoreService
          .usersCol()
          .doc(storeData!['id'])
          .collection('payments')
          .where('customerId', isEqualTo: currentUser.id)
          .get();

      double totalDebts = 0.0;
      double totalPayments = 0.0;

      for (final debtDoc in debtsQuery.docs) {
        final debtData = debtDoc.data();
        totalDebts += (debtData['amount'] ?? 0.0).toDouble();
      }

      for (final paymentDoc in paymentsQuery.docs) {
        final paymentData = paymentDoc.data();
        totalPayments += (paymentData['amount'] ?? 0.0).toDouble();
      }

      currentBalance.value = totalDebts - totalPayments;
    } catch (e, st) {
      LoggerService.error('خطأ في تحميل الرصيد الحالي',
          error: e, stackTrace: st);
    }
  }

  // التحقق من صحة البيانات
  String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال مبلغ السداد';
    }
    final amount = double.tryParse(value.trim());
    if (amount == null || amount <= 0) {
      return 'يرجى إدخال مبلغ صحيح';
    }
    if (amount > currentBalance.value) {
      return 'المبلغ لا يمكن أن يكون أكبر من الرصيد الحالي';
    }
    if (amount < 1) {
      return 'المبلغ يجب أن يكون ريال واحد على الأقل';
    }
    return null;
  }

  // إرسال طلب السداد
  Future<void> submitRequest() async {
    try {
      // التحقق من صحة البيانات
      if (!_validateForm()) return;

      isLoading.value = true;

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _showErrorMessage('يجب تسجيل الدخول أولاً');
        return;
      }

      if (storeData == null) {
        _showErrorMessage('بيانات المحل غير متوفرة');
        return;
      }

      // إنشاء طلب السداد
      final requestData = {
        'customerId': currentUser.id,
        'customerUniqueId': currentUser.uniqueId,
        'customerName': currentUser.name,
        'businessOwnerId': storeData!['id'],
        'businessName': storeData!['businessName'],
        'amount': double.parse(amountController.text.trim()),
        'paymentMethod': selectedPaymentMethod.value,
        'notes': notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
        'status': 'pending', // pending, approved, rejected
        'requestDate': DateTime.now(),
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      };

      // حفظ الطلب في Firestore
      await _firestoreService.addDoc(
        _firestoreService.paymentRequestsCol(),
        requestData,
      );

      // إرسال إشعار للمالك
      await _sendNotificationToOwner(requestData);

      _showSuccessMessage('تم إرسال طلب السداد بنجاح');
      Get.back();
    } catch (e, st) {
      LoggerService.error('خطأ في إرسال طلب السداد', error: e, stackTrace: st);
      _showErrorMessage('حدث خطأ في إرسال الطلب');
    } finally {
      isLoading.value = false;
    }
  }

  // التحقق من صحة النموذج
  bool _validateForm() {
    if (selectedPaymentMethod.value.isEmpty) {
      _showErrorMessage('يرجى اختيار طريقة الدفع');
      return false;
    }
    if (validateAmount(amountController.text) != null) {
      _showErrorMessage('يرجى إدخال مبلغ السداد بشكل صحيح');
      return false;
    }
    return true;
  }

  // إرسال إشعار للمالك
  Future<void> _sendNotificationToOwner(
      Map<String, dynamic> requestData) async {
    try {
      final notificationData = {
        'title': 'طلب سداد جديد',
        'body':
            'طلب سداد جديد من ${requestData['customerName']} بقيمة ${requestData['amount']} $currency',
        'type': 'payment_request',
        'data': {
          'requestId': requestData['id'],
          'customerId': requestData['customerId'],
          'customerName': requestData['customerName'],
          'amount': requestData['amount'],
          'paymentMethod': requestData['paymentMethod'],
        },
        'timestamp': DateTime.now(),
        'read': false,
      };

      await _firestoreService.addDoc(
        _firestoreService
            .usersCol()
            .doc(storeData!['id'])
            .collection('notifications'),
        notificationData,
      );
    } catch (e) {
      LoggerService.warning('فشل في إرسال الإشعار للمالك: $e');
    }
  }

  // إظهار رسائل النجاح والخطأ
  void _showSuccessMessage(String message) {
    Get.snackbar(
      'نجح ✅',
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
}


