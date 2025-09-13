import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_decorations.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final ButtonType type;
  final ButtonSize size;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.backgroundColor,
    this.textColor ,
    this.borderColor,
    this.width,
    this.height,
    this.borderRadius = AppDecorations.radiusMedium,
    this.padding,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonHeight = height ?? _getHeightForSize(size);
    final buttonPadding = padding ?? _getPaddingForSize(size);
    
    return SizedBox(
      width: width,
      height: buttonHeight,
      child: _buildButton(context, isDark, buttonPadding),
    );
  }

  Widget _buildButton(BuildContext context, bool isDark, EdgeInsetsGeometry buttonPadding) {
    final isDisabled = !isEnabled || onPressed == null || isLoading;
    
    switch (type) {
      case ButtonType.primary:
        return _buildPrimaryButton(context, isDark, buttonPadding, isDisabled);
      case ButtonType.secondary:
        return _buildSecondaryButton(context, isDark, buttonPadding, isDisabled);
      case ButtonType.outlined:
        return _buildOutlinedButton(context, isDark, buttonPadding, isDisabled);
      case ButtonType.text:
        return _buildTextButton(context, isDark, buttonPadding, isDisabled);
      case ButtonType.danger:
        return _buildDangerButton(context, isDark, buttonPadding, isDisabled);
      case ButtonType.success:
        return _buildSuccessButton(context, isDark, buttonPadding, isDisabled);
      case ButtonType.warning:
        return _buildWarningButton(context, isDark, buttonPadding, isDisabled);
      case ButtonType.info:
        return _buildInfoButton(context, isDark, buttonPadding, isDisabled);
      case ButtonType.filled:
        return _buildFilledButton(context, isDark, buttonPadding, isDisabled);
    }
  }

  Widget _buildPrimaryButton(BuildContext context, bool isDark, EdgeInsetsGeometry buttonPadding, bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? (isDark ? AppColors.accent : AppColors.primary),
        foregroundColor: textColor ?? Colors.white,
        disabledBackgroundColor: AppColors.textHintLight,
        disabledForegroundColor: Colors.white,
        elevation: isDisabled ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: buttonPadding,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, bool isDark, EdgeInsetsGeometry buttonPadding, bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.secondary,
        foregroundColor: textColor ?? Colors.white,
        disabledBackgroundColor: AppColors.textHintLight,
        disabledForegroundColor: Colors.white,
        elevation: isDisabled ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: buttonPadding,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildOutlinedButton(BuildContext context, bool isDark, EdgeInsetsGeometry buttonPadding, bool isDisabled) {
    final color = backgroundColor ?? (isDark ? AppColors.accent : AppColors.primary);
    
    return OutlinedButton(
      onPressed: isDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor ?? color,
        disabledForegroundColor: AppColors.textHintLight,
        side: BorderSide(
          color: borderColor ?? color,
          width: isDisabled ? 1 : 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: buttonPadding,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildTextButton(BuildContext context, bool isDark, EdgeInsetsGeometry buttonPadding, bool isDisabled) {
    final color = backgroundColor ?? (isDark ? AppColors.accent : AppColors.primary);
    
    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? color,
        disabledForegroundColor: AppColors.textHintLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: buttonPadding,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildDangerButton(BuildContext context, bool isDark, EdgeInsetsGeometry buttonPadding, bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.error,
        foregroundColor: textColor ?? Colors.white,
        disabledBackgroundColor: AppColors.textHintLight,
        disabledForegroundColor: Colors.white,
        elevation: isDisabled ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: buttonPadding,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildSuccessButton(BuildContext context, bool isDark, EdgeInsetsGeometry buttonPadding, bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.success,
        foregroundColor: textColor ?? Colors.white,
        disabledBackgroundColor: AppColors.textHintLight,
        disabledForegroundColor: Colors.white,
        elevation: isDisabled ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: buttonPadding,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildWarningButton(BuildContext context, bool isDark, EdgeInsetsGeometry buttonPadding, bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.warning,
        foregroundColor: textColor ?? Colors.white,
        disabledBackgroundColor: AppColors.textHintLight,
        disabledForegroundColor: Colors.white,
        elevation: isDisabled ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: buttonPadding,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildInfoButton(BuildContext context, bool isDark, EdgeInsetsGeometry buttonPadding, bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.info,
        foregroundColor: textColor ?? Colors.white,
        disabledBackgroundColor: AppColors.textHintLight,
        disabledForegroundColor: Colors.white,
        elevation: isDisabled ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: buttonPadding,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildFilledButton(BuildContext context, bool isDark, EdgeInsetsGeometry buttonPadding, bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: textColor ?? AppColors.onPrimary,
        disabledBackgroundColor: AppColors.textSecondary.withValues(alpha: 0.3),
        disabledForegroundColor: AppColors.textSecondary,
        padding: buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 2,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: _getIconSizeForSize(size),
            height: _getIconSizeForSize(size),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'جاري التحميل...',
              style: _getTextStyleForSize(size),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: _getIconSizeForSize(size),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: _getTextStyleForSize(size),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: _getTextStyleForSize(size),
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }

  double _getHeightForSize(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  EdgeInsetsGeometry _getPaddingForSize(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getIconSizeForSize(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  TextStyle _getTextStyleForSize(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600);
      case ButtonSize.medium:
        return AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600);
      case ButtonSize.large:
        return AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600);
    }
  }
}

// أنواع الأزرار
enum ButtonType {
  primary,
  secondary,
  outlined,
  text,
  danger,
  success,
  warning,
  info,
  filled,
}

// أحجام الأزرار
enum ButtonSize {
  small,
  medium,
  large,
}

// أزرار مخصصة للاستخدامات الشائعة

class SaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const SaveButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'حفظ',
      onPressed: onPressed,
      isLoading: isLoading,
      icon: Icons.save_rounded,
      type: ButtonType.primary,
    );
  }
}

class CancelButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CancelButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'إلغاء',
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
      icon: Icons.cancel_rounded,
      type: ButtonType.outlined,
    );
  }
}

class DeleteButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const DeleteButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'حذف',
      onPressed: onPressed,
      isLoading: isLoading,
      icon: Icons.delete_rounded,
      type: ButtonType.danger,
    );
  }
}

class AddButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;

  const AddButton({
    super.key,
    this.onPressed,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text ?? 'إضافة',
      onPressed: onPressed,
      icon: Icons.add_rounded,
      type: ButtonType.primary,
    );
  }
}
