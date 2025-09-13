import 'dart:convert';

class Debt {
  final String id;
  final String customerId;
  final String businessOwnerId;
  final double amount;
  final String? description;
  final String? notes;
  final DateTime? dueDate;
  final DateTime dateCreated;
  final bool isPaid;
  final double paidAmount;
  final String status; // pending, paid, partially_paid, cancelled
  final DateTime createdAt;
  final DateTime updatedAt;

  Debt({
    required this.id,
    required this.customerId,
    required this.businessOwnerId,
    required this.amount,
    this.description,
    this.notes,
    this.dueDate,
    required this.dateCreated,
    this.isPaid = false,
    this.paidAmount = 0.0,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  // إنشاء دين جديد
  factory Debt.create({
    required String customerId,
    required String businessOwnerId,
    required double amount,
    String? description,
    String? notes,
    DateTime? dueDate,
    DateTime? dateCreated,
  }) {
    final now = DateTime.now();
    return Debt(
      id: _generateId(),
      customerId: customerId,
      businessOwnerId: businessOwnerId,
      amount: amount,
      description: description,
      notes: notes,
      dueDate: dueDate,
      dateCreated: dateCreated ?? now,
      createdAt: now,
      updatedAt: now,
    );
  }

  // نسخ مع تعديل
  Debt copyWith({
    String? id,
    String? customerId,
    String? businessOwnerId,
    double? amount,
    String? description,
    String? notes,
    DateTime? dueDate,
    DateTime? dateCreated,
    bool? isPaid,
    double? paidAmount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Debt(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      businessOwnerId: businessOwnerId ?? this.businessOwnerId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      dueDate: dueDate ?? this.dueDate,
      dateCreated: dateCreated ?? this.dateCreated,
      isPaid: isPaid ?? this.isPaid,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'businessOwnerId': businessOwnerId,
      'amount': amount,
      'description': description,
      'notes': notes,
      'dueDate': dueDate?.toIso8601String(),
      'dateCreated': dateCreated.toIso8601String(),
      'isPaid': isPaid,
      'paidAmount': paidAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // إنشاء من JSON
  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      businessOwnerId: json['businessOwnerId'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      isPaid: json['isPaid'] as bool? ?? false,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // تحويل إلى نص JSON
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // إنشاء من نص JSON
  factory Debt.fromJsonString(String jsonString) {
    return Debt.fromJson(jsonDecode(jsonString));
  }

  // الحصول على المبلغ المتبقي
  double get remainingAmount {
    return amount - paidAmount;
  }

  // التحقق من الدفع الجزئي
  bool get isPartiallyPaid {
    return paidAmount > 0 && paidAmount < amount;
  }

  // التحقق من الدفع الكامل
  bool get isFullyPaid {
    return paidAmount >= amount;
  }

  // الحصول على نسبة الدفع
  double get paymentPercentage {
    if (amount == 0) return 0.0;
    return (paidAmount / amount) * 100;
  }

  // الحصول على حالة الدين
  String get debtStatus {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'مدفوع';
      case 'partially_paid':
        return 'مدفوع جزئياً';
      case 'cancelled':
        return 'ملغي';
      case 'pending':
      default:
        return 'معلق';
    }
  }

  // الحصول على لون الحالة
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'green';
      case 'partially_paid':
        return 'orange';
      case 'cancelled':
        return 'red';
      case 'pending':
      default:
        return 'blue';
    }
  }

  // التحقق من انتهاء صلاحية الدين (أكثر من 30 يوم)
  bool get isOverdue {
    final daysDifference = DateTime.now().difference(dateCreated).inDays;
    return daysDifference > 30 && !isPaid;
  }

  // الحصول على عدد الأيام منذ الإنشاء
  int get daysSinceCreated {
    return DateTime.now().difference(dateCreated).inDays;
  }

  // التحقق من صحة البيانات
  bool get isValid {
    return id.isNotEmpty &&
           customerId.isNotEmpty &&
           businessOwnerId.isNotEmpty &&
           amount > 0 &&
           paidAmount >= 0 &&
           paidAmount <= amount;
  }

  // توليد معرف فريد
  static String _generateId() {
    return 'debt_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond / 1000).round()}';
  }

  // مقارنة الديون
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Debt && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Debt(id: $id, amount: $amount, paidAmount: $paidAmount, status: $status)';
  }

  // إضافة دفعة
  Debt addPayment(double paymentAmount) {
    final newPaidAmount = paidAmount + paymentAmount;
    final newStatus = _calculateStatus(newPaidAmount);
    
    return copyWith(
      paidAmount: newPaidAmount,
      status: newStatus,
      isPaid: newPaidAmount >= amount,
    );
  }

  // حساب الحالة بناءً على المبلغ المدفوع
  String _calculateStatus(double paidAmount) {
    if (paidAmount >= amount) {
      return 'paid';
    } else if (paidAmount > 0) {
      return 'partially_paid';
    } else {
      return 'pending';
    }
  }

  // إلغاء الدين
  Debt cancel() {
    return copyWith(status: 'cancelled');
  }

  // إعادة تفعيل الدين
  Debt reactivate() {
    final newStatus = _calculateStatus(paidAmount);
    return copyWith(status: newStatus);
  }

  // تحديث الوصف
  Debt updateDescription(String newDescription) {
    return copyWith(description: newDescription);
  }

  // تحديث المبلغ
  Debt updateAmount(double newAmount) {
    final newStatus = _calculateStatus(paidAmount);
    return copyWith(
      amount: newAmount,
      status: newStatus,
      isPaid: paidAmount >= newAmount,
    );
  }

  // الحصول على ملخص الدين
  Map<String, dynamic> getSummary() {
    return {
      'id': id,
      'amount': amount,
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
      'paymentPercentage': paymentPercentage,
      'status': debtStatus,
      'isOverdue': isOverdue,
      'daysSinceCreated': daysSinceCreated,
      'dateCreated': dateCreated.toIso8601String(),
    };
  }

  // تصدير بيانات الدين
  Map<String, dynamic> exportData() {
    return {
      ...toJson(),
      'remainingAmount': remainingAmount,
      'paymentPercentage': paymentPercentage,
      'debtStatus': debtStatus,
      'isOverdue': isOverdue,
      'daysSinceCreated': daysSinceCreated,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  // تنسيق المبلغ
  String get formattedAmount {
    return '${amount.toStringAsFixed(2)} ر.س';
  }

  // تنسيق المبلغ المدفوع
  String get formattedPaidAmount {
    return '${paidAmount.toStringAsFixed(2)} ر.س';
  }

  // تنسيق المبلغ المتبقي
  String get formattedRemainingAmount {
    return '${remainingAmount.toStringAsFixed(2)} ر.س';
  }
}
