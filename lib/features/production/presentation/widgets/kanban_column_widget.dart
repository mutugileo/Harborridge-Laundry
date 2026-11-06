import 'package:flutter/material.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';
import 'package:laundry_ridge/app/theme/app_typography.dart';
import 'package:laundry_ridge/features/production/domain/production_order_card.dart';
import 'package:laundry_ridge/features/production/presentation/widgets/kanban_order_card_widget.dart';

class KanbanColumnWidget extends StatelessWidget {
  const KanbanColumnWidget({
    super.key,
    required this.stage,
    required this.orders,
    required this.selectedPriorityFilter,
    required this.onPriorityFilterChanged,
    required this.onOrderDropped,
    required this.onAdvanceOrderStage,
    required this.onOpenOrderDetails,
    required this.onDragStarted,
    required this.onDragEnded,
  });

  final ProductionStage stage;
  final List<ProductionOrderCard> orders;
  final OrderPriority? selectedPriorityFilter;
  final ValueChanged<OrderPriority?> onPriorityFilterChanged;
  final ValueChanged<String> onOrderDropped;
  final ValueChanged<String> onAdvanceOrderStage;
  final ValueChanged<String> onOpenOrderDetails;
  final ValueChanged<String> onDragStarted;
  final VoidCallback onDragEnded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final motion = context.motion;
    final textTheme = Theme.of(context).textTheme;
    final stageColor = _stageColor(stage, colors);

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => details.data.isNotEmpty,
      onAcceptWithDetails: (details) => onOrderDropped(details.data),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: motion.shortDuration,
          curve: motion.standardCurve,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isHovering
                ? colors.freshSkyBlue.withValues(alpha: 0.08)
                : colors.surface,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isHovering ? colors.freshSkyBlue : colors.borderSubtle,
              width: isHovering ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Clean Stage Header with Colored Indicator & Count Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 9.0,
                ),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(9.0),
                  border: Border.all(color: colors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26.0,
                      height: 26.0,
                      decoration: BoxDecoration(
                        color: stageColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      child: Icon(
                        _stageIcon(stage),
                        size: 14.0,
                        color: stageColor,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        stage.label,
                        style: textTheme.titleMedium?.copyWith(
                          fontSize: AppTypography.sectionTitleSize,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 3.0,
                      ),
                      decoration: BoxDecoration(
                        color: stageColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(99.0),
                      ),
                      child: Text(
                        '${orders.length}',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: AppTypography.captionSize,
                          fontWeight: FontWeight.w800,
                          color: colors.harborNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12.0),

              if (orders.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 28.0,
                  ),
                  decoration: BoxDecoration(
                    color: colors.cardBackground.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: colors.borderSubtle),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 20.0,
                        color: colors.textTertiary,
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        'No loads in ${stage.label}',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: AppTypography.captionSize,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...orders.map((order) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: KanbanOrderCardWidget(
                      order: order,
                      onAdvanceStage: () =>
                          onAdvanceOrderStage(order.orderNumber),
                      onOpenOrderDetails: () =>
                          onOpenOrderDetails(order.orderNumber),
                      onDragStarted: () => onDragStarted(order.orderNumber),
                      onDragEnded: onDragEnded,
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Color _stageColor(ProductionStage stage, AppColors colors) {
    switch (stage) {
      case ProductionStage.toDo:
        return colors.harborGold;
      case ProductionStage.cleaning:
        return colors.freshSkyBlue;
      case ProductionStage.drying:
        return colors.harborNavy;
      case ProductionStage.fold:
        return colors.accentGreen;
    }
  }

  IconData _stageIcon(ProductionStage stage) {
    switch (stage) {
      case ProductionStage.toDo:
        return Icons.assignment_turned_in_outlined;
      case ProductionStage.cleaning:
        return Icons.local_laundry_service_outlined;
      case ProductionStage.drying:
        return Icons.air_rounded;
      case ProductionStage.fold:
        return Icons.checkroom_rounded;
    }
  }
}
