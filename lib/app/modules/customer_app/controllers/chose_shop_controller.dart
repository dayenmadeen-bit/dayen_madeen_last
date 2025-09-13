import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ChoseShopController extends GetxController {
  // قائمة المحلات الأساسية
  final RxList<Map<String, String>> shops = <Map<String, String>>[].obs;

  // متغير لتخزين نص البحث
  var searchText = ''.obs;

  // قائمة المحلات المصفاة بناءً على البحث
  var filteredShops = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // جلب البيانات عند تهيئة المتحكم
    fetchShops();

    // مراقبة التغييرات في مربع البحث وتحديث القائمة
    debounce(searchText, (String query) {
      if (query.isEmpty) {
        filteredShops.value = shops;
      } else {
        filteredShops.value = shops.where((shop) {
          final shopName = shop['name'] as String;
          return shopName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    }, time: const Duration(milliseconds: 300));
  }

  void fetchShops() {
    // محاكاة عملية جلب البيانات ببيانات مؤقتة
    Future.delayed(const Duration(seconds: 2), () {
      final fetchedShops = [
        {'id': '1', 'name': 'محل العمار للهدايا', 'owner': 'أحمد العمار'},
        {'id': '2', 'name': 'محل السلام للملابس', 'owner': 'محمد السلام'},
        {'id': '3', 'name': 'محل الرحاب للإلكترونيات', 'owner': 'علي الرحاب'},
        {'id': '4', 'name': 'محل الأحمد للأدوات المنزلية', 'owner': 'يوسف الأحمد'},
        {'id': '5', 'name': 'محل النور للزهور', 'owner': 'فاطمة النور'},
        {'id': '6', 'name': 'محل الخير للعطور', 'owner': 'سارة الخير'},
      ];
      shops.assignAll(fetchedShops);
      // قم بتهيئة القائمة المصفاة بالقائمة الكاملة عند البداية
      filteredShops.assignAll(shops);

      Get.snackbar(
        'تحديث',
        'تم تحميل قائمة المحلات',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    });
  }
}
