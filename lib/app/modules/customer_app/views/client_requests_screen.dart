import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_app_controller.dart';
import '../../../data/models/client_request.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state_widget.dart';

/// شاشة طلبات الزبون - عرض طلباته الشخصية
class ClientRequestsScreen extends GetView<ClientAppController> {
  const ClientRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStatsCards(),
          _buildFilterTabs(),
          Expanded(child: _buildRequestsList()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'طلباتي',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: controller.refreshData,
          tooltip: 'تحديث',
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'في الانتظار',
                  count: controller.pendingRequestsCount.value,
                  color: AppColors.warning,
                  icon: Icons.pending_actions,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'موافق عليها',
                  count: controller.approvedRequestsCount.value,
                  color: AppColors.success,
                  icon: Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'مرفوضة',
                  count: controller.rejectedRequestsCount.value,
                  color: AppColors.error,
                  icon: Icons.cancel,
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: AppTextStyles.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: _buildFilterTab('all', 'الكل'),
              ),
              Expanded(
                child: _buildFilterTab('pending', 'في الانتظار'),
              ),
              Expanded(
                child: _buildFilterTab('approved', 'موافق عليها'),
              ),
              Expanded(
                child: _buildFilterTab('rejected', 'مرفوضة'),
              ),
            ],
          )),
    );
  }

  Widget _buildFilterTab(String filter, String title) {
    final isSelected = controller.selectedRequestFilter.value == filter;

    return GestureDetector(
      onTap: () => controller.changeRequestFilter(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildRequestsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingWidget(
          type: LoadingType.circular,
          size: LoadingSize.large,
          message: 'جاري تحميل الطلبات...',
        );
      }

      final requests = controller.filteredClientRequests;

      if (requests.isEmpty) {
        return EmptyStateWidget(
          icon: Icons.inbox_outlined,
          title: 'لا توجد طلبات',
          message: 'لم تقم بإرسال أي طلبات بعد',
          actionText: 'إرسال طلب جديد',
          onActionPressed: () {
            // يمكن إضافة التنقل إلى شاشة الطلبات من هنا
            Get.snackbar(
                'معلومة', 'يمكنك إرسال طلبات جديدة من الصفحة الرئيسية');
          },
          type: EmptyStateType.noData,
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildRequestCard(request);
          },
        ),
      );
    });
  }

  Widget _buildRequestCard(ClientRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس البطاقة
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: request.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  request.typeIcon,
                  color: request.statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.typeText,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDate(request.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: request.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  request.statusText,
                  style: AppTextStyles.caption.copyWith(
                    color: request.statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // تفاصيل الطلب
          Text(
            request.description,
            style: AppTextStyles.bodyMedium,
          ),

          const SizedBox(height: 8),

          // المبلغ
          Text(
            '${request.amount.toStringAsFixed(0)} ر.س',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),

          // سبب الرفض (للطلبات المرفوضة)
          if (request.status == RequestStatus.rejected &&
              request.rejectionReason != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.error,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'سبب الرفض: ${request.rejectionReason}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

Widget _buildFloatingActionButton() {
  return FloatingActionButton.extended(
    heroTag: "client_requests_fab", // إضافة heroTag فريد
    onPressed: _showRequestOptions,
    backgroundColor: AppColors.primary,
    icon: const Icon(Icons.add, color: Colors.white),
    label: const Text(
      'طلب جديد',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

void _showRequestOptions() {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'نوع الطلب',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add_circle,
                color: AppColors.warning,
              ),
            ),
            title: const Text('طلب دين جديد'),
            subtitle: const Text('طلب مبلغ جديد من مالك المنشأة'),
            onTap: () {
              Get.back();
              Get.toNamed('/debt-request');
            },
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.payment,
                color: AppColors.success,
              ),
            ),
            title: const Text('طلب سداد'),
            subtitle: const Text('إرسال طلب سداد مبلغ مستحق'),
            onTap: () {
              Get.back();
              Get.toNamed('/payment-request');
            },
          ),
        ],
      ),
    ),
  );
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}
