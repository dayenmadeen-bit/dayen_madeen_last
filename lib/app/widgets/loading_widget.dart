import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_decorations.dart';
import '../../core/constants/app_icons.dart';

/// أنواع مؤشرات التحميل المختلفة
enum LoadingType {
  circular,     // دائري
  linear,       // خطي
  dots,         // نقاط
  pulse,        // نبضة
  spinner,      // دوار
}

/// أحجام مؤشرات التحميل
enum LoadingSize {
  small,        // صغير
  medium,       // متوسط
  large,        // كبير
}

/// مؤشر تحميل مخصص مع دعم كامل للتصميم العربي
class LoadingWidget extends StatelessWidget {
  final LoadingType type;
  final LoadingSize size;
  final String? message;
  final Color? color;
  final bool showMessage;
  final double? strokeWidth;
  final EdgeInsetsGeometry? padding;

  const LoadingWidget({
    super.key,
    this.type = LoadingType.circular,
    this.size = LoadingSize.medium,
    this.message,
    this.color,
    this.showMessage = true,
    this.strokeWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loadingColor = color ?? AppColors.primary;
    
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLoadingIndicator(loadingColor),
          
          if (showMessage && message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: _getMessageTextStyle(isDark),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(Color loadingColor) {
    switch (type) {
      case LoadingType.circular:
        return _buildCircularIndicator(loadingColor);
      
      case LoadingType.linear:
        return _buildLinearIndicator(loadingColor);
      
      case LoadingType.dots:
        return _buildDotsIndicator(loadingColor);
      
      case LoadingType.pulse:
        return _buildPulseIndicator(loadingColor);
      
      case LoadingType.spinner:
        return _buildSpinnerIndicator(loadingColor);
    }
  }

  Widget _buildCircularIndicator(Color color) {
    return SizedBox(
      width: _getIndicatorSize(),
      height: _getIndicatorSize(),
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: strokeWidth ?? _getStrokeWidth(),
      ),
    );
  }

  Widget _buildLinearIndicator(Color color) {
    return SizedBox(
      width: _getLinearWidth(),
      child: LinearProgressIndicator(
        color: color,
        backgroundColor: color.withValues(alpha: 0.2),
        minHeight: _getLinearHeight(),
      ),
    );
  }

  Widget _buildDotsIndicator(Color color) {
    return _DotsLoadingIndicator(
      color: color,
      size: _getDotSize(),
    );
  }

  Widget _buildPulseIndicator(Color color) {
    return _PulseLoadingIndicator(
      color: color,
      size: _getIndicatorSize(),
    );
  }

  Widget _buildSpinnerIndicator(Color color) {
    return _SpinnerLoadingIndicator(
      color: color,
      size: _getIndicatorSize(),
    );
  }

  double _getIndicatorSize() {
    switch (size) {
      case LoadingSize.small:
        return 24;
      case LoadingSize.medium:
        return 32;
      case LoadingSize.large:
        return 48;
    }
  }

  double _getStrokeWidth() {
    switch (size) {
      case LoadingSize.small:
        return 2;
      case LoadingSize.medium:
        return 3;
      case LoadingSize.large:
        return 4;
    }
  }

  double _getLinearWidth() {
    switch (size) {
      case LoadingSize.small:
        return 120;
      case LoadingSize.medium:
        return 200;
      case LoadingSize.large:
        return 300;
    }
  }

  double _getLinearHeight() {
    switch (size) {
      case LoadingSize.small:
        return 3;
      case LoadingSize.medium:
        return 4;
      case LoadingSize.large:
        return 6;
    }
  }

  double _getDotSize() {
    switch (size) {
      case LoadingSize.small:
        return 6;
      case LoadingSize.medium:
        return 8;
      case LoadingSize.large:
        return 12;
    }
  }

  TextStyle _getMessageTextStyle(bool isDark) {
    switch (size) {
      case LoadingSize.small:
        return AppTextStyles.bodySmall.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        );
      case LoadingSize.medium:
        return AppTextStyles.bodyMedium.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        );
      case LoadingSize.large:
        return AppTextStyles.bodyLarge.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        );
    }
  }
}

/// مؤشر تحميل للشاشة الكاملة
class FullScreenLoading extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final bool dismissible;

  const FullScreenLoading({
    super.key,
    this.message,
    this.backgroundColor,
    this.indicatorColor,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: dismissible,
      child: Scaffold(
        backgroundColor: backgroundColor ?? Colors.black.withValues(alpha: 0.5),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(AppDecorations.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: LoadingWidget(
              type: LoadingType.circular,
              size: LoadingSize.large,
              message: message ?? 'جاري التحميل...',
              color: indicatorColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// مؤشر تحميل صغير للأزرار
class ButtonLoading extends StatelessWidget {
  final Color? color;
  final double? size;

  const ButtonLoading({
    super.key,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 16,
      height: size ?? 16,
      child: CircularProgressIndicator(
        color: color ?? Colors.white,
        strokeWidth: 2,
      ),
    );
  }
}

/// مؤشر تحميل للقوائم
class ListLoading extends StatelessWidget {
  final String? message;
  final int itemCount;

  const ListLoading({
    super.key,
    this.message,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (message != null) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: LoadingWidget(
              type: LoadingType.circular,
              size: LoadingSize.small,
              message: message,
            ),
          ),
        ],
        
        // عناصر وهمية للتحميل
        ...List.generate(
          itemCount,
          (index) => _buildShimmerItem(),
        ),
      ],
    );
  }

  Widget _buildShimmerItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDecorations.radiusLarge),
      ),
      child: Row(
        children: [
          // صورة وهمية
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // نص وهمي
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// مؤشر تحميل النقاط المتحركة
class _DotsLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _DotsLoadingIndicator({
    required this.color,
    required this.size,
  });

  @override
  State<_DotsLoadingIndicator> createState() => _DotsLoadingIndicatorState();
}

class _DotsLoadingIndicatorState extends State<_DotsLoadingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.2),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.3 + (_animations[index].value * 0.7)),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

/// مؤشر تحميل النبضة
class _PulseLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _PulseLoadingIndicator({
    required this.color,
    required this.size,
  });

  @override
  State<_PulseLoadingIndicator> createState() => _PulseLoadingIndicatorState();
}

class _PulseLoadingIndicatorState extends State<_PulseLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.3 + (_animation.value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

/// مؤشر تحميل دوار
class _SpinnerLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _SpinnerLoadingIndicator({
    required this.color,
    required this.size,
  });

  @override
  State<_SpinnerLoadingIndicator> createState() => _SpinnerLoadingIndicatorState();
}

class _SpinnerLoadingIndicatorState extends State<_SpinnerLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: Icon(
            AppIcons.refresh,
            size: widget.size,
            color: widget.color,
          ),
        );
      },
    );
  }
}
