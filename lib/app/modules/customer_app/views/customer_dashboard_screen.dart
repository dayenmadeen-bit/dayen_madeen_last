import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/auth_service.dart';
import '../../../widgets/announcements_banner.dart';
import '../../../../core/services/announcements_service.dart';
import '../controllers/customer_app_controller.dart';
import '../../../controllers/ad_banner_controller.dart';

/// شاشة المحل الرئيسية للزبون
class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  late ClientAppController controller;
  Timer? _greetingTimer;
  Map<String, dynamic>? storeData;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ClientAppController>();
    storeData = Get.arguments as Map<String, dynamic>?;

    // تسجيل AdBannerController
    Get.put(AdBannerController());

    // تحديث التحية كل دقيقة
    _greetingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          // تحديث التحية
        });
      }
    });
  }

  @override
  void dispose() {
    _greetingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          storeData?['businessName'] ?? 'المحل',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // TODO: الانتقال إلى شاشة الإشعارات
            },
            tooltip: 'الإشعارات',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GetX<AnnouncementsService>(builder: (svc) {
                  return AnnouncementsBanner(
                    announcements: svc.customerHome,
                  );
                }),
                const SizedBox(height: 16),
                GetX<AdBannerController>(
                  builder: (adBannerController) => SizedBox(
                    width: double.infinity,
                    height: 150, // الارتفاع المخصص لشريط الإعلانات
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            adBannerController.imagePaths[
                                adBannerController.currentIndex.value],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                // ترحيب بالعميل
                _buildWelcomeSection(),

                const SizedBox(height: 24),

                // بطاقة اسم المستخدم
                _buildUserCard(),

                const SizedBox(height: 24),

                // الملخص المالي
                _buildFinancialSummary(),

                const SizedBox(height: 24),

                // الإجراءات السريعة
                _buildQuickActions(),

                const SizedBox(height: 24),

                // زر طلب كشف حساب
                _buildStatementButton(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWelcomeSection() {
    return Obx(() {
      // الحصول على اسم المستخدم من AuthService بطريقة آمنة
      String userName = 'عزيزي الزبون';
      try {
        final authService = Get.find<AuthService>();
        userName = authService.currentUser?.name ?? 'عزيزي الزبون';
      } catch (e) {
        print('⚠️ خطأ في الحصول على AuthService: $e');
        // محاولة الحصول على الاسم من Controller كبديل
        try {
          final customer = controller.currentClient.value;
          if (customer != null && customer.name.isNotEmpty) {
            userName = customer.name;
          }
        } catch (e2) {
          print('⚠️ خطأ في الحصول على اسم العميل من Controller: $e2');
        }
      }
      final displayName =
          userName.contains(' - ') ? userName.split(' - ')[0] : userName;

      // الحصول على التحية والأيقونة حسب الوقت
      final greetingData = _getTimeBasedGreeting();

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              greetingData['color'] as Color,
              (greetingData['color'] as Color).withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (greetingData['color'] as Color).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // أيقونة الوقت
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  greetingData['icon'] as IconData,
                  color: Colors.white,
                  size: 32,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // التحية الديناميكية
                    Text(
                      greetingData['greeting'] as String,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // اسم المستخدم
                    Text(
                      displayName,
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // الوقت الحالي
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getCurrentTimeString(),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(
              AppIcons.person,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() {
                  final userName =
                      controller.currentClient.value?.name ?? 'عزيزي الزبون';
                  return Text(
                    userName,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الملخص المالي - الشهر الحالي',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'إجمالي الديون',
                      value:
                          '${controller.totalDebts.value.toStringAsFixed(2)} ${storeData?['currency'] ?? 'ر.س'}',
                      icon: Icons.receipt_long,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: 'إجمالي المدفوعات',
                      value:
                          '${controller.totalPayments.value.toStringAsFixed(2)} ${storeData?['currency'] ?? 'ر.س'}',
                      icon: Icons.payment,
                      color: AppColors.success,
                      backgroundColor: AppColors.success.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 16),
          Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'الرصيد المتبقي',
                      value:
                          '${controller.remainingBalance.value.toStringAsFixed(2)} ${storeData?['currency'] ?? 'ر.س'}',
                      icon: Icons.account_balance_wallet,
                      color: controller.remainingBalance.value > 0
                          ? AppColors.warning
                          : AppColors.success,
                      backgroundColor: (controller.remainingBalance.value > 0
                              ? AppColors.warning
                              : AppColors.success)
                          .withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: 'عدد الديون',
                      value: '${controller.pendingDebtsCount.value}',
                      icon: Icons.list_alt,
                      color: AppColors.info,
                      backgroundColor: AppColors.info.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildStatementButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: controller.requestStatement,
        icon: const Icon(Icons.description, color: Colors.white),
        label: const Text(
          'طلب كشف حساب',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // الأيقونة
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),

          const SizedBox(height: 12),

          // القيمة
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // العنوان
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Text(
            'الإجراءات السريعة',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 20),

          // الصف الأول من الأزرار
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  title: 'عرض الديون',
                  icon: Icons.receipt_long,
                  color: AppColors.primary,
                  onTap: () {
                    print(
                        '🔵 النقر على زر عرض الديون - الانتقال إلى التبويب 2');
                    controller.changeTab(2); // الانتقال إلى تبويب الديون
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  title: 'عرض المدفوعات',
                  icon: Icons.payment,
                  color: AppColors.success,
                  onTap: () {
                    print(
                        '🟢 النقر على زر عرض المدفوعات - الانتقال إلى التبويب 3');
                    controller.changeTab(3); // الانتقال إلى تبويب المدفوعات
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // الصف الثاني من الأزرار - طلبات الزبون
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  title: 'طلب دين',
                  icon: Icons.add_circle,
                  color: AppColors.warning,
                  onTap: () {
                    Get.toNamed('/debt-request', arguments: storeData);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  title: 'طلب سداد',
                  icon: Icons.payment,
                  color: AppColors.info,
                  onTap: () {
                    Get.toNamed('/payment-request', arguments: storeData);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
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

  /// الحصول على التحية والأيقونة حسب الوقت الحالي
  Map<String, dynamic> _getTimeBasedGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      // من 5:00 صباحاً إلى 11:59 صباحاً
      return {
        'greeting': 'صباح الخير',
        'icon': Icons.wb_sunny,
        'color': AppColors.warning, // أصفر للصباح
      };
    } else if (hour >= 12 && hour < 17) {
      // من 12:00 ظهراً إلى 4:59 مساءً
      return {
        'greeting': 'مساء الخير',
        'icon': Icons.wb_sunny_outlined,
        'color': AppColors.info, // أزرق للظهيرة
      };
    } else if (hour >= 17 && hour < 22) {
      // من 5:00 مساءً إلى 9:59 مساءً
      return {
        'greeting': 'مساء الخير',
        'icon': Icons.wb_twilight,
        'color': AppColors.primary, // بنفسجي للمساء
      };
    } else {
      // من 10:00 مساءً إلى 4:59 صباحاً
      return {
        'greeting': 'ليلة سعيدة',
        'icon': Icons.nightlight_round,
        'color': AppColors.secondary, // أزرق داكن لليل
      };
    }
  }

  /// الحصول على الوقت الحالي كنص
  String _getCurrentTimeString() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;

    // تحويل إلى نظام 12 ساعة
    String period = hour >= 12 ? 'مساءً' : 'صباحاً';
    int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}
