import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/test_data_service.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/offline_action_wrapper.dart';
import '../controllers/settings_controller.dart';
import '../../../../core/services/announcements_service.dart';

/// شاشة الإعدادات الرئيسية
class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(
            type: LoadingType.circular,
            size: LoadingSize.large,
            message: 'جاري تحميل الإعدادات...',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshSettings,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // معلومات المستخدم
                _buildUserInfoSection(),

                const SizedBox(height: 24),

                // إعدادات التطبيق
                _buildAppSettingsSection(),

                const SizedBox(height: 24),

                // إعدادات الحساب
                _buildAccountSettingsSection(),

                const SizedBox(height: 24),

                // إدارة البيانات
                _buildDataSection(),

                const SizedBox(height: 24),

                // معلومات التطبيق
                _buildAppInfoSection(),

                const SizedBox(height: 24),

                // أدوات المطور
                _buildDeveloperToolsSection(),

                const SizedBox(height: 24),

                // إجراءات خطيرة
                _buildDangerousActionsSection(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDeveloperToolsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أدوات المطور',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: AppDecorations.cardDecoration,
          child: Column(
            children: [
              ListTile(
                leading: Icon(AppIcons.update, color: AppColors.primary),
                title: const Text('Seed announcements'),
                subtitle:
                    const Text('إضافة عينات لِلوحة الإعلانات في Firestore'),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: AppColors.textHintLight),
                onTap: () async {
                  try {
                    await Get.find<AnnouncementsService>()
                        .seedSampleAnnouncements();
                    Get.snackbar('نجاح', 'تمت إضافة عينات الإعلانات',
                        snackPosition: SnackPosition.BOTTOM);
                  } catch (e) {
                    Get.snackbar('خطأ', 'فشل في إضافة العينات: $e',
                        snackPosition: SnackPosition.BOTTOM);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('الإعدادات'),
      actions: [
        IconButton(
          icon: const Icon(AppIcons.refresh),
          onPressed: controller.refreshSettings,
        ),
      ],
    );
  }

  Widget _buildUserInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppIcons.profile,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                          controller.userName.value.isNotEmpty
                              ? controller.userName.value
                              : 'اسم المستخدم',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          controller.userEmail.value.isNotEmpty
                              ? controller.userEmail.value
                              : ' رقم الهاتف ',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        )),
                    if (controller.businessName.value.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            controller.businessName.value,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textHintLight,
                            ),
                          )),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(AppIcons.edit),
                onPressed: controller.goToProfileSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إعدادات التطبيق',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: AppDecorations.cardDecoration,
          child: Column(
            children: [
              // الثيم
              Obx(() => _buildSettingsTile(
                    icon: controller.isDarkMode.value
                        ? AppIcons.darkMode
                        : AppIcons.lightMode,
                    title: 'المظهر',
                    subtitle: controller.isDarkMode.value
                        ? 'الوضع الليلي'
                        : 'الوضع النهاري',
                    trailing: Switch(
                      value: controller.isDarkMode.value,
                      onChanged: (_) => controller.toggleTheme(),
                    ),
                    onTap: controller.toggleTheme,
                  )),

              const Divider(height: 1),

              // الإشعارات
              Obx(() => _buildSettingsTile(
                    icon: AppIcons.notifications,
                    title: 'الإشعارات',
                    subtitle: controller.isNotificationsEnabled.value
                        ? 'مفعلة'
                        : 'معطلة',
                    trailing: Switch(
                      value: controller.isNotificationsEnabled.value,
                      onChanged: (_) => controller.toggleNotifications(),
                    ),
                    onTap: controller.goToNotificationSettings,
                  )),

              const Divider(height: 1),

              // المصادقة البيومترية
              Obx(() => _buildSettingsTile(
                    icon: AppIcons.fingerprint,
                    title: 'المصادقة البيومترية لمالك المنشأة',
                    subtitle: controller.isBiometricEnabled.value
                        ? 'مفعلة - تسجيل دخول سريع لمالك المنشأة'
                        : 'معطلة - استخدم البريد وكلمة المرور',
                    trailing: Switch(
                      value: controller.isBiometricEnabled.value,
                      onChanged: (_) => controller.toggleBiometric(),
                    ),
                    onTap: controller.toggleBiometric,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إعدادات الحساب',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: AppDecorations.cardDecoration,
          child: Column(
            children: [
              _buildSettingsTile(
                icon: AppIcons.profile,
                title: 'الملف الشخصي',
                subtitle: 'تعديل المعلومات الشخصية',
                onTap: controller.goToProfileSettings,
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: AppIcons.security,
                title: 'الأمان',
                subtitle: 'كلمة المرور والأمان',
                onTap: controller.goToSecuritySettings,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إدارة البيانات',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: AppDecorations.cardDecoration,
          child: Column(
            children: [
              _buildSettingsTile(
                icon: AppIcons.export,
                title: 'تصدير البيانات',
                subtitle: 'تصدير البيانات كملف',
                onTap: controller.exportData,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات التطبيق',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.cardDecoration,
          child: Column(
            children: [
              _buildInfoRow('الإصدار', controller.appVersion.value),
              const SizedBox(height: 12),
              _buildInfoRow('معرف الجهاز', controller.deviceId.value),
              const SizedBox(height: 12),
              Obx(() => _buildInfoRow(
                  'العملاء', '${controller.totalCustomers.value}')),
              const SizedBox(height: 12),
              Obx(() =>
                  _buildInfoRow('الديون', '${controller.totalDebts.value}')),
              const SizedBox(height: 12),
              Obx(() => _buildInfoRow(
                  'المدفوعات', '${controller.totalPayments.value}')),
              const SizedBox(height: 12),
              Obx(() => _buildInfoRow(
                  'التخزين المستخدم', controller.storageUsed.value)),
              const SizedBox(height: 12),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: AppDecorations.cardDecoration,
          child: Column(
            children: [
              _buildSettingsTile(
                icon: AppIcons.info,
                title: 'حول التطبيق',
                subtitle: 'معلومات التطبيق والمطور',
                onTap: controller.goToAbout,
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: AppIcons.help,
                title: 'المساعدة',
                subtitle: 'الأسئلة الشائعة والدعم',
                onTap: controller.goToHelp,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDangerousActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراءات خطيرة',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 12),
        // قسم البيانات التجريبية
        _buildTestDataSection(),
        const SizedBox(height: 12),
        Container(
          decoration: AppDecorations.cardDecoration.copyWith(
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              OfflineActionWrapper(
                action: 'delete_all_data',
                child: _buildSettingsTile(
                  icon: AppIcons.delete,
                  title: 'مسح جميع البيانات',
                  subtitle: 'حذف جميع البيانات نهائياً',
                  titleColor: AppColors.error,
                  onTap: controller.clearAllData,
                ),
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: AppIcons.logout,
                title: 'تسجيل الخروج',
                subtitle: 'الخروج من الحساب الحالي',
                titleColor: AppColors.error,
                onTap: controller.logout,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'البيانات التجريبية',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: AppDecorations.cardDecoration.copyWith(
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildSettingsTile(
                icon: Icons.add_circle_outline,
                title: 'إضافة بيانات تجريبية',
                subtitle: 'إضافة عملاء وديون ومدفوعات للاختبار',
                titleColor: AppColors.warning,
                onTap: () => _showTestDataDialog(),
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.delete_sweep,
                title: 'مسح البيانات التجريبية',
                subtitle: 'حذف جميع البيانات التجريبية',
                titleColor: AppColors.error,
                onTap: () => _showClearTestDataDialog(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (titleColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: titleColor ?? AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondaryLight,
        ),
      ),
      trailing: trailing ??
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textHintLight,
          ),
      onTap: onTap,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium,
        ),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showTestDataDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('إضافة البيانات التجريبية'),
        content: const Text(
          'هل تريد إضافة بيانات تجريبية للاختبار؟\n\n'
          'سيتم إضافة:\n'
          '• 5 عملاء تجريبيين\n'
          '• 5 ديون تجريبية\n'
          '• 4 مدفوعات تجريبية\n'
          '• 3 موظفين تجريبيين\n'
          '• 3 طلبات تجريبية\n'
          '• إشعارات تجريبية',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _addTestData();
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showClearTestDataDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('مسح البيانات التجريبية'),
        content: const Text(
          'هل تريد مسح جميع البيانات التجريبية؟\n\n'
          'سيتم حذف:\n'
          '• جميع العملاء التجريبيين\n'
          '• جميع الديون التجريبية\n'
          '• جميع المدفوعات التجريبية\n'
          '• جميع الموظفين التجريبيين\n'
          '• جميع الطلبات التجريبية\n'
          '• جميع الإشعارات التجريبية',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _clearTestData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  void _addTestData() async {
    try {
      final testDataService = TestDataService();
      await testDataService.seedTestData();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في إضافة البيانات التجريبية: $e');
    }
  }

  void _clearTestData() async {
    try {
      final testDataService = TestDataService();
      await testDataService.clearTestData();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في مسح البيانات التجريبية: $e');
    }
  }
}

