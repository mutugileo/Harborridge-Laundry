import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';
import 'package:laundry_ridge/features/orders/presentation/order_details_notifier.dart';

class ReportsView extends ConsumerStatefulWidget {
  const ReportsView({super.key, this.onFilterOrdersByBranch});

  final ValueChanged<String>? onFilterOrdersByBranch;

  @override
  ConsumerState<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends ConsumerState<ReportsView> {
  String _selectedPeriod = 'Nov 2026';
  String _selectedChartMetric = 'Revenue';
  String _selectedBranchFilter = 'All Branches';
  String? _exportMessage;

  static const List<String> _periods = [
    'Nov 2026',
    'Oct 2026',
    'Q4 2026',
    'Full Year 2026',
  ];

  static const List<String> _branches = [
    'All Branches',
    'Harborridge Main',
    'LaundryGo Nairobi',
    'LaundryGo Westlands',
    'LaundryGo Kilimani',
  ];

  double get _periodMultiplier => switch (_selectedPeriod) {
    'Nov 2026' => 1.0,
    'Oct 2026' => 0.92,
    'Q4 2026' => 2.85,
    'Full Year 2026' => 11.4,
    _ => 1.0,
  };

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(orderDetailsNotifierProvider);
    final colors = context.colors;
    final motion = context.motion;
    final textTheme = Theme.of(context).textTheme;

    final liveOrderCount = ordersState.orders.length;
    final totalOrders = (2146 * _periodMultiplier).round() + liveOrderCount;
    final grossRevenueKes = (485740 * _periodMultiplier).round();
    final netMarginKes = (grossRevenueKes * 0.78).round();

    final serviceBreakdown = [
      (
        service: 'Wash & Iron (Hanger & Crisp Press)',
        revenue: 'KES ${(194200 * _periodMultiplier).round()}',
        ordersCount: '${(912 * _periodMultiplier).round()} Orders',
        share: 0.42,
        color: colors.freshSkyBlue,
      ),
      (
        service: 'Wash & Fold (By Weight / Bulk)',
        revenue: 'KES ${(148500 * _periodMultiplier).round()}',
        ordersCount: '${(684 * _periodMultiplier).round()} Orders',
        share: 0.31,
        color: colors.harborGold,
      ),
      (
        service: 'Dry Cleaning (Suits, Gowns & Silk)',
        revenue: 'KES ${(98400 * _periodMultiplier).round()}',
        ordersCount: '${(318 * _periodMultiplier).round()} Orders',
        share: 0.19,
        color: colors.accentGreen,
      ),
      (
        service: 'Wet Wash & Stain Care Addons',
        revenue: 'KES ${(44640 * _periodMultiplier).round()}',
        ordersCount: '${(238 * _periodMultiplier).round()} Orders',
        share: 0.08,
        color: colors.harborNavy,
      ),
    ];

    final branchPerformance =
        <
          ({
            String branch,
            int orders,
            String revenue,
            String consumables,
            String sla,
            String topRider,
            String margin,
          })
        >[
          (
            branch: 'Harborridge Main',
            orders: (740 * _periodMultiplier).round(),
            revenue: 'KES ${(182400 * _periodMultiplier).round()}',
            consumables: 'KES ${(19400 * _periodMultiplier).round()}',
            sla: '98.2%',
            topRider: 'Peter Mwangi',
            margin: '+82.4%',
          ),
          (
            branch: 'LaundryGo Nairobi',
            orders: (620 * _periodMultiplier).round() + liveOrderCount,
            revenue: 'KES ${(141200 * _periodMultiplier).round()}',
            consumables: 'KES ${(15800 * _periodMultiplier).round()}',
            sla: '96.8%',
            topRider: 'David Ochieng',
            margin: '+79.1%',
          ),
          (
            branch: 'LaundryGo Westlands',
            orders: (465 * _periodMultiplier).round(),
            revenue: 'KES ${(96800 * _periodMultiplier).round()}',
            consumables: 'KES ${(11200 * _periodMultiplier).round()}',
            sla: '95.4%',
            topRider: 'Samuel Kariuki',
            margin: '+76.5%',
          ),
          (
            branch: 'LaundryGo Kilimani',
            orders: (321 * _periodMultiplier).round(),
            revenue: 'KES ${(65340 * _periodMultiplier).round()}',
            consumables: 'KES ${(7900 * _periodMultiplier).round()}',
            sla: '94.9%',
            topRider: 'Kelvin Mutua',
            margin: '+74.8%',
          ),
        ];

    final filteredBranches = _selectedBranchFilter == 'All Branches'
        ? branchPerformance
        : branchPerformance
              .where((b) => b.branch == _selectedBranchFilter)
              .toList();

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Toolbar & Period Selector
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12.0,
                  runSpacing: 10.0,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isMobile
                            ? (screenWidth - 48.0).clamp(200.0, 500.0)
                            : 600.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36.0,
                            height: 36.0,
                            decoration: BoxDecoration(
                              color: colors.freshSkyBlue.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(
                              Icons.insights_rounded,
                              size: 19.0,
                              color: colors.freshSkyBlue,
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Executive Operations & Financial Reports',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Turnaround SLA compliance, service mix revenue & branch margins • $_selectedPeriod',
                                  maxLines: isMobile ? 2 : 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    fontSize: 11.5,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final period in _periods)
                          InteractivePressScale(
                            onTap: () =>
                                setState(() => _selectedPeriod = period),
                            child: AnimatedContainer(
                              duration: motion.shortDuration,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11.0,
                                vertical: 6.0,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedPeriod == period
                                    ? colors.harborNavy
                                    : colors.background,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: _selectedPeriod == period
                                      ? colors.harborNavy
                                      : colors.borderSubtle,
                                ),
                              ),
                              child: Text(
                                period,
                                style: textTheme.labelSmall?.copyWith(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedPeriod == period
                                      ? Colors.white
                                      : colors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 4.0),
                        InteractivePressScale(
                          onTap: () => setState(() {
                            _exportMessage =
                                'Exported Executive Financial & SLA Report ($totalOrders orders) for $_selectedPeriod as PDF & CSV';
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13.0,
                              vertical: 7.0,
                            ),
                            decoration: BoxDecoration(
                              color: colors.freshSkyBlue,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.download_rounded,
                                  size: 14.0,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 5.0),
                                Text(
                                  'Export PDF / CSV',
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
                      ],
                    ),
                  ],
                ),
                AnimatedSwitcher(
                  duration: motion.shortDuration,
                  child: _exportMessage == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                              vertical: 8.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F8EF),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              _exportMessage!,
                              style: textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF15803D),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14.0),

          // Unified Integrated Metric Strip (Single Surface with hairline dividers)
          _buildIntegratedMetricsStrip(
            context: context,
            colors: colors,
            textTheme: textTheme,
            grossRevenueKes: grossRevenueKes,
            totalOrders: totalOrders,
            liveOrderCount: liveOrderCount,
            netMarginKes: netMarginKes,
          ),
          const SizedBox(height: 14.0),

          // Row 2: Visual Analytics (Left = Revenue Trajectory Chart, Right = Service Mix Donut + Breakdown)
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 960.0;

              final trendChartCard = _buildRevenueTrendCard(
                colors,
                textTheme,
                motion,
              );
              final serviceMixCard = _buildServiceMixCard(
                colors,
                textTheme,
                serviceBreakdown,
              );

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 56, child: trendChartCard),
                    const SizedBox(width: 16.0),
                    Expanded(flex: 44, child: serviceMixCard),
                  ],
                );
              }

              return Column(
                children: [
                  trendChartCard,
                  const SizedBox(height: 16.0),
                  serviceMixCard,
                ],
              );
            },
          ),
          const SizedBox(height: 16.0),

          // Row 3: Branch & Rider Performance Matrix
          _buildBranchPerformanceMatrix(
            colors,
            textTheme,
            motion,
            filteredBranches,
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTrendCard(
    AppColors colors,
    TextTheme textTheme,
    AppMotion motion,
  ) {
    const metrics = ['Revenue', 'Order Volume', 'SLA Compliance'];

    return Container(
      padding: const EdgeInsets.all(22.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10.0,
            runSpacing: 8.0,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revenue & Turnaround Trajectory ($_selectedPeriod)',
                    style: textTheme.titleSmall?.copyWith(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    'Weekly performance bars with smooth moving-average trendline',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11.0,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 6.0,
                children: metrics.map((metric) {
                  final isSelected = _selectedChartMetric == metric;
                  return InteractivePressScale(
                    onTap: () => setState(() => _selectedChartMetric = metric),
                    child: AnimatedContainer(
                      duration: motion.shortDuration,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 5.0,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.harborNavy
                            : colors.background,
                        borderRadius: BorderRadius.circular(99.0),
                      ),
                      child: Text(
                        metric,
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : colors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 18.0),
          SizedBox(
            height: 220.0,
            width: double.infinity,
            child: CustomPaint(
              painter: _ReportsTrajectoryChartPainter(
                metric: _selectedChartMetric,
                period: _selectedPeriod,
                primaryColor: colors.freshSkyBlue,
                secondaryColor: colors.harborGold,
                navyColor: colors.harborNavy,
                gridColor: colors.borderSubtle,
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _ChartWeekLabel('Wk 1'),
              _ChartWeekLabel('Wk 2'),
              _ChartWeekLabel('Wk 3'),
              _ChartWeekLabel('Wk 4'),
              _ChartWeekLabel('Wk 5'),
              _ChartWeekLabel('Wk 6'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceMixCard(
    AppColors colors,
    TextTheme textTheme,
    List<
      ({
        String service,
        String revenue,
        String ordersCount,
        double share,
        Color color,
      })
    >
    serviceBreakdown,
  ) {
    return Container(
      padding: const EdgeInsets.all(22.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Mix Revenue Breakdown',
                      style: textTheme.titleSmall?.copyWith(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      'Contribution by laundry care category',
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 11.0,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 64.0,
                height: 64.0,
                child: CustomPaint(
                  painter: _ServiceMixDonutPainter(
                    shares: serviceBreakdown.map((e) => e.share).toList(),
                    segmentColors: serviceBreakdown
                        .map((e) => e.color)
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          for (final item in serviceBreakdown) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: colors.background.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: colors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          item.service,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          '${item.revenue} • ${item.ordersCount} (${(item.share * 100).round()}%)',
                          style: textTheme.labelMedium?.copyWith(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w800,
                            color: colors.harborNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7.0),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99.0),
                      child: LinearProgressIndicator(
                        value: item.share,
                        minHeight: 6.5,
                        backgroundColor: colors.borderSubtle,
                        color: item.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBranchPerformanceMatrix(
    AppColors colors,
    TextTheme textTheme,
    AppMotion motion,
    List<
      ({
        String branch,
        int orders,
        String revenue,
        String consumables,
        String sla,
        String topRider,
        String margin,
      })
    >
    branches,
  ) {
    return Container(
      padding: const EdgeInsets.all(22.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12.0,
            runSpacing: 10.0,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Branch Profitability & SLA Compliance Matrix',
                    style: textTheme.titleSmall?.copyWith(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    'Compare branch order volume, chemical dosing cost, SLA speed, and net operating margin.',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11.0,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                children: _branches.map((branch) {
                  final isSelected = _selectedBranchFilter == branch;
                  return InteractivePressScale(
                    onTap: () => setState(() => _selectedBranchFilter = branch),
                    child: AnimatedContainer(
                      duration: motion.shortDuration,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.harborNavy
                            : colors.background,
                        borderRadius: BorderRadius.circular(99.0),
                      ),
                      child: Text(
                        branch,
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : colors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          Container(
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Column(
              children: [
                for (var i = 0; i < branches.length; i++) ...[
                  if (i > 0) Divider(height: 1.0, color: colors.borderSubtle),
                  InteractivePressScale(
                    onTap: () =>
                        widget.onFilterOrdersByBranch?.call(branches[i].branch),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                        vertical: 14.0,
                      ),
                      color: Colors.transparent,
                      child: Wrap(
                        spacing: 18.0,
                        runSpacing: 8.0,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: 190.0,
                            child: Row(
                              children: [
                                Container(
                                  width: 32.0,
                                  height: 32.0,
                                  decoration: BoxDecoration(
                                    color: colors.freshSkyBlue.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Icon(
                                    Icons.storefront_outlined,
                                    size: 16.0,
                                    color: colors.freshSkyBlue,
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${branches[i].branch} →',
                                        style: textTheme.labelMedium?.copyWith(
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w700,
                                          color: colors.freshSkyBlue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      Text(
                                        'Lead: ${branches[i].topRider}',
                                        style: textTheme.bodySmall?.copyWith(
                                          fontSize: 11.0,
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _BranchMetricColumn(
                            label: 'Orders',
                            value: '${branches[i].orders}',
                          ),
                          _BranchMetricColumn(
                            label: 'Gross Revenue',
                            value: branches[i].revenue,
                          ),
                          _BranchMetricColumn(
                            label: 'Chemical Cost',
                            value: branches[i].consumables,
                          ),
                          _BranchMetricColumn(
                            label: '24h SLA',
                            value: branches[i].sla,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 5.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F8EF),
                              borderRadius: BorderRadius.circular(99.0),
                            ),
                            child: Text(
                              '${branches[i].margin} Net Margin',
                              style: textTheme.labelSmall?.copyWith(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchMetricColumn extends StatelessWidget {
  const _BranchMetricColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 105.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              fontSize: 10.0,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            value,
            style: textTheme.labelMedium?.copyWith(
              fontSize: 13.0,
              fontWeight: FontWeight.w800,
              color: colors.harborNavy,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartWeekLabel extends StatelessWidget {
  const _ChartWeekLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontSize: 11.0,
        color: context.colors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

Widget _buildIntegratedMetricsStrip({
  required BuildContext context,
  required AppColors colors,
  required TextTheme textTheme,
  required int grossRevenueKes,
  required int totalOrders,
  required int liveOrderCount,
  required int netMarginKes,
}) {
  final metrics = [
    (
      icon: Icons.payments_rounded,
      iconBg: colors.freshSkyBlue,
      title: 'GROSS REVENUE',
      value: 'KES $grossRevenueKes',
      meta: '+18.4% vs prior period',
      metaColor: colors.accentGreen,
    ),
    (
      icon: Icons.local_laundry_service_rounded,
      iconBg: colors.harborGold,
      title: 'ORDERS PROCESSED',
      value: '$totalOrders Orders',
      meta: '$liveOrderCount active in plant',
      metaColor: colors.harborGold,
    ),
    (
      icon: Icons.timer_outlined,
      iconBg: colors.accentGreen,
      title: '24H SLA COMPLIANCE',
      value: '96.4%',
      meta: 'Avg turnaround: 4.2h',
      metaColor: colors.accentGreen,
    ),
    (
      icon: Icons.trending_up_rounded,
      iconBg: colors.harborNavy,
      title: 'NET OPERATING MARGIN',
      value: 'KES $netMarginKes',
      meta: '78.0% EBITDA conversion',
      metaColor: colors.freshSkyBlue,
    ),
  ];

  return Container(
    decoration: BoxDecoration(
      color: colors.cardBackground,
      borderRadius: BorderRadius.circular(14.0),
      border: Border.all(color: colors.borderSubtle),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 820.0;
        if (isWide) {
          return IntrinsicHeight(
            child: Row(
              children: [
                for (var i = 0; i < metrics.length; i++) ...[
                  if (i > 0)
                    VerticalDivider(
                      width: 1.0,
                      thickness: 1.0,
                      color: colors.borderSubtle,
                    ),
                  Expanded(child: _MetricStripTile(data: metrics[i])),
                ],
              ],
            ),
          );
        }

        return Column(
          children: [
            for (var i = 0; i < metrics.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1.0,
                  thickness: 1.0,
                  color: colors.borderSubtle,
                ),
              _MetricStripTile(data: metrics[i]),
            ],
          ],
        );
      },
    ),
  );
}

class _MetricStripTile extends StatelessWidget {
  const _MetricStripTile({required this.data});

  final ({
    IconData icon,
    Color iconBg,
    String title,
    String value,
    String meta,
    Color metaColor,
  })
  data;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38.0,
            height: 38.0,
            decoration: BoxDecoration(
              color: data.iconBg.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(data.icon, size: 19.0, color: data.iconBg),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  data.meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: data.metaColor,
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

class _ReportsTrajectoryChartPainter extends CustomPainter {
  const _ReportsTrajectoryChartPainter({
    required this.metric,
    required this.period,
    required this.primaryColor,
    required this.secondaryColor,
    required this.navyColor,
    required this.gridColor,
  });

  final String metric;
  final String period;
  final Color primaryColor;
  final Color secondaryColor;
  final Color navyColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    for (var i = 1; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final values = switch (metric) {
      'Order Volume' => const [0.52, 0.68, 0.61, 0.84, 0.76, 0.91],
      'SLA Compliance' => const [0.88, 0.91, 0.94, 0.93, 0.96, 0.98],
      _ => const [0.58, 0.49, 0.82, 0.66, 0.74, 0.89],
    };

    final count = values.length;
    final slotWidth = size.width / count;
    final barWidth = (slotWidth * 0.42).clamp(18.0, 38.0);
    final points = <Offset>[];

    for (var i = 0; i < count; i++) {
      final centerX = slotWidth * i + slotWidth / 2;
      final barHeight = size.height * values[i] * 0.85;
      final topY = size.height - barHeight;
      points.add(Offset(centerX, topY));

      final barRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(centerX - barWidth / 2, topY, barWidth, barHeight),
        topLeft: const Radius.circular(8.0),
        topRight: const Radius.circular(8.0),
      );

      canvas.drawRRect(
        barRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, primaryColor.withValues(alpha: 0.18)],
          ).createShader(barRect.outerRect),
      );
    }

    if (points.length >= 2) {
      final linePath = Path()..moveTo(points.first.dx, points.first.dy);
      for (var i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final midX = (p0.dx + p1.dx) / 2;
        linePath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
      }

      canvas.drawPath(
        linePath,
        Paint()
          ..color = secondaryColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round,
      );

      for (final pt in points) {
        canvas.drawCircle(pt, 5.0, Paint()..color = Colors.white);
        canvas.drawCircle(pt, 3.5, Paint()..color = navyColor);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ReportsTrajectoryChartPainter oldDelegate) {
    return oldDelegate.metric != metric || oldDelegate.period != period;
  }
}

class _ServiceMixDonutPainter extends CustomPainter {
  const _ServiceMixDonutPainter({
    required this.shares,
    required this.segmentColors,
  });

  final List<double> shares;
  final List<Color> segmentColors;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final strokeWidth = 10.0;
    final arcRect = rect.deflate(strokeWidth / 2);

    var startAngle = -math.pi / 2;
    for (var i = 0; i < shares.length; i++) {
      final sweepAngle = shares[i] * 2 * math.pi;
      canvas.drawArc(
        arcRect,
        startAngle,
        sweepAngle - 0.06,
        false,
        Paint()
          ..color = segmentColors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _ServiceMixDonutPainter oldDelegate) => false;
}
