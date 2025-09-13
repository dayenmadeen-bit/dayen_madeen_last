import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/offline_service.dart';

/// Widget للتحقق من العمليات المحظورة في وضع الأوفلاين
class OfflineActionWrapper extends StatelessWidget {
  final String action;
  final Widget child;
  final VoidCallback? onTap;
  final bool showMessage;
  final String? customMessage;

  const OfflineActionWrapper({
    super.key,
    required this.action,
    required this.child,
    this.onTap,
    this.showMessage = true,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return GetX<OfflineService>(
      builder: (offlineService) {
        final canPerform = offlineService.canPerformActionWithMessage(
          action,
          showMessage: showMessage,
        );

        return GestureDetector(
          onTap: canPerform ? onTap : () => _showOfflineMessage(offlineService),
          child: Opacity(
            opacity: canPerform ? 1.0 : 0.6,
            child: child,
          ),
        );
      },
    );
  }

  void _showOfflineMessage(OfflineService offlineService) {
    if (!showMessage) return;
    Get.dialog(
      AlertDialog(
        title: const Text('وضع الأوفلاين'),
        content: Text(
            customMessage ?? 'لا يمكن استخدام هذا الإجراء في وضع الأوفلاين'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('حسناً'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}

/// Widget للتحقق من العمليات المحظورة مع زر
class OfflineActionButton extends StatelessWidget {
  final String action;
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showMessage;
  final String? customMessage;
  final bool isLoading;

  const OfflineActionButton({
    super.key,
    required this.action,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.showMessage = true,
    this.customMessage,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GetX<OfflineService>(
      builder: (offlineService) {
        final canPerform = offlineService.canPerformActionWithMessage(
          action,
          showMessage: showMessage,
        );

        final bool enabled = canPerform && !isLoading;
        return ElevatedButton.icon(
          onPressed:
              enabled ? onPressed : () => _showOfflineMessage(offlineService),
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : (icon != null ? Icon(icon) : const SizedBox.shrink()),
          label: Text(isLoading ? 'جارٍ المعالجة...' : text),
          style: ElevatedButton.styleFrom(
            backgroundColor: enabled
                ? (backgroundColor ?? AppColors.primary)
                : AppColors.textSecondary,
            foregroundColor:
                enabled ? (textColor ?? Colors.white) : AppColors.textHintLight,
            disabledBackgroundColor: AppColors.textSecondary,
            disabledForegroundColor: AppColors.textHintLight,
          ),
        );
      },
    );
  }

  void _showOfflineMessage(OfflineService offlineService) {
    if (!showMessage) return;
    Get.dialog(
      AlertDialog(
        title: const Text('وضع الأوفلاين'),
        content: Text(
            customMessage ?? 'لا يمكن استخدام هذا الإجراء في وضع الأوفلاين'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('حسناً'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}

/// Widget للتحقق من العمليات المحظورة مع FloatingActionButton
class OfflineFloatingActionButton extends StatelessWidget {
  final String action;
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final bool showMessage;
  final String? customMessage;

  const OfflineFloatingActionButton({
    super.key,
    required this.action,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.showMessage = true,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return GetX<OfflineService>(
      builder: (offlineService) {
        final canPerform = offlineService.canPerformActionWithMessage(
          action,
          showMessage: showMessage,
        );

        return FloatingActionButton(
          onPressed: canPerform
              ? onPressed
              : () => _showOfflineMessage(offlineService),
          tooltip: canPerform ? tooltip : 'غير متاح في وضع الأوفلاين',
          backgroundColor:
              canPerform ? AppColors.primary : AppColors.textSecondary,
          child: Icon(
            icon,
            color: canPerform ? Colors.white : AppColors.textHintLight,
          ),
        );
      },
    );
  }

  void _showOfflineMessage(OfflineService offlineService) {
    if (!showMessage) return;
    Get.dialog(
      AlertDialog(
        title: const Text('وضع الأوفلاين'),
        content: Text(
            customMessage ?? 'لا يمكن استخدام هذا الإجراء في وضع الأوفلاين'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('حسناً'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}
