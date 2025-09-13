import 'dart:math';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';
import 'logger_service.dart';

/// خدمة توليد الرقم المميز ذو 7 خانات مع التحقق من التفرد
class UniqueIdService extends GetxService {
  static UniqueIdService get instance => Get.find<UniqueIdService>();

  FirestoreService? _firestore;
  final Random _random = Random();

  @override
  void onInit() {
    super.onInit();
    try {
      _firestore = Get.find<FirestoreService>();
    } catch (e) {
      LoggerService.warning('Firestore غير متوفر في UniqueIdService');
    }
  }

  /// توليد رقم مميز جديد ذو 7 خانات
  /// يحاول أولاً Firestore، ثم محلياً كاحتياط
  Future<String> generateUniqueId() async {
    String? uniqueId;

    // محاولة توليد رقم فريد في Firestore أولاً
    if (_firestore != null) {
      try {
        uniqueId = await _generateFromFirestore();
        if (uniqueId != null) {
          LoggerService.success(
              'تم توليد الرقم المميز من Firestore: $uniqueId');
          return uniqueId;
        }
      } catch (e) {
        LoggerService.warning('فشل توليد الرقم المميز من Firestore: $e');
      }
    }

    // توليد رقم محلي كاحتياط
    uniqueId = _generateLocalId();
    LoggerService.success('تم توليد الرقم المميز محلياً: $uniqueId');
    return uniqueId;
  }

  /// توليد رقم مميز من Firestore مع حجز ذري في مجموعة unique_ids
  Future<String?> _generateFromFirestore() async {
    if (_firestore == null) return null;

    const int maxAttempts = 10;
    int attempts = 0;

    while (attempts < maxAttempts) {
      final candidateId = _generate7DigitId();

      try {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final ref = FirebaseFirestore.instance
              .collection('unique_ids')
              .doc(candidateId);
          final snapshot = await transaction.get(ref);
          if (snapshot.exists) {
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'already-exists',
              message: 'unique id already exists',
            );
          }
          transaction.set(ref, {
            'reserved': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
        });

        // تم الحجز بنجاح
        return candidateId;
      } on FirebaseException catch (e) {
        if (e.code == 'already-exists') {
          // موجود مسبقاً، جرب رقم آخر
          attempts++;
          continue;
        }
        LoggerService.warning(
            'FirebaseException عند حجز $candidateId: ${e.code}');
      } catch (e) {
        LoggerService.warning('خطأ عند حجز $candidateId: $e');
      }

      attempts++;
    }

    throw Exception('فشل في توليد رقم مميز فريد بعد $maxAttempts محاولة');
  }

  // تمت إزالة التحقق الشامل القديم والاكتفاء بالحجز الذري في unique_ids

  /// وسم الرقم المحجوز بأنه مستخدم
  Future<void> markUniqueIdUsed(String id,
      {String? userDocId, String? role}) async {
    try {
      final ref = FirebaseFirestore.instance.collection('unique_ids').doc(id);
      await ref.set({
        'reserved': false,
        'used': true,
        'usedAt': FieldValue.serverTimestamp(),
        if (userDocId != null) 'userDocId': userDocId,
        if (role != null) 'role': role,
      }, SetOptions(merge: true));
    } catch (e) {
      LoggerService.warning('تعذر وسم الرقم $id كمستخدم: $e');
    }
  }

  /// توليد رقم محلي ذو 7 خانات
  String _generateLocalId() {
    return _generate7DigitId();
  }

  /// توليد رقم عشوائي ذو 7 خانات
  String _generate7DigitId() {
    // توليد رقم بين 1000000 و 9999999 (7 خانات)
    final int min = 1000000;
    final int max = 9999999;
    final int randomNumber = min + _random.nextInt(max - min + 1);

    return randomNumber.toString();
  }

  /// التحقق من صحة تنسيق الرقم المميز
  bool isValidUniqueId(String id) {
    if (id.length != 7) return false;

    // التحقق من أن جميع الأحرف أرقام
    final RegExp digitRegex = RegExp(r'^\d{7}$');
    return digitRegex.hasMatch(id);
  }

  /// البحث عن مستخدم بالرقم المميز
  Future<Map<String, dynamic>?> findUserByUniqueId(String uniqueId) async {
    if (_firestore == null) return null;

    try {
      final querySnapshot = await _firestore!
          .usersCol()
          .where('uniqueId', isEqualTo: uniqueId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }

      return null;
    } catch (e) {
      LoggerService.error('خطأ في البحث عن المستخدم بالرقم المميز', error: e);
      return null;
    }
  }

  /// التحقق من وجود الرقم المميز في النظام
  Future<bool> isUniqueIdExists(String uniqueId) async {
    if (_firestore == null) return false;

    try {
      final user = await findUserByUniqueId(uniqueId);
      return user != null;
    } catch (e) {
      LoggerService.error('خطأ في التحقق من وجود الرقم المميز', error: e);
      return false;
    }
  }

  /// توليد رقم مميز للعميل المؤقت (7 خانات)
  Future<String> generateTemporaryCustomerId() async {
    return await generateUniqueId();
  }

  /// توليد رقم مميز للموظف (7 خانات)
  Future<String> generateEmployeeId() async {
    return await generateUniqueId();
  }

  /// توليد رقم مميز لمالك المنشأة (7 خانات)
  Future<String> generateBusinessOwnerId() async {
    return await generateUniqueId();
  }

  /// حجز رقم مميز للمستخدم
  Future<void> reserveId(String id, String userId, UniqueIdType type) async {
    try {
      await _firestore!.usersCol().add({
        'id': id,
        'userId': userId,
        'type': 'reserved_id',
        'userType': type.name,
        'isUsed': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      LoggerService.success('تم حجز الرقم المميز: $id للمستخدم: $userId');
    } catch (e) {
      LoggerService.error('خطأ في حجز الرقم المميز', error: e);
      rethrow;
    }
  }

  /// تنظيف الأرقام المحجوزة القديمة (للاستخدام الداخلي)
  Future<void> cleanupReservedIds() async {
    if (_firestore == null) return;

    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 7));

      final querySnapshot = await _firestore!
          .usersCol()
          .where('type', isEqualTo: 'reserved_id')
          .where('createdAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _firestore!.batch();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      LoggerService.success(
          'تم تنظيف ${querySnapshot.docs.length} رقم محجوز قديم');
    } catch (e) {
      LoggerService.error('خطأ في تنظيف الأرقام المحجوزة', error: e);
    }
  }
}

enum UniqueIdType {
  customer,
  employee,
  owner,
}
