import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_decorations.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? labelText;
  final String? hint;
  final String? hintText;
  final String? initialValue;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function(String)? onSubmitted;
  final void Function(String)? onFieldSubmitted;
  final bool readOnly;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final double? maxAmount;
  final double? minAmount;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final Color? borderColor;
  final double borderRadius;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.labelText,
    this.hint,
    this.hintText,
    this.initialValue,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.onFieldSubmitted,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.borderRadius = AppDecorations.radiusLarge,
    this.minAmount,
    this.maxAmount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // تسمية الحقل
        if ((labelText ?? label).isNotEmpty) ...[
          Text(
            labelText ?? label,
            style: AppTextStyles.label.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // حقل الإدخال
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          obscureText: obscureText || isPassword,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          onTap: onTap,
          onFieldSubmitted: onFieldSubmitted ?? onSubmitted,
          readOnly: readOnly,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          focusNode: focusNode,
          autofocus: autofocus,
          textCapitalization: textCapitalization,
          textAlign: textAlign,
          style: AppTextStyles.bodyLarge.copyWith(
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          decoration: _buildInputDecoration(context, isDark),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(BuildContext context, bool isDark) {
    return InputDecoration(
      hintText: hintText ?? hint,
      prefixIcon: prefixIcon != null
          ? Icon(
              prefixIcon,
              color: isDark ? AppColors.textSecondaryDark : AppColors.primary,
              size: 20,
            )
          : null,
      suffixIcon: suffixIcon,

      // الحدود
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: borderColor ??
              (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: borderColor ??
              (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: AppColors.error,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: isDark
              ? AppColors.borderDark.withValues(alpha: 0.5)
              : AppColors.borderLight.withValues(alpha: 0.5),
          width: 1,
        ),
      ),

      // التعبئة والألوان
      filled: true,
      fillColor: fillColor ??
          (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),

      // المحاذاة والحشو
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(
            horizontal: AppDecorations.spacingMedium,
            vertical: AppDecorations.spacingMedium,
          ),

      // النصوص
      hintStyle: AppTextStyles.bodyLarge.copyWith(
        color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
      ),
      errorStyle: AppTextStyles.bodySmall.copyWith(
        color: AppColors.error,
      ),

      // إعدادات إضافية
      isDense: true,
      counterStyle: AppTextStyles.caption.copyWith(
        color:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
    );
  }
}

// حقل نص مخصص للبحث
class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final void Function(String)? onChanged;
  final void Function()? onClear;
  final bool showClearButton;

  const SearchTextField({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onClear,
    this.showClearButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: '',
      hint: hint ?? 'بحث...',
      prefixIcon: Icons.search_rounded,
      suffixIcon: showClearButton && controller?.text.isNotEmpty == true
          ? IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                controller?.clear();
                onClear?.call();
              },
            )
          : null,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
    );
  }
}

// حقل نص للمبالغ المالية
class AmountTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;

  const AmountTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hint: hint ?? 'أدخل المبلغ',
      prefixIcon: Icons.attach_money_rounded,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      validator: validator ?? _defaultAmountValidator,
      onChanged: onChanged,
      enabled: enabled,
      textAlign: TextAlign.end,
    );
  }

  String? _defaultAmountValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'المبلغ مطلوب';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'المبلغ غير صحيح';
    }

    if (amount <= 0) {
      return 'المبلغ يجب أن يكون أكبر من صفر';
    }

    return null;
  }
}

// حقل نص للهاتف
class PhoneTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;

  const PhoneTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hint: hint ?? 'أدخل رقم الهاتف',
      prefixIcon: Icons.phone_rounded,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      validator: validator ?? _defaultPhoneValidator,
      onChanged: onChanged,
      enabled: enabled,
      textAlign: TextAlign.end,
    );
  }

  String? _defaultPhoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return null; // الهاتف اختياري
    }

    if (value.length != 10) {
      return 'رقم الهاتف يجب أن يكون 10 أرقام';
    }

    if (!value.startsWith('05')) {
      return 'رقم الهاتف يجب أن يبدأ بـ 05';
    }

    return null;
  }
}
