import 'dart:convert';

class Customer {
  final String id;
  final String businessOwnerId;
  late final String name;
  final String uniqueId; // الرقم المميز 7 خانات
  final String? email; // البريد الإلكتروني اختياري
  final String? address;
  final String userType;
  final String password;
  final double creditLimit;
  final double currentBalance;
  final bool isActive;
  final bool isTemporary; // هل الحساب مؤقت أم دائم
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.businessOwnerId,
    required this.name,
    required this.uniqueId,
    this.email,
    this.address,
    required this.password,
    this.userType = 'customer',
    this.creditLimit = 0.0,
    this.currentBalance = 0.0,
    this.isActive = true,
    this.isTemporary = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // إنشاء عميل جديد
  factory Customer.create({
    required String businessOwnerId,
    required String name,
    required String uniqueId,
    required String password,
    String? email,
    double creditLimit = 1000.0,
    bool isTemporary = false,
  }) {
    final now = DateTime.now();
    return Customer(
      id: _generateId(),
      businessOwnerId: businessOwnerId,
      name: name,
      uniqueId: uniqueId,
      password: password,
      email: email,
      creditLimit: creditLimit,
      isTemporary: isTemporary,
      createdAt: now,
      updatedAt: now,
    );
  }

  // نسخ مع تعديل
  Customer copyWith({
    String? id,
    String? businessOwnerId,
    String? name,
    String? uniqueId,
    String? password,
    String? email,
    String? userType,
    double? creditLimit,
    double? currentBalance,
    bool? isActive,
    bool? isTemporary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      businessOwnerId: businessOwnerId ?? this.businessOwnerId,
      name: name ?? this.name,
      uniqueId: uniqueId ?? this.uniqueId,
      password: password ?? this.password,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      isActive: isActive ?? this.isActive,
      isTemporary: isTemporary ?? this.isTemporary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessOwnerId': businessOwnerId,
      'name': name,
      'uniqueId': uniqueId,
      'password': password,
      'email': email,
      'address': address,
      'userType': userType,
      'creditLimit': creditLimit,
      'currentBalance': currentBalance,
      'isActive': isActive,
      'isTemporary': isTemporary,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // إنشاء من JSON
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      businessOwnerId: json['businessOwnerId'] as String,
      name: json['name'] as String,
      uniqueId: json['uniqueId'] as String,
      password: json['password'] as String,
      email: json['email'] as String?,
      address: json['address'] as String?,
      userType: json['userType'] as String? ?? 'customer',
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0.0,
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
      isTemporary: json['isTemporary'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // تحويل إلى نص JSON
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // إنشاء من نص JSON
  factory Customer.fromJsonString(String jsonString) {
    return Customer.fromJson(jsonDecode(jsonString));
  }

  // الحصول على الأحرف الأولى للاسم
  String get initials {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'C';
  }

  // الحصول على الرصيد المتاح
  double get availableCredit {
    return creditLimit - currentBalance;
  }

  // التحقق من إمكانية الإقراض
  bool canBorrow(double amount) {
    return isActive && (currentBalance + amount) <= creditLimit;
  }

  // التحقق من تجاوز حد الائتمان
  bool get isOverCreditLimit {
    return currentBalance > creditLimit;
  }

  // الحصول على نسبة استخدام الائتمان
  double get creditUtilizationPercentage {
    if (creditLimit == 0) return 0.0;
    return (currentBalance / creditLimit) * 100;
  }

  // الحصول على حالة الائتمان
  String get creditStatus {
    if (!isActive) return 'غير نشط';
    if (currentBalance == 0) return 'لا يوجد ديون';
    if (isOverCreditLimit) return 'تجاوز الحد';
    if (creditUtilizationPercentage >= 90) return 'قريب من الحد';
    if (creditUtilizationPercentage >= 70) return 'استخدام عالي';
    return 'جيد';
  }

  // الحصول على لون حالة الائتمان
  String get creditStatusColor {
    if (!isActive) return 'grey';
    if (currentBalance == 0) return 'green';
    if (isOverCreditLimit) return 'red';
    if (creditUtilizationPercentage >= 90) return 'orange';
    if (creditUtilizationPercentage >= 70) return 'yellow';
    return 'green';
  }

  // التحقق من صحة البيانات
  bool get isValid {
    return id.isNotEmpty &&
        businessOwnerId.isNotEmpty &&
        name.isNotEmpty &&
        uniqueId.isNotEmpty &&
        creditLimit >= 0 &&
        currentBalance >= 0;
  }

  // توليد معرف فريد
  static String _generateId() {
    return 'customer_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond / 1000).round()}';
  }

  // مقارنة العملاء
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, uniqueId: $uniqueId, balance: $currentBalance)';
  }

  // تحديث الرصيد
  Customer updateBalance(double newBalance) {
    return copyWith(currentBalance: newBalance);
  }

  // إضافة مبلغ للرصيد (دين جديد)
  Customer addToBalance(double amount) {
    return copyWith(currentBalance: currentBalance + amount);
  }

  // خصم مبلغ من الرصيد (دفعة)
  Customer subtractFromBalance(double amount) {
    final newBalance = currentBalance - amount;
    return copyWith(currentBalance: newBalance < 0 ? 0 : newBalance);
  }

  // تحديث حد الائتمان
  Customer updateCreditLimit(double newLimit) {
    return copyWith(creditLimit: newLimit);
  }

  // تفعيل/إلغاء تفعيل العميل
  Customer toggleActive() {
    return copyWith(isActive: !isActive);
  }

  // تحديث معلومات العميل
  Customer updateInfo({
    String? name,
    String? email,
  }) {
    return copyWith(
      name: name,
      email: email,
    );
  }

  // تحديث آخر نشاط
  Customer updateLastActivity() {
    return copyWith(updatedAt: DateTime.now());
  }

  // الحصول على ملخص العميل
  Map<String, dynamic> getSummary() {
    return {
      'id': id,
      'name': name,
      'uniqueId': uniqueId,
      'email': email,
      'currentBalance': currentBalance,
      'creditLimit': creditLimit,
      'availableCredit': availableCredit,
      'creditUtilization': creditUtilizationPercentage,
      'creditStatus': creditStatus,
      'isActive': isActive,
      'isTemporary': isTemporary,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // تصدير بيانات العميل
  Map<String, dynamic> exportData() {
    return {
      ...toJson(),
      'availableCredit': availableCredit,
      'creditUtilization': creditUtilizationPercentage,
      'creditStatus': creditStatus,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }
}
