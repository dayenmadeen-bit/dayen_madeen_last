import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// شريط التطبيق المخصص
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;
  final Widget? bottom;
  final double? toolbarHeight;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = true,
    this.bottom,
    this.toolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.headlineSmall.copyWith(
          color: foregroundColor ?? AppColors.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions,
      leading: leading ?? (showBackButton ? _buildBackButton(context) : null),
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? AppColors.onPrimary,
      elevation: elevation ?? 2,
      centerTitle: centerTitle,
      bottom: bottom as PreferredSizeWidget?,
      toolbarHeight: toolbarHeight,
      automaticallyImplyLeading: showBackButton,
    );
  }

  Widget? _buildBackButton(BuildContext context) {
    if (!Navigator.of(context).canPop()) {
      return null;
    }

    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_rounded),
      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      tooltip: 'رجوع',
    );
  }

  @override
  Size get preferredSize {
    double height = toolbarHeight ?? kToolbarHeight;
    if (bottom != null) {
      height += (bottom as PreferredSizeWidget).preferredSize.height;
    }
    return Size.fromHeight(height);
  }
}

/// شريط تطبيق بسيط
class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const SimpleAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      actions: actions,
      showBackButton: showBackButton,
      elevation: 1,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// شريط تطبيق شفاف
class TransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? foregroundColor;

  const TransparentAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      actions: actions,
      showBackButton: showBackButton,
      backgroundColor: Colors.transparent,
      foregroundColor: foregroundColor ?? AppColors.textPrimary,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// شريط تطبيق مع بحث
class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final List<Widget>? actions;

  const SearchAppBar({
    super.key,
    required this.title,
    this.hintText = 'البحث...',
    this.controller,
    this.onChanged,
    this.onClear,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: controller?.text.isNotEmpty == true
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: onClear,
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 60);
}

/// شريط تطبيق مع تبويبات
class TabbedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Tab> tabs;
  final TabController? controller;
  final List<Widget>? actions;

  const TabbedAppBar({
    super.key,
    required this.title,
    required this.tabs,
    this.controller,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      actions: actions,
      bottom: TabBar(
        controller: controller,
        tabs: tabs,
        indicatorColor: AppColors.onPrimary,
        labelColor: AppColors.onPrimary,
        unselectedLabelColor: AppColors.onPrimary.withValues(alpha: 0.7),
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
}
