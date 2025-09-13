import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'business_owner_home_screen.dart';
import '../../customers/views/customers_screen.dart';
import '../../debts/views/debts_screen.dart';
import '../../payments/views/payments_screen.dart';
import '../../settings/views/business_owner_profile_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/services/employee_service.dart';
import '../../../../app/data/models/employee.dart';

/// الشاشة الرئيسية لمالك المنشأة مع التنقل السفلي
class BusinessOwnerMainScreen extends GetView<BusinessOwnerHomeController> {
  const BusinessOwnerMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentTabIndex.value,
            children: [
              const BusinessOwnerHomeScreen(),
              EmployeeService.instance.hasPermission(Permission.viewCustomers)
                  ? const CustomersScreen()
                  : const SizedBox.shrink(),
              EmployeeService.instance.hasPermission(Permission.viewDebts)
                  ? const DebtsScreen()
                  : const SizedBox.shrink(),
              EmployeeService.instance.hasPermission(Permission.viewPayments)
                  ? const PaymentsScreen()
                  : const SizedBox.shrink(),
              const BusinessOwnerProfileScreen(),
            ],
          )),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Obx(() => BottomNavigationBar(
          currentIndex: controller.currentTabIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: AppTextStyles.caption,
          backgroundColor: Colors.white,
          elevation: 8,
          items: [
            BottomNavigationBarItem(
              icon: Icon(AppIcons.home),
              activeIcon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(AppIcons.home, color: AppColors.primary),
              ),
              label: 'الرئيسية',
            ),
            if (EmployeeService.instance
                .hasPermission(Permission.viewCustomers))
              BottomNavigationBarItem(
                icon: Icon(AppIcons.customers),
                activeIcon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(AppIcons.customers, color: AppColors.primary),
                ),
                label: 'الزبائن',
              ),
            if (EmployeeService.instance.hasPermission(Permission.viewDebts))
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    Icon(AppIcons.debts),
                    // عدد الديون المعلقة
                    Obx(() {
                      final pendingCount = controller.pendingDebtsCount.value;
                      if (pendingCount > 0) {
                        return Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              pendingCount > 99
                                  ? '99+'
                                  : pendingCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Icon(AppIcons.debts, color: AppColors.primary),
                      // عدد الديون المعلقة للأيقونة النشطة
                      Obx(() {
                        final pendingCount = controller.pendingDebtsCount.value;
                        if (pendingCount > 0) {
                          return Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                pendingCount > 99
                                    ? '99+'
                                    : pendingCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
                label: 'الديون',
              ),
            if (EmployeeService.instance.hasPermission(Permission.viewPayments))
              BottomNavigationBarItem(
                icon: Icon(AppIcons.payments),
                activeIcon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(AppIcons.payments, color: AppColors.primary),
                ),
                label: 'المدفوعات',
              ),
            BottomNavigationBarItem(
              icon: Icon(AppIcons.profile),
              activeIcon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(AppIcons.profile, color: AppColors.primary),
              ),
              label: 'الملف الشخصي',
            ),
          ],
        ));
  }
}

/// ثوابت التنقل لمالك المنشأة
class BusinessOwnerNavigationConstants {
  static const List<BusinessOwnerTabItem> navigationTabs = [
    BusinessOwnerTabItem(
      index: 0,
      title: 'الرئيسية',
      icon: AppIcons.home,
      route: '/business-owner/home',
    ),
    BusinessOwnerTabItem(
      index: 1,
      title: 'الزبائن',
      icon: AppIcons.customers,
      route: '/business-owner/customers',
    ),
    BusinessOwnerTabItem(
      index: 2,
      title: 'الديون',
      icon: AppIcons.debts,
      route: '/business-owner/debts',
    ),
    BusinessOwnerTabItem(
      index: 3,
      title: 'المدفوعات',
      icon: AppIcons.payments,
      route: '/business-owner/payments',
    ),
    BusinessOwnerTabItem(
      index: 4,
      title: 'الملف الشخصي',
      icon: AppIcons.profile,
      route: '/profile',
    ),
  ];
}

/// عنصر تبويب مالك المنشأة
class BusinessOwnerTabItem {
  final int index;
  final String title;
  final IconData icon;
  final String route;

  const BusinessOwnerTabItem({
    required this.index,
    required this.title,
    required this.icon,
    required this.route,
  });
}
