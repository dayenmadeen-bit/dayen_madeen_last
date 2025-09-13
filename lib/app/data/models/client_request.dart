// إضافة imports مطلوبة
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/constants/client_constants.dart';

/// نموذج طلب الزبون
class ClientRequest {
  final String id;
  final String clientId;
  final String clientName;
  final RequestType type;
  final double amount;
  final String description;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? rejectionReason;
  final String? attachmentUrl; // رابط المرفق (إيصال السداد مثلاً)

  ClientRequest({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.type,
    required this.amount,
    required this.description,
    required this.status,
    required this.createdAt,
    this.processedAt,
    this.rejectionReason,
    this.attachmentUrl,
  });

  /// إنشاء طلب جديد
  factory ClientRequest.create({
    required String clientId,
    required String clientName,
    required RequestType type,
    required double amount,
    required String description,
    String? attachmentUrl,
  }) {
    return ClientRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientId: clientId,
      clientName: clientName,
      type: type,
      amount: amount,
      description: description,
      status: RequestStatus.pending,
      createdAt: DateTime.now(),
      attachmentUrl: attachmentUrl,
    );
  }

  /// نسخ الطلب مع تعديل بعض الخصائص
  ClientRequest copyWith({
    String? id,
    String? clientId,
    String? clientName,
    RequestType? type,
    double? amount,
    String? description,
    RequestStatus? status,
    DateTime? createdAt,
    DateTime? processedAt,
    String? rejectionReason,
    String? attachmentUrl,
  }) {
    return ClientRequest(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }

  /// تحويل إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'type': type.name,
      'amount': amount,
      'description': description,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'attachmentUrl': attachmentUrl,
    };
  }

  /// إنشاء من Map
  factory ClientRequest.fromMap(Map<String, dynamic> map) {
    return ClientRequest(
      id: map['id'] ?? '',
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      type: RequestType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => RequestType.debt,
      ),
      amount: (map['amount'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      status: RequestStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => RequestStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      processedAt: map['processedAt'] != null 
          ? DateTime.parse(map['processedAt']) 
          : null,
      rejectionReason: map['rejectionReason'],
      attachmentUrl: map['attachmentUrl'],
    );
  }

  /// تحويل إلى JSON
  String toJson() => jsonEncode(toMap());

  /// إنشاء من JSON
  factory ClientRequest.fromJson(String source) => 
      ClientRequest.fromMap(jsonDecode(source));

  /// نص نوع الطلب
  String get typeText => ClientConstants.getRequestTypeText(type.name);

  /// نص حالة الطلب
  String get statusText => ClientConstants.getRequestStatusText(status.name);

  /// لون حالة الطلب
  Color get statusColor => ClientConstants.getRequestStatusColor(status.name);

  /// أيقونة نوع الطلب
  IconData get typeIcon => ClientConstants.getRequestTypeIcon(type.name);

  @override
  String toString() {
    return 'ClientRequest(id: $id, clientName: $clientName, type: $type, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClientRequest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// أنواع الطلبات
enum RequestType {
  debt,    // طلب دين جديد
  payment, // طلب سداد دين
}

/// حالات الطلبات
enum RequestStatus {
  pending,  // في الانتظار
  approved, // موافق عليه
  rejected, // مرفوض
}
