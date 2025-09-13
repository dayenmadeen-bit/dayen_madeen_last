import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/offline_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// widget لعرض حالة الاتصال
class ConnectionStatusWidget extends GetView<OfflineService> {
  const ConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isReadOnlyMode) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _getStatusColor(),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(),
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                controller.connectionStatusMessage,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Color _getStatusColor() {
    switch (controller.connectionStatusColor) {
      case 'warning':
        return AppColors.warning;
      case 'error':
        return AppColors.error;
      case 'success':
        return AppColors.success;
      default:
        return AppColors.info;
    }
  }

  IconData _getStatusIcon() {
    if (controller.isOfflineMode) {
      return Icons.cloud_off;
    } else if (!controller.isOnline) {
      return Icons.wifi_off;
    } else {
      return Icons.cloud_done;
    }
  }
}

/// widget لعرض رسالة وضع الأوفلاين
class OfflineModeBanner extends StatelessWidget {
  final String action;

  const OfflineModeBanner({
    super.key,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        border: Border.all(color: AppColors.warning),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off,
            color: AppColors.warning,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'وضع الأوفلاين',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'هذا الإجراء ($action) لا يمكن القيام به في وضع الأوفلاين',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
