import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_decorations.dart';

/// شريط بحث مخصص
class CustomSearchBar extends StatefulWidget {
  final String? hintText;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool enabled;
  final bool autofocus;
  final TextEditingController? controller;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const CustomSearchBar({
    super.key,
    this.hintText = 'البحث...',
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.enabled = true,
    this.autofocus = false,
    this.controller,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = AppDecorations.radiusMedium,
    this.padding,
    this.margin,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
      _hasText = widget.initialValue!.isNotEmpty;
    }
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    widget.onChanged?.call(_controller.text);
  }

  void _onClear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: widget.margin,
      padding: widget.padding,
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? 
                 (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor ?? 
                   (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Leading widget أو أيقونة البحث
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: widget.leading ?? Icon(
                AppIcons.search,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                size: 20,
              ),
            ),
            
            // حقل النص
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: widget.enabled,
                autofocus: widget.autofocus,
                onSubmitted: widget.onSubmitted,
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            
            // زر المسح
            if (_hasText)
              IconButton(
                onPressed: _onClear,
                icon: Icon(
                  AppIcons.cancel,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  size: 20,
                ),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            
            // Actions
            if (widget.actions != null) ...[
              const SizedBox(width: 4),
              ...widget.actions!,
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

/// شريط بحث مع فلترة
class FilterableSearchBar extends StatelessWidget {
  final String? hintText;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onFilterTap;
  final bool enabled;
  final bool autofocus;
  final TextEditingController? controller;
  final bool hasActiveFilters;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const FilterableSearchBar({
    super.key,
    this.hintText = 'البحث...',
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onFilterTap,
    this.enabled = true,
    this.autofocus = false,
    this.controller,
    this.hasActiveFilters = false,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = AppDecorations.radiusMedium,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return CustomSearchBar(
      hintText: hintText,
      initialValue: initialValue,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onClear: onClear,
      enabled: enabled,
      autofocus: autofocus,
      controller: controller,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      actions: onFilterTap != null ? [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: onFilterTap,
            icon: Stack(
              children: [
                Icon(
                  AppIcons.filter,
                  color: hasActiveFilters 
                      ? AppColors.primary 
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  size: 20,
                ),
                if (hasActiveFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ),
      ] : null,
    );
  }
}

/// شريط بحث مبسط
class SimpleSearchBar extends StatelessWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool enabled;

  const SimpleSearchBar({
    super.key,
    this.hintText = 'البحث...',
    this.onChanged,
    this.controller,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSearchBar(
      hintText: hintText,
      onChanged: onChanged,
      controller: controller,
      enabled: enabled,
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
