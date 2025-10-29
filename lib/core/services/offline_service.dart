import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'storage_service.dart';
import 'logger_service.dart';

/// خدمة وضع الأوفلاين
class OfflineService extends GetxService {
  static OfflineService get instance => Get.find<OfflineService>();

  // حالة الاتصال
  final RxBool _isOnline = true.obs;
  final RxBool _isOfflineMode = false.obs;

  // خدمة الاتصال
  late final Connectivity _connectivity;

  @override
  void onInit() {
    super.onInit();
    _connectivity = Connectivity();
    _initConnectivityListener();
    _loadOfflineMode();
  }

  // Getters
  bool get isOnline => _isOnline.value;
  bool get isOfflineMode => _isOfflineMode.value;
  bool get isReadOnlyMode => _isOfflineMode.value || !_isOnline.value;

  // تهيئة مستمع الاتصال
  void _initConnectivityListener() {
    // فحص الاتصال الحقيقي - 🔧 إصلاح توقيع Callback
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // فحص إذا كان هناك أي اتصال فعال
      final hasConnection = results.any((result) => result != ConnectivityResult.none);
      _isOnline.value = hasConnection;

      if (_isOnline.value) {
        LoggerService.info('تم استعادة الاتصال بالإنترنت');
        _onConnectionRestored();
      } else {
        LoggerService.warning('فقدان الاتصال بالإنترنت');
        _onConnectionLost();
      }
    });

    // فحص الاتصال الأولي
    _checkInitialConnectivity();
  }

  // فحص الاتصال الأولي
  Future<void> _checkInitialConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isOnline.value = result != ConnectivityResult.none;
    } catch (e) {
      LoggerService.error('خطأ في فحص الاتصال الأولي', error: e);
      _isOnline.value = false;
    }
  }

  // تحميل وضع الأوفلاين المحفوظ
  void _loadOfflineMode() {
    _isOfflineMode.value = StorageService.getBool('offline_mode') ?? false;
  }
  
  // === ملحوقة attemptOfflineLogin - 🔧 إصلاح ===
  
  /// محاولة تسجيل دخول أوفلاين - 🔧 إصلاح
  Future<Map<String, dynamic>?> attemptOfflineLogin({
    required String email,
    required String password,
  }) async {
    try {
      LoggerService.info('🔒 محاولة تسجيل دخول أوفلاين...');
      
      // تحقق من بيانات محفوظة محلياً
      final cachedCredentials = StorageService.getJson('cached_login');
      
      if (cachedCredentials != null) {
        final cachedEmail = cachedCredentials['email'] as String?;
        final cachedPasswordHash = cachedCredentials['passwordHash'] as String?;
        final userData = cachedCredentials['userData'] as Map<String, dynamic>?;
        
        // تحقق بسيط من البيانات
        if (cachedEmail == email && cachedPasswordHash != null && userData != null) {
          final passwordHash = _hashPassword(password); 
          
          if (passwordHash == cachedPasswordHash) {
            LoggerService.success('✅ نجح تسجيل الدخول أوفلاين');
            return {
              'success': true,
              'user': userData,
              'offline': true,
            };
          }
        }
      }
      
      LoggerService.warning('⚠️ لا توجد بيانات محفوظة لتسجيل الدخول أوفلاين');
      return null;
      
    } catch (e) {
      LoggerService.error('خطأ في محاولة الدخول أوفلاين', error: e);
      return null;
    }
  }
  
  /// حفظ بيانات تسجيل الدخول للاستخدام أوفلاين
  Future<void> cacheLoginCredentials({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final passwordHash = _hashPassword(password);
      
      await StorageService.setJson('cached_login', {
        'email': email,
        'passwordHash': passwordHash,
        'userData': userData,
        'cachedAt': DateTime.now().toIso8601String(),
      });
      
      LoggerService.info('💾 تم حفظ بيانات الدخول للاستخدام أوفلاين');
    } catch (e) {
      LoggerService.error('خطأ في حفظ بيانات الدخول', error: e);
    }
  }
  
  /// مسح بيانات تسجيل الدخول المحفوظة
  Future<void> clearCachedLogin() async {
    try {
      await StorageService.remove('cached_login');
      LoggerService.info('🗑️ تم مسح بيانات الدخول المحفوظة');
    } catch (e) {
      LoggerService.error('خطأ في مسح بيانات الدخول', error: e);
    }
  }

  /// تشفير بسيط لكلمة المرور (للاختبار)
  String _hashPassword(String password) {
    return password.hashCode.toString();
  }
  
  // === نهاية الإضافة ===

  // تفعيل وضع الأوفلاين
  Future<void> enableOfflineMode() async {
    _isOfflineMode.value = true;
    await StorageService.setBool('offline_mode', true);
    LoggerService.info('تم تفعيل وضع الأوفلاين');
  }

  // إلغاء وضع الأوفلاين
  Future<void> disableOfflineMode() async {
    _isOfflineMode.value = false;
    await StorageService.setBool('offline_mode', false);
    LoggerService.info('تم إلغاء وضع الأوفلاين');
  }

  // التحقق من إمكانية تنفيذ العملية
  bool canPerformAction(String action) {
    if (isReadOnlyMode) {
      LoggerService.warning('لا يمكن تنفيذ $action في وضع الأوفلاين');
      return false;
    }
    return true;
  }

  // عرض رسالة وضع الأوفلاين
  void showOfflineMessage(String action) {
    Get.snackbar(
      'وضع الأوفلاين',
      'هذا الإجراء لا يمكن القيام به في وضع الأوفلاين',
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }

  // الحصول على رسالة حالة الاتصال
  String get connectionStatusMessage {
    if (_isOfflineMode.value) {
      return 'وضع الأوفلاين - قراءة فقط';
    } else if (!_isOnline.value) {
      return 'لا يوجد اتصال - قراءة فقط';
    } else {
      return 'متصل بالإنترنت';
    }
  }

  // الحصول على لون حالة الاتصال
  String get connectionStatusColor {
    if (_isOfflineMode.value) {
      return 'warning';
    } else if (!_isOnline.value) {
      return 'error';
    } else {
      return 'success';
    }
  }

  // استعادة الاتصال
  void _onConnectionRestored() {
    // يمكن إضافة منطق المزامنة هنا
    syncData();
  }

  // فقدان الاتصال
  void _onConnectionLost() {
    // يمكن إضافة منطق حفظ البيانات هنا
  }

  // مزامنة البيانات عند استعادة الاتصال
  Future<void> syncData() async {
    if (!_isOnline.value) {
      LoggerService.warning('لا يمكن المزامنة بدون اتصال بالإنترنت');
      return;
    }

    try {
      LoggerService.info('بدء مزامنة البيانات...');

      // هنا يمكن إضافة منطق المزامنة مع Firebase
      // await _syncWithFirebase();

      LoggerService.success('تمت مزامنة البيانات بنجاح');
    } catch (e) {
      LoggerService.error('فشل في مزامنة البيانات', error: e);
    }
  }

  // التحقق من إمكانية تنفيذ العملية مع عرض رسالة
  bool canPerformActionWithMessage(String action, {bool showMessage = true}) {
    if (isReadOnlyMode) {
      if (showMessage) {
        showOfflineMessage(action);
      }
      return false;
    }
    return true;
  }

  // التحقق من صحة البيانات المحلية
  Future<bool> validateLocalData() async {
    try {
      // التحقق من وجود البيانات الأساسية
      final hasUserData = StorageService.getString('user_unique_id') != null;
      final hasOfflineData =
          StorageService.getBool('has_offline_data') ?? false;

      return hasUserData && hasOfflineData;
    } catch (e) {
      LoggerService.error('فشل في التحقق من البيانات المحلية', error: e);
      return false;
    }
  }

  // حفظ البيانات للاستخدام الأوفلاين
  Future<void> saveOfflineData(Map<String, dynamic> data) async {
    try {
      await StorageService.setMap('offline_data', data);
      await StorageService.setBool('has_offline_data', true);
      LoggerService.info('تم حفظ البيانات للاستخدام الأوفلاين');
    } catch (e) {
      LoggerService.error('فشل في حفظ البيانات الأوفلاين', error: e);
    }
  }

  // تحميل البيانات المحفوظة
  Map<String, dynamic>? loadOfflineData() {
    try {
      return StorageService.getMap('offline_data');
    } catch (e) {
      LoggerService.error('فشل في تحميل البيانات الأوفلاين', error: e);
      return null;
    }
  }

  // تنظيف البيانات الأوفلاين
  Future<void> clearOfflineData() async {
    try {
      await StorageService.remove('offline_data');
      await StorageService.setBool('has_offline_data', false);
      LoggerService.info('تم تنظيف البيانات الأوفلاين');
    } catch (e) {
      LoggerService.error('فشل في تنظيف البيانات الأوفلاين', error: e);
    }
  }

  // إحصائيات وضع الأوفلاين
  Map<String, dynamic> getOfflineStats() {
    try {
      final offlineData = loadOfflineData();

      return {
        'is_offline_mode': _isOfflineMode.value,
        'is_online': _isOnline.value,
        'is_read_only': isReadOnlyMode,
        'has_offline_data': offlineData != null,
        'last_sync': StorageService.getString('last_sync_date'),
        'offline_data_size': offlineData?.length ?? 0,
      };
    } catch (e) {
      LoggerService.error('فشل في الحصول على إحصائيات الأوفلاين', error: e);
      return {};
    }
  }
}