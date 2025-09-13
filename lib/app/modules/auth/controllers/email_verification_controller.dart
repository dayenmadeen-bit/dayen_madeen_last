import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../../core/services/logger_service.dart';
import '../../../modules/settings/controllers/settings_controller.dart';
import '../../../../core/services/storage_service.dart';

class EmailVerificationController extends GetxController {
  final RxBool isSending = false.obs;
  final RxBool isChecking = false.obs;
  final RxBool isVerified = false.obs;
  final RxString email = ''.obs;
  final RxString contextTag = ''.obs; // register | change_email | other
  String? onVerifiedRoute;

  late final firebase_auth.FirebaseAuth _auth;

  @override
  void onInit() {
    super.onInit();
    _auth = firebase_auth.FirebaseAuth.instance;
    email.value = _auth.currentUser?.email ?? (Get.arguments?['email'] ?? '');
    contextTag.value = (Get.arguments?['context'] as String?) ?? '';
    onVerifiedRoute = Get.arguments?['onVerifiedRoute'] as String?;

    // إذا كان السياق تغيير بريد وتم تمرير بريد مختلف، حاول تحديث بريد المستخدم وإرسال التحقق
    final passedEmail = Get.arguments?['email'] as String?;
    final currentEmail = _auth.currentUser?.email;
    if (contextTag.value == 'change_email' && passedEmail != null) {
      if (currentEmail == null || currentEmail != passedEmail) {
        _attemptUpdateEmailAndSend(passedEmail);
      }
    }
    _refreshState();
  }

  Future<void> _attemptUpdateEmailAndSend(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateEmail(newEmail);
        await user.sendEmailVerification();
        email.value = newEmail;
      }
    } catch (e) {
      LoggerService.warning('تعذر تحديث البريد/إرسال التحقق: $e');
    }
  }

  Future<void> resend() async {
    try {
      isSending.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      LoggerService.warning('فشل إرسال رابط التحقق: $e');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> check() async {
    try {
      isChecking.value = true;
      await _auth.currentUser?.reload();
      final v = _auth.currentUser?.emailVerified ?? false;
      isVerified.value = v;
      if (v) {
        // في حالة تغيير البريد، قم بتحديث إعدادات التطبيق محلياً
        if (contextTag.value == 'change_email') {
          try {
            final settings = Get.isRegistered<SettingsController>()
                ? Get.find<SettingsController>()
                : null;
            if (settings != null) {
              settings.userEmail.value = email.value;
              await StorageService.setString('user_email', email.value);
            }
          } catch (e) {
            LoggerService.warning('فشل تحديث البريد محلياً بعد التحقق: $e');
          }
        }

        // التوجيه بعد النجاح
        if (onVerifiedRoute != null && onVerifiedRoute!.isNotEmpty) {
          Get.offNamed(onVerifiedRoute!);
        } else {
          Get.back(result: true);
        }
      }
    } catch (e) {
      LoggerService.warning('فشل التحقق من حالة البريد: $e');
    } finally {
      isChecking.value = false;
    }
  }

  void _refreshState() {
    isVerified.value = _auth.currentUser?.emailVerified ?? false;
  }
}
