import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../utils/app_constants.dart';
import 'logger_service.dart';
import 'offline_service.dart';

/// خدمة قاعدة البيانات المبسطة
/// تدير جميع العمليات مع Firestore بطريقة موحدة ومبسطة
class SimplifiedDatabaseService extends GetxService {
  static SimplifiedDatabaseService get instance => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OfflineService _offlineService = Get.find<OfflineService>();
  
  // === العمليات الأساسية ===
  
  /// إضافة وثيقة جديدة
  Future<DocumentReference?> addDocument({
    required String collection,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    try {
      // التحقق من الاتصال
      if (!_offlineService.isOnline.value) {
        LoggerService.warning('محاولة إضافة وثيقة في وضع الأوفلاين: $collection');
        return null;
      }
      
      // إضافة البيانات الأساسية
      data.addAll({
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'version': 1,
      });
      
      DocumentReference docRef;
      if (documentId != null) {
        docRef = _firestore.collection(collection).doc(documentId);
        await docRef.set(data);
      } else {
        docRef = await _firestore.collection(collection).add(data);
      }
      
      LoggerService.info('تم إضافة وثيقة بنجاح: ${docRef.id}');
      return docRef;
      
    } catch (e) {
      LoggerService.error('خطأ في إضافة وثيقة: $collection', error: e);
      return null;
    }
  }
  
  /// تحديث وثيقة موجودة
  Future<bool> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      // التحقق من الاتصال
      if (!_offlineService.isOnline.value) {
        LoggerService.warning('محاولة تحديث وثيقة في وضع الأوفلاين: $collection/$documentId');
        return false;
      }
      
      // إضافة بيانات التحديث
      data['updatedAt'] = FieldValue.serverTimestamp();
      data['version'] = FieldValue.increment(1);
      
      await _firestore
          .collection(collection)
          .doc(documentId)
          .update(data);
      
      LoggerService.info('تم تحديث الوثيقة بنجاح: $documentId');
      return true;
      
    } catch (e) {
      LoggerService.error('خطأ في تحديث وثيقة: $collection/$documentId', error: e);
      return false;
    }
  }
  
  /// حذف وثيقة
  Future<bool> deleteDocument({
    required String collection,
    required String documentId,
    bool softDelete = true,
  }) async {
    try {
      // التحقق من الاتصال
      if (!_offlineService.isOnline.value) {
        LoggerService.warning('محاولة حذف وثيقة في وضع الأوفلاين: $collection/$documentId');
        return false;
      }
      
      if (softDelete) {
        // حذف ناعم - تعديل حالة الوثيقة
        await _firestore
            .collection(collection)
            .doc(documentId)
            .update({
          'isDeleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // حذف كامل
        await _firestore
            .collection(collection)
            .doc(documentId)
            .delete();
      }
      
      LoggerService.info('تم حذف الوثيقة بنجاح: $documentId');
      return true;
      
    } catch (e) {
      LoggerService.error('خطأ في حذف وثيقة: $collection/$documentId', error: e);
      return false;
    }
  }
  
  /// جلب وثيقة واحدة
  Future<DocumentSnapshot?> getDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      final doc = await _firestore
          .collection(collection)
          .doc(documentId)
          .get();
      
      if (!doc.exists) {
        LoggerService.warning('الوثيقة غير موجودة: $collection/$documentId');
        return null;
      }
      
      return doc;
      
    } catch (e) {
      LoggerService.error('خطأ في جلب وثيقة: $collection/$documentId', error: e);
      return null;
    }
  }
  
  /// جلب مجموعة من الوثائق
  Future<QuerySnapshot?> getDocuments({
    required String collection,
    Query Function(Query query)? queryBuilder,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);
      
      // إضافة فلترة الحذف الناعم
      query = query.where('isDeleted', isEqualTo: false);
      
      // تطبيق استعلام مخصص
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      
      // تحديد العدد المطلوب
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      LoggerService.info('تم جلب ${snapshot.docs.length} وثيقة من $collection');
      
      return snapshot;
      
    } catch (e) {
      LoggerService.error('خطأ في جلب الوثائق: $collection', error: e);
      return null;
    }
  }
  
  /// استمع للتغييرات في الوثائق
  Stream<QuerySnapshot> watchDocuments({
    required String collection,
    Query Function(Query query)? queryBuilder,
    int? limit,
  }) {
    try {
      Query query = _firestore.collection(collection);
      
      // إضافة فلترة الحذف الناعم
      query = query.where('isDeleted', isEqualTo: false);
      
      // تطبيق استعلام مخصص
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      
      // تحديد العدد المطلوب
      if (limit != null) {
        query = query.limit(limit);
      }
      
      return query.snapshots();
      
    } catch (e) {
      LoggerService.error('خطأ في مراقبة الوثائق: $collection', error: e);
      // إرجاع stream فارغ في حالة الخطأ
      return const Stream.empty();
    }
  }
  
  /// استمع للتغييرات في وثيقة واحدة
  Stream<DocumentSnapshot> watchDocument({
    required String collection,
    required String documentId,
  }) {
    try {
      return _firestore
          .collection(collection)
          .doc(documentId)
          .snapshots();
          
    } catch (e) {
      LoggerService.error('خطأ في مراقبة الوثيقة: $collection/$documentId', error: e);
      // إرجاع stream فارغ في حالة الخطأ
      return const Stream.empty();
    }
  }
  
  // === العمليات المعقدة ===
  
  /// تنفيذ معاملة
  Future<T?> runTransaction<T>({
    required Future<T> Function(Transaction transaction) transactionHandler,
  }) async {
    try {
      return await _firestore.runTransaction(transactionHandler);
    } catch (e) {
      LoggerService.error('خطأ في تنفيذ المعاملة', error: e);
      return null;
    }
  }
  
  /// تنفيذ مجموعة عمليات
  Future<bool> runBatch({
    required List<Map<String, dynamic>> operations,
  }) async {
    try {
      final batch = _firestore.batch();
      
      for (final operation in operations) {
        final type = operation['type'] as String;
        final collection = operation['collection'] as String;
        final documentId = operation['documentId'] as String?;
        final data = operation['data'] as Map<String, dynamic>?;
        
        final docRef = documentId != null 
            ? _firestore.collection(collection).doc(documentId)
            : _firestore.collection(collection).doc();
        
        switch (type) {
          case 'set':
            batch.set(docRef, data!);
            break;
          case 'update':
            batch.update(docRef, data!);
            break;
          case 'delete':
            batch.delete(docRef);
            break;
        }
      }
      
      await batch.commit();
      LoggerService.info('تم تنفيذ ${operations.length} عملية بنجاح');
      return true;
      
    } catch (e) {
      LoggerService.error('خطأ في تنفيذ مجموعة العمليات', error: e);
      return false;
    }
  }
  
  // === دوال مساعدة ===
  
  /// التحقق من وجود وثيقة
  Future<bool> documentExists({
    required String collection,
    required String documentId,
  }) async {
    try {
      final doc = await _firestore
          .collection(collection)
          .doc(documentId)
          .get();
      return doc.exists;
    } catch (e) {
      LoggerService.error('خطأ في التحقق من وجود الوثيقة', error: e);
      return false;
    }
  }
  
  /// عد الوثائق في مجموعة
  Future<int> countDocuments({
    required String collection,
    Query Function(Query query)? queryBuilder,
  }) async {
    try {
      Query query = _firestore.collection(collection);
      
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      
      final snapshot = await query.count().get();
      return snapshot.count ?? 0;
      
    } catch (e) {
      LoggerService.error('خطأ في عد الوثائق: $collection', error: e);
      return 0;
    }
  }
  
  /// تنظيف البيانات المحذوفة نهائياً
  Future<void> cleanupDeletedDocuments(String collection) async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .where('isDeleted', isEqualTo: true)
          .get();
      
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      LoggerService.info('تم تنظيف ${snapshot.docs.length} وثيقة محذوفة من $collection');
      
    } catch (e) {
      LoggerService.error('خطأ في تنظيف البيانات المحذوفة: $collection', error: e);
    }
  }
}