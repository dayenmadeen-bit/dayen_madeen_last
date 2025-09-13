import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../data/models/client_request.dart';

/// Controller لإدارة طلبات الزبائن - مالك المنشأة
class ClientRequestsController extends GetxController {
  // حالات التفاعل
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  // قوائم الطلبات
  final RxList<ClientRequest> allRequests = <ClientRequest>[].obs;
  final RxList<ClientRequest> pendingRequests = <ClientRequest>[].obs;
  final RxList<ClientRequest> approvedRequests = <ClientRequest>[].obs;
  final RxList<ClientRequest> rejectedRequests = <ClientRequest>[].obs;

  // الفلاتر
  final RxString selectedFilter = 'pending'.obs;
  final RxString searchQuery = ''.obs;

  // الإحصائيات
  final RxInt totalPendingRequests = 0.obs;
  final RxInt totalApprovedRequests = 0.obs;
  final RxInt totalRejectedRequests = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadRequests();
  }

  @override
  void onReady() {
    super.onReady();
    refreshRequests();
  }

  /// تحميل جميع الطلبات
  Future<void> loadRequests() async {
    try {
      isLoading.value = true;

      // محاكاة تحميل البيانات
      await Future.delayed(const Duration(milliseconds: 800));

      // بيانات وهمية للطلبات
      allRequests.value = [
        ClientRequest.create(
          clientId: 'client_1',
          clientName: 'أحمد محمد',
          type: RequestType.debt,
          amount: 1500.0,
          description: 'طلب دين لشراء مواد غذائية',
        ), // يبقى pending تلقائياً

        ClientRequest.create(
          clientId: 'client_2',
          clientName: 'سارة أحمد',
          type: RequestType.payment,
          amount: 800.0,
          description: 'سداد دين سابق',
        ), // يبقى pending تلقائياً

        ClientRequest.create(
          clientId: 'client_3',
          clientName: 'محمد علي',
          type: RequestType.debt,
          amount: 2200.0,
          description: 'طلب دين لشراء معدات',
        ).copyWith(
          status: RequestStatus.approved,
          processedAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),

        ClientRequest.create(
          clientId: 'client_1',
          clientName: 'أحمد محمد',
          type: RequestType.payment,
          amount: 500.0,
          description: 'دفعة جزئية',
        ).copyWith(
          status: RequestStatus.rejected,
          rejectionReason: 'مبلغ غير كافي',
          processedAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ];

      _filterRequests();
      _calculateStatistics();
    } catch (e) {
      _showErrorMessage('فشل في تحميل الطلبات: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// تحديث الطلبات
  Future<void> refreshRequests() async {
    isRefreshing.value = true;
    await loadRequests();
    isRefreshing.value = false;

    _showSuccessMessage('تم تحديث الطلبات بنجاح ✅');
  }

  /// فلترة الطلبات حسب النوع
  void _filterRequests() {
    pendingRequests.value = allRequests
        .where((req) => req.status == RequestStatus.pending)
        .toList();
    approvedRequests.value = allRequests
        .where((req) => req.status == RequestStatus.approved)
        .toList();
    rejectedRequests.value = allRequests
        .where((req) => req.status == RequestStatus.rejected)
        .toList();
  }

  /// حساب الإحصائيات
  void _calculateStatistics() {
    totalPendingRequests.value = pendingRequests.length;
    totalApprovedRequests.value = approvedRequests.length;
    totalRejectedRequests.value = rejectedRequests.length;
  }

  /// الموافقة على طلب
  Future<void> approveRequest(String requestId) async {
    try {
      isLoading.value = true;

      final requestIndex = allRequests.indexWhere((req) => req.id == requestId);
      if (requestIndex != -1) {
        final request = allRequests[requestIndex];
        final updatedRequest = request.copyWith(
          status: RequestStatus.approved,
          processedAt: DateTime.now(),
        );

        allRequests[requestIndex] = updatedRequest;
        _filterRequests();
        _calculateStatistics();

        // تطبيق الطلب على حساب الزبون
        await _applyRequestToClientAccount(updatedRequest);

        _showSuccessMessage('تم الموافقة على الطلب بنجاح ✅');
      }
    } catch (e) {
      _showErrorMessage('فشل في الموافقة على الطلب: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// رفض طلب
  Future<void> rejectRequest(String requestId, String reason) async {
    try {
      isLoading.value = true;

      final requestIndex = allRequests.indexWhere((req) => req.id == requestId);
      if (requestIndex != -1) {
        final request = allRequests[requestIndex];
        final updatedRequest = request.copyWith(
          status: RequestStatus.rejected,
          rejectionReason: reason,
          processedAt: DateTime.now(),
        );

        allRequests[requestIndex] = updatedRequest;
        _filterRequests();
        _calculateStatistics();

        _showSuccessMessage('تم رفض الطلب ❌');
      }
    } catch (e) {
      _showErrorMessage('فشل في رفض الطلب: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// تطبيق الطلب على حساب الزبون
  Future<void> _applyRequestToClientAccount(ClientRequest request) async {
    // هنا يتم تطبيق الطلب على حساب الزبون
    // إضافة دين أو خصم مدفوعة حسب نوع الطلب

    if (request.type == RequestType.debt) {
      // إضافة دين جديد للزبون
      print('إضافة دين ${request.amount} للزبون ${request.clientName}');
    } else if (request.type == RequestType.payment) {
      // خصم مدفوعة من ديون الزبون
      print(
          'خصم مدفوعة ${request.amount} من ديون الزبون ${request.clientName}');
    }
  }

  /// تغيير الفلتر
  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  /// البحث في الطلبات
  void searchRequests(String query) {
    searchQuery.value = query;
  }

  /// الحصول على الطلبات المفلترة
  List<ClientRequest> get filteredRequests {
    List<ClientRequest> requests;

    switch (selectedFilter.value) {
      case 'pending':
        requests = pendingRequests;
        break;
      case 'approved':
        requests = approvedRequests;
        break;
      case 'rejected':
        requests = rejectedRequests;
        break;
      default:
        requests = allRequests;
    }

    if (searchQuery.value.isNotEmpty) {
      requests = requests
          .where((req) =>
              req.clientName
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ||
              req.description
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    return requests;
  }

  /// إظهار رسالة نجاح
  void _showSuccessMessage(String message) {
    Get.snackbar(
      'تم بنجاح ✅',
      message,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle, color: Colors.white),
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
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  /// الحصول على عدد الطلبات حسب الحالة
  int getRequestCountByStatus(String? status) {
    if (status == null) {
      return allRequests.length;
    }
    return allRequests.where((request) => request.status == status).length;
  }
}
