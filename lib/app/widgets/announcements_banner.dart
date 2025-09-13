import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';

/// لوحة إعلانات دوّارة تتبدل كل 10 ثوانٍ
class AnnouncementsBanner extends StatefulWidget {
  final List<String> announcements;
  final Duration interval;
  final IconData icon;
  final Color? backgroundColor;

  const AnnouncementsBanner({
    super.key,
    required this.announcements,
    this.interval = const Duration(seconds: 10),
    this.icon = Icons.campaign_rounded,
    this.backgroundColor,
  });

  @override
  State<AnnouncementsBanner> createState() => _AnnouncementsBannerState();
}

class _AnnouncementsBannerState extends State<AnnouncementsBanner> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    if (widget.announcements.isNotEmpty) {
      _timer = Timer.periodic(widget.interval, (_) => _nextPage());
    }
  }

  @override
  void didUpdateWidget(covariant AnnouncementsBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.interval != widget.interval ||
        oldWidget.announcements.length != widget.announcements.length) {
      _timer?.cancel();
      if (widget.announcements.isNotEmpty) {
        _timer = Timer.periodic(widget.interval, (_) => _nextPage());
      }
    }
  }

  void _nextPage() {
    if (!mounted || widget.announcements.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % widget.announcements.length;
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.announcements.isEmpty) {
      // عرض حالة فارغة بدلاً من الإخفاء الكامل لتحسين الإدراك البصري
      return Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          color: (widget.backgroundColor ??
              AppColors.info.withValues(alpha: 0.08)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.info.withValues(alpha: 0.2),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          AppStrings.announcementsEmpty,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        color:
            (widget.backgroundColor ?? AppColors.info.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.icon,
              color: AppColors.info,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.announcements.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, index) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.announcements[index],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

