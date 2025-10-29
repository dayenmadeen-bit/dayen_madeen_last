import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final String debtId;
  final String customerId;
  final String businessOwnerId;
  final double amount;
  final double? remainingAmount;
  final DateTime paymentDate;
  final String paymentMethod; // cash, card, bank, other
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.debtId,
    required this.customerId,
    required this.businessOwnerId,
    required this.amount,
    this.remainingAmount,
    required this.paymentDate,
    this.paymentMethod = 'cash',
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // إنشاء دفعة جديدة
  factory Payment.create({
    required String debtId,
    required String customerId,
    required String businessOwnerId,
    required double amount,
    double? remainingAmount,
    DateTime? paymentDate,
    String paymentMethod = 'cash',
    String? notes,
  }) {
    final now = DateTime.now();
    return Payment(
      id: _generateId(),
      debtId: debtId,
      customerId: customerId,
      businessOwnerId: businessOwnerId,
      amount: amount,
      remainingAmount: remainingAmount,
      paymentDate: paymentDate ?? now,
      paymentMethod: paymentMethod,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  // نسخ مع تعديل
  Payment copyWith({
    String? id,
    String? debtId,
    String? customerId,
    String? businessOwnerId,
    double? amount,
    DateTime? paymentDate,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      customerId: customerId ?? this.customerId,
      businessOwnerId: businessOwnerId ?? this.businessOwnerId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
  
  // === إضافة Methods المفقودة للتوافق مع Firebase ===
  
  /// تحويل إلى Map - 🔧 إصلاح
  Map<String, dynamic> toMap() {
    return toJson(); // استخدام toJson الموجود
  }

  /// إنشاء من Map - 🔧 إصلاح  
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment.fromJson(map); // استخدام fromJson الموجود
  }
  
  /// إنشاء من Firestore DocumentSnapshot - 🔧 إصلاح
  factory Payment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id; // إضافة id من DocumentSnapshot
    
    // معالجة Timestamp إلى DateTime
    final createdAtRaw = data['createdAt'];
    final updatedAtRaw = data['updatedAt'];
    final paymentDateRaw = data['paymentDate'];
    
    data['createdAt'] = _timestampToDateTime(createdAtRaw)?.toIso8601String() ?? DateTime.now().toIso8601String();
    data['updatedAt'] = _timestampToDateTime(updatedAtRaw)?.toIso8601String() ?? DateTime.now().toIso8601String();
    data['paymentDate'] = _timestampToDateTime(paymentDateRaw)?.toIso8601String() ?? DateTime.now().toIso8601String();
    
    return Payment.fromMap(data);
  }
  
  /// مساعد لتحويل Timestamp إلى DateTime
  static DateTime? _timestampToDateTime(dynamic timestampValue) {
    if (timestampValue == null) return null;
    
    if (timestampValue is Timestamp) {
      return timestampValue.toDate();
    } else if (timestampValue is String) {
      try {
        return DateTime.parse(timestampValue);
      } catch (e) {
        return null;
      }
    } else if (timestampValue is DateTime) {
      return timestampValue;
    }
    
    return null;
  }
  
  // === نهاية الإضافة ===

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'debtId': debtId,
      'customerId': customerId,
      'businessOwnerId': businessOwnerId,
      'amount': amount,
      'remainingAmount': remainingAmount,
      'paymentDate': paymentDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // إنشاء من JSON
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      debtId: json['debtId'] as String,
      customerId: json['customerId'] as String,
      businessOwnerId: json['businessOwnerId'] as String,
      amount: (json['amount'] as num).toDouble(),
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble(),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? json['createdAt'] as String),
    );
  }

  // تحويل إلى نص JSON
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // إنشاء من نص JSON
  factory Payment.fromJsonString(String jsonString) {
    return Payment.fromJson(jsonDecode(jsonString));
  }

  // الحصول على اسم طريقة الدفع
  String get paymentMethodName {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return 'نقدي';
      case 'card':
        return 'بطاقة';
      case 'bank':
        return 'تحويل بنكي';
      case 'other':
        return 'أخرى';
      default:
        return 'غير محدد';
    }
  }

  // الحصول على أيقونة طريقة الدفع
  String get paymentMethodIcon {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return 'money';
      case 'card':
        return 'credit_card';
      case 'bank':
        return 'account_balance';
      case 'other':
        return 'payment';
      default:
        return 'payment';
    }
  }

  // التحقق من صحة البيانات
  bool get isValid {
    return id.isNotEmpty &&
           debtId.isNotEmpty &&
           customerId.isNotEmpty &&
           businessOwnerId.isNotEmpty &&
           amount > 0;
  }

  // التحقق من كون الدفعة حديثة (خلال آخر 24 ساعة)
  bool get isRecent {
    final hoursDifference = DateTime.now().difference(paymentDate).inHours;
    return hoursDifference <= 24;
  }

  // الحصول على عدد الأيام منذ الدفع
  int get daysSincePayment {
    return DateTime.now().difference(paymentDate).inDays;
  }

  // توليد معرف فريد
  static String _generateId() {
    return 'payment_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond / 1000).round()}';
  }

  // مقارنة الدفعات
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Payment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Payment(id: $id, amount: $amount, method: $paymentMethod, date: $paymentDate)';
  }

  // تحديث الملاحظات
  Payment updateNotes(String newNotes) {
    return copyWith(notes: newNotes);
  }

  // تحديث طريقة الدفع
  Payment updatePaymentMethod(String newMethod) {
    return copyWith(paymentMethod: newMethod);
  }

  // تحديث تاريخ الدفع
  Payment updatePaymentDate(DateTime newDate) {
    return copyWith(paymentDate: newDate);
  }

  // الحصول على ملخص الدفعة
  Map<String, dynamic> getSummary() {
    return {
      'id': id,
      'amount': amount,
      'paymentMethod': paymentMethodName,
      'paymentDate': paymentDate.toIso8601String(),
      'isRecent': isRecent,
      'daysSincePayment': daysSincePayment,
      'notes': notes,
    };
  }

  // تصدير بيانات الدفعة
  Map<String, dynamic> exportData() {
    return {
      ...toJson(),
      'paymentMethodName': paymentMethodName,
      'isRecent': isRecent,
      'daysSincePayment': daysSincePayment,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  // تنسيق المبلغ
  String get formattedAmount {
    return '${amount.toStringAsFixed(2)} ر.س';
  }

  // تنسيق التاريخ
  String get formattedDate {
    return '${paymentDate.day.toString().padLeft(2, '0')}/${paymentDate.month.toString().padLeft(2, '0')}/${paymentDate.year}';
  }

  // تنسيق الوقت
  String get formattedTime {
    return '${paymentDate.hour.toString().padLeft(2, '0')}:${paymentDate.minute.toString().padLeft(2, '0')}';
  }

  // تنسيق التاريخ والوقت
  String get formattedDateTime {
    return '$formattedDate $formattedTime';
  }

  // إنشاء إيصال الدفع
  Map<String, dynamic> generateReceipt({
    String? customerName,
    String? businessName,
    String? debtDescription,
  }) {
    return {
      'receiptId': id,
      'paymentAmount': formattedAmount,
      'paymentMethod': paymentMethodName,
      'paymentDate': formattedDate,
      'paymentTime': formattedTime,
      'customerName': customerName ?? 'غير محدد',
      'businessName': businessName ?? 'غير محدد',
      'debtDescription': debtDescription ?? 'غير محدد',
      'notes': notes ?? '',
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  // التحقق من إمكانية التعديل (خلال 24 ساعة من الإنشاء)
  bool get canBeEdited {
    final hoursSinceCreation = DateTime.now().difference(createdAt).inHours;
    return hoursSinceCreation <= 24;
  }

  // التحقق من إمكانية الحذف (خلال ساعة من الإنشاء)
  bool get canBeDeleted {
    final minutesSinceCreation = DateTime.now().difference(createdAt).inMinutes;
    return minutesSinceCreation <= 60;
  }

  // الحصول على رقم مرجعي للدفعة
  String get referenceNumber {
    return 'PAY-${id.substring(id.length - 8).toUpperCase()}';
  }
}