import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notifications_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/notification_service.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/offline_action_wrapper.dart';

/// شاشة إدارة الإشعارات
class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(
            type: LoadingType.circular,
            size: LoadingSize.large,
            message: 'جاري تحميل الإشعارات...',
          );
        }

        if (controller.notifications.isEmpty) {
          return const EmptyStateWidget(
            type: EmptyStateType.noData,
            icon: AppIcons.notifications,
            title: 'لا توجد إشعارات',
            subtitle: 'ستظهر الإشعارات هنا عند وجودها',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshNotifications,
          child: Column(
            children: [
              // فلاتر الإشعارات
              _buildFiltersSection(),

              // قائمة الإشعارات
              Expanded(
                child: _buildNotificationsList(),
              ),
            ],
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          const Text('الإشعارات'),
          const SizedBox(width: 8),
          Obx(() {
            if (controller.unreadCount.value > 0) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${controller.unreadCount.value}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      actions: [
        // تحديد الكل كمقروء
        Obx(() {
          if (controller.unreadCount.value > 0) {
            return TextButton(
              onPressed: controller.markAllAsRead,
              child: const Text('تحديد الكل كمقروء'),
            );
          }
          return const SizedBox.shrink();
        }),

        // قائمة الخيارات
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'clear_all':
                controller.clearAllNotifications();
                break;
              case 'settings':
                controller.goToNotificationSettings();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'clear_all',
              child: OfflineActionWrapper(
                action: 'delete_notifications',
                child: const Row(
                  children: [
                    Icon(AppIcons.delete, size: 20),
                    SizedBox(width: 12),
                    Text('مسح جميع الإشعارات'),
                  ],
                ),
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(AppIcons.settings, size: 20),
                  SizedBox(width: 12),
                  Text('إعدادات الإشعارات'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تصفية الإشعارات',
            style: AppTextStyles.labelMedium,
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'الكل',
                  null,
                  controller.selectedFilter.value == null,
                  () => controller.setFilter(null),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'غير مقروءة',
                  'unread',
                  controller.selectedFilter.value == 'unread',
                  () => controller.setFilter('unread'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'التذكيرات',
                  'debt',
                  controller.selectedFilter.value == 'debt',
                  () => controller.setFilter('debt'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'المدفوعات',
                  NotificationType.payment.name,
                  controller.selectedFilter.value ==
                      NotificationType.payment.name,
                  () => controller.setFilter(NotificationType.payment.name),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'الاشتراك',
                  NotificationType.subscription.name,
                  controller.selectedFilter.value ==
                      NotificationType.subscription.name,
                  () =>
                      controller.setFilter(NotificationType.subscription.name),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      String label, String? value, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondaryLight,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.filteredNotifications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final notification = controller.filteredNotifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildNotificationItem(LocalNotification notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          AppIcons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        controller.deleteNotification(notification.id);
      },
      child: InkWell(
        onTap: () => controller.onNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.cardDecoration.copyWith(
            color: notification.isRead
                ? Colors.white
                : AppColors.primary.withValues(alpha: 0.05),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.borderLight
                  : AppColors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // أيقونة الإشعار
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // محتوى الإشعار
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getNotificationColor(notification.type)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getNotificationTypeLabel(notification.type),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: _getNotificationColor(notification.type),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatNotificationTime(notification.timestamp),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textHintLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // قائمة الخيارات
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'mark_read':
                      controller.markAsRead(notification.id);
                      break;
                    case 'delete':
                      controller.deleteNotification(notification.id);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (!notification.isRead)
                    const PopupMenuItem(
                      value: 'mark_read',
                      child: Row(
                        children: [
                          Icon(Icons.mark_email_read, size: 20),
                          SizedBox(width: 12),
                          Text('تحديد كمقروء'),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: OfflineActionWrapper(
                      action: 'delete_notifications',
                      child: const Row(
                        children: [
                          Icon(AppIcons.delete,
                              size: 20, color: AppColors.error),
                          SizedBox(width: 12),
                          Text('حذف', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ),
                ],
                child: Icon(
                  AppIcons.more,
                  color: AppColors.textHintLight,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'success':
        return AppColors.success;
      case 'error':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      case 'debt':
        return AppColors.warning;
      case 'payment':
        return AppColors.success;
      case 'subscription':
        return AppColors.primary;
      case 'employee':
        return AppColors.info;
      case 'customer':
        return AppColors.primary;
      case 'security':
        return AppColors.error;
      case 'system':
      default:
        return AppColors.info;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'debt':
        return Icons.schedule;
      case 'payment':
        return Icons.payment;
      case 'subscription':
        return Icons.card_membership;
      case 'employee':
        return Icons.people;
      case 'customer':
        return Icons.person;
      case 'security':
        return Icons.security;
      case 'system':
      default:
        return Icons.info;
    }
  }

  String _getNotificationTypeLabel(String type) {
    switch (type) {
      case 'success':
        return 'نجح';
      case 'error':
        return 'خطأ';
      case 'warning':
        return 'تحذير';
      case 'debt':
        return 'دين';
      case 'payment':
        return 'دفعة';
      case 'subscription':
        return 'اشتراك';
      case 'employee':
        return 'موظف';
      case 'customer':
        return 'عميل';
      case 'security':
        return 'أمان';
      case 'system':
      default:
        return 'معلومات';
    }
  }

  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return AppConstants.formatDate(dateTime);
    }
  }
}
