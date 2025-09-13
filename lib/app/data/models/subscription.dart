import 'dart:convert';

class Subscription {
  final String id;
  final String deviceId;
  final String businessOwnerId;
  final String businessName;
  final String planType; // trial, premium, enterprise
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool isTrial;
  final DateTime? trialStartDate;
  final DateTime? trialEndDate;
  final String? activatedBy; // admin, system, payment
  final DateTime? activatedAt;
  final DateTime lastChecked;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subscription({
    required this.id,
    required this.deviceId,
    required this.businessOwnerId,
    required this.businessName,
    this.planType = 'trial',
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.isTrial = true,
    this.trialStartDate,
    this.trialEndDate,
    this.activatedBy,
    this.activatedAt,
    required this.lastChecked,
    required this.createdAt,
    required this.updatedAt,
  });

  // إنشاء اشتراك تجريبي جديد
  factory Subscription.createTrial({
    required String deviceId,
    required String businessOwnerId,
    required String businessName,
    int trialDays = 30,
  }) {
    final now = DateTime.now();
    final trialEnd = now.add(Duration(days: trialDays));
    
    return Subscription(
      id: _generateId(),
      deviceId: deviceId,
      businessOwnerId: businessOwnerId,
      businessName: businessName,
      planType: 'trial',
      startDate: now,
      endDate: trialEnd,
      isTrial: true,
      trialStartDate: now,
      trialEndDate: trialEnd,
      activatedBy: 'system',
      activatedAt: now,
      lastChecked: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  // نسخ مع تعديل
  Subscription copyWith({
    String? id,
    String? deviceId,
    String? businessOwnerId,
    String? businessName,
    String? planType,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? isTrial,
    DateTime? trialStartDate,
    DateTime? trialEndDate,
    String? activatedBy,
    DateTime? activatedAt,
    DateTime? lastChecked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      businessOwnerId: businessOwnerId ?? this.businessOwnerId,
      businessName: businessName ?? this.businessName,
      planType: planType ?? this.planType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      isTrial: isTrial ?? this.isTrial,
      trialStartDate: trialStartDate ?? this.trialStartDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      activatedBy: activatedBy ?? this.activatedBy,
      activatedAt: activatedAt ?? this.activatedAt,
      lastChecked: lastChecked ?? this.lastChecked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'businessOwnerId': businessOwnerId,
      'businessName': businessName,
      'planType': planType,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'isTrial': isTrial,
      'trialStartDate': trialStartDate?.toIso8601String(),
      'trialEndDate': trialEndDate?.toIso8601String(),
      'activatedBy': activatedBy,
      'activatedAt': activatedAt?.toIso8601String(),
      'lastChecked': lastChecked.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // إنشاء من JSON
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String,
      businessOwnerId: json['businessOwnerId'] as String,
      businessName: json['businessName'] as String,
      planType: json['planType'] as String? ?? 'trial',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      isTrial: json['isTrial'] as bool? ?? true,
      trialStartDate: json['trialStartDate'] != null 
          ? DateTime.parse(json['trialStartDate'] as String) 
          : null,
      trialEndDate: json['trialEndDate'] != null 
          ? DateTime.parse(json['trialEndDate'] as String) 
          : null,
      activatedBy: json['activatedBy'] as String?,
      activatedAt: json['activatedAt'] != null 
          ? DateTime.parse(json['activatedAt'] as String) 
          : null,
      lastChecked: DateTime.parse(json['lastChecked'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // تحويل إلى نص JSON
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // إنشاء من نص JSON
  factory Subscription.fromJsonString(String jsonString) {
    return Subscription.fromJson(jsonDecode(jsonString));
  }

  // التحقق من انتهاء الاشتراك
  bool get isExpired {
    return DateTime.now().isAfter(endDate) || !isActive;
  }

  // الحصول على الأيام المتبقية
  int get daysRemaining {
    if (isExpired) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  // التحقق من الحاجة لتذكير
  bool get needsReminder {
    if (isExpired) return false;
    final daysLeft = daysRemaining;
    return daysLeft <= 7 && daysLeft > 0;
  }

  // الحصول على نوع التذكير
  String get reminderType {
    final daysLeft = daysRemaining;
    if (daysLeft <= 1) return 'urgent';
    if (daysLeft <= 3) return 'warning';
    if (daysLeft <= 7) return 'info';
    return 'none';
  }

  // الحصول على اسم الخطة
  String get planName {
    switch (planType.toLowerCase()) {
      case 'trial':
        return 'تجريبي';
      case 'premium':
        return 'مميز';
      case 'enterprise':
        return 'مؤسسي';
      default:
        return 'غير محدد';
    }
  }

  // الحصول على حالة الاشتراك
  String get statusName {
    if (!isActive) return 'غير نشط';
    if (isExpired) return 'منتهي';
    if (needsReminder) return 'قارب على الانتهاء';
    return 'نشط';
  }

  // الحصول على لون الحالة
  String get statusColor {
    if (!isActive) return 'grey';
    if (isExpired) return 'red';
    if (reminderType == 'urgent') return 'red';
    if (reminderType == 'warning') return 'orange';
    if (reminderType == 'info') return 'yellow';
    return 'green';
  }

  // توليد معرف فريد
  static String _generateId() {
    return 'sub_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond / 1000).round()}';
  }

  // مقارنة الاشتراكات
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Subscription && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Subscription(id: $id, planType: $planType, isActive: $isActive, daysRemaining: $daysRemaining)';
  }

  // تجديد الاشتراك
  Subscription renew({
    required int days,
    String? newPlanType,
    String? activatedBy,
  }) {
    final now = DateTime.now();
    final newEndDate = now.add(Duration(days: days));
    
    return copyWith(
      planType: newPlanType ?? planType,
      endDate: newEndDate,
      isActive: true,
      isTrial: newPlanType == 'trial',
      activatedBy: activatedBy ?? 'admin',
      activatedAt: now,
      lastChecked: now,
    );
  }

  // إلغاء الاشتراك
  Subscription cancel() {
    return copyWith(isActive: false);
  }

  // إعادة تفعيل الاشتراك
  Subscription reactivate() {
    return copyWith(isActive: true);
  }

  // تحديث آخر فحص
  Subscription updateLastChecked() {
    return copyWith(lastChecked: DateTime.now());
  }

  // الحصول على ملخص الاشتراك
  Map<String, dynamic> getSummary() {
    return {
      'id': id,
      'deviceId': deviceId,
      'businessName': businessName,
      'planName': planName,
      'statusName': statusName,
      'daysRemaining': daysRemaining,
      'isExpired': isExpired,
      'needsReminder': needsReminder,
      'reminderType': reminderType,
      'endDate': endDate.toIso8601String(),
    };
  }

  // تصدير بيانات الاشتراك
  Map<String, dynamic> exportData() {
    return {
      ...toJson(),
      'planName': planName,
      'statusName': statusName,
      'daysRemaining': daysRemaining,
      'isExpired': isExpired,
      'needsReminder': needsReminder,
      'reminderType': reminderType,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  // تنسيق تاريخ الانتهاء
  String get formattedEndDate {
    return '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';
  }

  // الحصول على رسالة التذكير
  String get reminderMessage {
    final daysLeft = daysRemaining;
    if (daysLeft <= 0) {
      return 'انتهى اشتراكك. يرجى التجديد للمتابعة.';
    } else if (daysLeft == 1) {
      return 'ينتهي اشتراكك غداً. يرجى التجديد لتجنب انقطاع الخدمة.';
    } else if (daysLeft <= 3) {
      return 'ينتهي اشتراكك خلال $daysLeft أيام. يرجى التجديد قريباً.';
    } else if (daysLeft <= 7) {
      return 'ينتهي اشتراكك خلال $daysLeft أيام. فكر في التجديد.';
    }
    return '';
  }
}
