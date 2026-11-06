import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';
import 'package:laundry_ridge/app/theme/app_typography.dart';
import 'package:laundry_ridge/core/widgets/app_skeleton.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';
import 'package:laundry_ridge/features/production/domain/production_order_card.dart';
import 'package:laundry_ridge/features/production/presentation/order_tracking_notifier.dart';
import 'package:laundry_ridge/features/production/presentation/order_tracking_state.dart';
import 'package:laundry_ridge/features/production/presentation/widgets/kanban_column_widget.dart';

class OrderTrackingBoardView extends ConsumerStatefulWidget {
  const OrderTrackingBoardView({
    super.key,
    this.onOpenOrderDetails,
    this.onNewOrderIntake,
  });

  final ValueChanged<String>? onOpenOrderDetails;
  final VoidCallback? onNewOrderIntake;

  @override
  ConsumerState<OrderTrackingBoardView> createState() =>
      _OrderTrackingBoardViewState();
}

class _OrderTrackingBoardViewState
    extends ConsumerState<OrderTrackingBoardView> {
  final TextEditingController _searchController = TextEditingController();
  BoardWorkflowTab _selectedWorkflowTab = BoardWorkflowTab.clean;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleOpenOrderDetails(String orderNumber) {
    widget.onOpenOrderDetails?.call(orderNumber);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderTrackingNotifierProvider);
    final notifier = ref.read(orderTrackingNotifierProvider.notifier);
    final colors = context.colors;
    final motion = context.motion;

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Container(
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBoardTopBar(
                context: context,
                state: state,
                notifier: notifier,
              ),
              Divider(height: 1.0, color: colors.borderSubtle),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: AnimatedSwitcher(
                  duration: motion.mediumDuration,
                  switchInCurve: motion.standardCurve,
                  switchOutCurve: motion.standardCurve,
                  child: _buildBoardBody(
                    context: context,
                    state: state,
                    notifier: notifier,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoardTopBar({
    required BuildContext context,
    required OrderTrackingState state,
    required OrderTrackingNotifier notifier,
  }) {
    final colors = context.colors;
    final motion = context.motion;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Production Floor & Kanban Telemetry Title + Segmented Navigation & Search
          Wrap(
            spacing: 12.0,
            runSpacing: 10.0,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38.0,
                    height: 38.0,
                    decoration: BoxDecoration(
                      color: colors.freshSkyBlue.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Icon(
                      Icons.precision_manufacturing_outlined,
                      size: 20.0,
                      color: colors.freshSkyBlue,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Production Floor & Kanban Telemetry',
                        style: textTheme.titleLarge?.copyWith(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        'Live stage tracking across In Queue, Cleaning, Drying, and Fold stations • ${state.orders.length} active loads',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: AppTypography.captionSize,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Workflow Tabs matching production reference
                  Container(
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(99.0),
                      border: Border.all(color: colors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final tab in BoardWorkflowTab.values)
                          InteractivePressScale(
                            onTap: () {
                              if (tab == BoardWorkflowTab.newOrder) {
                                widget.onNewOrderIntake?.call();
                              } else {
                                setState(() => _selectedWorkflowTab = tab);
                              }
                            },
                            child: AnimatedContainer(
                              duration: motion.shortDuration,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11.0,
                                vertical: 5.0,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedWorkflowTab == tab
                                    ? colors.harborNavy
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(99.0),
                              ),
                              child: Text(
                                tab.label,
                                style: textTheme.labelSmall?.copyWith(
                                  fontSize: AppTypography.captionSize,
                                  fontWeight: _selectedWorkflowTab == tab
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: _selectedWorkflowTab == tab
                                      ? Colors.white
                                      : colors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 220.0,
                    height: 36.0,
                    child: TextField(
                      controller: _searchController,
                      onChanged: notifier.updateSearchQuery,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: AppTypography.bodySmallSize,
                        color: colors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Filter by order, customer...',
                        hintStyle: textTheme.bodySmall?.copyWith(
                          fontSize: AppTypography.captionSize,
                          color: colors.textTertiary,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 16.0,
                          color: colors.textSecondary,
                        ),
                        filled: true,
                        fillColor: colors.background,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 8.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(99.0),
                          borderSide: BorderSide(color: colors.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(99.0),
                          borderSide: BorderSide(color: colors.borderSubtle),
                        ),
                      ),
                    ),
                  ),
                  if (widget.onNewOrderIntake != null)
                    InteractivePressScale(
                      onTap: widget.onNewOrderIntake,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: colors.harborNavy,
                          borderRadius: BorderRadius.circular(99.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_circle_outline_rounded,
                              size: 14.0,
                              color: colors.harborGold,
                            ),
                            const SizedBox(width: 5.0),
                            Text(
                              '+ New Intake',
                              style: textTheme.labelSmall?.copyWith(
                                fontSize: AppTypography.captionSize,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
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
          const SizedBox(height: 16.0),

          // Row 2: Unified Integrated Live Telemetry Strip
          _buildIntegratedTelemetryStrip(
            context: context,
            colors: colors,
            textTheme: textTheme,
            totalOrders: state.orders.length,
          ),
          const SizedBox(height: 14.0),

          // Row 3: Priority Filter Chips
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _PriorityFilterChip(
                label: 'All Priorities (${state.orders.length})',
                isSelected: state.selectedPriorityFilter == null,
                onTap: () => notifier.filterByPriority(null),
                motion: motion,
                colors: colors,
              ),
              for (final priority in OrderPriority.values)
                _PriorityFilterChip(
                  label: '${priority.label} Priority',
                  isSelected: state.selectedPriorityFilter == priority,
                  onTap: () => notifier.filterByPriority(priority),
                  motion: motion,
                  colors: colors,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntegratedTelemetryStrip({
    required BuildContext context,
    required AppColors colors,
    required TextTheme textTheme,
    required int totalOrders,
  }) {
    final metrics = [
      (
        icon: Icons.local_laundry_service_outlined,
        iconBg: colors.freshSkyBlue,
        title: 'IN-QUEUE LOADS',
        value: '$totalOrders Active Loads',
        meta: 'To-Do, Clean, Dry, Fold',
        metaColor: colors.accentGreen,
      ),
      (
        icon: Icons.speed_rounded,
        iconBg: colors.accentGreen,
        title: 'SLA ADHERENCE',
        value: '96.4% On-Track',
        meta: 'Within 24h turnaround target',
        metaColor: colors.accentGreen,
      ),
      (
        icon: Icons.scale_outlined,
        iconBg: colors.harborNavy,
        title: 'DAILY VOLUME',
        value: '87.6 lbs Total',
        meta: 'Avg 13.5 lbs per load drum',
        metaColor: colors.freshSkyBlue,
      ),
      (
        icon: Icons.badge_outlined,
        iconBg: colors.harborGold,
        title: 'STATION CREW',
        value: '4 Specialists',
        meta: 'Elena, Sarah, Marcus, David',
        metaColor: colors.textSecondary,
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
                    Expanded(
                      child: _TelemetryMetricStripTile(data: metrics[i]),
                    ),
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
                _TelemetryMetricStripTile(data: metrics[i]),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildBoardBody({
    required BuildContext context,
    required OrderTrackingState state,
    required OrderTrackingNotifier notifier,
  }) {
    switch (state.status) {
      case OrderTrackingStatus.loading:
        return _buildSkeletonColumns(context);

      case OrderTrackingStatus.error:
        final colors = context.colors;
        final textTheme = Theme.of(context).textTheme;
        return Center(
          key: const ValueKey('tracking_error'),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 40.0,
                  color: colors.statusError,
                ),
                const SizedBox(height: 12.0),
                Text(
                  state.errorMessage ?? 'Unable to load production board',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 16.0),
                InteractivePressScale(
                  onTap: notifier.loadProductionBoard,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: colors.brandPrimary,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'Retry',
                      style: textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case OrderTrackingStatus.success:
        return LayoutBuilder(
          key: const ValueKey('tracking_columns'),
          builder: (context, constraints) {
            final isFourColumn = constraints.maxWidth >= 820.0;
            final isTwoColumn =
                constraints.maxWidth >= 480.0 && constraints.maxWidth < 820.0;

            final columnWidgets = ProductionStage.values.map((stage) {
              return KanbanColumnWidget(
                stage: stage,
                orders: state.ordersForStage(stage),
                selectedPriorityFilter: state.selectedPriorityFilter,
                onPriorityFilterChanged: notifier.filterByPriority,
                onOrderDropped: (orderNumber) {
                  notifier.moveOrderToStage(
                    orderNumber: orderNumber,
                    targetStage: stage,
                  );
                },
                onAdvanceOrderStage: notifier.advanceOrderToNextStage,
                onOpenOrderDetails: _handleOpenOrderDetails,
                onDragStarted: notifier.setDraggedOrder,
                onDragEnded: () => notifier.setDraggedOrder(null),
              );
            }).toList();

            if (isFourColumn) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < columnWidgets.length; i++) ...[
                    if (i > 0) const SizedBox(width: 14.0),
                    Expanded(child: columnWidgets[i]),
                  ],
                ],
              );
            }

            if (isTwoColumn) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: columnWidgets[0]),
                      const SizedBox(width: 14.0),
                      Expanded(child: columnWidgets[1]),
                    ],
                  ),
                  const SizedBox(height: 14.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: columnWidgets[2]),
                      const SizedBox(width: 14.0),
                      Expanded(child: columnWidgets[3]),
                    ],
                  ),
                ],
              );
            }

            return Column(
              children: [
                for (var i = 0; i < columnWidgets.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14.0),
                  columnWidgets[i],
                ],
              ],
            );
          },
        );
    }
  }

  Widget _buildSkeletonColumns(BuildContext context) {
    return Row(
      key: const ValueKey('tracking_skeleton'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(4, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 14.0),
            child: const Column(
              children: [
                AppSkeleton(width: 110.0, height: 24.0),
                SizedBox(height: 16.0),
                AppSkeleton(width: double.infinity, height: 150.0),
                SizedBox(height: 12.0),
                AppSkeleton(width: double.infinity, height: 150.0),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _PriorityFilterChip extends StatelessWidget {
  const _PriorityFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.motion,
    required this.colors,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final AppMotion motion;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InteractivePressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: motion.shortDuration,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.5),
        decoration: BoxDecoration(
          color: isSelected ? colors.harborNavy : colors.background,
          borderRadius: BorderRadius.circular(99.0),
          border: Border.all(
            color: isSelected ? colors.harborNavy : colors.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            fontSize: AppTypography.captionSize,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _TelemetryMetricStripTile extends StatelessWidget {
  const _TelemetryMetricStripTile({required this.data});

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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 36.0,
            height: 36.0,
            decoration: BoxDecoration(
              color: data.iconBg.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9.0),
            ),
            child: Icon(data.icon, size: 18.0, color: data.iconBg),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.microSize,
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
                    fontSize: AppTypography.bodySize,
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
                    fontSize: AppTypography.microSize,
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
