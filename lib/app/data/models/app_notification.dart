import 'dart:convert';
import 'package:uuid/uuid.dart';

/// أنواع الإشعارات
enum NotificationType {
  debtReminder('debt_reminder', 'تذكير دين'),
  paymentReceived('payment_received', 'دفعة مستلمة'),
  subscriptionExpiring('subscription_expiring', 'انتهاء الاشتراك'),
  trialExpiring('trial_expiring', 'انتهاء الفترة التجريبية'),
  systemUpdate('system_update', 'تحديث النظام'),
  general('general', 'عام');

  const NotificationType(this.value, this.displayName);
  
  final String value;
  final String displayName;
  
  static NotificationType? fromValue(String value) {
    for (final type in NotificationType.values) {
      if (type.value == value) {
        return type;
      }
    }
    return null;
  }
}

/// نموذج بيانات الإشعار
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  /// إنشاء إشعار جديد
  factory AppNotification.create({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: const Uuid().v4(),
      userId: userId,
      title: title,
      message: message,
      type: type,
      data: data,
      createdAt: DateTime.now(),
    );
  }

  /// تحويل من JSON
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final dataString = json['data'] as String?;
    Map<String, dynamic>? data;
    
    if (dataString != null && dataString.isNotEmpty) {
      try {
        data = jsonDecode(dataString) as Map<String, dynamic>;
      } catch (e) {
        data = null;
      }
    }

    return AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.fromValue(json['type'] as String) ?? NotificationType.general,
      data: data,
      isRead: (json['is_read'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type.value,
      'data': data != null ? jsonEncode(data) : null,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// تحويل إلى JSON لقاعدة البيانات
  Map<String, dynamic> toDatabaseJson() {
    return toJson();
  }

  /// إنشاء نسخة محدثة
  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// تحديد الإشعار كمقروء
  AppNotification markAsRead() {
    return copyWith(isRead: true);
  }

  /// تحديد الإشعار كغير مقروء
  AppNotification markAsUnread() {
    return copyWith(isRead: false);
  }

  /// الحصول على الوقت المنسق
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  /// الحصول على أيقونة الإشعار
  String get iconName {
    switch (type) {
      case NotificationType.debtReminder:
        return 'debt_reminder';
      case NotificationType.paymentReceived:
        return 'payment';
      case NotificationType.subscriptionExpiring:
      case NotificationType.trialExpiring:
        return 'warning';
      case NotificationType.systemUpdate:
        return 'update';
      case NotificationType.general:
      default:
        return 'notification';
    }
  }

  /// الحصول على لون الإشعار
  String get colorName {
    switch (type) {
      case NotificationType.debtReminder:
        return 'warning';
      case NotificationType.paymentReceived:
        return 'success';
      case NotificationType.subscriptionExpiring:
      case NotificationType.trialExpiring:
        return 'error';
      case NotificationType.systemUpdate:
        return 'info';
      case NotificationType.general:
      default:
        return 'primary';
    }
  }

  /// التحقق من أهمية الإشعار
  bool get isImportant {
    return type == NotificationType.subscriptionExpiring ||
           type == NotificationType.trialExpiring;
  }

  /// التحقق من إمكانية التفاعل مع الإشعار
  bool get isActionable {
    return data != null && data!.containsKey('action');
  }

  /// الحصول على إجراء الإشعار
  String? get action {
    return data?['action'] as String?;
  }

  /// الحصول على معرف الكيان المرتبط
  String? get entityId {
    return data?['entity_id'] as String?;
  }

  /// الحصول على نوع الكيان المرتبط
  String? get entityType {
    return data?['entity_type'] as String?;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AppNotification(id: $id, title: $title, type: ${type.value}, isRead: $isRead)';
  }
}

/// بيانات إنشاء إشعار جديد
class NotificationData {
  final String title;
  final String message;
  final NotificationType type;
  final Map<String, dynamic>? data;

  const NotificationData({
    required this.title,
    required this.message,
    required this.type,
    this.data,
  });

  /// التحقق من صحة البيانات
  bool get isValid {
    return title.isNotEmpty && message.isNotEmpty;
  }

  @override
  String toString() {
    return 'NotificationData(title: $title, type: ${type.value})';
  }
}

/// إحصائيات الإشعارات
class NotificationStats {
  final int total;
  final int unread;
  final int read;
  final Map<NotificationType, int> byType;

  const NotificationStats({
    required this.total,
    required this.unread,
    required this.read,
    required this.byType,
  });

  /// إنشاء إحصائيات من قائمة الإشعارات
  factory NotificationStats.fromNotifications(List<AppNotification> notifications) {
    final byType = <NotificationType, int>{};
    int unreadCount = 0;
    
    for (final notification in notifications) {
      byType[notification.type] = (byType[notification.type] ?? 0) + 1;
      if (!notification.isRead) {
        unreadCount++;
      }
    }
    
    return NotificationStats(
      total: notifications.length,
      unread: unreadCount,
      read: notifications.length - unreadCount,
      byType: byType,
    );
  }

  /// نسبة الإشعارات المقروءة
  double get readPercentage {
    if (total == 0) return 0;
    return (read / total) * 100;
  }

  /// نسبة الإشعارات غير المقروءة
  double get unreadPercentage {
    if (total == 0) return 0;
    return (unread / total) * 100;
  }

  @override
  String toString() {
    return 'NotificationStats(total: $total, unread: $unread, read: $read)';
  }
}
