import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/announcements_banner.dart';
import '../../../../core/services/announcements_service.dart';
import '../../../../app/data/models/employee.dart';
import '../../../../core/services/employee_service.dart';

/// الشاشة الرئيسية لمالك المنشأة
class BusinessOwnerHomeScreen extends GetView<BusinessOwnerHomeController> {
  const BusinessOwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Obx(() => Text(controller.storeDisplayName)),
        centerTitle: true,
        leading: IconButton(
          tooltip: 'تسجيل خروج',
          icon: const Icon(Icons.logout),
          onPressed: () {
            Get.dialog(
              AlertDialog(
                title: const Text('تأكيد'),
                content: const Text('هل تريد العودة إلى صفحة تسجيل الدخول؟'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('لا'),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      Get.offAllNamed('/login');
                    },
                    child: const Text('نعم'),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          IconButton(
            tooltip: 'الإعدادات',
            icon: const Icon(Icons.settings),
            onPressed: () => controller.openSettings(),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: 'الإشعارات',
                icon: const Icon(Icons.notifications),
                onPressed: () => controller.openNotifications(),
              ),
              Obx(() {
                final count = controller.unreadNotificationsCount.value;
                if (count <= 0) return const SizedBox.shrink();
                final display = count > 99 ? '99+' : '$count';
                return Positioned(
                  right: 8,
                  top: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      display,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }),
            ],
          ),
          IconButton(
            tooltip: 'الملف الشخصي',
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed('/profile'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetX<AnnouncementsService>(builder: (svc) {
                return AnnouncementsBanner(
                  announcements: svc.ownerHome,
                );
              }),
              const SizedBox(height: 16),
              _buildWelcomeCard(),
              const SizedBox(height: 20),
              _buildStatsCards(),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 20),
              _buildRecentActivity(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(
                'مرحباً بك, ${controller.currentUser.value?.name ?? ''}!'
                    .trim(),
                style: AppTextStyles.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )),
          const SizedBox(height: 8),
          Text(
            'إدارة أعمالك بسهولة ومرونة',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإحصائيات',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Obx(() => _buildStatCard(
                    'عدد العملاء',
                    controller.totalCustomers.value.toString(),
                    AppIcons.customers,
                    AppColors.success,
                  )),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => _buildStatCard(
                    'ديون هذا الشهر',
                    controller.monthlyDebtCount.value.toString(),
                    AppIcons.debts,
                    AppColors.warning,
                  )),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => _buildStatCard(
                    'مجموع ديون الشهر',
                    '${controller.monthlyDebtAmount.value.toStringAsFixed(0)}',
                    Icons.trending_up,
                    AppColors.warning,
                  )),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Obx(() => _buildStatCard(
                    'مدفوعات هذا الشهر',
                    controller.monthlyPaymentCount.value.toString(),
                    AppIcons.payments,
                    AppColors.info,
                  )),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => _buildStatCard(
                    'إجمالي مدفوعات الشهر',
                    '${controller.monthlyPaymentAmount.value.toStringAsFixed(0)}',
                    Icons.attach_money,
                    AppColors.info,
                  )),
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإجراءات السريعة',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: EmployeeService.instance
                      .hasPermission(Permission.addCustomers)
                  ? _buildActionCard(
                      'إضافة عميل',
                      AppIcons.customers,
                      AppColors.primary,
                      () => Get.toNamed(AppRoutes.addCustomer),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: EmployeeService.instance.hasPermission(Permission.addDebts)
                  ? _buildActionCard(
                      'إضافة دين',
                      AppIcons.debts,
                      AppColors.warning,
                      () => Get.toNamed(AppRoutes.addDebt),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child:
                  EmployeeService.instance.hasPermission(Permission.addPayments)
                      ? _buildActionCard(
                          'إضافة دفعة',
                          AppIcons.payments,
                          AppColors.success,
                          () => Get.toNamed(AppRoutes.addPayment),
                        )
                      : const SizedBox.shrink(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child:
                  EmployeeService.instance.hasPermission(Permission.viewReports)
                      ? _buildActionCard(
                          'التقارير',
                          AppIcons.reports,
                          AppColors.info,
                          () => Get.toNamed(AppRoutes.reports),
                        )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: EmployeeService.instance
                      .hasPermission(Permission.manageEmployees)
                  ? _buildActionCard(
                      'إدارة الموظفين',
                      Icons.group,
                      AppColors.primary,
                      () => controller.viewEmployees(),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'النشاط الأخير',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                AppIcons.activity,
                color: AppColors.textSecondary,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'لا يوجد نشاط حديث',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ستظهر هنا آخر العمليات والأنشطة',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
