import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_strings.dart';
import 'custom_button.dart';

/// أنواع الحالات الفارغة المختلفة
enum EmptyStateType {
  noData,           // لا توجد بيانات
  noResults,        // لا توجد نتائج بحث
  noCustomers,      // لا يوجد عملاء
  noDebts,          // لا توجد ديون
  noPayments,       // لا توجد مدفوعات
  noReports,        // لا توجد تقارير
  noNotifications,  // لا توجد إشعارات
  error,            // خطأ
  offline,          // غير متصل
  maintenance,      // صيانة
}

/// ويدجت عرض الحالات الفارغة مع تصميم جميل ومناسب
class EmptyStateWidget extends StatelessWidget {
  final EmptyStateType type;
  final String? title;
  final String? subtitle;
  final String? message;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Widget? customIcon;
  final Color? iconColor;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final bool showAction;

  const EmptyStateWidget({
    super.key,
    required this.type,
    this.title,
    this.subtitle,
    this.message,
    this.icon,
    this.actionText,
    this.onActionPressed,
    this.customIcon,
    this.iconColor,
    this.iconSize,
    this.padding,
    this.showAction = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emptyStateData = _getEmptyStateData();
    
    return Container(
      padding: padding ?? const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // الأيقونة
          _buildIcon(emptyStateData, isDark),
          
          const SizedBox(height: 24),
          
          // العنوان
          Text(
            title ?? emptyStateData.title,
            style: AppTextStyles.titleLarge.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // الرسالة
          Text(
            message ?? emptyStateData.message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          
          // زر الإجراء
          if (showAction && (onActionPressed != null || emptyStateData.hasDefaultAction)) ...[
            const SizedBox(height: 32),
            _buildActionButton(emptyStateData),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon(_EmptyStateData data, bool isDark) {
    if (customIcon != null) {
      return customIcon!;
    }

    final displayIcon = icon ?? data.icon;
    final displayIconColor = iconColor ?? data.iconColor;
    final displayIconSize = iconSize ?? 80.0;

    return Container(
      width: displayIconSize + 32,
      height: displayIconSize + 32,
      decoration: BoxDecoration(
        color: displayIconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular((displayIconSize + 32) / 2),
      ),
      child: Icon(
        displayIcon,
        size: displayIconSize,
        color: displayIconColor,
      ),
    );
  }

  Widget _buildActionButton(_EmptyStateData data) {
    final buttonText = actionText ?? data.actionText;
    final buttonAction = onActionPressed ?? data.defaultAction;

    if (buttonText == null || buttonAction == null) {
      return const SizedBox.shrink();
    }

    return CustomButton(
      text: buttonText,
      onPressed: buttonAction,
      type: _getButtonType(),
      icon: data.actionIcon,
    );
  }

  ButtonType _getButtonType() {
    switch (type) {
      case EmptyStateType.error:
        return ButtonType.danger;
      case EmptyStateType.offline:
        return ButtonType.outlined;
      default:
        return ButtonType.primary;
    }
  }

  _EmptyStateData _getEmptyStateData() {
    switch (type) {
      case EmptyStateType.noData:
        return _EmptyStateData(
          title: 'لا توجد بيانات',
          message: 'لم يتم العثور على أي بيانات للعرض',
          icon: AppIcons.noData,
          iconColor: AppColors.info,
          actionText: 'تحديث',
          actionIcon: AppIcons.refresh,
        );

      case EmptyStateType.noResults:
        return _EmptyStateData(
          title: 'لا توجد نتائج',
          message: 'لم يتم العثور على نتائج مطابقة لبحثك',
          icon: AppIcons.search,
          iconColor: AppColors.warning,
          actionText: 'مسح البحث',
          actionIcon: Icons.clear_rounded,
        );

      case EmptyStateType.noCustomers:
        return _EmptyStateData(
          title: AppStrings.noCustomers,
          message: 'لم تقم بإضافة أي عملاء بعد. ابدأ بإضافة عميلك الأول',
          icon: AppIcons.customers,
          iconColor: AppColors.primary,
          actionText: AppStrings.addCustomer,
          actionIcon: AppIcons.add,
        );

      case EmptyStateType.noDebts:
        return _EmptyStateData(
          title: AppStrings.noDebts,
          message: 'لا توجد ديون مسجلة حالياً. ابدأ بتسجيل أول دين',
          icon: AppIcons.debts,
          iconColor: AppColors.warning,
          actionText: AppStrings.addDebt,
          actionIcon: AppIcons.add,
        );

      case EmptyStateType.noPayments:
        return _EmptyStateData(
          title: AppStrings.noPayments,
          message: 'لا توجد مدفوعات مسجلة حالياً. ابدأ بتسجيل أول دفعة',
          icon: AppIcons.payments,
          iconColor: AppColors.success,
          actionText: AppStrings.addPayment,
          actionIcon: AppIcons.add,
        );

      case EmptyStateType.noReports:
        return _EmptyStateData(
          title: 'لا توجد تقارير',
          message: 'لا توجد تقارير متاحة للفترة المحددة',
          icon: AppIcons.reports,
          iconColor: AppColors.info,
          actionText: 'إنشاء تقرير',
          actionIcon: AppIcons.add,
        );

      case EmptyStateType.noNotifications:
        return _EmptyStateData(
          title: 'لا توجد إشعارات',
          message: 'لا توجد إشعارات جديدة في الوقت الحالي',
          icon: AppIcons.notification,
          iconColor: AppColors.info,
          actionText: 'تحديث',
          actionIcon: AppIcons.refresh,
        );

      case EmptyStateType.error:
        return _EmptyStateData(
          title: 'حدث خطأ',
          message: 'عذراً، حدث خطأ أثناء تحميل البيانات. يرجى المحاولة مرة أخرى',
          icon: AppIcons.error,
          iconColor: AppColors.error,
          actionText: AppStrings.tryAgain,
          actionIcon: AppIcons.refresh,
        );

      case EmptyStateType.offline:
        return _EmptyStateData(
          title: 'غير متصل',
          message: 'يبدو أنك غير متصل بالإنترنت. تحقق من اتصالك وحاول مرة أخرى',
          icon: AppIcons.wifiOff,
          iconColor: AppColors.warning,
          actionText: 'إعادة المحاولة',
          actionIcon: AppIcons.refresh,
        );

      case EmptyStateType.maintenance:
        return _EmptyStateData(
          title: 'صيانة مؤقتة',
          message: 'النظام تحت الصيانة حالياً. سيعود للعمل قريباً',
          icon: Icons.build_rounded,
          iconColor: AppColors.warning,
          actionText: 'تحديث',
          actionIcon: AppIcons.refresh,
        );
    }
  }
}

/// ويدجت خاص للقوائم الفارغة
class EmptyListWidget extends StatelessWidget {
  final EmptyStateType type;
  final String? title;
  final String? message;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final bool showIllustration;

  const EmptyListWidget({
    super.key,
    required this.type,
    this.title,
    this.message,
    this.actionText,
    this.onActionPressed,
    this.showIllustration = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: EmptyStateWidget(
          type: type,
          title: title,
          message: message,
          actionText: actionText,
          onActionPressed: onActionPressed,
          padding: const EdgeInsets.all(24),
        ),
      ),
    );
  }
}

/// ويدجت للبحث بدون نتائج
class NoSearchResultsWidget extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;
  final VoidCallback? onNewSearch;

  const NoSearchResultsWidget({
    super.key,
    required this.searchQuery,
    this.onClearSearch,
    this.onNewSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      type: EmptyStateType.noResults,
      title: 'لا توجد نتائج',
      message: 'لم يتم العثور على نتائج لـ "$searchQuery"',
      actionText: 'مسح البحث',
      onActionPressed: onClearSearch,
    );
  }
}

/// ويدجت لحالة الخطأ مع إعادة المحاولة
class ErrorStateWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final bool showRetryButton;

  const ErrorStateWidget({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.showRetryButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      type: EmptyStateType.error,
      title: title,
      message: message,
      actionText: showRetryButton ? AppStrings.tryAgain : null,
      onActionPressed: onRetry,
      showAction: showRetryButton,
    );
  }
}

/// ويدجت لحالة عدم الاتصال
class OfflineStateWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const OfflineStateWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      type: EmptyStateType.offline,
      onActionPressed: onRetry,
    );
  }
}

/// كلاس مساعد لبيانات الحالة الفارغة
class _EmptyStateData {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final String? actionText;
  final IconData? actionIcon;
  final VoidCallback? defaultAction;

  _EmptyStateData({
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    this.actionText,
    this.actionIcon,
    this.defaultAction,
  });

  bool get hasDefaultAction => defaultAction != null;
}
