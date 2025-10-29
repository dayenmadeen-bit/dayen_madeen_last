# دليل إعداد Firebase الكامل لتطبيق دائن مدين

## الخطوة 1: إنشاء Firebase Project

### 1. الذهاب إلى Firebase Console
- انتقل إلى [Firebase Console](https://console.firebase.google.com/)
- اضغط "Create a project" أو "إضافة مشروع"

### 2. إعداد المشروع
```
Project Name: DayenMadeen-Production
Project ID: dayen-madeen-prod-[random]
Location: us-central1 (أفضل للمنطقة العربية)
```

### 3. تفعيل Google Analytics (اختياري)
- يُفضل تفعيله لمراقبة استخدام التطبيق

---

## الخطوة 2: إضافة تطبيق Android

### 1. اضغط على أيقونة Android في Firebase Console

### 2. إدخال بيانات التطبيق:
```
Android package name: com.dayenmadeen.app
App nickname: دائن مدين
Debug signing certificate SHA-1: (سيتم إضافته لاحقاً)
```

### 3. تحميل google-services.json
- حمل الملف وضعه في: `android/app/google-services.json`
- **مهم جداً**: احرص على وضعه في المكان الصحيح

---

## الخطوة 3: تكوين Android

### 1. تحديث android/build.gradle (Project level):
```gradle
buildscript {
    ext.kotlin_version = '1.9.10'
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.4.0'  // <-- إضافة هذا السطر
    }
}
```

### 2. تحديث android/app/build.gradle:
```gradle
// في بداية الملف
apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply plugin: 'com.google.gms.google-services'  // <-- إضافة هذا السطر

android {
    compileSdk 34
    
    defaultConfig {
        applicationId "com.dayenmadeen.app"  // <-- تحديث المعرف
        minSdk 21
        targetSdk 34
        versionCode 2
        versionName "1.0.1"
        multiDexEnabled true  // <-- إضافة هذا السطر
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-firestore'
    implementation 'com.google.firebase:firebase-messaging'
}
```

### 3. تحديث AndroidManifest.xml:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.dayenmadeen.app">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.USE_BIOMETRIC" />
    <uses-permission android:name="android.permission.USE_FINGERPRINT" />

    <application
        android:label="دائن مدين"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Firebase Messaging -->
        <meta-data
            android:name="firebase_messaging_auto_init_enabled"
            android:value="true" />
        <meta-data
            android:name="firebase_analytics_collection_enabled"
            android:value="true" />
            
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme">
            <!-- ... باقي المحتوى -->
        </activity>
    </application>
</manifest>
```

---

## الخطوة 4: تفعيل خدمات Firebase

### 1. Authentication
- اذهب إلى Authentication > Sign-in method
- فعّل:
  - ✅ Email/Password
  - ✅ Google (اختياري)
  - ✅ Anonymous (للضيوف)

### 2. Cloud Firestore
- اذهب إلى Firestore Database
- اضغط "Create database"
- اختر "Start in test mode" (سنضع قواعد الأمان لاحقاً)
- اختر الموقع: `us-central1`

### 3. Cloud Messaging (للإشعارات)
- سيتم تفعيله تلقائياً مع تفعيل الباقي

---

## الخطوة 5: قواعد الأمان لـ Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // قواعد المستخدمين
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // قواعد العملاء - يجب أن يكون المالك هو المصادق
    match /customers/{document} {
      allow read, write: if request.auth != null &&
        request.auth.uid == resource.data.ownerId;
    }
    
    // قواعد الديون
    match /debts/{document} {
      allow read, write: if request.auth != null &&
        request.auth.uid == resource.data.ownerId;
    }
    
    // قواعد المدفوعات
    match /payments/{document} {
      allow read, write: if request.auth != null &&
        request.auth.uid == resource.data.ownerId;
    }
    
    // قواعد الموظفين
    match /employees/{document} {
      allow read, write: if request.auth != null &&
        request.auth.uid == resource.data.businessOwnerId;
    }
    
    // قواعد الأرقام المميزة
    match /unique_ids/{document} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## الخطوة 6: إنشاء بنية قاعدة البيانات

### Collections المطلوبة:

1. **users** - معلومات المستخدمين
2. **customers** - بيانات العملاء 
3. **debts** - سجلات الديون
4. **payments** - سجلات المدفوعات
5. **employees** - بيانات الموظفين
6. **unique_ids** - الأرقام المميزة المستخدمة
7. **notifications** - الإشعارات
8. **business_settings** - إعدادات المنشآت

---

## الخطوة 7: إعداد Email Verification

### 1. في Firebase Console > Authentication > Templates:
- تخصيص قالب "Email address verification"
- تغيير النص للعربية
- إضافة شعار التطبيق

### 2. تخصيص رابط التحقق:
```
Domain: dayenmadeen-prod.firebaseapp.com
Action URL: https://dayenmadeen-prod.firebaseapp.com/__/auth/action
```

---

## الخطوة 8: إعداد Cloud Messaging

### 1. رفع مفتاح الخادم:
- اذهب إلى Project Settings > Cloud Messaging
- ارفع مفتاح الخادم (Server Key)

### 2. إضافة SHA keys:
```bash
# للحصول على SHA-1 key:
cd android
./gradlew signingReport

# أو باستخدام keytool:
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

---

## الخطوة 9: اختبار الاتصال

### أوامر الاختبار:
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter run --debug
```

### فحص الاتصال:
1. تسجيل حساب جديد
2. التحقق من وصول البريد الإلكتروني
3. تسجيل الدخول
4. إضافة بيانات وهمية
5. فحص ظهور البيانات في Firebase Console

---

## الخطوة 10: النشر الإنتاجي

### 1. إنشاء Release Build:
```bash
flutter build appbundle --release
```

### 2. تحديث قواعد الأمان لوضع الإنتاج:
- تغيير من "test mode" إلى قواعد محكمة
- إضافة validation إضافي

### 3. مراقبة الأداء:
- تفعيل Performance Monitoring
- تفعيل Crashlytics للتقارير

---

## ملاحظات مهمة:

1. **احرص على نسخ احتياطية دورية للبيانات**
2. **راقب usage quota لتجنب رسوم إضافية**
3. **اختبر على أجهزة مختلفة قبل النشر**
4. **احتفظ بمفاتيح التوقيع في مكان آمن**

---

## في حالة المشاكل:

### مشاكل شائعة وحلولها:

**خطأ: "Default FirebaseApp is not initialized"**
- تأكد من استدعاء `await Firebase.initializeApp()` في main()

**خطأ: "google-services.json missing"**
- تأكد من وضع الملف في `android/app/`

**خطأ في Build**
- نظف المشروع: `flutter clean && cd android && ./gradlew clean`

**مشاكل Permissions**
- تأكد من إضافة جميع الـ permissions في AndroidManifest.xml