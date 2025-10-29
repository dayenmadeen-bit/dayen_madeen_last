# دليل أفضل الممارسات للتطوير - دائن مدين

## نظرة عامة

هذا الدليل يوضح أفضل الممارسات والمعايير المتبعة في تطوير تطبيق "دائن مدين" لضمان جودة عالية وأداء متميز.

## البنية العامة للمشروع

### تنظيم المجلدات

```
lib/
├── app/                  # طبقة التطبيق
│   ├── controllers/    # كنترولرات GetX
│   ├── data/           # نماذج البيانات والخدمات
│   ├── modules/        # وحدات التطبيق (كل وحدة لها views/controllers/bindings)
│   ├── routes/         # مسارات التطبيق
│   └── widgets/        # واجهات مشتركة
└── core/                 # العناصر الأساسية
    ├── constants/      # الثوابت
    ├── services/       # الخدمات الأساسية
    ├── themes/         # الثيمات والألوان
    └── utils/          # الأدوات المساعدة
```

### مبادئ البنية

1. **فصل الاهتمامات**: كل طبقة لها مسؤولية محددة
2. **الاعتماد على الحقن**: استخدام GetX لحقن التبعيات
3. **المودولارية**: كل ميزة في وحدة منفصلة
4. **ققابلية الاختبار**: فصل المنطق عن الواجهة

## معايير الكود

### تسمية الملفات والمجلدات

- **الملفات**: `snake_case` (مثل: `auth_service.dart`)
- **المجلدات**: `lowercase_with_underscores`
- **الفئات**: `PascalCase`
- **المتغيرات**: `camelCase`
- **الثوابت**: `SCREAMING_SNAKE_CASE`

### تعليقات الكود

```dart
/// وصف مفصل للفئة أو الوظيفة
/// شرح للهدف والاستخدام
class AuthService extends GetxService {
  // === ترأس أقسام الكود ===
  
  /// وصف مختصر للوظيفة
  /// [parameter] وصف المعامل
  /// Returns: وصف الإرجاع
  Future<bool> authenticate(String email, String password) async {
    // تعليق موجز للمنطق المعقد
    return await _performAuthentication(email, password);
  }
}
```

### معالجة الأخطاء

```dart
// استخدام EnhancedErrorHandler دائماً
Future<UserModel?> getUser(String id) async {
  return await EnhancedErrorHandler.safeExecute(
    operation: () => _fetchUserFromFirebase(id),
    context: 'جلب بيانات المستخدم',
    severity: ErrorSeverity.medium,
  );
}
```

## إدارة الحالة

### استخدام GetX Controllers

```dart
class CustomersController extends GetxController {
  // === المتغيرات القابلة للمراقبة ===
  final RxList<CustomerModel> customers = <CustomerModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  
  // === الخدمات ===
  final SimplifiedDatabaseService _database = Get.find();
  final AuthService _auth = Get.find();
  
  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }
  
  /// تهيئة الكنترولر
  void _initializeController() {
    // استمع للتغييرات في البحث
    debounce(searchQuery, _performSearch, time: const Duration(milliseconds: 500));
    
    // جلب البيانات الأولية
    loadCustomers();
  }
  
  /// تحميل قائمة العملاء
  Future<void> loadCustomers() async {
    await EnhancedErrorHandler.safeExecute(
      operation: () async {
        isLoading.value = true;
        final result = await _database.getDocuments(
          collection: 'customers',
          queryBuilder: (query) => query
              .where('ownerId', isEqualTo: _auth.currentUser.value?.uid)
              .orderBy('createdAt', descending: true),
        );
        
        if (result != null) {
          customers.value = result.docs
              .map((doc) => CustomerModel.fromFirestore(doc))
              .toList();
        }
      },
      context: 'تحميل قائمة العملاء',
      severity: ErrorSeverity.medium,
    );
    
    isLoading.value = false;
  }
}
```

## قاعدة البيانات

### استخدام SimplifiedDatabaseService

```dart
// إضافة عميل جديد
Future<bool> addCustomer(CustomerModel customer) async {
  final result = await SimplifiedDatabaseService.instance.addDocument(
    collection: 'customers',
    data: customer.toJson(),
  );
  
  return result != null;
}

// تحديث بيانات عميل
Future<bool> updateCustomer(String id, Map<String, dynamic> updates) async {
  return await SimplifiedDatabaseService.instance.updateDocument(
    collection: 'customers',
    documentId: id,
    data: updates,
  );
}

// مراقبة التغييرات في العملاء
Stream<List<CustomerModel>> watchCustomers(String ownerId) {
  return SimplifiedDatabaseService.instance
      .watchDocuments(
        collection: 'customers',
        queryBuilder: (query) => query.where('ownerId', isEqualTo: ownerId),
      )
      .map((snapshot) => snapshot.docs
          .map((doc) => CustomerModel.fromFirestore(doc))
          .toList());
}
```

### نماذج البيانات

```dart
class CustomerModel {
  final String id;
  final String name;
  final String email;
  final double debtLimit;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  
  const CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.debtLimit,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });
  
  /// إنشاء من Firestore Document
  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomerModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      debtLimit: (data['debtLimit'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDeleted: data['isDeleted'] ?? false,
    );
  }
  
  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'debtLimit': debtLimit,
      'isDeleted': isDeleted,
      // createdAt و updatedAt يتم إضافتهما تلقائياً في SimplifiedDatabaseService
    };
  }
  
  /// إنشاء نسخة محدثة
  CustomerModel copyWith({
    String? name,
    String? email,
    double? debtLimit,
    bool? isDeleted,
  }) {
    return CustomerModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      debtLimit: debtLimit ?? this.debtLimit,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
```

## واجهات المستخدم

### هيكل الواجهة

```dart
class CustomersScreen extends GetView<CustomersController> {
  const CustomersScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // === شريط التطبيق ===
      appBar: _buildAppBar(),
      
      // === الجسم الرئيسي ===
      body: _buildBody(),
      
      // === زر الٜرأي ===
      floatingActionButton: _buildFAB(),
    );
  }
  
  /// بناء شريط التطبيق
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('العملاء'),
      actions: [
        _buildSearchButton(),
        _buildMenuButton(),
      ],
    );
  }
  
  /// بناء الجسم الرئيسي
  Widget _buildBody() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _buildCustomersList(),
        ),
      ],
    );
  }
  
  /// بناء قائمة العملاء
  Widget _buildCustomersList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.customers.isEmpty) {
        return _buildEmptyState();
      }
      
      return ListView.builder(
        itemCount: controller.customers.length,
        itemBuilder: (context, index) {
          final customer = controller.customers[index];
          return _buildCustomerTile(customer);
        },
      );
    });
  }
}
```

## الاختبارات

### اختبارات الوحدة

```dart
void main() {
  group('CustomerService Tests', () {
    late CustomerService service;
    late MockDatabaseService mockDatabase;
    
    setUp(() {
      mockDatabase = MockDatabaseService();
      service = CustomerService(database: mockDatabase);
    });
    
    test('يجب إضافة عميل جديد بنجاح', () async {
      // Arrange
      final customer = CustomerModel.test();
      when(mockDatabase.addDocument(any, any)).thenAnswer((_) async => mockDocRef);
      
      // Act
      final result = await service.addCustomer(customer);
      
      // Assert
      expect(result, isTrue);
      verify(mockDatabase.addDocument('customers', customer.toJson()));
    });
  });
}
```

### اختبارات التكامل

```dart
void main() {
  group('Customer Flow Integration Tests', () {
    testWidgets('يجب إضافة عميل جديد وعرضه في القائمة', (tester) async {
      // Arrange
      await tester.pumpWidget(TestApp());
      
      // Act
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byKey(const Key('customer_name')), 'عميل اختبار');
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('عميل اختبار'), findsOneWidget);
    });
  });
}
```

## الأداء

### تحسين الاستعلامات

```dart
// استخدام pagination
Future<void> loadMoreCustomers() async {
  if (isLoadingMore.value || !hasMoreData.value) return;
  
  isLoadingMore.value = true;
  
  final result = await _database.getDocuments(
    collection: 'customers',
    queryBuilder: (query) => query
        .where('ownerId', isEqualTo: _auth.currentUserId)
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastDocument.value!)
        .limit(20),
  );
  
  if (result != null && result.docs.isNotEmpty) {
    customers.addAll(
      result.docs.map((doc) => CustomerModel.fromFirestore(doc)).toList(),
    );
    lastDocument.value = result.docs.last;
    hasMoreData.value = result.docs.length == 20;
  } else {
    hasMoreData.value = false;
  }
  
  isLoadingMore.value = false;
}
```

### تحسين الذاكرة

```dart
// استخدام lazy loading للصور
Widget _buildCustomerAvatar(String? imageUrl) {
  if (imageUrl == null) {
    return const CircleAvatar(
      child: Icon(Icons.person),
    );
  }
  
  return CachedNetworkImage(
    imageUrl: imageUrl,
    placeholder: (context, url) => const CircularProgressIndicator(),
    errorWidget: (context, url, error) => const Icon(Icons.error),
    imageBuilder: (context, imageProvider) => CircleAvatar(
      backgroundImage: imageProvider,
    ),
  );
}
```

## الأمان

### حماية البيانات الحساسة

```dart
// تشفير البيانات المحلية
class SecureStorage {
  static Future<void> storeSecurely(String key, String value) async {
    final encrypted = SecurityService.encrypt(value);
    await StorageService.write(key, encrypted);
  }
  
  static Future<String?> getSecurely(String key) async {
    final encrypted = await StorageService.read(key);
    if (encrypted == null) return null;
    
    return SecurityService.decrypt(encrypted);
  }
}
```

### تحقق من الصلاحيات

```dart
// استخدام RolePermissionService
Future<bool> deleteCustomer(String customerId) async {
  // التحقق من الصلاحية
  if (!RolePermissionService.instance.canDeleteCustomers()) {
    EnhancedErrorHandler.reportCustomError(
      title: 'خطأ في الصلاحية',
      message: 'ليس لديك صلاحية حذف العملاء',
      severity: ErrorSeverity.medium,
    );
    return false;
  }
  
  return await _database.deleteDocument(
    collection: 'customers',
    documentId: customerId,
    softDelete: true, // حذف ناعم للأمان
  );
}
```

## Git Workflow

### هيكل الفروع

- `main`: الفرع الرئيسي (الإنتاج)
- `develop`: فرع التطوير
- `feature/feature-name`: فروع الميزات
- `hotfix/fix-name`: إصلاحات عاجلة

### رسائل الالتزام (Commit Messages)

```
feat: إضافة ميزة جديدة
fix: إصلاح خطأ في تسجيل الدخول
refactor: إعادة هيكلة خدمة المصادقة
test: إضافة اختبارات للعملاء
docs: تحديث وثائق المشروع
perf: تحسين أداء تحميل القوائم
```

## مراجعة الكود

### قائمة التحقق

- [ ] هل يتبع الكود معايير التسمية؟
- [ ] هل توجد تعليقات واضحة؟
- [ ] هل يحتوي على معالجة شاملة للأخطاء؟
- [ ] هل يتبع مبادئ SOLID؟
- [ ] هل يحتوي على اختبارات مناسبة؟
- [ ] هل يحقق الأداء المطلوب؟
- [ ] هل يتبع معايير الأمان؟

## النشر والإنتاج

### قبل النشر

1. تشغيل جميع الاختبارات
2. مراجعة أداء التطبيق
3. اختبار التطبيق على أجهزة مختلفة
4. مراجعة إعدادات الأمان
5. تحديث رقم الإصدار في pubspec.yaml

### بعد النشر

1. مراقبة الأخطاء في Sentry
2. متابعة إحصائيات الاستخدام
3. جمع ملاحظات المستخدمين
4. تحضير التحديث التالي

---

*هذا الدليل حي ويتم تحديثه بانتظام ليعكس أفضل الممارسات والتطويرات في المشروع.*