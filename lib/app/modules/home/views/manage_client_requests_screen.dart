import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/client_requests_controller.dart';
import '../../../data/models/client_request.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';

/// شاشة إدارة طلبات الزبائن
class ManageClientRequestsScreen extends GetView<ClientRequestsController> {
  const ManageClientRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'إدارة طلبات الزبائن',
        showBackButton: true,
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(child: _buildRequestsList()),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: _buildFilterChip('الكل', null),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip('معلقة', 'pending'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip('موافق عليها', 'approved'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip('مرفوضة', 'rejected'),
              ),
            ],
          )),
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == (status ?? '');
      final count = controller.getRequestCountByStatus(status);

      return FilterChip(
        label: Text('$label${count > 0 ? ' ($count)' : ''}'),
        selected: isSelected,
        onSelected: (_) => controller.changeFilter(status ?? ''),
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      );
    });
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

      final requests = controller.filteredRequests;

      if (requests.isEmpty) {
        return EmptyStateWidget(
          type: EmptyStateType.noData,
          icon: AppIcons.clientRequests,
          title: 'لا توجد طلبات',
          message: 'لا توجد طلبات في هذا القسم حالياً',
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshRequests,
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
    final statusColor = _getStatusColor(request.status.toString());
    final statusText = _getStatusText(request.status.toString());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: request.status == 'pending'
            ? BorderSide(color: AppColors.warning, width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس البطاقة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.clientName,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getRequestTypeText(request.type.toString()),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // تفاصيل الطلب
            Row(
              children: [
                Icon(
                  AppIcons.money,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'المبلغ: ${request.amount.toStringAsFixed(2)} ر.س',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Row(
              children: [
                Icon(
                  AppIcons.calendar,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'تاريخ الطلب: ${_formatDate(request.createdAt)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            if (request.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                request.description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            // أزرار الإجراءات للطلبات المعلقة
            if (request.status.toString().contains('pending')) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.approveRequest(request.id),
                      icon: const Icon(AppIcons.checkCircle, size: 16),
                      label: const Text('موافقة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.rejectRequest(
                          request.id, 'تم الرفض من قبل المدير'),
                      icon: const Icon(AppIcons.cancel, size: 16),
                      label: const Text('رفض'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.contains('pending')) {
      return AppColors.warning;
    } else if (status.contains('approved')) {
      return AppColors.success;
    } else if (status.contains('rejected')) {
      return AppColors.error;
    } else {
      return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    if (status.contains('pending')) {
      return 'معلق';
    } else if (status.contains('approved')) {
      return 'موافق عليه';
    } else if (status.contains('rejected')) {
      return 'مرفوض';
    } else {
      return 'غير محدد';
    }
  }

  String _getRequestTypeText(String type) {
    if (type.contains('debt')) {
      return 'طلب دين جديد';
    } else if (type.contains('payment')) {
      return 'طلب تأكيد سداد';
    } else {
      return 'طلب غير محدد';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
