import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_icons.dart';
import 'loading_widget.dart';
import 'empty_state_widget.dart';

/// Widget لعرض قوائم طويلة مع Pagination لتحسين الأداء
class PaginatedListView<T> extends StatefulWidget {
  const PaginatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    this.emptyStateType = EmptyStateType.noData,
    this.emptyTitle,
    this.emptySubtitle,
    this.emptyActionText,
    this.onEmptyAction,
    this.isLoading = false,
    this.hasMore = true,
    this.itemsPerPage = 20,
    this.loadingMessage,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  /// قائمة العناصر الحالية
  final List<T> items;

  /// باني العنصر الواحد
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// عند السحب للتحديث
  final Future<void> Function() onRefresh;

  /// عند الحاجة لتحميل المزيد
  final Future<void> Function() onLoadMore;

  /// نوع الحالة الفارغة
  final EmptyStateType emptyStateType;

  /// عنوان الحالة الفارغة
  final String? emptyTitle;

  /// وصف الحالة الفارغة
  final String? emptySubtitle;

  /// نص زر الإجراء في الحالة الفارغة
  final String? emptyActionText;

  /// إجراء الحالة الفارغة
  final VoidCallback? onEmptyAction;

  /// هل يتم التحميل حالياً
  final bool isLoading;

  /// هل توجد عناصر أكثر لتحميلها
  final bool hasMore;

  /// عدد العناصر في الصفحة الواحدة
  final int itemsPerPage;

  /// رسالة التحميل
  final String? loadingMessage;

  /// هوامش القائمة
  final EdgeInsetsGeometry? padding;

  /// فيزياء القائمة
  final ScrollPhysics? physics;

  /// تقليص حجم القائمة
  final bool shrinkWrap;

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// معالج أحداث التمرير
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        widget.hasMore &&
        !widget.isLoading) {
      _loadMoreItems();
    }
  }

  /// تحميل المزيد من العناصر
  Future<void> _loadMoreItems() async {
    if (_isLoadingMore || !widget.hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await widget.onLoadMore();
    } catch (e) {
      // معالجة الأخطاء
      Get.snackbar(
        'خطأ',
        'فشل في تحميل المزيد من البيانات',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // حالة التحميل الأولي
    if (widget.isLoading && widget.items.isEmpty) {
      return LoadingWidget(
        type: LoadingType.circular,
        size: LoadingSize.large,
        message: widget.loadingMessage ?? 'جاري تحميل البيانات...',
      );
    }

    // حالة فارغة
    if (widget.items.isEmpty) {
      return EmptyStateWidget(
        type: widget.emptyStateType,
        title: widget.emptyTitle,
        subtitle: widget.emptySubtitle,
        actionText: widget.emptyActionText,
        onActionPressed: widget.onEmptyAction,
      );
    }

    // قائمة بالعناصر
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: widget.padding ?? const EdgeInsets.all(16),
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        itemCount: widget.items.length + (_hasMoreIndicator ? 1 : 0),
        itemBuilder: (context, index) {
          // عرض العنصر
          if (index < widget.items.length) {
            return widget.itemBuilder(context, widget.items[index], index);
          }

          // مؤسر تحميل المزيد
          return _buildLoadMoreIndicator();
        },
      ),
    );
  }

  /// هل يجب عرض مؤشر التحميل
  bool get _hasMoreIndicator {
    return (widget.hasMore || _isLoadingMore) && widget.items.isNotEmpty;
  }

  /// مؤشر تحميل المزيد
  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_isLoadingMore)
            const LoadingWidget(
              type: LoadingType.circular,
              size: LoadingSize.small,
              message: 'جاري تحميل المزيد...',
            )
          else if (widget.hasMore)
            Column(
              children: [
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      AppIcons.expandMore,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'امرر لأسفل لتحميل المزيد',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      AppIcons.expandMore,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),
              ],
            )
          else
            // لا توجد عناصر أكثر
            Column(
              children: [
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      AppIcons.checkCircle,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'لا توجد عناصر أكثر لعرضها',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      AppIcons.checkCircle,
                      color: AppColors.success,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'تم عرض جميع ${widget.items.length} عنصر',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
        ],
      ),
    );
  }
}

/// كنترولر مساعد لإدارة الـ Pagination
abstract class PaginatedController extends GetxController {
  // متغيرات الـ Pagination
  var currentPage = 1.obs;
  var itemsPerPage = 20.obs;
  var isLoading = false.obs;
  var hasMore = true.obs;
  var totalCount = 0.obs;

  /// تحميل الصفحة الأولى
  Future<void> loadFirstPage();

  /// تحميل الصفحة التالية
  Future<void> loadNextPage();

  /// تحديث البيانات
  Future<void> refreshData() async {
    currentPage.value = 1;
    hasMore.value = true;
    await loadFirstPage();
  }

  /// حساب عدد الصفحات الإجمالي
  int get totalPages {
    return (totalCount.value / itemsPerPage.value).ceil();
  }

  /// هل هذه الصفحة الأخيرة
  bool get isLastPage {
    return currentPage.value >= totalPages;
  }

  /// تغيير حجم الصرحة
  void changePageSize(int newSize) {
    if (newSize != itemsPerPage.value) {
      itemsPerPage.value = newSize;
      refreshData();
    }
  }

  /// الانتقال لصفحة محددة
  Future<void> goToPage(int pageNumber) async {
    if (pageNumber >= 1 && pageNumber <= totalPages) {
      currentPage.value = pageNumber;
      await loadFirstPage();
    }
  }
}

/// widget لعرض معلومات الـ Pagination
class PaginationInfo extends StatelessWidget {
  const PaginationInfo({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    this.onPageChanged,
    this.onPageSizeChanged,
  });

  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final Function(int)? onPageChanged;
  final Function(int)? onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // معلومات الصفحة
          Text(
            'عرض ${((currentPage - 1) * itemsPerPage) + 1}-${(currentPage * itemsPerPage > totalItems) ? totalItems : currentPage * itemsPerPage} من $totalItems',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          // متحكمات الصفحة
          Row(
            children: [
              // الصفحة السابقة
              IconButton(
                onPressed: currentPage > 1
                    ? () => onPageChanged?.call(currentPage - 1)
                    : null,
                icon: const Icon(Icons.chevron_right),
                iconSize: 20,
              ),

              // رقم الصفحة
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$currentPage / $totalPages',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // الصفحة التالية
              IconButton(
                onPressed: currentPage < totalPages
                    ? () => onPageChanged?.call(currentPage + 1)
                    : null,
                icon: const Icon(Icons.chevron_left),
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget مبسط لعدم وجود نتائج بحث
class NoSearchResultsWidget extends StatelessWidget {
  const NoSearchResultsWidget({
    super.key,
    required this.searchQuery,
    this.onClearSearch,
  });

  final String searchQuery;
  final VoidCallback? onClearSearch;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.search,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد نتائج',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم العثور على نتائج لـ "$searchQuery"',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (onClearSearch != null)
            ElevatedButton.icon(
              onPressed: onClearSearch,
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('مسح البحث'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget لعرض حالة قائمة فارغة
class EmptyListWidget extends StatelessWidget {
  const EmptyListWidget({
    super.key,
    required this.type,
    this.title,
    this.subtitle,
    this.actionText,
    this.onActionPressed,
  });

  final EmptyStateType type;
  final String? title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      type: type,
      title: title,
      subtitle: subtitle,
      actionText: actionText,
      onActionPressed: onActionPressed,
    );
  }
}