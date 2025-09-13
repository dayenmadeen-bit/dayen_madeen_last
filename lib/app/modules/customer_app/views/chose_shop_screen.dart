import 'package:dayen_madeen/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../controllers/chose_shop_controller.dart';
import '../../../../app/routes/app_routes.dart';
import '../controllers/customer_app_controller.dart';



class ChoseShopScreen extends GetView<ChoseShopController> {
  const ChoseShopScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child:  Text(
            "قائمة المحلات المشترك فيها",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            // استخدام Get.back() للرجوع إلى الصفحة السابقة
            Get.back();
          },
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: const [
            IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _showLogoutDialog,
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
        // مربع البحث الجديد
        Container(
        decoration: BoxDecoration(
        color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          onChanged: (value) {
            controller.searchText.value = value;
          },
          decoration: InputDecoration(
            hintText: 'ابحث عن اسم المنشأة...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          ),
        ),
      ),
        const SizedBox(height: 20),
        // قائمة المحلات
        Expanded(
            child: Obx(() {
            if (controller.shops.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.filteredShops.isEmpty) {
              return const Center(child: Text('لا توجد نتائج بحث', style: TextStyle(color: AppColors.textSecondary)));
            }
            return GridView.builder(
              itemCount: controller.filteredShops.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
              ),
              itemBuilder: (context, index) {
                final shop = controller.filteredShops[index];
                return InkWell(
                  onTap: () {
                    // الانتقال إلى شاشة لوحة تحكم العميل
                    Get.toNamed(AppRoutes.clientDashboard, arguments: shop);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // صورة المتجر
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            AppIcons.business,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // اسم المتجر (الآن قابل للتمرير)
                        // استخدام Expanded هنا قد يسبب مشاكل، لذا استبدلناه بـ SingleChildScrollView
                        SizedBox(
                          height: 25, // ارتفاع ثابت لضمان عدم تداخل النصوص
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              shop['name'] as String,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // اسم مالك المتجر
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              shop['owner'] as String,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              );
            }

    )
              )
        ]
    )
      )
              );
  }

}

void _showLogoutDialog() {
  Get.dialog(
    AlertDialog(
      title: const Row(
        children: [
          Icon(
            Icons.logout,
            color: AppColors.error,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text('تسجيل الخروج'),
        ],
      ),
      content: const Text(
        'هل أنت متأكد من تسجيل الخروج من التطبيق؟\n\nسيتم إنهاء جلستك الحالية والعودة إلى شاشة تسجيل الدخول.',
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'إلغاء',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            print('🚪 تأكيد تسجيل الخروج من AppBar');
            Get.back(); // إغلاق حوار التأكيد

            // عرض مؤشر التحميل
            Get.dialog(
              WillPopScope(
                onWillPop: () async => false, // منع الإغلاق بالضغط على الخلف
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              barrierDismissible: false,
            );

            try {
              // تأخير قصير لإظهار المؤشر
              await Future.delayed(const Duration(milliseconds: 300));

              print('🔄 بدء عملية تسجيل الخروج من AppBar...');
              await Get.find<ClientAppController>().logout();
              print('✅ انتهت عملية تسجيل الخروج من AppBar');

            } catch (e) {
              print('❌ خطأ في تسجيل الخروج من AppBar: $e');

              // إغلاق مؤشر التحميل في حالة الخطأ
              if (Get.isDialogOpen == true) {
                Get.back();
              }

              // الانتقال لتسجيل الدخول كحل طارئ
              Get.offAllNamed('/login');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child:

          const Text('تسجيل الخروج'),
        ),
      ],
    ),
  );
}
