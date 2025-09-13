import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/client_constants.dart';
import '../controllers/customer_app_controller.dart';
import 'client_requests_screen.dart';
import 'customer_dashboard_screen.dart';
import 'customer_profile_screen.dart';
import 'simple_debts_screen.dart';
import 'simple_payments_screen.dart';

/// الشاشة الرئيسية لتطبيق الزبون
class ClientMainScreen extends GetView<ClientAppController> {
  const ClientMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('🏠 ClientMainScreen: تم بناء الصفحة الرئيسية للزبون');
    print('📱 التبويب الحالي: ${controller.currentTabIndex.value}');
    return Obx(() => Scaffold(
      body: IndexedStack(
        index: controller.currentTabIndex.value,
        children: const [
          ClientDashboardScreen(),
          ClientRequestsScreen(),
          SimpleDebtsScreen(),
          SimplePaymentsScreen(),
          CustomerProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    ));
  }

  Widget _buildBottomNavigationBar() {
    return Obx(() => BottomNavigationBar(
      currentIndex: controller.currentTabIndex.value,
      onTap: (index) {
        print('👆 تم النقر على التبويب: $index');
        controller.changeTab(index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      backgroundColor: Colors.white,
      elevation: 8,
      items: [
        BottomNavigationBarItem(
          icon: Icon(ClientConstants.navigationTabs[0].icon),
          label: ClientConstants.navigationTabs[0].title,
        ),
        BottomNavigationBarItem(
          icon: Icon(ClientConstants.navigationTabs[1].icon),
          label: ClientConstants.navigationTabs[1].title,
        ),
        BottomNavigationBarItem(
          icon: Icon(ClientConstants.navigationTabs[2].icon),
          label: ClientConstants.navigationTabs[2].title,
        ),
        BottomNavigationBarItem(
          icon: Icon(ClientConstants.navigationTabs[3].icon),
          label: ClientConstants.navigationTabs[3].title,
        ),
        BottomNavigationBarItem(
          icon: Icon(ClientConstants.navigationTabs[4].icon),
          label: ClientConstants.navigationTabs[4].title,
        ),
      ],
    ));
  }
}
