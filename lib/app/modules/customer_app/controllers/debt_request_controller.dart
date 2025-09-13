import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/constants/app_colors.dart';

/// كنترولر شاشة طلب دين للزبون
class DebtRequestController extends GetxController {
  // Controllers
  final itemsController = TextEditingController();
  final estimatedAmountController = TextEditingController();
  final notesController = TextEditingController();

  // حالات التحكم
  var isLoading = false.obs;
  Map<String, dynamic>? storeData;

  // الخدمات
  late final FirestoreService _firestoreService;
  late final AuthService _authService;

  @override
  void onInit() {
    super.onInit();
    _firestoreService = Get.find<FirestoreService>();
    _authService = Get.find<AuthService>();
    storeData = Get.arguments as Map<String, dynamic>?;
  }

  @override
  void onClose() {
    itemsController.dispose();
    estimatedAmountController.dispose();
    notesController.dispose();
    super.onClose();
  }

  // التحقق من صحة البيانات
  String? validateItems(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال الأشياء المطلوبة';
    }
    if (value.trim().length < 10) {
      return 'يرجى إدخال تفاصيل أكثر عن الأشياء المطلوبة';
    }
    return null;
  }

  String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال المبلغ المقدر';
    }
    final amount = double.tryParse(value.trim());
    if (amount == null || amount <= 0) {
      return 'يرجى إدخال مبلغ صحيح';
    }
    if (amount < 1) {
      return 'المبلغ يجب أن يكون ريال واحد على الأقل';
    }
    return null;
  }

  // إرسال طلب الدين
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

      // إنشاء طلب الدين
      final requestData = {
        'customerId': currentUser.id,
        'customerUniqueId': currentUser.uniqueId,
        'customerName': currentUser.name,
        'businessOwnerId': storeData!['id'],
        'businessName': storeData!['businessName'],
        'items': itemsController.text.trim(),
        'estimatedAmount': double.parse(estimatedAmountController.text.trim()),
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
        _firestoreService.purchaseRequestsCol(),
        requestData,
      );

      // إرسال إشعار للمالك
      await _sendNotificationToOwner(requestData);

      _showSuccessMessage('تم إرسال طلب الدين بنجاح');
      Get.back();
    } catch (e, st) {
      LoggerService.error('خطأ في إرسال طلب الدين', error: e, stackTrace: st);
      _showErrorMessage('حدث خطأ في إرسال الطلب');
    } finally {
      isLoading.value = false;
    }
  }

  // التحقق من صحة النموذج
  bool _validateForm() {
    if (validateItems(itemsController.text) != null) {
      _showErrorMessage('يرجى إدخال الأشياء المطلوبة بشكل صحيح');
      return false;
    }
    if (validateAmount(estimatedAmountController.text) != null) {
      _showErrorMessage('يرجى إدخال المبلغ المقدر بشكل صحيح');
      return false;
    }
    return true;
  }

  // إرسال إشعار للمالك
  Future<void> _sendNotificationToOwner(
      Map<String, dynamic> requestData) async {
    try {
      final notificationData = {
        'title': 'طلب دين جديد',
        'body':
            'طلب دين جديد من ${requestData['customerName']} بقيمة ${requestData['estimatedAmount']} ${storeData!['currency'] ?? 'ر.س'}',
        'type': 'debt_request',
        'data': {
          'requestId': requestData['id'],
          'customerId': requestData['customerId'],
          'customerName': requestData['customerName'],
          'amount': requestData['estimatedAmount'],
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


