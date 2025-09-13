import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../data/models/employee.dart';

class EmployeeProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final BiometricService _biometricService = Get.find<BiometricService>();

  // متغيرات الحالة
  final RxBool _isLoading = false.obs;
  final RxBool _isBiometricEnabled = false.obs;
  final Rx<Employee?> _employee = Rx<Employee?>(null);

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isBiometricEnabled => _isBiometricEnabled.value;
  Employee? get employee => _employee.value;

  @override
  void onInit() {
    super.onInit();
    _loadEmployeeData();
    _checkBiometricStatus();
  }

  // تحميل بيانات الموظف
  Future<void> _loadEmployeeData() async {
    try {
      _isLoading.value = true;

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        LoggerService.warning('المستخدم غير مسجل الدخول');
        return;
      }

      // البحث عن بيانات الموظف
      final employeeDoc =
          await _firestoreService.getEmployeeByUniqueId(currentUser.uniqueId);
      if (employeeDoc != null) {
        _employee.value =
            Employee.fromJson(employeeDoc.data() as Map<String, dynamic>);
        LoggerService.info('تم تحميل بيانات الموظف: ${_employee.value?.name}');
      } else {
        LoggerService.warning('لم يتم العثور على بيانات الموظف');
      }
    } catch (e, st) {
      LoggerService.error('خطأ في تحميل بيانات الموظف',
          error: e, stackTrace: st);
      Get.snackbar(
        'خطأ',
        'فشل في تحميل بيانات الموظف',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // التحقق من حالة البصمة
  Future<void> _checkBiometricStatus() async {
    try {
      final isEnabled = await _biometricService.isBiometricEnabled();
      _isBiometricEnabled.value = isEnabled;
    } catch (e, st) {
      LoggerService.error('خطأ في التحقق من حالة البصمة',
          error: e, stackTrace: st);
    }
  }

  // تحديث حقل معين
  Future<void> updateField(String field, String value) async {
    try {
      _isLoading.value = true;

      if (_employee.value == null) {
        Get.snackbar(
          'خطأ',
          'لم يتم العثور على بيانات الموظف',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return;
      }

      // التحقق من صحة البيانات
      if (field == 'email' && value.isNotEmpty) {
        if (!_isValidEmail(value)) {
          Get.snackbar(
            'خطأ',
            'البريد الإلكتروني غير صحيح',
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
          return;
        }
      }

      if (field == 'phone' && value.isNotEmpty) {
        if (!_isValidPhone(value)) {
          Get.snackbar(
            'خطأ',
            'رقم الهاتف غير صحيح',
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
          return;
        }
      }

      // تحديث البيانات في Firestore
      final updateData = <String, dynamic>{
        field: value.isEmpty ? null : value,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // الحصول على معرف المالك من الموظف
      final businessOwnerId = _employee.value!.businessOwnerId;
      await _firestoreService.updateDoc(
        _firestoreService
            .employeesCol(businessOwnerId)
            .doc(_employee.value!.id),
        updateData,
      );

      // تحديث البيانات المحلية
      _employee.value = _employee.value!.copyWith(
        name: field == 'name' ? value : _employee.value!.name,
        email: field == 'email'
            ? (value.isEmpty ? null : value)
            : _employee.value!.email,
        phone: field == 'phone'
            ? (value.isEmpty ? null : value)
            : _employee.value!.phone,
        updatedAt: DateTime.now(),
      );

      Get.snackbar(
        'نجح',
        'تم تحديث البيانات بنجاح',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e, st) {
      LoggerService.error('خطأ في تحديث البيانات', error: e, stackTrace: st);
      Get.snackbar(
        'خطأ',
        'فشل في تحديث البيانات',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // تغيير كلمة المرور
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      _isLoading.value = true;

      if (newPassword.length < 6) {
        Get.snackbar(
          'خطأ',
          'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return;
      }

      final success =
          await _authService.updatePassword(currentPassword, newPassword);
      if (success) {
        Get.snackbar(
          'نجح',
          'تم تغيير كلمة المرور بنجاح',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'خطأ',
          _authService.errorMessage ?? 'فشل في تغيير كلمة المرور',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } catch (e, st) {
      LoggerService.error('خطأ في تغيير كلمة المرور', error: e, stackTrace: st);
      Get.snackbar(
        'خطأ',
        'فشل في تغيير كلمة المرور',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // إضافة بريد إلكتروني
  Future<void> addEmail(String email) async {
    try {
      _isLoading.value = true;

      if (!_isValidEmail(email)) {
        Get.snackbar(
          'خطأ',
          'البريد الإلكتروني غير صحيح',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return;
      }

      if (_employee.value == null) {
        Get.snackbar(
          'خطأ',
          'لم يتم العثور على بيانات الموظف',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return;
      }

      // إرسال رابط التحقق
      final success =
          await _authService.addEmailToCustomer(_employee.value!.id, email);
      if (success) {
        Get.snackbar(
          'نجح',
          'تم إرسال رابط التحقق للبريد الإلكتروني',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'خطأ',
          _authService.errorMessage ?? 'فشل في إضافة البريد الإلكتروني',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } catch (e, st) {
      LoggerService.error('خطأ في إضافة البريد الإلكتروني',
          error: e, stackTrace: st);
      Get.snackbar(
        'خطأ',
        'فشل في إضافة البريد الإلكتروني',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // تفعيل البصمة
  Future<void> enableBiometric() async {
    try {
      _isLoading.value = true;

      final success = await _biometricService.enableBiometric();
      if (success) {
        _isBiometricEnabled.value = true;
        Get.snackbar(
          'نجح',
          'تم تفعيل البصمة بنجاح',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في تفعيل البصمة',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } catch (e, st) {
      LoggerService.error('خطأ في تفعيل البصمة', error: e, stackTrace: st);
      Get.snackbar(
        'خطأ',
        'فشل في تفعيل البصمة',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // إلغاء تفعيل البصمة
  Future<void> disableBiometric() async {
    try {
      _isLoading.value = true;

      final success = await _biometricService.disableBiometric();
      if (success) {
        _isBiometricEnabled.value = false;
        Get.snackbar(
          'نجح',
          'تم إلغاء تفعيل البصمة بنجاح',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في إلغاء تفعيل البصمة',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } catch (e, st) {
      LoggerService.error('خطأ في إلغاء تفعيل البصمة',
          error: e, stackTrace: st);
      Get.snackbar(
        'خطأ',
        'فشل في إلغاء تفعيل البصمة',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    try {
      _isLoading.value = true;
      await _authService.signOut();
      Get.offAllNamed('/login');
    } catch (e, st) {
      LoggerService.error('خطأ في تسجيل الخروج', error: e, stackTrace: st);
      Get.snackbar(
        'خطأ',
        'فشل في تسجيل الخروج',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // التحقق من صحة البريد الإلكتروني
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // التحقق من صحة رقم الهاتف
  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone);
  }
}
