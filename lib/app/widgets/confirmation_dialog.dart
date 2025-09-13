import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_decorations.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_text_styles.dart';
import 'custom_button.dart';

/// أنواع حوارات التأكيد المختلفة
enum ConfirmationType {
  delete, // حذف
  save, // حفظ
  cancel, // إلغاء
  logout, // تسجيل خروج
  warning, // تحذير
  info, // معلومات
  success, // نجاح
  error, // خطأ
}

/// حوار تأكيد مخصص مع تصميم جميل ومناسب
class ConfirmationDialog extends StatelessWidget {
  final ConfirmationType type;
  final String? title;
  final String? message;
  final String? details;
  final IconData? icon;
  final Color? iconColor;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool showIcon;
  final bool barrierDismissible;
  final bool showDetails;

  const ConfirmationDialog({
    super.key,
    required this.type,
    this.title,
    this.message,
    this.details,
    this.icon,
    this.iconColor,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.showIcon = true,
    this.barrierDismissible = true,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogData = _getDialogData();

    return WillPopScope(
      onWillPop: () async => barrierDismissible,
      child: AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecorations.radiusLarge),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // الأيقونة
            if (showIcon) ...[
              _buildIcon(dialogData),
              const SizedBox(height: 20),
            ],

            // العنوان
            Text(
              title ?? dialogData.title,
              style: AppTextStyles.titleLarge.copyWith(
                color: dialogData.titleColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // الرسالة
            Text(
              message ?? dialogData.message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),

            // التفاصيل (اختيارية)
            if (showDetails &&
                (details != null || dialogData.details != null)) ...[
              const SizedBox(height: 16),
              _buildDetailsSection(dialogData, isDark),
            ],

            const SizedBox(height: 24),

            // الأزرار
            _buildActionButtons(context, dialogData),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(_DialogData data) {
    final displayIcon = icon ?? data.icon;
    final displayIconColor = iconColor ?? data.iconColor;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: displayIconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Icon(
        displayIcon,
        size: 32,
        color: displayIconColor,
      ),
    );
  }

  Widget _buildDetailsSection(_DialogData data, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppDecorations.radiusMedium),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Text(
        details ?? data.details ?? '',
        style: AppTextStyles.bodySmall.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, _DialogData data) {
    final confirmButtonText = confirmText ?? data.confirmText;
    final cancelButtonText = cancelText ?? data.cancelText;

    return Row(
      children: [
        // زر الإلغاء
        if (cancelButtonText != null)
          Expanded(
            child: CustomButton(
              text: cancelButtonText,
              onPressed: onCancel ?? () => Navigator.of(context).pop(false),
              type: ButtonType.outlined,
              size: ButtonSize.medium,
            ),
          ),

        // مسافة بين الأزرار
        if (cancelButtonText != null && confirmButtonText != null)
          const SizedBox(width: 12),

        // زر التأكيد
        if (confirmButtonText != null)
          Expanded(
            child: CustomButton(
              text: confirmButtonText,
              onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
              type: data.confirmButtonType,
              size: ButtonSize.medium,
            ),
          ),
      ],
    );
  }

  _DialogData _getDialogData() {
    switch (type) {
      case ConfirmationType.delete:
        return _DialogData(
          title: 'تأكيد الحذف',
          message:
              'هل أنت متأكد من حذف هذا العنصر؟ لا يمكن التراجع عن هذا الإجراء',
          icon: AppIcons.delete,
          iconColor: AppColors.error,
          titleColor: AppColors.error,
          confirmText: 'حذف',
          cancelText: 'إلغاء',
          confirmButtonType: ButtonType.danger,
          details: 'سيتم حذف العنصر نهائياً من قاعدة البيانات',
        );

      case ConfirmationType.save:
        return _DialogData(
          title: 'حفظ التغييرات',
          message: 'هل تريد حفظ التغييرات التي قمت بها؟',
          icon: AppIcons.save,
          iconColor: AppColors.success,
          titleColor: AppColors.success,
          confirmText: 'حفظ',
          cancelText: 'إلغاء',
          confirmButtonType: ButtonType.success,
          details: 'سيتم حفظ جميع التغييرات المدخلة',
        );

      case ConfirmationType.cancel:
        return _DialogData(
          title: 'إلغاء العملية',
          message:
              'هل أنت متأكد من إلغاء العملية؟ ستفقد جميع التغييرات غير المحفوظة',
          icon: AppIcons.cancel,
          iconColor: AppColors.warning,
          titleColor: AppColors.warning,
          confirmText: 'نعم، إلغاء',
          cancelText: 'متابعة',
          confirmButtonType: ButtonType.warning,
          details: 'سيتم فقدان جميع البيانات المدخلة',
        );

      case ConfirmationType.logout:
        return _DialogData(
          title: 'تسجيل الخروج',
          message: 'هل أنت متأكد من تسجيل الخروج من التطبيق؟',
          icon: AppIcons.logout,
          iconColor: AppColors.warning,
          titleColor: AppColors.warning,
          confirmText: 'تسجيل خروج',
          cancelText: 'إلغاء',
          confirmButtonType: ButtonType.warning,
          details: 'ستحتاج لإدخال بيانات الدخول مرة أخرى',
        );

      case ConfirmationType.warning:
        return _DialogData(
          title: 'تحذير',
          message: 'يرجى الانتباه قبل المتابعة',
          icon: AppIcons.warning,
          iconColor: AppColors.warning,
          titleColor: AppColors.warning,
          confirmText: 'متابعة',
          cancelText: 'إلغاء',
          confirmButtonType: ButtonType.warning,
        );

      case ConfirmationType.info:
        return _DialogData(
          title: 'معلومات',
          message: 'معلومات مهمة يجب الانتباه إليها',
          icon: AppIcons.info,
          iconColor: AppColors.info,
          titleColor: AppColors.info,
          confirmText: 'فهمت',
          cancelText: null,
          confirmButtonType: ButtonType.primary,
        );

      case ConfirmationType.success:
        return _DialogData(
          title: 'تم بنجاح',
          message: 'تمت العملية بنجاح',
          icon: AppIcons.success,
          iconColor: AppColors.success,
          titleColor: AppColors.success,
          confirmText: 'ممتاز',
          cancelText: null,
          confirmButtonType: ButtonType.success,
        );

      case ConfirmationType.error:
        return _DialogData(
          title: 'حدث خطأ',
          message: 'حدث خطأ أثناء تنفيذ العملية',
          icon: AppIcons.error,
          iconColor: AppColors.error,
          titleColor: AppColors.error,
          confirmText: 'حسناً',
          cancelText: null,
          confirmButtonType: ButtonType.danger,
        );
    }
  }

  /// عرض حوار التأكيد
  static Future<bool?> show({
    required BuildContext context,
    required ConfirmationType type,
    String? title,
    String? message,
    String? details,
    IconData? icon,
    Color? iconColor,
    String? confirmText,
    String? cancelText,
    bool showIcon = true,
    bool barrierDismissible = true,
    bool showDetails = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => ConfirmationDialog(
        type: type,
        title: title,
        message: message,
        details: details,
        icon: icon,
        iconColor: iconColor,
        confirmText: confirmText,
        cancelText: cancelText,
        showIcon: showIcon,
        barrierDismissible: barrierDismissible,
        showDetails: showDetails,
      ),
    );
  }
}

/// حوارات تأكيد جاهزة للاستخدام المباشر

/// حوار تأكيد الحذف
class DeleteConfirmationDialog {
  static Future<bool?> show({
    required BuildContext context,
    String? title,
    String? message,
    String? itemName,
  }) {
    return ConfirmationDialog.show(
      context: context,
      type: ConfirmationType.delete,
      title: title,
      message: message ??
          (itemName != null ? 'هل أنت متأكد من حذف "$itemName"؟' : null),
    );
  }
}

/// حوار تأكيد الحفظ
class SaveConfirmationDialog {
  static Future<bool?> show({
    required BuildContext context,
    String? title,
    String? message,
  }) {
    return ConfirmationDialog.show(
      context: context,
      type: ConfirmationType.save,
      title: title,
      message: message,
    );
  }
}

/// حوار تأكيد الإلغاء
class CancelConfirmationDialog {
  static Future<bool?> show({
    required BuildContext context,
    String? title,
    String? message,
  }) {
    return ConfirmationDialog.show(
      context: context,
      type: ConfirmationType.cancel,
      title: title,
      message: message,
    );
  }
}

/// حوار تأكيد تسجيل الخروج
class LogoutConfirmationDialog {
  static Future<bool?> show({
    required BuildContext context,
    String? title,
    String? message,
  }) {
    return ConfirmationDialog.show(
      context: context,
      type: ConfirmationType.logout,
      title: title,
      message: message,
    );
  }
}

/// حوار إظهار رسالة نجاح
class SuccessDialog {
  static Future<void> show({
    required BuildContext context,
    String? title,
    String? message,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        type: ConfirmationType.success,
        title: title,
        message: message,
        barrierDismissible: true,
      ),
    );
  }
}

/// حوار إظهار رسالة خطأ
class ErrorDialog {
  static Future<void> show({
    required BuildContext context,
    String? title,
    String? message,
    String? details,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        type: ConfirmationType.error,
        title: title,
        message: message,
        details: details,
        showDetails: details != null,
        barrierDismissible: true,
      ),
    );
  }
}

/// حوار إظهار معلومات
class InfoDialog {
  static Future<void> show({
    required BuildContext context,
    String? title,
    String? message,
    String? details,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        type: ConfirmationType.info,
        title: title,
        message: message,
        details: details,
        showDetails: details != null,
        barrierDismissible: true,
      ),
    );
  }
}

/// كلاس مساعد لبيانات الحوار
class _DialogData {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final Color titleColor;
  final String? confirmText;
  final String? cancelText;
  final ButtonType confirmButtonType;
  final String? details;

  _DialogData({
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.titleColor,
    this.confirmText,
    this.cancelText,
    required this.confirmButtonType,
    this.details,
  });
}
