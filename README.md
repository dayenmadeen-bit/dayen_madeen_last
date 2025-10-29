# 📊 دائن مدين - نظام إدارة الديون الاحترافي

نظام شامل ومتطور لإدارة الديون والمدفوعات مصمم خصيصاً لأصحاب المنشآت التجارية وعملائهم في العالم العربي.

[![Flutter Version](https://img.shields.io/badge/Flutter-3.24.0%2B-blue.svg)](https://flutter.dev/docs/get-started/install)
[![Dart Version](https://img.shields.io/badge/Dart-3.1.0%2B-blue.svg)](https://dart.dev/get-dart)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)

## 🎆 الميزات الرئيسية

### 👥 إدارة شاملة للمستخدمين
- **أصحاب المنشآت**: إدارة كاملة للمتجر والعمليات
- **الموظفين**: نظام أدوار وصلاحيات متقدم
- **العملاء**: تطبيق مخصص لمتابعة الحسابات

### 💱 إدارة مالية متقدمة
- تسجيل ومتابعة الديون والمدفوعات
- نظام حدود الدين الذكي
- ترارير مفصلة وقابلة للتخصيص
- دعم عملات متعددة (ريال، دولار، إلخ...)

### 🚀 تقنيات حديثة
- **Firebase**: مزامنة فورية للبيانات
- **وضع أوفلاين**: عمل بدون إنترنت
- **أمان متقدم**: مصادقة بيومترية وتشفير
- **إشعارات**: نظام إشعارات ذكي وفوري

### 📊 تقارير وتحليلات
- تقارير يومية وشهرية ومخصصة
- تصدير لـ PDF، Excel، CSV
- طباعة محسنة للفواتير والإيصالات

## 🔧 التحسينات الجديدة (v1.0.1)

### ✨ ما تم تحسينه

#### 💾 قاعدة البيانات
- **إزالة SQLite**: اعتماد كامل على Firebase فقط
- **SimplifiedDatabaseService**: خدمة موحدة ومبسطة لجميع عمليات البيانات
- **حذف ناعم**: حماية أفضل للبيانات الحساسة

#### 🛑 معالجة الأخطاء
- **EnhancedErrorHandler**: نظام شامل لمعالجة وتصنيف الأخطاء
- **تتبع ذكي**: إرسال تلقائي لـ Sentry حسب شدة الخطأ
- **رسائل مخصصة**: رسائل خطأ باللغة العربية واضحة

#### 📋 التبعيات
- **تحديث شامل**: جميع المكتبات محدثة لأحدث إصدار
- **مكتبات جديدة**: CachedNetworkImage، Shimmer، Lottie
- **تحسين الأداء**: معالجة محسنة للصور والرسوم المتحركة

#### 🧪 الاختبارات
- **اختبارات شاملة**: تغطية كاملة للخدمات الحرجة
- **Mock Testing**: اختبارات معزولة عن قاعدة البيانات
- **Mockito**: إطار عمل متقدم للاختبارات

#### 📚 التوثيق
- **دليل أفضل الممارسات**: دليل شامل للتطوير
- **أمثلة عملية**: رموز وأمثلة محدثة
- **معايير الكود**: قواعد واضحة للتطوير

## 📱 متطلبات النظام

### بيئة التطوير
- **Flutter**: 3.24.0 أو أحدث
- **Dart SDK**: 3.1.0 أو أحدث
- **Android Studio / VS Code**: مع إضافات Flutter

### الاعتماديات الخارجية
- **Firebase Project**: مع Firestore و Authentication
- **Sentry Account**: لتتبع الأخطاء (اختياري)

### المنصات المدعومة
- **Android**: 5.0 (API 21) أو أحدث
- **iOS**: 12.0 أو أحدث (قريباً)

## 🚀 التشغيل السريع

### 1. استنساخ المشروع
```bash
git clone https://github.com/dayenmadeen-bit/dayen_madeen_last.git
cd dayen_madeen_last
```

### 2. تهيئة Flutter
```bash
flutter pub get
flutter pub run build_runner build
```

### 3. إعداد Firebase
1. إنشاء مشروع Firebase جديد
2. تفعيل Authentication و Firestore
3. تحديث `lib/firebase_options.dart` ببيانات مشروعك
4. نسخ ملف `google-services.json` إلى `android/app/`

### 4. تشغيل التطبيق
```bash
flutter run
```

### 5. تشغيل الاختبارات
```bash
flutter test
```

## 📝 بنية المشروع

```
dayen_madeen_last/
├── android/              # إعدادات Android
├── ios/                 # إعدادات iOS
├── lib/                 # كود التطبيق الرئيسي
│   ├── app/             # طبقة التطبيق
│   │   ├── controllers/ # كنترولرات GetX
│   │   ├── data/        # نماذج البيانات
│   │   ├── modules/     # وحدات التطبيق
│   │   ├── routes/      # مسارات التطبيق
│   │   └── widgets/     # واجهات مشتركة
│   └── core/            # العناصر الأساسية
│       ├── constants/   # الثوابت
│       ├── services/    # الخدمات
│       ├── themes/      # الثيمات
│       └── utils/       # الأدوات
├── test/                # الاختبارات
├── assets/              # الأصول (صور، خطوط، إلخ)
├── docs/                # الوثائق
└── pubspec.yaml        # تبعيات المشروع
```

## 📊 أمثلة عملية

### إضافة عميل جديد

```dart
// في CustomerController
Future<void> addCustomer(String name, String email, double debtLimit) async {
  final customer = CustomerModel(
    id: '',
    name: name,
    email: email,
    debtLimit: debtLimit,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  
  final result = await SimplifiedDatabaseService.instance.addDocument(
    collection: 'customers',
    data: customer.toJson(),
  );
  
  if (result != null) {
    Get.snackbar('نجاح', 'تم إضافة العميل بنجاح');
    loadCustomers(); // إعادة تحميل القائمة
  }
}
```

### معالجة الأخطاء

```dart
// استخدام EnhancedErrorHandler
Future<List<DebtModel>> loadDebts() async {
  return await EnhancedErrorHandler.safeExecute(
    operation: () async {
      final result = await SimplifiedDatabaseService.instance.getDocuments(
        collection: 'debts',
        queryBuilder: (query) => query.where('customerId', isEqualTo: customerId),
      );
      
      return result?.docs
          .map((doc) => DebtModel.fromFirestore(doc))
          .toList() ?? [];
    },
    context: 'تحميل قائمة الديون',
    defaultValue: <DebtModel>[],
    severity: ErrorSeverity.medium,
  ) ?? [];
}
```

## 🛡️ الأمان والخصوصية

### حماية البيانات
- **تشفير محلي**: جميع البيانات الحساسة مشفرة
- **Firebase Security Rules**: قواعد أمان متقدمة
- **مصادقة بيومترية**: بصمة الإصبع والوجه

### الالتزام بالمعايير
- **GDPR Ready**: التزام بقوانين حماية البيانات
- **Google Play Policy**: متوافق مع سياسات Google Play
- **معايير أمنية**: اتباع أفضل الممارسات الأمنية

## 💾 قاعدة البيانات

### Firebase Firestore
يعتمد التطبيق على Firebase Firestore كقاعدة بيانات رئيسية مع الميزات التالية:

- **مزامنة فورية**: تحديث فوري عبر جميع الأجهزة
- **وضع أوفلاين**: عمل بدون اتصال إنترنت
- **قابلية توسع**: توسع تلقائي مع زيادة عدد المستخدمين
- **أمان متقدم**: قواعد أمان قوية

### هيكل البيانات

```
Firestore Collections:
├── users/               # بيانات المستخدمين
│   ├── customers/       # عملاء المنشأة
│   ├── employees/       # موظفي المنشأة
│   ├── debts/           # الديون
│   ├── payments/        # المدفوعات
│   └── notifications/   # الإشعارات
├── unique_ids/         # معرفات فريدة
├── announcements/      # الإعلانات
└── purchase_requests/  # طلبات الشراء
```

## 🔧 التطوير والمساهمة

### إعداد بيئة التطوير

1. **Fork المشروع**
2. **إنشاء branch جديد**:
   ```bash
   git checkout -b feature/new-feature-name
   ```
3. **متابعة قواعد الكود**: مراجعة `docs/DEVELOPMENT_BEST_PRACTICES.md`
4. **كتابة الاختبارات**: لأي عملية جديدة
5. **تشغيل الاختبارات**: `flutter test`
6. **Commit و Push**:
   ```bash
   git commit -m "feat: إضافة ميزة جديدة"
   git push origin feature/new-feature-name
   ```
7. **إنشاء Pull Request**

### الإبلاغ عن المشاكل

استخدم [GitHub Issues](https://github.com/dayenmadeen-bit/dayen_madeen_last/issues) ل:
- الإبلاغ عن الأخطاء
- طلب ميزات جديدة
- مناقشة التحسينات

## 📊 إحصائيات المشروع

- **أسطر коد**: ~15,000 سطر
- **الملفات**: ~80 ملف Dart
- **الوحدات**: 12 وحدة رئيسية
- **الخدمات**: 25+ خدمة متخصصة
- **الاختبارات**: 50+ اختبار متنوع

## 🕰️ خارطة الطريق (Roadmap)

### الإصدار التالي (v1.1.0)
- [ ] دعم منصة iOS
- [ ] تطبيق ويب (Web App)
- [ ] API عام للتكامل مع الأنظمة الأخرى
- [ ] تحسينات الأداء والذاكرة

### ميزات مقترحة
- [ ] تطبيق سطح المكتب (Desktop)
- [ ] تكامل مع أنظمة المحاسبة
- [ ] ذكاء اصطناعي للتنبؤات والتحليلات
- [ ] دعم لغات إضافية

## 📞 الدعم والمساعدة

### طرق التواصل
- **GitHub Issues**: [أسئلة تقنية وإبلاغ عن الأخطاء](https://github.com/dayenmadeen-bit/dayen_madeen_last/issues)
- **Email**: dayenmadeen@gmail.com
- **مجتمع المطورين**: [مناقشات GitHub](https://github.com/dayenmadeen-bit/dayen_madeen_last/discussions)

### الموارد المفيدة
- [دليل أفضل الممارسات](docs/DEVELOPMENT_BEST_PRACTICES.md)
- [وثائق Firebase](https://firebase.google.com/docs)
- [وثائق Flutter](https://docs.flutter.dev/)
- [وثائق GetX](https://github.com/jonataslaw/getx)

## 📄 التراخيص والحقوق

هذا المشروع مملوك ومحمي بحقوق المؤلف. جميع الحقوق محفوظة.

الاستخدام التجاري يتطلب ترخيص منفصل. للمزيد من المعلومات، يرجى التواصل معنا.

---

<div align="center">

**مبني بـ ❤️ في اليمن**

المطور بواسطة: **Dayen Madeen Team**

إصدار 1.0.1+2 | 2025

</div>