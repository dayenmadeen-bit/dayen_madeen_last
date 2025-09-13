import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_decorations.dart';

/// شاشة عرض جميع الأنشطة الأخيرة
class AllActivityScreen extends GetView<BusinessOwnerHomeController> {
  const AllActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كل الأنشطة'),
      ),
      body: Obx(() {
        if (controller.recentActivities.isEmpty) {
          return _buildEmptyState();
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.recentActivities.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final activity = controller.recentActivities[index];
            return _buildActivityItem(activity);
          },
        );
      }),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getActivityColor(activity['type']).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getActivityIcon(activity['type']),
              color: _getActivityColor(activity['type']),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] ?? '',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['description'] ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            activity['time'] ?? '',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHintLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.info,
            size: 64,
            color: AppColors.textHintLight,
          ),
          const SizedBox(height: 24),
          Text(
            'لا يوجد نشاط لعرضه',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'customer':
        return AppIcons.customers;
      case 'debt':
        return AppIcons.debts;
      case 'payment':
        return AppIcons.payments;
      default:
        return AppIcons.info;
    }
  }

  Color _getActivityColor(String? type) {
    switch (type) {
      case 'customer':
        return AppColors.info;
      case 'debt':
        return AppColors.warning;
      case 'payment':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }
}
