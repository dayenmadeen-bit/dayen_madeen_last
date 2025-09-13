import 'package:dayen_madeen/app/modules/auth/controllers/customer_register_controller.dart';
import 'package:dayen_madeen/app/modules/customer_app/views/Chose_Shop_Screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/auth_service.dart';

import '../modules/auth/controllers/forgot_password_controller.dart';
import '../modules/auth/controllers/login_controller.dart';
import '../modules/auth/controllers/splash_controller.dart';
import '../modules/auth/views/forgot_password_screen.dart';
import '../modules/auth/views/login_screen.dart';
import '../modules/auth/views/business_owner_registration_screen.dart';
import '../modules/auth/controllers/business_owner_registration_controller.dart';
import '../modules/auth/views/email_verification_screen.dart';
import '../modules/auth/controllers/email_verification_controller.dart';
import '../modules/auth/views/customer_register_Screen.dart';
import '../modules/auth/views/customer_registration_screen.dart';
import '../modules/auth/controllers/customer_registration_controller.dart';
// Auth Module
import '../modules/auth/views/splash_screen.dart';
// Support Module
import '../modules/customer_app/controllers/chose_shop_controller.dart';
import '../modules/support/views/contact_support_screen.dart';
import '../modules/support/views/business_owner_support_screen.dart';
// Common Module
import '../modules/common/views/error_screen.dart';
import '../modules/common/views/maintenance_screen.dart';
import '../modules/customer_app/controllers/customer_app_controller.dart';
import '../modules/customer_app/views/client_debts_screen.dart' as client_views;
// Client App Module

import '../modules/customer_app/views/client_main_screen.dart';
import '../modules/customer_app/views/client_payments_screen.dart'
    as client_views;
import '../modules/customer_app/views/client_requests_screen.dart'
    as client_views;
import '../modules/customer_app/views/customer_profile_screen.dart';
import '../modules/customer_app/views/request_debt_screen.dart';
import '../modules/customer_app/views/request_payment_screen.dart';
import '../modules/customer_app/views/customer_stores_screen.dart';
import '../modules/customer_app/views/customer_dashboard_screen.dart';
import '../modules/customer_app/views/customer_settings_screen.dart';
import '../modules/customer_app/views/debt_request_screen.dart';
import '../modules/customer_app/views/payment_request_screen.dart';
import '../modules/customer_app/controllers/customer_stores_controller.dart';
import '../modules/customer_app/controllers/customer_settings_controller.dart';
import '../modules/customer_app/controllers/debt_request_controller.dart';
import '../modules/customer_app/controllers/payment_request_controller.dart';
import '../modules/customers/controllers/customer_import_controller.dart';
import '../modules/customers/controllers/customers_controller.dart';
import '../modules/customers/views/add_customer_screen.dart';
import '../modules/customers/views/customer_details_screen.dart';
import '../modules/customers/views/customer_import_screen.dart';
// Customers Module
import '../modules/customers/views/customers_screen.dart';
import '../modules/customers/views/edit_customer_screen.dart';
import '../modules/debts/controllers/debts_controller.dart';
import '../modules/debts/views/add_debt_screen.dart';
import '../modules/debts/views/debt_details_screen.dart';
// Debts Module
import '../modules/debts/views/debts_screen.dart';
import '../modules/debts/views/edit_debt_screen.dart';
import '../modules/employees/controllers/employees_controller.dart';
import '../modules/employees/views/add_employee_screen.dart';
// import '../modules/employees/views/edit_employee_screen.dart';
import '../modules/employees/views/employee_details_screen.dart';
// Employees Module
import '../modules/employees/views/employees_screen.dart';
import '../modules/home/controllers/client_requests_controller.dart';
import '../modules/home/controllers/home_controller.dart';
import '../modules/home/views/business_owner_main_screen.dart';
// Client Requests Management Module
import '../modules/home/views/client_requests_screen.dart';
// Home Module - Additional
import '../modules/home/views/manage_client_requests_screen.dart';
import '../modules/home/views/all_activity_screen.dart';
import '../modules/notifications/controllers/notifications_controller.dart';
import '../modules/notifications/views/business_owner_notifications_screen.dart';
// Notifications Module
import '../modules/notifications/views/notifications_screen.dart';
import '../modules/payments/controllers/payments_controller.dart';
import '../modules/payments/views/add_payment_screen.dart';
import '../modules/payments/views/edit_payment_screen.dart';
import '../modules/payments/views/payment_details_screen.dart';
// Payments Module
import '../modules/payments/views/payments_screen.dart';
import '../modules/reports/controllers/reports_controller.dart';
import '../modules/reports/views/custom_report_screen.dart';
import '../modules/reports/views/daily_report_screen.dart';
// import '../modules/reports/views/monthly_report_screen.dart'; // تم حذف الملف
// Reports Module
import '../modules/reports/views/reports_screen.dart';
import '../modules/settings/controllers/settings_controller.dart';
import '../modules/settings/views/about_screen.dart';
import '../modules/settings/views/change_password_screen.dart';
import '../modules/settings/views/contact_screen.dart';
import '../modules/settings/views/edit_profile_screen.dart';
import '../modules/settings/views/help_screen.dart';
import '../modules/settings/views/privacy_screen.dart';
import '../modules/settings/views/profile_settings_screen.dart';
import '../modules/settings/views/security_settings_screen.dart';
// Settings Module
import '../modules/settings/views/settings_screen.dart';
import '../modules/settings/views/terms_screen.dart';
import '../modules/subscription/controllers/subscription_controller.dart';
// Subscription Module
import '../modules/subscription/views/subscription_expired_screen.dart';
import '../modules/subscription/views/subscription_screen.dart';
import 'app_routes.dart';

class AppPages {
  static const String initial = AppRoutes.splash;

  static final routes = [
    // ===== مسارات المصادقة =====
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SplashController>(() => SplashController());
      }),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LoginController>(() => LoginController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // GetPage(
    //   name: AppRoutes.register,
    //   page: () => const RegisterScreen(),
    //   binding: BindingsBuilder(() {
    //     Get.lazyPut<RegisterController>(() => RegisterController());
    //   }),
    //   transition: Transition.rightToLeft,
    //   transitionDuration: const Duration(milliseconds: 300),
    // ),

    GetPage(
      name: AppRoutes.businessOwnerRegister,
      page: () => const BusinessOwnerRegistrationScreen(),
      binding: BindingsBuilder(() {
        Get.put<BusinessOwnerRegistrationController>(
            BusinessOwnerRegistrationController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.emailVerification,
      page: () => const EmailVerificationScreen(),
      binding: BindingsBuilder(() {
        Get.put<EmailVerificationController>(EmailVerificationController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.CustomerRegister,
      page: () => const CustomerRegisterScreen(),
      binding: BindingsBuilder(() {
        Get.put<CustomerRegisterController>(CustomerRegisterController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.customerRegistration,
      page: () => const CustomerRegistrationScreen(),
      binding: BindingsBuilder(() {
        Get.put<CustomerRegistrationController>(
            CustomerRegistrationController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.contactSupport,
      page: () => const ContactSupportScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.businessOwnerSupport,
      page: () => const BusinessOwnerSupportScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ===== المسارات الرئيسية =====
    GetPage(
      name: AppRoutes.home,
      page: () => const BusinessOwnerMainScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<BusinessOwnerHomeController>(
            () => BusinessOwnerHomeController());
      }),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ===== مسارات العملاء =====
    GetPage(
      name: AppRoutes.clientShops,
      page: () => const ChoseShopScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ChoseShopController>(() => ChoseShopController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.customers,
      page: () => const CustomersScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CustomersController>(() => CustomersController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.addCustomer,
      page: () => const AddCustomerScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CustomersController>(() => CustomersController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.editCustomer,
      page: () => const EditCustomerScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CustomersController>(() => CustomersController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.customerDetails,
      page: () => const CustomerDetailsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CustomersController>(() => CustomersController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.importCustomers,
      page: () => const CustomerImportScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CustomerImportController>(() => CustomerImportController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ===== مسارات الديون =====
    GetPage(
      name: AppRoutes.debts,
      page: () => const DebtsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DebtsController>(() => DebtsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.addDebt,
      page: () => const AddDebtScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DebtsController>(() => DebtsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.debtDetails,
      page: () => const DebtDetailsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DebtsController>(() => DebtsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.editDebt,
      page: () => const EditDebtScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DebtsController>(() => DebtsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ===== مسارات المدفوعات =====
    GetPage(
      name: AppRoutes.payments,
      page: () => const PaymentsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PaymentsController>(() => PaymentsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.addPayment,
      page: () => const AddPaymentScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PaymentsController>(() => PaymentsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.paymentDetails,
      page: () => const PaymentDetailsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PaymentsController>(() => PaymentsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.editPayment,
      page: () => const EditPaymentScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PaymentsController>(() => PaymentsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ===== مسارات الموظفين =====
    GetPage(
      name: AppRoutes.employees,
      page: () => const EmployeesScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EmployeesController>(() => EmployeesController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.addEmployee,
      page: () => const AddEmployeeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EmployeesController>(() => EmployeesController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // GetPage(
    //   name: AppRoutes.editEmployee,
    //   page: () => const EditEmployeeScreen(),
    //   binding: BindingsBuilder(() {
    //     Get.lazyPut<EmployeesController>(() => EmployeesController());
    //   }),
    //   transition: Transition.rightToLeft,
    //   transitionDuration: const Duration(milliseconds: 300),
    // ),

    GetPage(
      name: AppRoutes.employeeDetails,
      page: () => const EmployeeDetailsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EmployeesController>(() => EmployeesController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ===== مسارات التقارير =====
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ReportsController>(() => ReportsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.dailyReport,
      page: () => const DailyReportScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ReportsController>(() => ReportsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // GetPage(
    //   name: AppRoutes.monthlyReport,
    //   page: () => const MonthlyReportScreen(),
    //   binding: BindingsBuilder(() {
    //     Get.lazyPut<ReportsController>(() => ReportsController());
    //   }),
    //   transition: Transition.rightToLeft,
    //   transitionDuration: const Duration(milliseconds: 300),
    // ),

    GetPage(
      name: AppRoutes.customReport,
      page: () => const CustomReportScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ReportsController>(() => ReportsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ===== مسارات الإعدادات =====
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileSettingsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: '/security-settings',
      page: () => const SecuritySettingsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.contact,
      page: () => const ContactScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.privacy,
      page: () => const PrivacyScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.terms,
      page: () => const TermsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ===== مسارات الإشعارات =====
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NotificationsController>(() => NotificationsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ===== صفحات إضافية =====
    GetPage(
      name: AppRoutes.about,
      page: () => const AboutScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.help,
      page: () => const HelpScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SettingsController>(() => SettingsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ===== مسارات الاشتراك =====
    GetPage(
      name: AppRoutes.subscriptionExpired,
      page: () => const SubscriptionExpiredScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SubscriptionController>(() => SubscriptionController());
      }),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.subscription,
      page: () => const SubscriptionScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SubscriptionController>(() => SubscriptionController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ===== مسارات تطبيق الزبائن =====
    GetPage(
      name: AppRoutes.clientDashboard,
      page: () => const ClientMainScreen(),
      binding: BindingsBuilder(() {
        // التأكد من تهيئة AuthService
        if (!Get.isRegistered<AuthService>()) {
          Get.put(AuthService(), permanent: true);
        }
        Get.lazyPut<ClientAppController>(() => ClientAppController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.clientRequestDebt,
      page: () => const RequestDebtScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ClientAppController>(() => ClientAppController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.clientRequestPayment,
      page: () => const RequestPaymentScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ClientAppController>(() => ClientAppController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.clientDebts,
      page: () => const client_views.ClientDebtsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ClientAppController>(() => ClientAppController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.clientPayments,
      page: () => const client_views.ClientPaymentsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ClientAppController>(() => ClientAppController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.clientProfile,
      page: () => const CustomerProfileScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ClientAppController>(() => ClientAppController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.clientRequests,
      page: () => const client_views.ClientRequestsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ClientAppController>(() => ClientAppController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ===== مسارات الزبون الجديدة =====
    GetPage(
      name: AppRoutes.customerStores,
      page: () => const CustomerStoresScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CustomerStoresController>(() => CustomerStoresController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.customerStoreHome,
      page: () => const ClientDashboardScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ClientAppController>(() => ClientAppController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.customerSettings,
      page: () => const CustomerSettingsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CustomerSettingsController>(
            () => CustomerSettingsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.debtRequest,
      page: () => const DebtRequestScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DebtRequestController>(() => DebtRequestController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.paymentRequest,
      page: () => const PaymentRequestScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<PaymentRequestController>(() => PaymentRequestController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ===== مسارات إدارة طلبات الزبائن - مالك المنشأة =====
    GetPage(
      name: AppRoutes.manageClientRequests,
      page: () => const ClientRequestsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ClientRequestsController>(() => ClientRequestsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ===== مسارات الإشعارات - مالك المنشأة =====
    GetPage(
      name: AppRoutes.businessOwnerNotifications,
      page: () => const BusinessOwnerNotificationsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.allActivity,
      page: () => const AllActivityScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<BusinessOwnerHomeController>(
            () => BusinessOwnerHomeController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ===== مسارات إدارة الطلبات =====
    GetPage(
      name: AppRoutes.manageClientRequests,
      page: () => const ManageClientRequestsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ClientRequestsController>(() => ClientRequestsController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ===== مسارات الصفحات العامة =====
    GetPage(
      name: AppRoutes.error,
      page: () => const ErrorScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.maintenance,
      page: () => const MaintenanceScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ===== مسار الخطأ 404 =====
    GetPage(
      name: AppRoutes.notFound,
      page: () => const NotFoundScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];

  // دوال مساعدة للتنقل

  // التنقل للرئيسية مع مسح المسارات السابقة
  static void toHome() {
    Get.offAllNamed(AppRoutes.home);
  }

  // التنقل لتسجيل الدخول مع مسح المسارات السابقة
  static void toLogin() {
    Get.offAllNamed(AppRoutes.login);
  }

  // التنقل لشاشة البداية مع مسح المسارات السابقة
  static void toSplash() {
    Get.offAllNamed(AppRoutes.splash);
  }

  // التنقل لتفاصيل العميل
  static void toCustomerDetails(String customerId) {
    Get.toNamed(AppRoutes.customerDetails,
        arguments: {'customerId': customerId});
  }

  // التنقل لإضافة عميل جديد
  static void toAddCustomer() {
    Get.toNamed(AppRoutes.addCustomer);
  }

  // التنقل لقائمة الديون
  static void toDebts() {
    Get.toNamed(AppRoutes.debts);
  }

  // التنقل لإضافة دين جديد
  static void toAddDebt({String? customerId}) {
    Get.toNamed(AppRoutes.addDebt,
        arguments: customerId != null ? {'customerId': customerId} : null);
  }

  // التنقل لتفاصيل الدين
  static void toDebtDetails(String debtId) {
    Get.toNamed(AppRoutes.debtDetails, arguments: {'debtId': debtId});
  }

  // التنقل لتعديل الدين
  static void toEditDebt(String debtId) {
    Get.toNamed(AppRoutes.editDebt, arguments: {'debtId': debtId});
  }

  // التنقل لقائمة المدفوعات
  static void toPayments() {
    Get.toNamed(AppRoutes.payments);
  }

  // التنقل لإضافة دفعة جديدة
  static void toAddPayment({String? debtId}) {
    Get.toNamed(AppRoutes.addPayment,
        arguments: debtId != null ? {'debtId': debtId} : null);
  }

  // التنقل لتفاصيل الدفعة
  static void toPaymentDetails(String paymentId) {
    Get.toNamed(AppRoutes.paymentDetails, arguments: {'paymentId': paymentId});
  }

  // التنقل لتعديل الدفعة
  static void toEditPayment(String paymentId) {
    Get.toNamed(AppRoutes.editPayment, arguments: {'paymentId': paymentId});
  }

  // التنقل لقائمة التقارير
  static void toReports() {
    Get.toNamed(AppRoutes.reports);
  }

  // التنقل للتقرير اليومي
  static void toDailyReport() {
    Get.toNamed(AppRoutes.dailyReport);
  }

  // التنقل للتقرير الشهري
  static void toMonthlyReport() {
    Get.toNamed(AppRoutes.monthlyReport);
  }

  // التنقل للتقرير المخصص
  static void toCustomReport() {
    Get.toNamed(AppRoutes.customReport);
  }

  // التنقل للإعدادات
  static void toSettings() {
    Get.toNamed(AppRoutes.settings);
  }

  // التنقل لإعدادات الملف الشخصي
  static void toProfileSettings() {
    Get.toNamed(AppRoutes.profile);
  }

  // التنقل لإعدادات الأمان
  static void toSecuritySettings() {
    Get.toNamed('/security-settings');
  }

  // التنقل للإشعارات
  static void toNotifications() {
    Get.toNamed(AppRoutes.notifications);
  }

  // التنقل لشاشة انتهاء الاشتراك
  static void toSubscriptionExpired() {
    Get.offAllNamed(AppRoutes.subscriptionExpired);
  }

  // العودة للخلف مع التحقق من وجود صفحات سابقة
  static void goBack() {
    if (Navigator.canPop(Get.context!)) {
      Get.back();
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  // التنقل مع استبدال الصفحة الحالية
  static void toReplacement(String route, {dynamic arguments}) {
    Get.offNamed(route, arguments: arguments);
  }

  // التنقل مع مسح جميع الصفحات السابقة
  static void toAndClearAll(String route, {dynamic arguments}) {
    Get.offAllNamed(route, arguments: arguments);
  }

  // التحقق من إمكانية العودة
  static bool canGoBack() {
    return Navigator.canPop(Get.context!);
  }

  // الحصول على المسار الحالي
  static String getCurrentRoute() {
    return Get.currentRoute;
  }

  // الحصول على المعاملات المرسلة للصفحة
  static dynamic getArguments() {
    return Get.arguments;
  }

  // الحصول على معامل محدد
  static T? getArgument<T>(String key) {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      return args[key] as T?;
    }
    return null;
  }

  // التحقق من وجود معامل
  static bool hasArgument(String key) {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      return args.containsKey(key);
    }
    return false;
  }
}

// شاشة 404 - الصفحة غير موجودة
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الصفحة غير موجودة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppPages.toHome(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              '404',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'الصفحة غير موجودة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'عذراً، الصفحة التي تبحث عنها غير موجودة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => AppPages.toHome(),
              icon: const Icon(Icons.home),
              label: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      ),
    );
  }
}

// Middleware للتحقق من المصادقة
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // قائمة المسارات التي لا تحتاج مصادقة
    final publicRoutes = [
      AppRoutes.splash,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.forgotPassword,
      AppRoutes.contactSupport,
      AppRoutes.subscriptionExpired,
    ];

    // إذا كان المسار عام، السماح بالوصول
    if (publicRoutes.contains(route)) {
      return null;
    }

    // التحقق من تسجيل الدخول (يمكن تحسينه لاحقاً)
    // if (!AuthService.isLoggedIn()) {
    //   return const RouteSettings(name: AppRoutes.login);
    // }

    return null;
  }
}

// Middleware للتحقق من الاشتراك
class SubscriptionMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // قائمة المسارات التي لا تحتاج اشتراك
    final freeRoutes = [
      AppRoutes.splash,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.forgotPassword,
      AppRoutes.contactSupport,
      AppRoutes.subscriptionExpired,
      AppRoutes.subscription,
      AppRoutes.subscriptionInfo,
    ];

    // إذا كان المسار مجاني، السماح بالوصول
    if (freeRoutes.contains(route)) {
      return null;
    }

    // التحقق من الاشتراك (يمكن تحسينه لاحقاً)
    // if (subscription expired) {
    //   return const RouteSettings(name: AppRoutes.subscriptionExpired);
    // }

    return null;
  }
}
