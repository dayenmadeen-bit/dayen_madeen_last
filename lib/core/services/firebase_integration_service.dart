import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';

import '../../firebase_options.dart';
import '../constants/app_strings.dart';
import '../../app/data/models/user.dart' as app_user;
import '../../app/data/models/business_owner.dart';
import '../../app/data/models/customer.dart';
import '../../app/data/models/debt.dart';
import '../../app/data/models/payment.dart';
import '../../app/data/models/employee.dart';
import 'logger_service.dart';
import 'storage_service.dart';

/// خدمة ربط Firebase المتكاملة - تدير جميع اتصالات Firebase
class FirebaseIntegrationService extends GetxService {
  static FirebaseIntegrationService get instance => Get.find<FirebaseIntegrationService>();

  // Firebase instances
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  late final FirebaseMessaging _messaging;
  late final FirebaseAnalytics _analytics;

  // حالة الاتصال
  final _isInitialized = false.obs;
  final _isOnline = true.obs;
  final _currentUser = Rx<User?>(null);
  final _fcmToken = ''.obs;

  // Getters
  bool get isInitialized => _isInitialized.value;
  bool get isOnline => _isOnline.value;
  User? get currentUser => _currentUser.value;
  String get fcmToken => _fcmToken.value;
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseMessaging get messaging => _messaging;
  FirebaseAnalytics get analytics => _analytics;

  @override
  Future<void> onInit() async {
    super.onInit();
    await initializeFirebase();
  }

  /// تهيئة Firebase كاملة
  Future<void> initializeFirebase() async {
    try {
      LoggerService.info('🔥 بدء تهيئة Firebase...');

      // تهيئة Firebase Core
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // تهيئة الخدمات
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _messaging = FirebaseMessaging.instance;
      _analytics = FirebaseAnalytics.instance;

      // إعداد Firestore للعمل أوفلاين
      await _configureFirestore();

      // إعداد FCM للإشعارات
      await _configureFCM();

      // إعداد Analytics
      await _configureAnalytics();

      // مراقبة حالة المصادقة
      _setupAuthListener();

      // مراقبة حالة الاتصال
      _setupConnectivityListener();

      _isInitialized.value = true;
      LoggerService.success('✅ تم تهيئة Firebase بنجاح');

      // إرسال إحصائية بدء التطبيق
      await _analytics.logAppOpen();

    } catch (e, stackTrace) {
      LoggerService.error('❌ فشل تهيئة Firebase', error: e, stackTrace: stackTrace);
      throw Exception('فشل في تهيئة Firebase: $e');
    }
  }

  /// إعداد Firestore للعمل أوفلاين
  Future<void> _configureFirestore() async {
    try {
      // تفعيل الوضع الأوفلاين
      await _firestore.enablePersistence(
        const PersistenceSettings(synchronizeTabs: true),
      );
      
      // تفعيل الشبكة
      await _firestore.enableNetwork();
      
      LoggerService.success('✅ تم إعداد Firestore للعمل أوفلاين');
    } catch (e) {
      LoggerService.warning('⚠️ لا يمكن تفعيل persistence: $e');
      // الاستمرار بدون الوضع الأوفلاين
    }
  }

  /// إعداد Firebase Cloud Messaging
  Future<void> _configureFCM() async {
    try {
      // طلب إذن الإشعارات
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        announcement: false,
      );

      LoggerService.info('إذن الإشعارات: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // الحصول على FCM Token
        final token = await _messaging.getToken();
        if (token != null) {
          _fcmToken.value = token;
          await _saveFCMTokenToFirestore(token);
          LoggerService.success('✅ تم الحصول على FCM Token');
        }

        // إعداد معالج الرسائل في الخلفية
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        // إعداد معالج الرسائل في المقدمة
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          LoggerService.info('رسالة جديدة في المقدمة: ${message.messageId}');
          _handleForegroundMessage(message);
        });

        // إعداد معالج النقر على الإشعار
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          LoggerService.info('تم النقر على إشعار: ${message.messageId}');
          _handleNotificationClick(message);
        });
      }
    } catch (e) {
      LoggerService.error('❌ خطأ في إعداد FCM', error: e);
    }
  }

  /// إعداد Firebase Analytics
  Future<void> _configureAnalytics() async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(true);
      await _analytics.setUserId(null); // سيتم تعيينه عند تسجيل الدخول
      LoggerService.success('✅ تم إعداد Firebase Analytics');
    } catch (e) {
      LoggerService.error('❌ خطأ في إعداد Analytics', error: e);
    }
  }

  /// إعداد مراقب حالة المصادقة
  void _setupAuthListener() {
    _auth.authStateChanges().listen((User? user) {
      _currentUser.value = user;
      if (user != null) {
        LoggerService.info('✅ المستخدم مسجل الدخول: ${user.uid}');
        _analytics.setUserId(user.uid);
        _syncUserDataOnLogin(user);
      } else {
        LoggerService.info('🚪 المستخدم خارج من التطبيق');
        _analytics.setUserId(null);
      }
    });
  }

  /// إعداد مراقب حالة الاتصال
  void _setupConnectivityListener() {
    _firestore.disableNetwork().then((_) {
      _isOnline.value = false;
      return _firestore.enableNetwork();
    }).then((_) {
      _isOnline.value = true;
    }).catchError((error) {
      LoggerService.warning('مشكلة في مراقبة الاتصال: $error');
    });
  }

  /// حفظ FCM Token في Firestore
  Future<void> _saveFCMTokenToFirestore(String token) async {
    try {
      final user = _currentUser.value;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
          'platform': GetPlatform.operatingSystem,
        });
      }
    } catch (e) {
      LoggerService.warning('لا يمكن حفظ FCM Token: $e');
    }
  }

  /// مزامنة بيانات المستخدم عند تسجيل الدخول
  Future<void> _syncUserDataOnLogin(User user) async {
    try {
      // تحديث معلومات المستخدم الأساسية
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'emailVerified': user.emailVerified,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'fcmToken': _fcmToken.value,
        'platform': GetPlatform.operatingSystem,
        'appVersion': await _getAppVersion(),
      }, SetOptions(merge: true));

      LoggerService.success('✅ تم مزامنة بيانات المستخدم');
    } catch (e) {
      LoggerService.error('خطأ في مزامنة بيانات المستخدم', error: e);
    }
  }

  /// معالج رسائل الخلفية
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    LoggerService.info('معالجة رسالة خلفية: ${message.messageId}');
  }

  /// معالج الرسائل في المقدمة
  void _handleForegroundMessage(RemoteMessage message) {
    // عرض إشعار داخل التطبيق
    if (message.notification != null) {
      Get.snackbar(
        message.notification!.title ?? 'إشعار جديد',
        message.notification!.body ?? '',
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// معالج النقر على الإشعار
  void _handleNotificationClick(RemoteMessage message) {
    final data = message.data;
    if (data.containsKey('route')) {
      Get.toNamed(data['route']);
    }
  }

  /// إرسال إشعار مخصص لمستخدم
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // الحصول على FCM Token للمستخدم
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final fcmToken = userDoc.data()?['fcmToken'] as String?;

      if (fcmToken != null) {
        // إرسال الإشعار عبر Cloud Functions (يحتاج إعداد منفصل)
        await _firestore.collection('notifications').add({
          'userId': userId,
          'title': title,
          'body': body,
          'data': data ?? {},
          'fcmToken': fcmToken,
          'sent': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        LoggerService.success('✅ تم إرسال الإشعار');
      }
    } catch (e) {
      LoggerService.error('خطأ في إرسال الإشعار', error: e);
    }
  }

  /// إرسال بريد تحقق
  Future<bool> sendEmailVerification() async {
    try {
      final user = _currentUser.value;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification(ActionCodeSettings(
          url: 'https://dayenmadeen-ce109.firebaseapp.com/__/auth/action',
          handleCodeInApp: true,
          iOSBundleId: 'com.dayenmadeen.app',
          androidPackageName: 'com.dayenmadeen.app',
          androidInstallApp: true,
          androidMinimumVersion: '21',
        ));
        
        LoggerService.success('✅ تم إرسال بريد التحقق');
        return true;
      }
      return false;
    } catch (e) {
      LoggerService.error('خطأ في إرسال بريد التحقق', error: e);
      return false;
    }
  }

  /// إنشاء حساب جديد مع التحقق
  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    try {
      LoggerService.info('🔐 إنشاء حساب جديد...');
      
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // إرسال بريد التحقق
        await sendEmailVerification();
        
        // حفظ بيانات المستخدم الإضافية
        await _firestore.collection('users').doc(credential.user!.uid).set({
          ...userData,
          'uid': credential.user!.uid,
          'email': email,
          'emailVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'fcmToken': _fcmToken.value,
          'platform': GetPlatform.operatingSystem,
        });

        // تسجيل إحصائية
        await _analytics.logSignUp(signUpMethod: 'email');
        
        LoggerService.success('✅ تم إنشاء الحساب بنجاح');
        return credential;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      LoggerService.error('❌ خطأ في إنشاء الحساب', error: e);
      _handleAuthError(e);
      return null;
    }
  }

  /// تسجيل دخول بالبريد وكلمة المرور
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      LoggerService.info('🔐 تسجيل دخول...');
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // تحديث آخر تسجيل دخول
        await _firestore.collection('users').doc(credential.user!.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
          'fcmToken': _fcmToken.value,
          'platform': GetPlatform.operatingSystem,
        });

        // تسجيل إحصائية
        await _analytics.logLogin(loginMethod: 'email');
        
        LoggerService.success('✅ تم تسجيل الدخول بنجاح');
        return credential;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      LoggerService.error('❌ خطأ في تسجيل الدخول', error: e);
      _handleAuthError(e);
      return null;
    }
  }

  /// تسجيل خروج
  Future<void> signOut() async {
    try {
      // إحصائية تسجيل الخروج
      await _analytics.logEvent(name: 'user_logout');
      
      // تسجيل الخروج
      await _auth.signOut();
      
      // مسح البيانات المحلية
      await StorageService.clearAll();
      
      LoggerService.success('✅ تم تسجيل الخروج');
    } catch (e) {
      LoggerService.error('خطأ في تسجيل الخروج', error: e);
    }
  }

  /// إعادة تعيين كلمة المرور
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: 'https://dayenmadeen-ce109.firebaseapp.com/__/auth/action',
          handleCodeInApp: false,
        ),
      );
      
      LoggerService.success('✅ تم إرسال رابط إعادة تعيين كلمة المرور');
      return true;
    } on FirebaseAuthException catch (e) {
      LoggerService.error('خطأ في إرسال رابط إعادة تعيين كلمة المرور', error: e);
      _handleAuthError(e);
      return false;
    }
  }

  /// إعداد Analytics
  Future<void> _configureAnalytics() async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(true);
      await _analytics.setDefaultEventParameters({
        'app_version': await _getAppVersion(),
        'platform': GetPlatform.operatingSystem,
      });
      
      LoggerService.success('✅ تم إعداد Analytics');
    } catch (e) {
      LoggerService.error('خطأ في إعداد Analytics', error: e);
    }
  }

  /// معالجة أخطاء المصادقة
  void _handleAuthError(FirebaseAuthException e) {
    String message;
    
    switch (e.code) {
      case 'weak-password':
        message = 'كلمة المرور ضعيفة جداً';
        break;
      case 'email-already-in-use':
        message = 'البريد الإلكتروني مستخدم بالفعل';
        break;
      case 'invalid-email':
        message = 'البريد الإلكتروني غير صحيح';
        break;
      case 'user-not-found':
        message = 'المستخدم غير موجود';
        break;
      case 'wrong-password':
        message = 'كلمة المرور خاطئة';
        break;
      case 'user-disabled':
        message = 'الحساب معطل';
        break;
      case 'too-many-requests':
        message = 'محاولات كثيرة، حاول لاحقاً';
        break;
      case 'network-request-failed':
        message = 'خطأ في الاتصال بالإنترنت';
        break;
      default:
        message = 'خطأ غير معروف: ${e.message}';
    }
    
    Get.snackbar(
      'خطأ في المصادقة',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }

  /// الحصول على إصدار التطبيق
  Future<String> _getAppVersion() async {
    try {
      // يمكن استخدام package_info_plus هنا
      return '1.0.1';
    } catch (e) {
      return 'unknown';
    }
  }

  /// تسجيل أحداث مخصصة للتحليلات
  Future<void> logEvent(String eventName, [Map<String, dynamic>? parameters]) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } catch (e) {
      LoggerService.error('خطأ في تسجيل الحدث', error: e);
    }
  }

  /// فحص حالة التحقق من البريد
  Future<bool> checkEmailVerification() async {
    try {
      await _currentUser.value?.reload();
      final user = _auth.currentUser;
      return user?.emailVerified ?? false;
    } catch (e) {
      LoggerService.error('خطأ في فحص التحقق من البريد', error: e);
      return false;
    }
  }

  /// إعداد قواعد الأمان الأساسية
  String get firestoreSecurityRules => '''
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
    
    // قواعد الإشعارات
    match /notifications/{document} {
      allow read, write: if request.auth != null &&
        request.auth.uid == resource.data.userId;
    }
  }
}
''';
}