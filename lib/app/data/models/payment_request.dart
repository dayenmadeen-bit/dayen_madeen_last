import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج طلب الدفع
class PaymentRequest {
  final String id;
  final String customerId;
  final String businessOwnerId;
  final String businessName;
  final String customerName;
  final String customerUniqueId;
  final double amount;
  final String paymentMethod; // cash, card, transfer, etc.
  final String status; // pending, approved, rejected, completed
  final String? notes;
  final String? rejectionReason;
  final String? approvedBy; // employee ID who approved
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? approvedAt;
  final DateTime? completedAt;

  const PaymentRequest({
    required this.id,
    required this.customerId,
    required this.businessOwnerId,
    required this.businessName,
    required this.customerName,
    required this.customerUniqueId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.notes,
    this.rejectionReason,
    this.approvedBy,
    required this.createdAt,
    required this.updatedAt,
    this.approvedAt,
    this.completedAt,
  });

  /// إنشاء طلب دفع جديد
  factory PaymentRequest.create({
    required String customerId,
    required String businessOwnerId,
    required String businessName,
    required String customerName,
    required String customerUniqueId,
    required double amount,
    required String paymentMethod,
    String? notes,
  }) {
    final now = DateTime.now();
    return PaymentRequest(
      id: _generateId(),
      customerId: customerId,
      businessOwnerId: businessOwnerId,
      businessName: businessName,
      customerName: customerName,
      customerUniqueId: customerUniqueId,
      amount: amount,
      paymentMethod: paymentMethod,
      status: 'pending',
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// نسخ مع تحديث
  PaymentRequest copyWith({
    String? id,
    String? customerId,
    String? businessOwnerId,
    String? businessName,
    String? customerName,
    String? customerUniqueId,
    double? amount,
    String? paymentMethod,
    String? status,
    String? notes,
    String? rejectionReason,
    String? approvedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? approvedAt,
    DateTime? completedAt,
  }) {
    return PaymentRequest(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      businessOwnerId: businessOwnerId ?? this.businessOwnerId,
      businessName: businessName ?? this.businessName,
      customerName: customerName ?? this.customerName,
      customerUniqueId: customerUniqueId ?? this.customerUniqueId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvedBy: approvedBy ?? this.approvedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'businessOwnerId': businessOwnerId,
      'businessName': businessName,
      'customerName': customerName,
      'customerUniqueId': customerUniqueId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'notes': notes,
      'rejectionReason': rejectionReason,
      'approvedBy': approvedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  /// إنشاء من JSON
  factory PaymentRequest.fromJson(Map<String, dynamic> json) {
    return PaymentRequest(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      businessOwnerId: json['businessOwnerId'] ?? '',
      businessName: json['businessName'] ?? '',
      customerName: json['customerName'] ?? '',
      customerUniqueId: json['customerUniqueId'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      rejectionReason: json['rejectionReason'],
      approvedBy: json['approvedBy'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      approvedAt: json['approvedAt'] != null
          ? (json['approvedAt'] as Timestamp).toDate()
          : null,
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// توليد معرف فريد
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// التحقق من صحة البيانات
  bool get isValid {
    return id.isNotEmpty &&
        customerId.isNotEmpty &&
        businessOwnerId.isNotEmpty &&
        businessName.isNotEmpty &&
        customerName.isNotEmpty &&
        customerUniqueId.isNotEmpty &&
        amount > 0 &&
        paymentMethod.isNotEmpty &&
        status.isNotEmpty;
  }

  /// التحقق من حالة الطلب
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCompleted => status == 'completed';

  /// الحصول على لون الحالة
  String get statusColor {
    switch (status) {
      case 'pending':
        return 'warning';
      case 'approved':
        return 'success';
      case 'rejected':
        return 'error';
      case 'completed':
        return 'info';
      default:
        return 'secondary';
    }
  }

  /// الحصول على نص الحالة
  String get statusText {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'approved':
        return 'موافق عليه';
      case 'rejected':
        return 'مرفوض';
      case 'completed':
        return 'مكتمل';
      default:
        return 'غير محدد';
    }
  }

  /// الحصول على مدة الطلب
  Duration get duration {
    return DateTime.now().difference(createdAt);
  }

  /// التحقق من انتهاء صلاحية الطلب (أكثر من 7 أيام)
  bool get isExpired {
    return duration.inDays > 7;
  }

  /// الحصول على نص طريقة الدفع
  String get paymentMethodText {
    switch (paymentMethod) {
      case 'cash':
        return 'نقداً';
      case 'card':
        return 'بطاقة ائتمان';
      case 'transfer':
        return 'تحويل بنكي';
      case 'wallet':
        return 'محفظة إلكترونية';
      default:
        return paymentMethod;
    }
  }
}


