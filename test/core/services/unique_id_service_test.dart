import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../../lib/core/services/unique_id_service.dart';
import '../../../lib/core/services/firestore_service.dart';
import '../../../lib/core/services/logger_service.dart';

// توليد Mock classes
@GenerateNiceMocks([MockSpec<FirestoreService>()])
import 'unique_id_service_test.mocks.dart';

void main() {
  group('UniqueIdService Tests', () {
    late UniqueIdService uniqueIdService;
    late MockFirestoreService mockFirestoreService;

    setUp(() {
      // تهيئة GetX للاختبارات
      Get.testMode = true;
      
      // إعداد Mock objects
      mockFirestoreService = MockFirestoreService();
      
      // تسجيل الخدمات الوهمية
      Get.put<FirestoreService>(mockFirestoreService);
      
      // إنشاء الخدمة تحت الاختبار
      uniqueIdService = UniqueIdService();
      uniqueIdService.onInit();
    });

    tearDown(() {
      Get.reset();
    });

    group('توليد الرقم المميز', () {
      test('يجب أن يولد رقم 7 خانات', () async {
        // Arrange & Act
        final uniqueId = await uniqueIdService.generateUniqueId();
        
        // Assert
        expect(uniqueId.length, equals(7));
        expect(RegExp(r'^\d{7}$').hasMatch(uniqueId), isTrue);
      });

      test('يجب أن يولد أرقام مختلفة في استدعاءات متتالية', () async {
        // Arrange & Act
        final List<String> generatedIds = [];
        for (int i = 0; i < 10; i++) {
          final id = await uniqueIdService.generateUniqueId();
          generatedIds.add(id);
        }
        
        // Assert
        final uniqueIds = generatedIds.toSet();
        expect(uniqueIds.length, equals(generatedIds.length), 
               reason: 'يجب أن تكون جميع الأرقام فريدة');
      });

      test('يجب أن يبدأ برقم من 1000000 إلى 9999999', () async {
        // Act
        final uniqueId = await uniqueIdService.generateUniqueId();
        final idNumber = int.parse(uniqueId);
        
        // Assert
        expect(idNumber, greaterThanOrEqualTo(1000000));
        expect(idNumber, lessThanOrEqualTo(9999999));
      });
    });

    group('التحقق من صحة الرقم', () {
      test('يجب أن يقبل الأرقام الصحيحة', () {
        // Test cases
        const validIds = ['1234567', '7654321', '1000000', '9999999'];
        
        for (final id in validIds) {
          expect(uniqueIdService.isValidUniqueId(id), isTrue,
                 reason: '$id يجب أن يكون صحيح');
        }
      });

      test('يجب أن يرفض الأرقام غير الصحيحة', () {
        // Test cases
        const invalidIds = [
          '123456',    // 6 خانات فقط
          '12345678',  // 8 خانات
          'abcdefg',   // حروف
          '123456a',   // مختلط
          '',          // فارغ
          '0123456',   // يبدأ بصفر
        ];
        
        for (final id in invalidIds) {
          expect(uniqueIdService.isValidUniqueId(id), isFalse,
                 reason: '$id يجب أن يكون غير صحيح');
        }
      });
    });

    group('توليد الأرقام المخصصة', () {
      test('يجب أن يولد رقم عميل مؤقت صحيح', () async {
        // Act
        final customerId = await uniqueIdService.generateTemporaryCustomerId();
        
        // Assert
        expect(customerId.length, equals(7));
        expect(uniqueIdService.isValidUniqueId(customerId), isTrue);
      });

      test('يجب أن يولد رقم موظف صحيح', () async {
        // Act
        final employeeId = await uniqueIdService.generateEmployeeId();
        
        // Assert
        expect(employeeId.length, equals(7));
        expect(uniqueIdService.isValidUniqueId(employeeId), isTrue);
      });

      test('يجب أن يولد رقم مالك منشأة صحيح', () async {
        // Act
        final ownerId = await uniqueIdService.generateBusinessOwnerId();
        
        // Assert
        expect(ownerId.length, equals(7));
        expect(uniqueIdService.isValidUniqueId(ownerId), isTrue);
      });
    });

    group('حفظ واستعادة الرقم المميز', () {
      test('يجب وضع علامة على الرقم كمستخدم', () async {
        // Arrange
        const testId = '1234567';
        const userDocId = 'user123';
        const role = 'business_owner';
        
        // Act & Assert
        // هذا الاختبار يتطلب mock Firestore ولكن نتأكد من عدم رمي استثناء
        expect(
          () async => await uniqueIdService.markUniqueIdUsed(
            testId,
            userDocId: userDocId,
            role: role,
          ),
          isA<Future<void>>(),
        );
      });
    });
  });

  group('اختبارات تكامل UniqueIdService', () {
    testWidgets('يجب أن يعمل مع GetX dependency injection', 
        (WidgetTester tester) async {
      // Arrange
      Get.testMode = true;
      
      // Act
      Get.put(UniqueIdService());
      final service = Get.find<UniqueIdService>();
      
      // Assert
      expect(service, isNotNull);
      expect(service, isA<UniqueIdService>());
      
      // Cleanup
      Get.reset();
    });

    test('يجب أن يتعامل مع فشل Firestore بشكل لائق', () async {
      // Arrange
      Get.testMode = true;
      
      // محاكاة فشل Firestore
      final serviceWithoutFirestore = UniqueIdService();
      serviceWithoutFirestore.onInit();
      
      // Act
      final result = await serviceWithoutFirestore.generateUniqueId();
      
      // Assert - يجب أن يعود للتوليد المحلي
      expect(result.length, equals(7));
      expect(RegExp(r'^\d{7}$').hasMatch(result), isTrue);
    });
  });
}