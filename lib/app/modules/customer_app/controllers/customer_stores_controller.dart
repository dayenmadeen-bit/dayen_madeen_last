import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/logger_service.dart';

/// كنترولر شاشة قائمة المحلات للزبون
class CustomerStoresController extends GetxController {
  // Controllers
  final searchController = TextEditingController();

  // حالات التحكم
  var isLoading = true.obs;
  var stores = <Map<String, dynamic>>[].obs;
  var filteredStores = <Map<String, dynamic>>[].obs;

  // الخدمات
  late final FirestoreService _firestoreService;
  late final AuthService _authService;

  @override
  void onInit() {
    super.onInit();
    _firestoreService = Get.find<FirestoreService>();
    _authService = Get.find<AuthService>();
    loadStores();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // تحميل المحلات المرتبطة بالزبون
  Future<void> loadStores() async {
    try {
      isLoading.value = true;

      final currentUser = _authService.currentUser;
      if (currentUser == null) return;

      // البحث عن المحلات المرتبطة بالزبون
      final storesQuery = await _firestoreService
          .usersCol()
          .where('role', isEqualTo: 'businessOwner')
          .get();

      final customerStores = <Map<String, dynamic>>[];

      for (final storeDoc in storesQuery.docs) {
        final storeData = storeDoc.data();

        // التحقق من وجود الزبون في قائمة العملاء
        final customersQuery = await _firestoreService
            .usersCol()
            .doc(storeDoc.id)
            .collection('customers')
            .where('uniqueId', isEqualTo: currentUser.uniqueId)
            .limit(1)
            .get();

        if (customersQuery.docs.isNotEmpty) {
          customerStores.add({
            'id': storeDoc.id,
            'businessName': storeData['businessName'],
            'businessType': storeData['businessType'],
            'businessAddress': storeData['businessAddress'],
            'currency': storeData['currency'],
            'phoneNumber': storeData['phoneNumber'],
            'email': storeData['email'],
          });
        }
      }

      stores.value = customerStores;
      filteredStores.value = customerStores;

      LoggerService.info('تم تحميل ${stores.length} محل للزبون');
    } catch (e, st) {
      LoggerService.error('خطأ في تحميل المحلات', error: e, stackTrace: st);
      Get.snackbar(
        'خطأ',
        'تعذر تحميل المحلات',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // البحث في المحلات
  void onSearchChanged(String query) {
    if (query.isEmpty) {
      filteredStores.value = stores;
    } else {
      filteredStores.value = stores.where((store) {
        final businessName =
            (store['businessName'] ?? '').toString().toLowerCase();
        final businessType =
            (store['businessType'] ?? '').toString().toLowerCase();
        final searchQuery = query.toLowerCase();

        return businessName.contains(searchQuery) ||
            businessType.contains(searchQuery);
      }).toList();
    }
  }

  // اختيار محل
  void selectStore(Map<String, dynamic> store) {
    Get.toNamed('/customer-store-home', arguments: store);
  }

  // الذهاب إلى الإعدادات
  void goToSettings() {
    Get.toNamed('/customer-settings');
  }

  // تسجيل الخروج
  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _authService.signOut();
              Get.offAllNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  // إنشاء حساب جديد
  void createNewAccount() {
    Get.toNamed('/customer-register');
  }
}


