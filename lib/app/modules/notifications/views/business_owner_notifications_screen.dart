import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../widgets/custom_app_bar.dart';

/// شاشة إشعارات مالك المنشأة
class BusinessOwnerNotificationsScreen extends StatefulWidget {
  const BusinessOwnerNotificationsScreen({super.key});

  @override
  State<BusinessOwnerNotificationsScreen> createState() => _BusinessOwnerNotificationsScreenState();
}

class _BusinessOwnerNotificationsScreenState extends State<BusinessOwnerNotificationsScreen> {
  String selectedFilter = 'all';
  List<BusinessOwnerNotification> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    // محاكاة تحميل البيانات
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        notifications = _createMockNotifications();
        isLoading = false;
      });
    });
  }

  List<BusinessOwnerNotification> _createMockNotifications() {
    return [
      BusinessOwnerNotification(
        id: '1',
        title: 'طلب دين جديد',
        message: 'أحمد محمد طلب دين بقيمة 1,500 ر.س',
        type: 'client_request',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      BusinessOwnerNotification(
        id: '2',
        title: 'دين متأخر',
        message: 'دين سارة أحمد متأخر منذ 5 أيام (800 ر.س)',
        type: 'overdue_debt',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      BusinessOwnerNotification(
        id: '3',
        title: 'دفعة جديدة',
        message: 'محمد علي دفع 500 ر.س من دينه',
        type: 'payment_received',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      BusinessOwnerNotification(
        id: '4',
        title: 'طلب سداد',
        message: 'فاطمة خالد طلبت تأكيد سداد 300 ر.س',
        type: 'client_request',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      BusinessOwnerNotification(
        id: '5',
        title: 'تحديث النظام',
        message: 'تم تحديث النظام إلى الإصدار 2.1.0',
        type: 'system_alert',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'الإشعارات',
        showBackButton: true,
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(child: _buildNotificationsList()),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterChip('الكل', 'all'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterChip('طلبات الزبائن', 'client_request'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterChip('ديون متأخرة', 'overdue_debt'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterChip('تنبيهات النظام', 'system_alert'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String type) {
    final isSelected = selectedFilter == type;
    final count = _getNotificationCountByType(type);

    return FilterChip(
      label: Text('$label${count > 0 ? ' ($count)' : ''}'),
      selected: isSelected,
      onSelected: (_) => _changeFilter(type),
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  int _getNotificationCountByType(String type) {
    if (type == 'all') {
      return notifications.length;
    }
    return notifications.where((n) => n.type == type).length;
  }

  void _changeFilter(String type) {
    setState(() {
      selectedFilter = type;
    });
  }

  Widget _buildNotificationsList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final filteredNotifications = _getFilteredNotifications();

    if (filteredNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.notification,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد إشعارات',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لا توجد إشعارات في هذا القسم حالياً',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadNotifications();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredNotifications.length,
        itemBuilder: (context, index) {
          final notification = filteredNotifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  List<BusinessOwnerNotification> _getFilteredNotifications() {
    if (selectedFilter == 'all') {
      return notifications;
    }
    return notifications.where((n) => n.type == selectedFilter).toList();
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !notifications[index].isRead) {
        notifications[index] = BusinessOwnerNotification(
          id: notifications[index].id,
          title: notifications[index].title,
          message: notifications[index].message,
          type: notifications[index].type,
          isRead: true,
          createdAt: notifications[index].createdAt,
          data: notifications[index].data,
        );
      }
    });
  }

  Widget _buildNotificationCard(BusinessOwnerNotification notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 1 : 3,
      child: InkWell(
        onTap: () => _markAsRead(notification.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: notification.isRead 
                ? Colors.white 
                : AppColors.primary.withValues(alpha: 0.05),
            border: notification.isRead 
                ? null 
                : Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // أيقونة الإشعار
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // محتوى الإشعار
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: notification.isRead 
                            ? FontWeight.normal 
                            : FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      notification.message,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(notification.createdAt),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // نقطة عدم القراءة
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'client_request':
        return AppIcons.clientRequests;
      case 'overdue_debt':
        return AppIcons.warning;
      case 'payment_received':
        return AppIcons.payments;
      case 'system_alert':
        return AppIcons.info;
      default:
        return AppIcons.notification;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'client_request':
        return AppColors.info;
      case 'overdue_debt':
        return AppColors.warning;
      case 'payment_received':
        return AppColors.success;
      case 'system_alert':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

/// نموذج إشعار مالك المنشأة
class BusinessOwnerNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  BusinessOwnerNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });
}
