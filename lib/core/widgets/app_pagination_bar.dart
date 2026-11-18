import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_typography.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';

class AppPaginationBar extends StatelessWidget {
  const AppPaginationBar({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.onPageChanged,
    this.pageSize = 6,
  });

  final int currentPage;
  final int totalItems;
  final int pageSize;
  final ValueChanged<int> onPageChanged;

  static int totalPagesFor(int totalItems, {int pageSize = 6}) {
    if (totalItems <= 0) return 1;
    return (totalItems / pageSize).ceil();
  }

  static List<T> paginate<T>(
    List<T> items,
    int currentPage, {
    int pageSize = 6,
  }) {
    if (items.isEmpty) return const [];
    final totalPages = totalPagesFor(items.length, pageSize: pageSize);
    final safePage = currentPage.clamp(0, totalPages - 1);
    final start = safePage * pageSize;
    final end = math.min(start + pageSize, items.length);
    return items.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    if (totalItems == 0) return const SizedBox.shrink();

    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final totalPages = totalPagesFor(totalItems, pageSize: pageSize);
    final safePage = currentPage.clamp(0, totalPages - 1);
    final startItem = safePage * pageSize + 1;
    final endItem = math.min((safePage + 1) * pageSize, totalItems);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 8.0,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Showing $startItem–$endItem of $totalItems',
            style: textTheme.bodySmall?.copyWith(
              fontSize: AppTypography.captionSize,
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (totalPages > 1)
            Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _PageNavButton(
                  icon: Icons.chevron_left_rounded,
                  tooltip: 'Previous page',
                  enabled: safePage > 0,
                  onTap: () => onPageChanged(safePage - 1),
                ),
                for (var i = 0; i < totalPages; i++)
                  _PageNumberPill(
                    pageNumber: i + 1,
                    isSelected: i == safePage,
                    onTap: () => onPageChanged(i),
                  ),
                _PageNavButton(
                  icon: Icons.chevron_right_rounded,
                  tooltip: 'Next page',
                  enabled: safePage < totalPages - 1,
                  onTap: () => onPageChanged(safePage + 1),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PageNavButton extends StatelessWidget {
  const _PageNavButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: tooltip,
      child: InteractivePressScale(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 30.0,
          height: 30.0,
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(7.0),
            border: Border.all(color: colors.borderSubtle),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 16.0,
            color: enabled ? colors.textPrimary : colors.textTertiary,
          ),
        ),
      ),
    );
  }
}

class _PageNumberPill extends StatelessWidget {
  const _PageNumberPill({
    required this.pageNumber,
    required this.isSelected,
    required this.onTap,
  });

  final int pageNumber;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return InteractivePressScale(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 30.0, minHeight: 30.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: isSelected ? colors.freshSkyBlue : colors.cardBackground,
          borderRadius: BorderRadius.circular(7.0),
          border: Border.all(
            color: isSelected ? colors.freshSkyBlue : colors.borderSubtle,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '$pageNumber',
          style: textTheme.labelSmall?.copyWith(
            fontSize: AppTypography.captionSize,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
