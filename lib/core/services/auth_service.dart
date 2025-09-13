import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get/get.dart';
import '../../app/data/models/user.dart' as app_user;
import '../../app/data/models/user_role.dart';
import '../../app/data/models/auth_result.dart';
import 'firestore_service.dart';
import 'unique_id_service.dart';
import 'logger_service.dart';
import 'security_service.dart';
import 'biometric_auth_service.dart';

class AuthService extends GetxService {
  static AuthService get instance => Get.find<AuthService>();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final UniqueIdService _uniqueIdService = Get.find<UniqueIdService>();
  final BiometricAuthService _biometricAuthService =
      Get.find<BiometricAuthService>();

  // متغيرات الحالة
  final Rx<app_user.User?> _currentUser = Rx<app_user.User?>(null);
  final Rx<bool> _isLoading = false.obs;
  final Rx<String?> _errorMessage = Rx<String?>(null);

  // Getters
  app_user.User? get currentUser => _currentUser.value;
  bool get isLoggedIn => _currentUser.value != null;
  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;

  // Stream للاستماع لتغييرات المصادقة
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  @override
  void onInit() {
    super.onInit();
    // الاستماع لتغييرات المصادقة
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // معالجة تغييرات حالة المصادقة
  void _onAuthStateChanged(firebase_auth.User? firebaseUser) async {
    if (firebaseUser != null) {
      await _loadUserData(firebaseUser.uid);
    } else {
      _currentUser.value = null;
    }
  }

  // تحميل بيانات المستخدم من Firestore
  Future<void> _loadUserData(String firebaseUserId) async {
    try {
      final userDoc = await _firestore.usersCol().doc(firebaseUserId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        // ضمان أن يكون معرف النموذج يساوي معرف وثيقة Firestore (UID)
        _currentUser.value =
            app_user.User.fromJson(userData).copyWith(id: userDoc.id);
        await _reconcileUserDoc(userDoc.id, firebaseUserId, userData);
        LoggerService.info(
            'تم تحميل بيانات المستخدم: ${_currentUser.value?.name}');
      } else {
        LoggerService.warning('لم يتم العثور على بيانات المستخدم في Firestore');
        await signOut();
      }
    } catch (e, st) {
      LoggerService.error('خطأ في تحميل بيانات المستخدم',
          error: e, stackTrace: st);
      _errorMessage.value = 'خطأ في تحميل بيانات المستخدم';
    }
  }

  // تحميل بيانات المستخدم من Firestore بالمعرف المباشر
  Future<void> _loadUserDataById(String userId) async {
    try {
      final userDoc = await _firestore.usersCol().doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        _currentUser.value =
            app_user.User.fromJson(userData).copyWith(id: userDoc.id);
        await _reconcileUserDoc(userDoc.id, userId, userData);
        LoggerService.info(
            'تم تحميل بيانات المستخدم: ${_currentUser.value?.name}');
      } else {
        LoggerService.warning('لم يتم العثور على بيانات المستخدم في Firestore');
        await signOut();
      }
    } catch (e, st) {
      LoggerService.error('خطأ في تحميل بيانات المستخدم',
          error: e, stackTrace: st);
      _errorMessage.value = 'خطأ في تحميل بيانات المستخدم';
    }
  }

  // تسجيل دخول بالرقم المميز
  Future<bool> signInWithUniqueId(String uniqueId, String password) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      // البحث عن المستخدم بالرقم المميز
      final userQuery = await _firestore
          .usersCol()
          .where('uniqueId', isEqualTo: uniqueId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        _errorMessage.value = 'الرقم المميز غير صحيح أو غير موجود';
        return false;
      }

      final userDoc = userQuery.docs.first;
      final userData = userDoc.data();
      final email = userData['email'] as String?;

      if (email == null || email.isEmpty) {
        // تسجيل الدخول بالرقم المميز وكلمة المرور مباشرة
        final storedPassword = userData['passwordHash'] as String?;
        if (storedPassword != password) {
          _errorMessage.value = 'كلمة المرور غير صحيحة';
          return false;
        }

        // تحميل بيانات المستخدم
        await _loadUserDataById(userDoc.id);
        LoggerService.success('تم تسجيل الدخول بالرقم المميز: $uniqueId');
        return true;
      }

      // تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _loadUserData(credential.user!.uid);
        LoggerService.success('تم تسجيل الدخول بنجاح بالرقم المميز: $uniqueId');
        return true;
      }

      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e, st) {
      LoggerService.error('خطأ في تسجيل الدخول بالرقم المميز',
          error: e, stackTrace: st);
      _errorMessage.value = 'خطأ في تسجيل الدخول';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // تسجيل دخول بالبريد الإلكتروني
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _loadUserData(credential.user!.uid);
        LoggerService.success(
            'تم تسجيل الدخول بنجاح بالبريد الإلكتروني: $email');
        return true;
      }

      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e, st) {
      LoggerService.error('خطأ في تسجيل الدخول بالبريد الإلكتروني',
          error: e, stackTrace: st);
      _errorMessage.value = 'خطأ في تسجيل الدخول';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // تسجيل مستخدم جديد
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    String? businessName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      // توليد رقم مميز
      final uniqueId = await _uniqueIdService.generateUniqueId();

      // إنشاء حساب Firebase
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // إنشاء بيانات المستخدم
        final user = app_user.User.create(
          uniqueId: uniqueId,
          email: email,
          name: name,
          role: role,
          businessName: businessName,
          metadata: metadata,
        );

        // حفظ بيانات المستخدم في Firestore
        await _firestore.setDoc(
          _firestore.usersCol().doc(credential.user!.uid),
          {
            ...user.toJson(),
            // توحيد الأرقام والمعرّفات: اجعل id و uid يساويان Firebase UID
            'id': credential.user!.uid,
            'uid': credential.user!.uid,
            'isActive': true,
          },
          merge: false,
        );

        // حجز الرقم المميز
        await _uniqueIdService.reserveId(
            uniqueId,
            credential.user!.uid,
            role == UserRole.businessOwner
                ? UniqueIdType.owner
                : role == UserRole.employee
                    ? UniqueIdType.employee
                    : UniqueIdType.customer);

        // تحديث حالة المستخدم الحالي
        _currentUser.value = user.copyWith(id: credential.user!.uid);

        LoggerService.success('تم إنشاء الحساب بنجاح: $uniqueId');
        return true;
      }

      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e, st) {
      LoggerService.error('خطأ في إنشاء الحساب', error: e, stackTrace: st);
      _errorMessage.value = 'خطأ في إنشاء الحساب';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // إصلاح تلقائي لحقول الوثيقة المفقودة التي قد تسبب permission-denied
  Future<void> _reconcileUserDoc(
      String docId, String expectedUid, Map<String, dynamic> data) async {
    try {
      final updates = <String, dynamic>{};
      if (data['uid'] != expectedUid) {
        updates['uid'] = expectedUid;
      }
      if (data['isActive'] == null) {
        updates['isActive'] = true;
      }
      if (updates.isNotEmpty) {
        await _firestore.updateDoc(_firestore.usersCol().doc(docId), updates);
        LoggerService.info('تمت مزامنة حقول وثيقة المستخدم الناقصة');
      }
    } catch (e) {
      LoggerService.warning('فشل تصحيح وثيقة المستخدم تلقائياً: $e');
    }
  }

  // تسجيل خروج
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser.value = null;
      _errorMessage.value = null;
      LoggerService.info('تم تسجيل الخروج بنجاح');
    } catch (e, st) {
      LoggerService.error('خطأ في تسجيل الخروج', error: e, stackTrace: st);
    }
  }

  // تسجيل خروج (alias لـ signOut للتوافق مع الكود القديم)
  Future<void> logout() async {
    await signOut();
  }

  // تسجيل دخول العميل بالرقم المميز
  Future<bool> signInCustomerWithUniqueId(
      String uniqueId, String password) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      // البحث عن العميل بالرقم المميز
      final customerDoc = await _firestore.getCustomerByUniqueId(uniqueId);
      if (customerDoc == null) {
        _errorMessage.value = 'الرقم المميز غير صحيح';
        return false;
      }

      // التحقق من كلمة المرور
      final customerData = customerDoc.data() as Map<String, dynamic>;
      final storedPassword = customerData['password'] as String?;

      if (storedPassword != password) {
        _errorMessage.value = 'كلمة المرور غير صحيحة';
        return false;
      }

      // إنشاء جلسة عميل مؤقتة
      final customer = app_user.User.fromJson(customerData);
      _currentUser.value = customer;

      LoggerService.success('تم تسجيل دخول العميل بالرقم المميز: $uniqueId');
      return true;
    } catch (e, st) {
      LoggerService.error('خطأ في تسجيل دخول العميل بالرقم المميز',
          error: e, stackTrace: st);
      _errorMessage.value = 'خطأ في تسجيل الدخول';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // تسجيل دخول بالبريد الإلكتروني (للتوافق مع الكود القديم)
  Future<AuthResult> loginWithEmail(LoginCredentials credentials) async {
    try {
      final success =
          await signInWithEmail(credentials.email, credentials.password);
      if (success) {
        return AuthResult.success('تم تسجيل الدخول بنجاح');
      } else {
        return AuthResult.failure(_errorMessage.value ?? 'فشل تسجيل الدخول');
      }
    } catch (e) {
      return AuthResult.failure('خطأ في تسجيل الدخول: $e');
    }
  }

  // تسجيل دخول العميل (للتوافق مع الكود القديم)
  Future<AuthResult> loginClient(LoginCredentials credentials) async {
    // نفس منطق loginWithEmail
    return await loginWithEmail(credentials);
  }

  // تسجيل دخول بالبصمة (للتوافق مع الكود القديم)
  Future<AuthResult> loginWithBiometric() async {
    try {
      final securityService = Get.find<SecurityService>();
      final authenticated = await securityService.authenticateWithBiometric();
      if (authenticated) {
        return AuthResult.success('تم تسجيل الدخول بالبصمة بنجاح');
      } else {
        return AuthResult.failure('فشل في تسجيل الدخول بالبصمة');
      }
    } catch (e) {
      return AuthResult.failure('خطأ في تسجيل الدخول بالبصمة: $e');
    }
  }

  // تسجيل الدخول بالبصمة للمالك/الموظف (محسن)
  Future<AuthResult> loginWithBiometricEnhanced(
      {required String userType}) async {
    try {
      final result =
          await _biometricAuthService.loginWithBiometric(userType: userType);
      if (result != null && result['success'] == true) {
        return AuthResult.success(
            'تم تسجيل الدخول بالبصمة: ${result['userType']}');
      } else {
        return AuthResult.failure('فشل في تسجيل الدخول بالبصمة');
      }
    } catch (e) {
      return AuthResult.failure('خطأ في تسجيل الدخول بالبصمة: $e');
    }
  }

  // تسجيل دخول العميل بالبصمة (للتوافق مع الكود القديم)
  Future<AuthResult> loginClientWithBiometric() async {
    try {
      final securityService = Get.find<SecurityService>();
      final authenticated = await securityService.authenticateWithBiometric();
      if (authenticated) {
        return AuthResult.success('تم تسجيل الدخول بالبصمة للعميل بنجاح');
      } else {
        return AuthResult.failure('فشل في تسجيل الدخول بالبصمة للعميل');
      }
    } catch (e) {
      return AuthResult.failure('خطأ في تسجيل الدخول بالبصمة للعميل: $e');
    }
  }

  // تسجيل الدخول بالبصمة للزبون (محسن)
  Future<AuthResult> loginClientWithBiometricEnhanced() async {
    try {
      final result =
          await _biometricAuthService.loginWithBiometric(userType: 'customer');
      if (result != null && result['success'] == true) {
        return AuthResult.success('تم تسجيل الدخول بالبصمة: زبون');
      } else {
        return AuthResult.failure('فشل في تسجيل الدخول بالبصمة للزبون');
      }
    } catch (e) {
      return AuthResult.failure('خطأ في تسجيل الدخول بالبصمة للزبون: $e');
    }
  }

  // إرسال طلب إعادة تعيين كلمة المرور (للتوافق مع الكود القديم)
  Future<AuthResult> sendPasswordReset(String email) async {
    try {
      final success = await resetPasswordByEmail(email);
      if (success) {
        return AuthResult.success('تم إرسال رابط إعادة تعيين كلمة المرور');
      } else {
        return AuthResult.failure(
            _errorMessage.value ?? 'فشل إرسال رابط إعادة تعيين كلمة المرور');
      }
    } catch (e) {
      return AuthResult.failure(
          'خطأ في إرسال رابط إعادة تعيين كلمة المرور: $e');
    }
  }

  // إعادة تعيين كلمة المرور (للتوافق مع الكود القديم)
  Future<AuthResult> resetPassword(PasswordResetData resetData) async {
    try {
      if (!resetData.isValidForReset) {
        return AuthResult.failure('بيانات إعادة تعيين كلمة المرور غير صحيحة');
      }

      // تنفيذ إعادة تعيين كلمة المرور باستخدام الرمز
      try {
        await _auth.confirmPasswordReset(
          code: resetData.email ?? '', // استخدام البريد الإلكتروني كرمز مؤقت
          newPassword: resetData.newPassword ?? '',
        );
        return AuthResult.success('تم إعادة تعيين كلمة المرور بنجاح');
      } catch (e) {
        return AuthResult.failure('فشل في إعادة تعيين كلمة المرور: $e');
      }
    } catch (e) {
      return AuthResult.failure('خطأ في إعادة تعيين كلمة المرور: $e');
    }
  }

  // إعادة تعيين كلمة المرور
  Future<bool> resetPasswordByEmail(String email) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      await _auth.sendPasswordResetEmail(email: email);
      LoggerService.success('تم إرسال رابط إعادة تعيين كلمة المرور');
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e, st) {
      LoggerService.error('خطأ في إعادة تعيين كلمة المرور',
          error: e, stackTrace: st);
      _errorMessage.value = 'خطأ في إعادة تعيين كلمة المرور';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // تحديث كلمة المرور (للتوافق مع الكود القديم)
  Future<bool> updateCurrentUserPassword(
      String currentPassword, String newPassword) async {
    return await updatePassword(currentPassword, newPassword);
  }

  // تحديث كلمة المرور
  Future<bool> updatePassword(
      String currentPassword, String newPassword) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final user = _auth.currentUser;
      if (user == null) {
        _errorMessage.value = 'المستخدم غير مسجل الدخول';
        return false;
      }

      // إعادة المصادقة قبل تحديث كلمة المرور
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      LoggerService.success('تم تحديث كلمة المرور بنجاح');
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e, st) {
      LoggerService.error('خطأ في تحديث كلمة المرور', error: e, stackTrace: st);
      _errorMessage.value = 'خطأ في تحديث كلمة المرور';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // تحديث بيانات المستخدم
  Future<bool> updateUserProfile({
    String? name,
    String? phone,
    String? profileImageUrl,
    String? businessName,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final user = _auth.currentUser;
      if (user == null || _currentUser.value == null) {
        _errorMessage.value = 'المستخدم غير مسجل الدخول';
        return false;
      }

      // تحديث بيانات المستخدم في Firestore
      final updatedUser = _currentUser.value!.updateInfo(
        name: name,
        profileImageUrl: profileImageUrl,
        businessName: businessName,
      );

      await _firestore.updateDoc(
        _firestore.usersCol().doc(user.uid),
        updatedUser.toJson(),
      );

      // تحديث البيانات المحلية
      _currentUser.value = updatedUser;

      LoggerService.success('تم تحديث بيانات المستخدم بنجاح');
      return true;
    } catch (e, st) {
      LoggerService.error('خطأ في تحديث بيانات المستخدم',
          error: e, stackTrace: st);
      _errorMessage.value = 'خطأ في تحديث بيانات المستخدم';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // التحقق من الصلاحية
  bool hasPermission(UserPermission permission) {
    return _currentUser.value?.hasPermission(permission) ?? false;
  }

  // التحقق من إمكانية الوصول لميزة
  bool canAccessFeature(String feature) {
    return _currentUser.value?.canAccessFeature(feature) ?? false;
  }

  // التحقق من الدور
  bool isRole(UserRole role) {
    return _currentUser.value?.role == role;
  }

  // التحقق من صاحب العمل
  bool get isBusinessOwner => isRole(UserRole.businessOwner);

  // التحقق من الموظف
  bool get isEmployee => isRole(UserRole.employee);

  // التحقق من العميل
  bool get isCustomer => isRole(UserRole.customer);

  // معالجة أخطاء Firebase Auth
  void _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        _errorMessage.value = 'المستخدم غير موجود';
        break;
      case 'wrong-password':
        _errorMessage.value = 'كلمة المرور غير صحيحة';
        break;
      case 'email-already-in-use':
        _errorMessage.value = 'البريد الإلكتروني مستخدم بالفعل';
        break;
      case 'weak-password':
        _errorMessage.value = 'كلمة المرور ضعيفة جداً';
        break;
      case 'invalid-email':
        _errorMessage.value = 'البريد الإلكتروني غير صحيح';
        break;
      case 'user-disabled':
        _errorMessage.value = 'الحساب معطل';
        break;
      case 'too-many-requests':
        _errorMessage.value = 'محاولات كثيرة جداً، حاول لاحقاً';
        break;
      case 'network-request-failed':
        _errorMessage.value = 'خطأ في الاتصال بالإنترنت';
        break;
      default:
        _errorMessage.value = 'خطأ في المصادقة: ${e.message}';
    }
    LoggerService.error('خطأ في المصادقة: ${e.code}', error: e);
  }

  // مسح رسالة الخطأ
  void clearError() {
    _errorMessage.value = null;
  }

  // تحديث آخر تسجيل دخول
  Future<void> updateLastLogin() async {
    try {
      final user = _auth.currentUser;
      if (user != null && _currentUser.value != null) {
        final updatedUser = _currentUser.value!.updateLastLogin();
        await _firestore.updateDoc(
          _firestore.usersCol().doc(user.uid),
          {'lastLoginAt': updatedUser.lastLoginAt?.toIso8601String()},
        );
        _currentUser.value = updatedUser;
      }
    } catch (e, st) {
      LoggerService.error('خطأ في تحديث آخر تسجيل دخول',
          error: e, stackTrace: st);
    }
  }

  // ===== التحقق من البريد الإلكتروني =====

  // إرسال رابط التحقق من البريد الإلكتروني
  Future<bool> sendEmailVerification() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final user = _auth.currentUser;
      if (user == null) {
        _errorMessage.value = 'المستخدم غير مسجل الدخول';
        return false;
      }

      if (user.emailVerified) {
        _errorMessage.value = 'البريد الإلكتروني مُتحقق منه بالفعل';
        return false;
      }

      await user.sendEmailVerification();
      LoggerService.success('تم إرسال رابط التحقق من البريد الإلكتروني');
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e, st) {
      LoggerService.error('خطأ في إرسال رابط التحقق من البريد الإلكتروني',
          error: e, stackTrace: st);
      _errorMessage.value = 'خطأ في إرسال رابط التحقق';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // التحقق من حالة التحقق من البريد الإلكتروني
  Future<bool> checkEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // إعادة تحميل بيانات المستخدم للحصول على أحدث حالة
      await user.reload();
      final refreshedUser = _auth.currentUser;

      if (refreshedUser != null) {
        return refreshedUser.emailVerified;
      }

      return false;
    } catch (e, st) {
      LoggerService.error('خطأ في التحقق من حالة البريد الإلكتروني',
          error: e, stackTrace: st);
      return false;
    }
  }

  // إعادة إرسال رابط التحقق من البريد الإلكتروني
  Future<bool> resendEmailVerification() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final user = _auth.currentUser;
      if (user == null) {
        _errorMessage.value = 'المستخدم غير مسجل الدخول';
        return false;
      }

      if (user.emailVerified) {
        _errorMessage.value = 'البريد الإلكتروني مُتحقق منه بالفعل';
        return false;
      }

      // إعادة إرسال رابط التحقق
      await user.sendEmailVerification();
      LoggerService.success('تم إعادة إرسال رابط التحقق من البريد الإلكتروني');
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e, st) {
      LoggerService.error('خطأ في إعادة إرسال رابط التحقق من البريد الإلكتروني',
          error: e, stackTrace: st);
      _errorMessage.value = 'خطأ في إعادة إرسال رابط التحقق';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // التحقق من صحة البريد الإلكتروني
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // تحديث البريد الإلكتروني مع إرسال رابط التحقق
  Future<bool> updateEmailWithVerification(String newEmail) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final user = _auth.currentUser;
      if (user == null) {
        _errorMessage.value = 'المستخدم غير مسجل الدخول';
        return false;
      }

      if (!isValidEmail(newEmail)) {
        _errorMessage.value = 'البريد الإلكتروني غير صحيح';
        return false;
      }

      // تحديث البريد الإلكتروني
      await user.verifyBeforeUpdateEmail(newEmail);

      LoggerService.success('تم إرسال رابط التحقق للبريد الإلكتروني الجديد');
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e, st) {
      LoggerService.error('خطأ في تحديث البريد الإلكتروني',
          error: e, stackTrace: st);
      _errorMessage.value = 'خطأ في تحديث البريد الإلكتروني';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // إضافة البريد الإلكتروني للعميل مع التحقق
  Future<bool> addEmailToCustomer(String customerId, String email) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      if (!isValidEmail(email)) {
        _errorMessage.value = 'البريد الإلكتروني غير صحيح';
        return false;
      }

      // التحقق من عدم استخدام البريد الإلكتروني
      final existingUser = await _auth.fetchSignInMethodsForEmail(email);
      if (existingUser.isNotEmpty) {
        _errorMessage.value = 'البريد الإلكتروني مستخدم بالفعل';
        return false;
      }

      // إنشاء حساب مؤقت للتحقق
      final tempPassword = _generateTempPassword();
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: tempPassword,
      );

      if (credential.user != null) {
        // إرسال رابط التحقق
        await credential.user!.sendEmailVerification();

        // حذف الحساب المؤقت بعد إرسال التحقق
        await credential.user!.delete();

        LoggerService.success('تم إرسال رابط التحقق للبريد الإلكتروني');
        return true;
      }

      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e, st) {
      LoggerService.error('خطأ في إضافة البريد الإلكتروني للعميل',
          error: e, stackTrace: st);
      _errorMessage.value = 'خطأ في إضافة البريد الإلكتروني';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // توليد كلمة مرور مؤقتة
  String _generateTempPassword() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(12, (index) => chars[random % chars.length]).join();
  }

  // التحقق من حالة التحقق من البريد الإلكتروني للمستخدم الحالي
  bool get isEmailVerified {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // الحصول على البريد الإلكتروني للمستخدم الحالي
  String? get currentUserEmail {
    return _auth.currentUser?.email;
  }
}
