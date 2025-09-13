import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_decorations.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_strings.dart';
import 'custom_button.dart';

/// أنواع الأخطاء المختلفة
enum ErrorType {
  network, // خطأ شبكة
  server, // خطأ خادم
  validation, // خطأ تحقق
  permission, // خطأ صلاحية
  notFound, // غير موجود
  timeout, // انتهاء وقت
  unknown, // خطأ غير معروف
  subscription, // خطأ اشتراك
  storage, // خطأ تخزين
}

/// ويدجت عرض الأخطاء بشكل جميل ومفهوم
class CustomErrorWidget extends StatelessWidget {
  final ErrorType type;
  final String? title;
  final String? message;
  final String? details;
  final IconData? icon;
  final Color? iconColor;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryActionPressed;
  final bool showDetails;
  final bool showActions;
  final EdgeInsetsGeometry? padding;

  const CustomErrorWidget({
    super.key,
    required this.type,
    this.title,
    this.message,
    this.details,
    this.icon,
    this.iconColor,
    this.actionText,
    this.onActionPressed,
    this.secondaryActionText,
    this.onSecondaryActionPressed,
    this.showDetails = false,
    this.showActions = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorData = _getErrorData();

    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // الأيقونة
          _buildErrorIcon(errorData, isDark),

          const SizedBox(height: 24),

          // العنوان
          Text(
            title ?? errorData.title,
            style: AppTextStyles.titleLarge.copyWith(
              color: errorData.titleColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // الرسالة
          Text(
            message ?? errorData.message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),

          // التفاصيل (اختيارية)
          if (showDetails &&
              (details != null || errorData.details != null)) ...[
            const SizedBox(height: 16),
            _buildDetailsSection(errorData, isDark),
          ],

          // الأزرار
          if (showActions) ...[
            const SizedBox(height: 32),
            _buildActionButtons(errorData),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorIcon(_ErrorData data, bool isDark) {
    final displayIcon = icon ?? data.icon;
    final displayIconColor = iconColor ?? data.iconColor;

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: displayIconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(48),
        border: Border.all(
          color: displayIconColor.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Icon(
        displayIcon,
        size: 48,
        color: displayIconColor,
      ),
    );
  }

  Widget _buildDetailsSection(_ErrorData data, bool isDark) {
    return ExpansionTile(
      title: Text(
        'تفاصيل الخطأ',
        style: AppTextStyles.bodySmall.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppDecorations.radiusMedium),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Text(
            details ?? data.details ?? 'لا توجد تفاصيل إضافية',
            style: AppTextStyles.bodySmall.copyWith(
              fontFamily: 'monospace',
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(_ErrorData data) {
    final primaryText = actionText ?? data.primaryActionText;
    final primaryAction = onActionPressed ?? data.primaryAction;
    final secondaryText = secondaryActionText ?? data.secondaryActionText;
    final secondaryAction = onSecondaryActionPressed ?? data.secondaryAction;

    if (primaryText == null && secondaryText == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // الزر الأساسي
        if (primaryText != null && primaryAction != null)
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: primaryText,
              onPressed: primaryAction,
              type: _getPrimaryButtonType(),
              icon: data.primaryActionIcon,
            ),
          ),

        // الزر الثانوي
        if (secondaryText != null && secondaryAction != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: secondaryText,
              onPressed: secondaryAction,
              type: ButtonType.outlined,
              icon: data.secondaryActionIcon,
            ),
          ),
        ],
      ],
    );
  }

  ButtonType _getPrimaryButtonType() {
    switch (type) {
      case ErrorType.network:
      case ErrorType.timeout:
        return ButtonType.primary;
      case ErrorType.server:
      case ErrorType.unknown:
        return ButtonType.warning;
      case ErrorType.permission:
      case ErrorType.subscription:
        return ButtonType.danger;
      default:
        return ButtonType.primary;
    }
  }

  _ErrorData _getErrorData() {
    switch (type) {
      case ErrorType.network:
        return _ErrorData(
          title: 'خطأ في الاتصال',
          message:
              'تعذر الاتصال بالشبكة. تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
          icon: AppIcons.wifiOff,
          iconColor: AppColors.warning,
          titleColor: AppColors.warning,
          primaryActionText: 'إعادة المحاولة',
          primaryActionIcon: AppIcons.refresh,
          details: 'فشل في الاتصال بالخادم. كود الخطأ: NETWORK_ERROR',
        );

      case ErrorType.server:
        return _ErrorData(
          title: 'خطأ في الخادم',
          message: 'حدث خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً',
          icon: AppIcons.error,
          iconColor: AppColors.error,
          titleColor: AppColors.error,
          primaryActionText: 'إعادة المحاولة',
          primaryActionIcon: AppIcons.refresh,
          secondaryActionText: 'تواصل مع الدعم',
          secondaryActionIcon: AppIcons.help,
          details: 'خطأ داخلي في الخادم. كود الخطأ: SERVER_ERROR_500',
        );

      case ErrorType.validation:
        return _ErrorData(
          title: 'خطأ في البيانات',
          message:
              'البيانات المدخلة غير صحيحة. يرجى مراجعة المعلومات والمحاولة مرة أخرى',
          icon: AppIcons.warning,
          iconColor: AppColors.warning,
          titleColor: AppColors.warning,
          primaryActionText: 'تصحيح البيانات',
          primaryActionIcon: AppIcons.edit,
          details: 'فشل في التحقق من صحة البيانات المدخلة',
        );

      case ErrorType.permission:
        return _ErrorData(
          title: 'غير مصرح',
          message: 'ليس لديك صلاحية للوصول إلى هذه الميزة',
          icon: AppIcons.lock,
          iconColor: AppColors.error,
          titleColor: AppColors.error,
          primaryActionText: 'تسجيل الدخول',
          primaryActionIcon: AppIcons.login,
          secondaryActionText: 'العودة',
          secondaryActionIcon: AppIcons.arrowBack,
          details: 'مطلوب صلاحيات إضافية للوصول إلى هذا المحتوى',
        );

      case ErrorType.notFound:
        return _ErrorData(
          title: 'غير موجود',
          message: 'المحتوى المطلوب غير موجود أو تم حذفه',
          icon: AppIcons.search,
          iconColor: AppColors.info,
          titleColor: AppColors.info,
          primaryActionText: 'العودة للرئيسية',
          primaryActionIcon: AppIcons.home,
          details: 'المورد المطلوب غير متاح. كود الخطأ: NOT_FOUND_404',
        );

      case ErrorType.timeout:
        return _ErrorData(
          title: 'انتهت المهلة',
          message: 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى',
          icon: AppIcons.time,
          iconColor: AppColors.warning,
          titleColor: AppColors.warning,
          primaryActionText: 'إعادة المحاولة',
          primaryActionIcon: AppIcons.refresh,
          details: 'انتهت مهلة الاتصال بالخادم. كود الخطأ: TIMEOUT',
        );

      case ErrorType.subscription:
        return _ErrorData(
          title: 'انتهى الاشتراك',
          message: 'انتهت صلاحية اشتراكك. يرجى تجديد الاشتراك للمتابعة',
          icon: AppIcons.subscription,
          iconColor: AppColors.warning,
          titleColor: AppColors.warning,
          primaryActionText: 'تجديد الاشتراك',
          primaryActionIcon: AppIcons.subscription,
          secondaryActionText: 'تواصل معنا',
          secondaryActionIcon: AppIcons.phone,
          details: 'انتهت صلاحية الاشتراك في التاريخ المحدد',
        );

      case ErrorType.storage:
        return _ErrorData(
          title: 'خطأ في التخزين',
          message: 'فشل في حفظ أو قراءة البيانات من التخزين المحلي',
          icon: AppIcons.error,
          iconColor: AppColors.error,
          titleColor: AppColors.error,
          primaryActionText: 'إعادة المحاولة',
          primaryActionIcon: AppIcons.refresh,
          secondaryActionText: 'مسح البيانات',
          secondaryActionIcon: AppIcons.delete,
          details: 'فشل في الوصول إلى قاعدة البيانات المحلية',
        );

      case ErrorType.unknown:
      default:
        return _ErrorData(
          title: 'خطأ غير معروف',
          message:
              'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى أو التواصل مع الدعم الفني',
          icon: AppIcons.error,
          iconColor: AppColors.error,
          titleColor: AppColors.error,
          primaryActionText: 'إعادة المحاولة',
          primaryActionIcon: AppIcons.refresh,
          secondaryActionText: 'تواصل مع الدعم',
          secondaryActionIcon: AppIcons.help,
          details: 'خطأ غير محدد. يرجى التواصل مع الدعم الفني',
        );
    }
  }
}

/// ويدجت خطأ مبسط للاستخدام السريع
class SimpleErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const SimpleErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      type: ErrorType.unknown,
      message: message,
      actionText: onRetry != null ? AppStrings.tryAgain : null,
      onActionPressed: onRetry,
      showActions: onRetry != null,
      showDetails: false,
    );
  }
}

/// ويدجت خطأ الشبكة
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      type: ErrorType.network,
      onActionPressed: onRetry,
    );
  }
}

/// ويدجت خطأ الخادم
class ServerErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final VoidCallback? onContactSupport;

  const ServerErrorWidget({
    super.key,
    this.message,
    this.onRetry,
    this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      type: ErrorType.server,
      message: message,
      onActionPressed: onRetry,
      onSecondaryActionPressed: onContactSupport,
    );
  }
}

/// ويدجت خطأ الصلاحيات
class PermissionErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onLogin;
  final VoidCallback? onGoBack;

  const PermissionErrorWidget({
    super.key,
    this.message,
    this.onLogin,
    this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      type: ErrorType.permission,
      message: message,
      onActionPressed: onLogin,
      onSecondaryActionPressed: onGoBack,
    );
  }
}

/// كلاس مساعد لبيانات الخطأ
class _ErrorData {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final Color titleColor;
  final String? primaryActionText;
  final IconData? primaryActionIcon;
  final VoidCallback? primaryAction;
  final String? secondaryActionText;
  final IconData? secondaryActionIcon;
  final VoidCallback? secondaryAction;
  final String? details;

  _ErrorData({
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.titleColor,
    this.primaryActionText,
    this.primaryActionIcon,
    this.primaryAction,
    this.secondaryActionText,
    this.secondaryActionIcon,
    this.secondaryAction,
    this.details,
  });
}
