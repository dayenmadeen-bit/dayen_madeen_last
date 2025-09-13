import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/offline_action_wrapper.dart';
import '../controllers/settings_controller.dart';

/// شاشة تعديل الملف الشخصي
class EditProfileScreen extends GetView<SettingsController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'تعديل الملف الشخصي',
        showBackButton: true,
      ),
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
              _buildProfileImage(),

              const SizedBox(height: 32),

              // نموذج تعديل البيانات
              _buildEditForm(),

              const SizedBox(height: 32),

              // أزرار الحفظ والإلغاء
              _buildActionButtons(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
              border: Border.all(
                color: AppColors.primary,
                width: 3,
              ),
            ),
            child: Obx(() {
              final profileImage = controller.profileImage.value;
              if (profileImage != null) {
                return ClipOval(
                  child: Image.file(
                    profileImage,
                    fit: BoxFit.cover,
                  ),
                );
              }

              return Icon(
                AppIcons.person,
                size: 60,
                color: AppColors.primary,
              );
            }),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  AppIcons.camera,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: controller.pickProfileImage,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: controller.editProfileFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الاسم الكامل
          CustomTextField(
            controller: controller.nameController,
            label: 'الاسم الكامل',
            hint: 'أدخل اسمك الكامل',
            prefixIcon: AppIcons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الاسم مطلوب';
              }
              if (value.length < 2) {
                return 'الاسم يجب أن يكون أكثر من حرفين';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // البريد الإلكتروني
          CustomTextField(
            controller: controller.emailController,
            label: 'البريد الإلكتروني',
            hint: 'أدخل بريدك الإلكتروني',
            prefixIcon: AppIcons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'البريد الإلكتروني مطلوب';
              }
              if (!GetUtils.isEmail(value)) {
                return 'البريد الإلكتروني غير صحيح';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // رقم الهاتف
          CustomTextField(
            controller: controller.phoneController,
            label: 'رقم الهاتف',
            hint: 'أدخل رقم هاتفك',
            prefixIcon: AppIcons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'رقم الهاتف مطلوب';
              }
              if (!GetUtils.isPhoneNumber(value)) {
                return 'رقم الهاتف غير صحيح';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // اسم المنشأة
          CustomTextField(
            controller: controller.businessNameController,
            label: 'اسم المنشأة',
            hint: 'أدخل اسم منشأتك',
            prefixIcon: AppIcons.business,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'اسم المنشأة مطلوب';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // العنوان
          CustomTextField(
            controller: controller.addressController,
            label: 'العنوان',
            hint: 'أدخل عنوان منشأتك',
            prefixIcon: AppIcons.location,
            maxLines: 3,
          ),

          const SizedBox(height: 16),

          // الوصف
          CustomTextField(
            controller: controller.descriptionController,
            label: 'وصف المنشأة',
            hint: 'أدخل وصفاً مختصراً عن منشأتك',
            prefixIcon: AppIcons.description,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // زر الحفظ
        Obx(() => OfflineActionButton(
              action: 'edit_profile',
              text: 'حفظ التغييرات',
              onPressed:
                  controller.isSaving.value ? null : () => _saveProfile(),
              icon: AppIcons.save,
            )),

        const SizedBox(height: 12),

        // زر الإلغاء
        CustomButton(
          text: 'إلغاء',
          onPressed: () => Get.back(),
          type: ButtonType.outlined,
          icon: AppIcons.cancel,
        ),
      ],
    );
  }

  /// حفظ الملف الشخصي
  Future<void> _saveProfile() async {
    if (!controller.editProfileFormKey.currentState!.validate()) return;

    final name = controller.nameController.text.trim();
    final email = controller.emailController.text.trim();
    final phone = controller.phoneController.text.trim();
    final businessName = controller.businessNameController.text.trim();
    final address = controller.addressController.text.trim();

    await controller.saveProfile(
      name: name,
      email: email,
      businessName: businessName,
      phone: phone.isEmpty ? null : phone,
      address: address.isEmpty ? null : address,
    );
  }
}
