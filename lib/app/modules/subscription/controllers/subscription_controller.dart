import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/models/subscription.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../routes/app_routes.dart';

class SubscriptionController extends GetxController {
  // البيانات
  var currentSubscription = Rxn<Subscription>();
  var deviceId = ''.obs;
  final availablePlans = <SubscriptionPlan>[].obs;

  // حالات التحكم
  var isLoading = false.obs;
  var isCheckingSubscription = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSubscriptionData();
    _loadDeviceId();
    _loadMockPlans();
  }

  /// تحميل الخطط الوهمية
  void _loadMockPlans() {
    availablePlans.value = [
      SubscriptionPlan(
        id: 'free',
        name: 'الخطة المجانية',
        description: 'للاستخدام الشخصي البسيط',
        price: 0,
        duration: 'مجاناً',
        features: [
          'حتى 10 عملاء',
          'تقارير أساسية',
          'دعم عبر البريد الإلكتروني',
          'تخزين محلي فقط',
        ],
        isPopular: false,
        isActive: true,
        expiryDate: DateTime.now().add(const Duration(days: 365)),
      ),

      SubscriptionPlan(
        id: 'premium',
        name: 'الخطة المميزة',
        description: 'للأعمال الصغيرة والمتوسطة',
        price: 99,
        duration: 'شهرياً',
        features: [
          'عملاء غير محدودين',
          'تقارير متقدمة ورسوم بيانية',
          'نسخ احتياطي تلقائي',
          'دعم فني أولوية',
          'تخصيص الفواتير',
          'تصدير البيانات',
        ],
        isPopular: true,
        isActive: false,
        expiryDate: DateTime.now().add(const Duration(days: 30)),
      ),

      SubscriptionPlan(
        id: 'enterprise',
        name: 'خطة المؤسسات',
        description: 'للشركات الكبيرة والمؤسسات',
        price: 299,
        duration: 'شهرياً',
        features: [
          'جميع ميزات الخطة المميزة',
          'دعم فني 24/7',
          'تعدد المستخدمين',
          'تخصيص كامل للتطبيق',
          'تكامل مع الأنظمة الخارجية',
          'تدريب مخصص',
          'مدير حساب مخصص',
        ],
        isPopular: false,
        isActive: false,
        expiryDate: DateTime.now().add(const Duration(days: 30)),
      ),
    ];
  }

  // تحميل بيانات الاشتراك
  Future<void> _loadSubscriptionData() async {
    try {
      isLoading.value = true;
      
      final deviceIdValue = await DeviceService.getDeviceId();
      final subscription = await LocalStorageService.getSubscriptionByDeviceId(deviceIdValue);
      
      currentSubscription.value = subscription;
      
    } catch (e) {
      print('Error loading subscription data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // تحميل معرف الجهاز
  Future<void> _loadDeviceId() async {
    try {
      final id = await DeviceService.getDeviceId();
      deviceId.value = id;
    } catch (e) {
      print('Error loading device ID: $e');
      deviceId.value = 'غير متاح';
    }
  }

  // نسخ معرف الجهاز
  Future<void> copyDeviceId() async {
    try {
      await Clipboard.setData(ClipboardData(text: deviceId.value));
      _showSuccessMessage('تم نسخ معرف الجهاز');
    } catch (e) {
      _showErrorMessage('فشل في نسخ معرف الجهاز');
    }
  }

  // فحص الاشتراك
  Future<void> checkSubscription() async {
    try {
      isCheckingSubscription.value = true;
      
      // إعادة تحميل بيانات الاشتراك
      await _loadSubscriptionData();
      
      if (currentSubscription.value != null && !currentSubscription.value!.isExpired) {
        // الاشتراك نشط، الانتقال للرئيسية
        _showSuccessMessage('تم تجديد الاشتراك بنجاح');
        Get.offAllNamed(AppRoutes.home);
      } else {
        // الاشتراك ما زال منتهي
        _showErrorMessage('الاشتراك ما زال منتهي الصلاحية');
      }
      
    } catch (e) {
      _showErrorMessage('فشل في فحص الاشتراك');
      print('Error checking subscription: $e');
    } finally {
      isCheckingSubscription.value = false;
    }
  }

  // تجديد الاشتراك
  void renewSubscription() {
    Get.dialog(
      AlertDialog(
        title: const Text('تجديد الاشتراك'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('لتجديد الاشتراك، يرجى التواصل معنا عبر:'),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text('واتساب'),
              subtitle: const Text('+966500000000'),
              onTap: () {
                Get.back();
                contactWhatsApp();
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.blue),
              title: const Text('هاتف'),
              subtitle: const Text('+966500000000'),
              onTap: () {
                Get.back();
                contactPhone();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  // التواصل عبر واتساب
  Future<void> contactWhatsApp() async {
    try {
      final message = _generateContactMessage();
      final encodedMessage = Uri.encodeComponent(message);
      final url = 'https://wa.me/${AppConstants.supportWhatsApp}?text=$encodedMessage';
      
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        _showErrorMessage('فشل في فتح واتساب');
      }
    } catch (e) {
      _showErrorMessage('فشل في فتح واتساب');
      print('Error launching WhatsApp: $e');
    }
  }

  // التواصل عبر الهاتف
  Future<void> contactPhone() async {
    try {
      final url = 'tel:${AppConstants.supportPhone}';
      
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        _showErrorMessage('فشل في فتح تطبيق الهاتف');
      }
    } catch (e) {
      _showErrorMessage('فشل في فتح تطبيق الهاتف');
      print('Error launching phone: $e');
    }
  }

  // التواصل عبر البريد الإلكتروني
  Future<void> contactEmail() async {
    try {
      final subject = Uri.encodeComponent('طلب تجديد اشتراك - ${AppConstants.appName}');
      final body = Uri.encodeComponent(_generateContactMessage());
      final url = 'mailto:${AppConstants.supportEmail}?subject=$subject&body=$body';
      
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        _showErrorMessage('فشل في فتح تطبيق البريد الإلكتروني');
      }
    } catch (e) {
      _showErrorMessage('فشل في فتح تطبيق البريد الإلكتروني');
      print('Error launching email: $e');
    }
  }

  // إنشاء رسالة التواصل
  String _generateContactMessage() {
    final subscription = currentSubscription.value;
    
    return '''
السلام عليكم ورحمة الله وبركاته

أرغب في تجديد اشتراك تطبيق ${AppConstants.appName}

معلومات الجهاز:
- معرف الجهاز: ${deviceId.value}
- نوع الاشتراك الحالي: ${subscription?.planName ?? 'غير محدد'}
- تاريخ انتهاء الاشتراك: ${subscription?.formattedEndDate ?? 'غير محدد'}

يرجى إرسال تفاصيل التجديد والدفع.

شكراً لكم
''';
  }

  // إغلاق التطبيق
  void exitApp() {
    Get.dialog(
      AlertDialog(
        title: const Text('إغلاق التطبيق'),
        content: const Text('هل أنت متأكد من إغلاق التطبيق؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              SystemNavigator.pop();
            },
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  // تحديث الاشتراك محلياً (للاختبار)
  Future<void> updateSubscriptionLocally({
    required int days,
    String planType = 'premium',
  }) async {
    try {
      if (currentSubscription.value != null) {
        final updatedSubscription = currentSubscription.value!.renew(
          days: days,
          newPlanType: planType,
          activatedBy: 'admin',
        );
        
        await LocalStorageService.saveSubscription(updatedSubscription);
        currentSubscription.value = updatedSubscription;
        
        _showSuccessMessage('تم تحديث الاشتراك بنجاح');
      }
    } catch (e) {
      _showErrorMessage('فشل في تحديث الاشتراك');
      print('Error updating subscription: $e');
    }
  }

  // الحصول على معلومات الاشتراك
  Map<String, dynamic> getSubscriptionInfo() {
    final subscription = currentSubscription.value;
    
    return {
      'deviceId': deviceId.value,
      'planName': subscription?.planName ?? 'غير محدد',
      'statusName': subscription?.statusName ?? 'منتهي',
      'endDate': subscription?.formattedEndDate ?? 'غير محدد',
      'daysRemaining': subscription?.daysRemaining ?? 0,
      'isExpired': subscription?.isExpired ?? true,
    };
  }

  // إظهار رسالة نجاح
  void _showSuccessMessage(String message) {
    Get.snackbar(
      'نجح',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  // إظهار رسالة خطأ
  void _showErrorMessage(String message) {
    Get.snackbar(
      'خطأ',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  // إظهار معلومات الاشتراك
  void showSubscriptionInfo() {
    final info = getSubscriptionInfo();
    
    Get.dialog(
      AlertDialog(
        title: const Text('معلومات الاشتراك'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('معرف الجهاز', info['deviceId']),
            _buildInfoRow('نوع الاشتراك', info['planName']),
            _buildInfoRow('الحالة', info['statusName']),
            _buildInfoRow('تاريخ الانتهاء', info['endDate']),
            _buildInfoRow('الأيام المتبقية', '${info['daysRemaining']} يوم'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// الاشتراك في خطة
  Future<void> subscribeToPlan(SubscriptionPlan plan) async {
    try {
      // محاكاة عملية الاشتراك
      Get.dialog(
        AlertDialog(
          title: const Text('تأكيد الاشتراك'),
          content: Text('هل تريد الاشتراك في ${plan.name} بسعر ${plan.price} ر.س/${plan.duration}؟'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back();
                await _processSubscription(plan);
              },
              child: const Text('تأكيد'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء الاشتراك',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// معالجة الاشتراك
  Future<void> _processSubscription(SubscriptionPlan plan) async {
    try {
      // محاكاة معالجة الدفع
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'تم الاشتراك',
        'تم الاشتراك في ${plan.name} بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ في الدفع',
        'حدث خطأ أثناء معالجة الدفع',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    // تنظيف الموارد
    super.onClose();
  }
}

/// نموذج خطة الاشتراك
class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String duration;
  final List<String> features;
  final bool isPopular;
  final bool isActive;
  final DateTime expiryDate;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.features,
    this.isPopular = false,
    this.isActive = false,
    required this.expiryDate,
  });

  SubscriptionPlan copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? duration,
    List<String>? features,
    bool? isPopular,
    bool? isActive,
    DateTime? expiryDate,
  }) {
    return SubscriptionPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      features: features ?? this.features,
      isPopular: isPopular ?? this.isPopular,
      isActive: isActive ?? this.isActive,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}
