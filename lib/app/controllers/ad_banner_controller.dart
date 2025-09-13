import 'dart:async';
import 'package:get/get.dart';

class AdBannerController extends GetxController {
  final List<String> imagePaths = [
    'assets/images/ad1.jpg',
    'assets/images/ad2.jpg',
    'assets/images/ad3.jpg',
    // أضف مسارات صورك المحلية هنا
  ];

  var currentIndex = 0.obs;
  late Timer timer;

  @override
  void onInit() {
    super.onInit();
    // بدء المؤقت لتغيير الصورة كل دقيقة
    timer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      if (currentIndex.value < imagePaths.length - 1) {
        currentIndex.value++;
      } else {
        currentIndex.value = 0;
      }
    });
  }

  @override
  void onClose() {
    timer.cancel();
    super.onClose();
  }
}
