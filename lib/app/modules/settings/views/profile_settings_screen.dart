import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/offline_action_wrapper.dart';
import '../controllers/settings_controller.dart';

/// شاشة إعدادات الملف الشخصي
class ProfileSettingsScreen extends GetView<SettingsController> {
  const ProfileSettingsScreen({super.key});

  // متغيرات لحفظ القيم المؤقتة
  static String _tempName = '';
  static String _tempEmail = '';
  static String _tempPhone = '';
  static String _tempBusinessName = '';
  static String _tempAddress = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(
            type: LoadingType.circular,
            size: LoadingSize.large,
            message: 'جاري تحميل البيانات...',
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة الملف الشخصي
              _buildProfileImageSection(),

              const SizedBox(height: 32),

              // معلومات أساسية
              _buildBasicInfoSection(),

              const SizedBox(height: 24),

              // معلومات العمل
              _buildBusinessInfoSection(),

              const SizedBox(height: 24),

              // معلومات الاتصال
              _buildContactInfoSection(),

              const SizedBox(height: 32),

              // أزرار الحفظ والإلغاء
              _buildActionButtons(),
            ],
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('الملف الشخصي'),
      actions: [
        OfflineActionWrapper(
          action: 'edit_profile',
          child: TextButton(
            onPressed: _saveProfile,
            child: const Text('حفظ'),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  AppIcons.profile,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    AppIcons.camera,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _changeProfileImage,
            icon: const Icon(AppIcons.camera),
            label: const Text('تغيير الصورة'),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المعلومات الأساسية',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.cardDecoration,
          child: Column(
            children: [
              CustomTextField(
                label: 'الاسم الكامل',
                initialValue: controller.userName.value,
                prefixIcon: AppIcons.profile,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الاسم';
                  }
                  return null;
                },
                onChanged: (value) {
                  _tempName = value;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'البريد الإلكتروني',
                initialValue: controller.userEmail.value,
                prefixIcon: AppIcons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال البريد الإلكتروني';
                  }
                  if (!GetUtils.isEmail(value)) {
                    return 'يرجى إدخال بريد إلكتروني صحيح';
                  }
                  return null;
                },
                onChanged: (value) {
                  _tempEmail = value;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات العمل',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.cardDecoration,
          child: Column(
            children: [
              CustomTextField(
                label: 'اسم المنشأة',
                initialValue: controller.businessName.value,
                prefixIcon: AppIcons.business,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم المنشأة';
                  }
                  return null;
                },
                onChanged: (value) {
                  _tempBusinessName = value;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'نوع النشاط',
                prefixIcon: AppIcons.category,
                hintText: 'مثال: متجر، مطعم، خدمات',
                onChanged: (value) {
                  // يمكن حفظ القيمة في متغير مؤقت
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'العنوان',
                prefixIcon: AppIcons.location,
                maxLines: 2,
                onChanged: (value) {
                  _tempAddress = value;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات الاتصال',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.cardDecoration,
          child: Column(
            children: [
              CustomTextField(
                label: 'رقم الهاتف',
                prefixIcon: AppIcons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      !GetUtils.isPhoneNumber(value)) {
                    return 'يرجى إدخال رقم هاتف صحيح';
                  }
                  return null;
                },
                onChanged: (value) {
                  _tempPhone = value;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'رقم واتساب',
                prefixIcon: AppIcons.whatsapp,
                keyboardType: TextInputType.phone,
                hintText: 'اختياري - للتواصل مع العملاء',
                onChanged: (value) {
                  // يمكن حفظ القيمة في متغير مؤقت
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'الموقع الإلكتروني',
                prefixIcon: AppIcons.web,
                keyboardType: TextInputType.url,
                hintText: 'اختياري',
                onChanged: (value) {
                  // يمكن حفظ القيمة في متغير مؤقت
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OfflineActionButton(
            action: 'edit_profile',
            text: 'حفظ التغييرات',
            onPressed: _saveProfile,
            icon: AppIcons.save,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'إلغاء',
            onPressed: () => Get.back(),
            type: ButtonType.outlined,
          ),
        ),
      ],
    );
  }

  void _changeProfileImage() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'تغيير صورة الملف الشخصي',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: AppIcons.camera,
                  label: 'الكاميرا',
                  onTap: () {
                    Get.back();
                    _pickImageFromCamera();
                  },
                ),
                _buildImageSourceOption(
                  icon: AppIcons.gallery,
                  label: 'المعرض',
                  onTap: () {
                    Get.back();
                    _pickImageFromGallery();
                  },
                ),
                _buildImageSourceOption(
                  icon: AppIcons.delete,
                  label: 'حذف',
                  color: AppColors.error,
                  onTap: () {
                    Get.back();
                    _removeProfileImage();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (color ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color ?? AppColors.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: color ?? AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickImageFromCamera() {
    // سيتم إضافة وظيفة اختيار الصورة من الكاميرا
    Get.snackbar(
      'قريباً',
      'سيتم إضافة وظيفة التقاط الصورة قريباً',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  void _pickImageFromGallery() {
    // سيتم إضافة وظيفة اختيار الصورة من المعرض
    Get.snackbar(
      'قريباً',
      'سيتم إضافة وظيفة اختيار الصورة قريباً',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  void _removeProfileImage() {
    // سيتم إضافة وظيفة حذف الصورة
    Get.snackbar(
      'تم الحذف',
      'تم حذف صورة الملف الشخصي',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  void _saveProfile() async {
    // استخدام القيم الحالية إذا لم يتم تغييرها
    final name = _tempName.isNotEmpty ? _tempName : controller.userName.value;
    final email =
        _tempEmail.isNotEmpty ? _tempEmail : controller.userEmail.value;
    final businessName = _tempBusinessName.isNotEmpty
        ? _tempBusinessName
        : controller.businessName.value;
    final phone = _tempPhone.isNotEmpty ? _tempPhone : null;
    final address = _tempAddress.isNotEmpty ? _tempAddress : null;

    // التحقق من صحة البيانات الأساسية
    if (name.isEmpty) {
      Get.snackbar(
        'خطأ ❌',
        'يرجى إدخال الاسم',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar(
        'خطأ ❌',
        'يرجى إدخال بريد إلكتروني صحيح',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (businessName.isEmpty) {
      Get.snackbar(
        'خطأ ❌',
        'يرجى إدخال اسم المنشأة',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // تحديث البيانات في الكنترولر
    controller.nameController.text = name;
    controller.emailController.text = email;
    controller.businessNameController.text = businessName;
    controller.phoneController.text = phone ?? '';
    controller.addressController.text = address ?? '';

    // حفظ البيانات
    await controller.saveProfile(
      name: name,
      email: email,
      businessName: businessName,
      phone: phone,
      address: address,
    );

    // العودة للشاشة السابقة
    Get.back();
  }
}
