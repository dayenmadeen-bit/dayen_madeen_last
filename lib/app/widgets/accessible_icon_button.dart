import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// زر أيقونة محسن للوصولية مع tooltip وsemantic labels
class AccessibleIconButton extends StatelessWidget {
  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.semanticLabel,
    this.color,
    this.size = 24.0,
    this.padding = const EdgeInsets.all(8.0),
    this.splashRadius,
    this.enableFeedback = true,
    this.autofocus = false,
    this.focusNode,
  });

  /// الأيقونة
  final IconData icon;

  /// عند الضغط
  final VoidCallback? onPressed;

  /// نص التلميح (يظهر عند الضغط المطول)
  final String tooltip;

  /// التسمية الوصفية (لقارئات الشاشة)
  final String? semanticLabel;

  /// لون الأيقونة
  final Color? color;

  /// حجم الأيقونة
  final double size;

  /// هوامش الزر
  final EdgeInsetsGeometry padding;

  /// نصف قطر تأثير اللمس
  final double? splashRadius;

  /// تفعيل البيانات المرتدة
  final bool enableFeedback;

  /// التركيز التلقائي
  final bool autofocus;

  /// عقدة التركيز
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? tooltip,
      hint: 'زر قابل للضغط',
      button: true,
      enabled: onPressed != null,
      child: Tooltip(
        message: tooltip,
        preferBelow: false,
        textStyle: AppTextStyles.bodySmall.copyWith(
          color: Colors.white,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundDark.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        waitDuration: const Duration(milliseconds: 500),
        child: IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          color: color,
          iconSize: size,
          padding: padding,
          splashRadius: splashRadius,
          enableFeedback: enableFeedback,
          autofocus: autofocus,
          focusNode: focusNode,
          // تحسينات إضافيع للوصولية
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
      ),
    );
  }
}

/// زر عام محسن للوصولية مع tooltips
class AccessibleButton extends StatelessWidget {
  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.semanticLabel,
    this.tooltip,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.enableFeedback = true,
  });

  /// عند الضغط
  final VoidCallback? onPressed;

  /// محتوى الزر
  final Widget child;

  /// التسمية الوصفية
  final String semanticLabel;

  /// نص التلميح
  final String? tooltip;

  /// نمط الزر
  final ButtonStyle? style;

  /// عقدة التركيز
  final FocusNode? focusNode;

  /// التركيز التلقائي
  final bool autofocus;

  /// تفعيل البيانات المرتدة
  final bool enableFeedback;

  @override
  Widget build(BuildContext context) {
    Widget button = Semantics(
      label: semanticLabel,
      hint: 'زر قابل للضغط',
      button: true,
      enabled: onPressed != null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style,
        focusNode: focusNode,
        autofocus: autofocus,
        child: child,
      ),
    );

    // إضافة tooltip إذا تم توفيره
    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        preferBelow: false,
        textStyle: AppTextStyles.bodySmall.copyWith(
          color: Colors.white,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundDark.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        waitDuration: const Duration(milliseconds: 500),
        child: button,
      );
    }

    return button;
  }
}

/// Widget لتحسين الوصولية في القوائم
class AccessibleListTile extends StatelessWidget {
  const AccessibleListTile({
    super.key,
    required this.title,
    required this.semanticLabel,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.enabled = true,
    this.dense,
    this.visualDensity,
  });

  final Widget title;
  final String semanticLabel;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final bool enabled;
  final bool? dense;
  final VisualDensity? visualDensity;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: onLongPress != null 
          ? 'اضغط مطولاً للمزيد من الخيارات'
          : 'عنصر قابل للضغط',
      button: onTap != null,
      selected: selected,
      enabled: enabled,
      child: ListTile(
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
        onLongPress: onLongPress,
        selected: selected,
        enabled: enabled,
        dense: dense,
        visualDensity: visualDensity ?? VisualDensity.adaptivePlatformDensity,
        // تحسينات إضافية
        selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Card محسن للوصولية
class AccessibleCard extends StatelessWidget {
  const AccessibleCard({
    super.key,
    required this.child,
    required this.semanticLabel,
    this.onTap,
    this.margin,
    this.padding,
    this.elevation,
    this.color,
    this.shape,
    this.hint,
  });

  final Widget child;
  final String semanticLabel;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final Color? color;
  final ShapeBorder? shape;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: hint ?? (
        onTap != null 
          ? 'بطاقة قابلة للضغط للمزيد من التفاصيل'
          : 'بطاقة معلومات'
      ),
      button: onTap != null,
      child: Card(
        margin: margin,
        elevation: elevation,
        color: color,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Floating Action Button محسن
class AccessibleFloatingActionButton extends StatelessWidget {
  const AccessibleFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.tooltip,
    required this.semanticLabel,
    this.child,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.mini = false,
    this.heroTag,
  });

  final VoidCallback? onPressed;
  final String tooltip;
  final String semanticLabel;
  final Widget? child;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool mini;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: 'زر عائم - اضغط للتفعيل',
      button: true,
      enabled: onPressed != null,
      child: FloatingActionButton(
        onPressed: onPressed,
        tooltip: tooltip,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        mini: mini,
        heroTag: heroTag,
        child: child ?? (icon != null ? Icon(icon) : null),
      ),
    );
  }
}

/// خدمات مساعدة للوصولية
class AccessibilityHelper {
  /// تفعيل قارئ الشاشة
  static void announceToScreenReader(String message) {
    Semantics(
      liveRegion: true,
      child: Text(
        message,
        style: const TextStyle(fontSize: 0), // مخفي بصرياً
      ),
    );
  }

  /// تحسين الوصولية للقوائم
  static Widget enhanceListAccessibility({
    required Widget child,
    required int itemCount,
    required String listName,
  }) {
    return Semantics(
      label: '$listName تحتوي على $itemCount عنصر',
      hint: 'قائمة قابلة للتمرير',
      child: child,
    );
  }

  /// تحسين الوصولية للنماذج
  static Widget enhanceFormAccessibility({
    required Widget child,
    required String formName,
  }) {
    return Semantics(
      label: 'نموذج $formName',
      hint: 'استخدم التمرير للتنقل بين الحقول',
      child: child,
    );
  }

  /// تحسين الوصولية للإحصائيات
  static Widget enhanceStatsAccessibility({
    required Widget child,
    required String statValue,
    required String statName,
  }) {
    return Semantics(
      label: '$statName: $statValue',
      hint: 'إحصائية',
      readOnly: true,
      child: child,
    );
  }
}