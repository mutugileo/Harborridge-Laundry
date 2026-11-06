import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';
import 'package:laundry_ridge/features/dashboard/domain/dashboard_models.dart';
import 'package:laundry_ridge/features/dashboard/presentation/dashboard_notifier.dart';
import 'package:laundry_ridge/features/dashboard/presentation/dashboard_state.dart';
import 'package:laundry_ridge/features/dashboard/presentation/widgets/dashboard_charts.dart';

class AdminDashboardView extends ConsumerWidget {
  const AdminDashboardView({
    super.key,
    this.onQuickLinkSelected,
    this.onNewOrderRequested,
    this.onRegisterWorkerRequested,
  });

  final ValueChanged<DashboardQuickLinkTarget>? onQuickLinkSelected;
  final VoidCallback? onNewOrderRequested;
  final VoidCallback? onRegisterWorkerRequested;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardNotifierProvider);
    final notifier = ref.read(dashboardNotifierProvider.notifier);
    final colors = context.colors;
    final motion = context.motion;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 24.0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DashboardTopUtilityRow(
                activeOrdersCount: state.activeOrdersCount,
                onUpgradeTap: () => notifier.triggerDashboardAction(
                  'Harborridge Enterprise plan details opened',
                ),
                onAddWorkerTap: () {
                  if (onRegisterWorkerRequested != null) {
                    onRegisterWorkerRequested!();
                  } else {
                    notifier.triggerDashboardAction(
                      'Opening Staff & Worker Registration',
                    );
                  }
                },
              ),
              const SizedBox(height: 18.0),
              _DashboardFilterActionToolbar(
                selectedDateFilter: state.selectedDateFilter,
                onDateFilterChanged: notifier.selectDateFilter,
                onExportTap: () => notifier.triggerDashboardAction(
                  'Exported ${state.selectedDateFilter} Harborridge analytics report',
                ),
                onNewOrderTap: () {
                  if (onNewOrderRequested != null) {
                    onNewOrderRequested!();
                  } else {
                    notifier.triggerDashboardAction(
                      'New laundry order intake initialized',
                    );
                  }
                },
              ),
              AnimatedSwitcher(
                duration: motion.shortDuration,
                child: state.feedbackMessage == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 9.0,
                          ),
                          decoration: BoxDecoration(
                            color: colors.freshSkyBlue.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: colors.freshSkyBlue.withValues(
                                alpha: 0.30,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 16.0,
                                color: colors.freshSkyBlue,
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  state.feedbackMessage!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colors.harborNavy,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 18.0),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktopGrid = constraints.maxWidth >= 900.0;

                  if (isDesktopGrid) {
                    final leftWidth = (constraints.maxWidth - 18.0) * 0.73;
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 73,
                            child: _LeftKpiAndQuickLinksColumn(
                              state: state,
                              availableWidth: leftWidth,
                              onQuickLinkTap: (target) {
                                if (onQuickLinkSelected != null) {
                                  onQuickLinkSelected!(target);
                                } else {
                                  notifier.triggerDashboardAction(
                                    'Navigated to ${target.name}',
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 18.0),
                          Expanded(
                            flex: 27,
                            child: _TopCustomersFeatureCard(
                              customers: state.topCustomers,
                              selectedIndex: state.selectedCustomerIndex,
                              onSelectCustomer: notifier.selectTopCustomer,
                              onViewAllTap: () {
                                if (onQuickLinkSelected != null) {
                                  onQuickLinkSelected!(
                                    DashboardQuickLinkTarget.customer,
                                  );
                                } else {
                                  notifier.triggerDashboardAction(
                                    'Viewing all top customers',
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _LeftKpiAndQuickLinksColumn(
                        state: state,
                        availableWidth: constraints.maxWidth,
                        onQuickLinkTap: (target) {
                          if (onQuickLinkSelected != null) {
                            onQuickLinkSelected!(target);
                          } else {
                            notifier.triggerDashboardAction(
                              'Navigated to ${target.name}',
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 18.0),
                      _TopCustomersFeatureCard(
                        customers: state.topCustomers,
                        selectedIndex: state.selectedCustomerIndex,
                        onSelectCustomer: notifier.selectTopCustomer,
                        onViewAllTap: () {
                          if (onQuickLinkSelected != null) {
                            onQuickLinkSelected!(
                              DashboardQuickLinkTarget.customer,
                            );
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18.0),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktopCharts = constraints.maxWidth >= 900.0;

                  if (isDesktopCharts) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 56,
                          child: OrderStatisticsChartCard(
                            selectedFilter: state.selectedStatsFilter,
                            totalOrdersCount: state.totalOrdersCount,
                            points: state.weeklyStatistics,
                            onFilterChanged: notifier.selectStatsFilter,
                          ),
                        ),
                        const SizedBox(width: 18.0),
                        Expanded(
                          flex: 44,
                          child: RealtimeRevenueChartCard(
                            selectedFilter: state.selectedRevenueFilter,
                            normalizedPoints: state.realtimeRevenueNormalized,
                            onFilterChanged: notifier.selectRevenueFilter,
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      OrderStatisticsChartCard(
                        selectedFilter: state.selectedStatsFilter,
                        totalOrdersCount: state.totalOrdersCount,
                        points: state.weeklyStatistics,
                        onFilterChanged: notifier.selectStatsFilter,
                      ),
                      const SizedBox(height: 18.0),
                      RealtimeRevenueChartCard(
                        selectedFilter: state.selectedRevenueFilter,
                        normalizedPoints: state.realtimeRevenueNormalized,
                        onFilterChanged: notifier.selectRevenueFilter,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardTopUtilityRow extends StatelessWidget {
  const _DashboardTopUtilityRow({
    required this.activeOrdersCount,
    required this.onUpgradeTap,
    required this.onAddWorkerTap,
  });

  final int activeOrdersCount;
  final VoidCallback onUpgradeTap;
  final VoidCallback onAddWorkerTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: 12.0,
      runSpacing: 10.0,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Wrap(
          spacing: 10.0,
          runSpacing: 6.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Operations Overview',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(99.0),
                border: Border.all(color: colors.borderSubtle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 14.0,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    'No of Orders : $activeOrdersCount',
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 6.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            InteractivePressScale(
              onTap: onUpgradeTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 7.0,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.freshSkyBlue, colors.harborGold],
                  ),
                  borderRadius: BorderRadius.circular(99.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.workspace_premium_outlined,
                      size: 14.0,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5.0),
                    Text(
                      'Upgrade',
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 58.0,
              height: 28.0,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    child: _MiniCircleAvatar(
                      initials: 'ER',
                      backgroundColor: colors.harborNavy,
                    ),
                  ),
                  Positioned(
                    left: 16.0,
                    child: _MiniCircleAvatar(
                      initials: 'MO',
                      backgroundColor: colors.freshSkyBlue,
                    ),
                  ),
                  Positioned(
                    left: 32.0,
                    child: GestureDetector(
                      onTap: onAddWorkerTap,
                      child: Container(
                        width: 26.0,
                        height: 26.0,
                        decoration: BoxDecoration(
                          color: colors.background,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 14.0,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _UtilityIconCircle(icon: Icons.notifications_none_rounded),
            _UtilityIconCircle(icon: Icons.settings_outlined),
            _UtilityIconCircle(icon: Icons.wb_sunny_outlined),
            _MiniCircleAvatar(
              initials: 'HR',
              backgroundColor: colors.harborGold,
              textColor: colors.harborNavy,
            ),
          ],
        ),
      ],
    );
  }
}

class _DashboardFilterActionToolbar extends StatelessWidget {
  const _DashboardFilterActionToolbar({
    required this.selectedDateFilter,
    required this.onDateFilterChanged,
    required this.onExportTap,
    required this.onNewOrderTap,
  });

  final String selectedDateFilter;
  final ValueChanged<String> onDateFilterChanged;
  final VoidCallback onExportTap;
  final VoidCallback onNewOrderTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: 12.0,
      runSpacing: 10.0,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        PopupMenuButton<String>(
          onSelected: onDateFilterChanged,
          itemBuilder: (context) =>
              const ['Last 30 days', 'Last 7 days', 'Today', 'This Quarter']
                  .map(
                    (period) => PopupMenuItem<String>(
                      value: period,
                      child: Text(period, style: textTheme.bodySmall),
                    ),
                  )
                  .toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(99.0),
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14.0,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: 8.0),
                Text(
                  selectedDateFilter,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6.0),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16.0,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 6.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            InteractivePressScale(
              onTap: onExportTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 9.0,
                ),
                decoration: BoxDecoration(
                  color: colors.harborNavy,
                  borderRadius: BorderRadius.circular(99.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.download_rounded,
                      size: 14.0,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      'Export',
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InteractivePressScale(
              onTap: onNewOrderTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 9.0,
                ),
                decoration: BoxDecoration(
                  color: colors.freshSkyBlue,
                  borderRadius: BorderRadius.circular(99.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      size: 16.0,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'New Order',
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LeftKpiAndQuickLinksColumn extends StatelessWidget {
  const _LeftKpiAndQuickLinksColumn({
    required this.state,
    required this.availableWidth,
    required this.onQuickLinkTap,
  });

  final DashboardUiState state;
  final double availableWidth;
  final ValueChanged<DashboardQuickLinkTarget> onQuickLinkTap;

  @override
  Widget build(BuildContext context) {
    final isThreeCol = availableWidth >= 560.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isThreeCol)
          Row(
            children: [
              for (var i = 0; i < state.kpiMetrics.length; i++) ...[
                if (i > 0) const SizedBox(width: 16.0),
                Expanded(child: _DashboardKpiCard(metric: state.kpiMetrics[i])),
              ],
            ],
          )
        else
          Column(
            children: [
              for (var i = 0; i < state.kpiMetrics.length; i++) ...[
                if (i > 0) const SizedBox(height: 12.0),
                _DashboardKpiCard(metric: state.kpiMetrics[i]),
              ],
            ],
          ),
        const SizedBox(height: 16.0),
        _QuickLinksRowCard(
          availableWidth: availableWidth,
          onQuickLinkTap: onQuickLinkTap,
        ),
      ],
    );
  }
}

class _DashboardKpiCard extends StatelessWidget {
  const _DashboardKpiCard({required this.metric});

  final DashboardKpiMetric metric;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final badgeBgColor = metric.isPositive
        ? const Color(0xFFE6F8EF)
        : const Color(0xFFFEE2E2);
    final badgeTextColor = metric.isPositive
        ? const Color(0xFF15803D)
        : const Color(0xFFB91C1C);

    return Container(
      padding: const EdgeInsets.fromLTRB(18.0, 16.0, 18.0, 16.0),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: colors.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 14.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  metric.title,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 34.0,
                height: 34.0,
                decoration: BoxDecoration(
                  color: metric.accentColor,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.65),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(metric.icon, size: 16.0, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            metric.value,
            style: textTheme.titleLarge?.copyWith(
              fontSize: 22.0,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(99.0),
                ),
                child: Text(
                  metric.changeBadge,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    color: badgeTextColor,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 28.0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (
                      var i = 0;
                      i < metric.sparklineHeights.length;
                      i++
                    ) ...[
                      if (i > 0) const SizedBox(width: 4.0),
                      Container(
                        width: 4.0,
                        height: 28.0 * metric.sparklineHeights[i],
                        decoration: BoxDecoration(
                          color: metric.accentColor,
                          borderRadius: BorderRadius.circular(99.0),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickLinksRowCard extends StatelessWidget {
  const _QuickLinksRowCard({
    required this.availableWidth,
    required this.onQuickLinkTap,
  });

  final double availableWidth;
  final ValueChanged<DashboardQuickLinkTarget> onQuickLinkTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final innerWidth = (availableWidth - 40.0).clamp(200.0, 2000.0);
    final isWideRow = innerWidth >= 520.0;

    final links =
        <
          ({
            String label,
            IconData icon,
            Color iconColor,
            DashboardQuickLinkTarget target,
          })
        >[
          (
            label: 'Orders',
            icon: Icons.shopping_cart_outlined,
            iconColor: colors.freshSkyBlue,
            target: DashboardQuickLinkTarget.orders,
          ),
          (
            label: 'Products',
            icon: Icons.shopping_bag_outlined,
            iconColor: colors.harborNavy,
            target: DashboardQuickLinkTarget.products,
          ),
          (
            label: 'Invoices',
            icon: Icons.monetization_on_outlined,
            iconColor: colors.harborNavy,
            target: DashboardQuickLinkTarget.invoices,
          ),
          (
            label: 'Customer',
            icon: Icons.person_outline_rounded,
            iconColor: colors.freshSkyBlue,
            target: DashboardQuickLinkTarget.customer,
          ),
          (
            label: 'Drivers',
            icon: Icons.directions_bike_outlined,
            iconColor: colors.harborNavy,
            target: DashboardQuickLinkTarget.drivers,
          ),
        ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 18.0),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: colors.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 14.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Links',
            style: textTheme.titleSmall?.copyWith(
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 14.0),
          if (isWideRow)
            Row(
              children: [
                for (var i = 0; i < links.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10.0),
                  Expanded(
                    child: _QuickLinkTile(
                      label: links[i].label,
                      icon: links[i].icon,
                      iconColor: links[i].iconColor,
                      onTap: () => onQuickLinkTap(links[i].target),
                    ),
                  ),
                ],
              ],
            )
          else
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: links
                  .map(
                    (item) => SizedBox(
                      width: (innerWidth - 10.0) / 2,
                      child: _QuickLinkTile(
                        label: item.label,
                        icon: item.icon,
                        iconColor: item.iconColor,
                        onTap: () => onQuickLinkTap(item.target),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _QuickLinkTile extends StatelessWidget {
  const _QuickLinkTile({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return InteractivePressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 13.0),
        decoration: BoxDecoration(
          color: colors.background.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16.0, color: iconColor),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16.0,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopCustomersFeatureCard extends StatelessWidget {
  const _TopCustomersFeatureCard({
    required this.customers,
    required this.selectedIndex,
    required this.onSelectCustomer,
    required this.onViewAllTap,
  });

  final List<DashboardTopCustomer> customers;
  final int selectedIndex;
  final ValueChanged<int> onSelectCustomer;
  final VoidCallback onViewAllTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    if (customers.isEmpty) {
      return Container(
        padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.freshSkyBlue,
              const Color(0xFF124E8C),
              colors.harborNavy,
            ],
          ),
          borderRadius: BorderRadius.circular(14.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F152042),
              blurRadius: 18.0,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Top Customers',
                    style: textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onViewAllTap,
                  child: Text(
                    'View All',
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            Center(
              child: Container(
                width: 56.0,
                height: 56.0,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people_outline_rounded,
                  color: Colors.white,
                  size: 26.0,
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              'No Customer Orders Yet',
              textAlign: TextAlign.center,
              style: textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Customer insights and ranking will populate automatically when transactions are recorded.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11.0,
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      );
    }

    final activeCustomer =
        customers[selectedIndex.clamp(0, customers.length - 1)];

    return Container(
      padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.freshSkyBlue,
            const Color(0xFF124E8C),
            colors.harborNavy,
          ],
        ),
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F152042),
            blurRadius: 18.0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Top Customers',
                  style: textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              InkWell(
                onTap: onViewAllTap,
                child: Text(
                  'View All',
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          Center(
            child: SizedBox(
              width: 176.0,
              height: 58.0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (final offsetIndex in [0, 4, 1, 3, 2])
                    if (offsetIndex < customers.length)
                      Positioned(
                        left: offsetIndex * 30.0,
                        child: GestureDetector(
                          onTap: () => onSelectCustomer(offsetIndex),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: offsetIndex == selectedIndex ? 54.0 : 40.0,
                            height: offsetIndex == selectedIndex ? 54.0 : 40.0,
                            decoration: BoxDecoration(
                              color: customers[offsetIndex].avatarBackground,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: offsetIndex == selectedIndex
                                    ? colors.harborGold
                                    : Colors.white,
                                width: offsetIndex == selectedIndex ? 2.5 : 1.8,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 8.0,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              customers[offsetIndex].initials,
                              style: textTheme.labelSmall?.copyWith(
                                color: customers[offsetIndex].avatarAccent,
                                fontSize: offsetIndex == selectedIndex
                                    ? 14.0
                                    : 11.0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Column(
              children: [
                Text(
                  activeCustomer.name,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  activeCustomer.totalSpent,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  activeCustomer.ordersCountLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 3.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(99.0),
                ),
                child: Text(
                  activeCustomer.growthBadge,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.harborNavy,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Flexible(
                child: Text(
                  'Increased from last month',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniCircleAvatar extends StatelessWidget {
  const _MiniCircleAvatar({
    required this.initials,
    required this.backgroundColor,
    this.textColor = Colors.white,
  });

  final String initials;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26.0,
      height: 26.0,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: textColor,
          fontSize: 10.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _UtilityIconCircle extends StatelessWidget {
  const _UtilityIconCircle({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: 28.0,
      height: 28.0,
      decoration: BoxDecoration(
        color: colors.background,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 15.0, color: colors.textSecondary),
    );
  }
}
