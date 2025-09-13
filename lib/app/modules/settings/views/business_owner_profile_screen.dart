import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_button.dart';
import '../../../../core/services/auth_service.dart';
import '../../../routes/app_routes.dart';

/// شاشة الملف الشخصي لمالك المنشأة
class BusinessOwnerProfileScreen extends GetView<SettingsController> {
  const BusinessOwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'الملف الشخصي',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildProfileInfo(),
            const SizedBox(height: 24),
            _buildBusinessInfo(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildSettingsOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = AuthService.instance.currentUser;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // صورة المستخدم
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              AppIcons.business,
              size: 40,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // اسم المستخدم
          Text(
            user?.name ?? '—',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if ((user?.uniqueId ?? '').isNotEmpty) ...[
            Text(
              'الرقم المميز: ${user!.uniqueId}',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
          ],

          const SizedBox(height: 4),

          // نوع الحساب
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'مالك المنشأة',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    final user = AuthService.instance.currentUser;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المعلومات الشخصية',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if ((user?.email ?? '').isNotEmpty)
              _buildInfoRow('البريد الإلكتروني', user!.email!, AppIcons.email),
            if (user?.createdAt != null)
              _buildInfoRow('تاريخ الانضمام', _formatDate(user!.createdAt),
                  AppIcons.calendar),
            if (user?.lastLoginAt != null)
              _buildInfoRow('آخر تسجيل دخول', _formatDate(user!.lastLoginAt!),
                  AppIcons.time),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessInfo() {
    final user = AuthService.instance.currentUser;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات المنشأة',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if ((user?.businessName ?? '').isNotEmpty)
              _buildInfoRow(
                  'اسم المنشأة', user!.businessName!, AppIcons.business),
            if ((user?.metadata?['businessType'] ?? '').toString().isNotEmpty)
              _buildInfoRow('نوع النشاط', user!.metadata!['businessType'],
                  AppIcons.category),
            if ((user?.metadata?['businessAddress'] ?? '')
                .toString()
                .isNotEmpty)
              _buildInfoRow('العنوان', user!.metadata!['businessAddress'],
                  AppIcons.location),
            _buildInfoRow('الاشتراك', _formatSubscriptionRemaining(user),
                AppIcons.subscription),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إجراءات سريعة',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'تعديل الملف',
                    AppIcons.edit,
                    AppColors.primary,
                    () => Get.toNamed(AppRoutes.editProfile),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'تغيير كلمة المرور',
                    AppIcons.security,
                    AppColors.warning,
                    () => Get.toNamed(AppRoutes.changePassword),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOptions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildSettingsTile(
            'الإعدادات العامة',
            'إدارة إعدادات التطبيق',
            AppIcons.settings,
            () => Get.toNamed(AppRoutes.settings),
          ),
          _buildSettingsTile(
            'الإشعارات',
            'عرض الإشعارات والتنبيهات',
            AppIcons.notification,
            () => Get.toNamed(AppRoutes.businessOwnerNotifications),
          ),
          _buildSettingsTile(
            'المساعدة والدعم',
            'الحصول على المساعدة',
            AppIcons.help,
            () => Get.toNamed(AppRoutes.help),
          ),
          _buildSettingsTile(
            'تسجيل الخروج',
            'الخروج من الحساب',
            AppIcons.logout,
            _showLogoutDialog,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return CustomButton(
      text: title,
      onPressed: onTap,
      backgroundColor: color.withValues(alpha: 0.1),
      textColor: color,
      icon: icon,
      height: 48,
    );
  }

  Widget _buildSettingsTile(
      String title, String subtitle, IconData icon, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isDestructive ? AppColors.error : AppColors.primary)
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          color: isDestructive ? AppColors.error : null,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج من الحساب؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatSubscriptionRemaining(final user) {
    try {
      final meta = user?.metadata as Map<String, dynamic>?;
      final expiryStr = meta?['subscriptionExpiry'] as String?;
      final trialStr = meta?['trialEndsAt'] as String?;
      final now = DateTime.now();
      DateTime? expiry;
      if (expiryStr != null && expiryStr.isNotEmpty) {
        expiry = DateTime.tryParse(expiryStr);
      } else if (trialStr != null && trialStr.isNotEmpty) {
        expiry = DateTime.tryParse(trialStr);
      }
      if (expiry == null) return 'غير محدد';
      final diff = expiry.difference(now);
      if (diff.isNegative) return 'انتهى';
      final days = diff.inDays;
      final hours = diff.inHours % 24;
      if (days > 0)
        return 'متبقي: $days يوم ${hours > 0 ? 'و $hours ساعة' : ''}';
      final mins = diff.inMinutes % 60;
      if (hours > 0)
        return 'متبقي: $hours ساعة ${mins > 0 ? 'و $mins دقيقة' : ''}';
      return 'متبقي: ${diff.inMinutes} دقيقة';
    } catch (_) {
      return 'غير محدد';
    }
  }
}
