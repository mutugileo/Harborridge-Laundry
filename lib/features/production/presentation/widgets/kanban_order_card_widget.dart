import 'package:flutter/material.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_typography.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';
import 'package:laundry_ridge/features/production/domain/production_order_card.dart';

class KanbanOrderCardWidget extends StatelessWidget {
  const KanbanOrderCardWidget({
    super.key,
    required this.order,
    required this.onAdvanceStage,
    required this.onOpenOrderDetails,
    required this.onDragStarted,
    required this.onDragEnded,
  });

  final ProductionOrderCard order;
  final VoidCallback onAdvanceStage;
  final VoidCallback onOpenOrderDetails;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Draggable<String>(
      data: order.orderNumber,
      onDragStarted: onDragStarted,
      onDragEnd: (_) => onDragEnded(),
      feedback: Material(
        color: Colors.transparent,
        child: Transform.rotate(
          angle: -0.03,
          child: SizedBox(
            width: 260.0,
            child: _buildCardSurface(context: context, isElevated: true),
          ),
        ),
      ),
      childWhenDragging: Container(
        height: 185.0,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: colors.freshSkyBlue.withValues(alpha: 0.45),
            width: 1.5,
          ),
        ),
      ),
      child: InteractivePressScale(
        onTap: onOpenOrderDetails,
        child: _buildCardSurface(context: context, isElevated: false),
      ),
    );
  }

  Widget _buildCardSurface({
    required BuildContext context,
    required bool isElevated,
  }) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final priorityColor = _priorityDotColor(order.priority);
    final stageColor = _stageAccentColor(order.stage, colors);

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isElevated ? colors.freshSkyBlue : colors.borderSubtle,
          width: isElevated ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isElevated
                ? const Color(0x280F172A)
                : const Color(0x0C0F172A),
            blurRadius: isElevated ? 24.0 : 10.0,
            offset: Offset(0, isElevated ? 12.0 : 4.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Order Number + Priority Pill & Station Tag (no truncation)
          Wrap(
            spacing: 6.0,
            runSpacing: 4.0,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                order.orderNumber,
                style: textTheme.labelLarge?.copyWith(
                  fontSize: AppTypography.bodySize,
                  fontWeight: FontWeight.w800,
                  color: colors.harborNavy,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7.0,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(99.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.5,
                          height: 6.5,
                          decoration: BoxDecoration(
                            color: priorityColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          order.priority.label,
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: AppTypography.microSize,
                            fontWeight: FontWeight.w700,
                            color: priorityColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 2.0,
                    ),
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(6.0),
                      border: Border.all(color: colors.borderSubtle),
                    ),
                    child: Text(
                      order.stationNumber,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: AppTypography.microSize,
                        fontWeight: FontWeight.w700,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6.0),

          // Row 2: Customer Name
          Text(
            order.customerName,
            style: textTheme.titleSmall?.copyWith(
              fontSize: AppTypography.subtitleSize,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8.0),

          // Row 3: Service Type & Garment Count / Weight Pills
          Wrap(
            spacing: 6.0,
            runSpacing: 4.0,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 3.0,
                ),
                decoration: BoxDecoration(
                  color: colors.freshSkyBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  order.serviceType,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.microSize,
                    fontWeight: FontWeight.w700,
                    color: colors.harborNavy,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 3.0,
                ),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(color: colors.borderSubtle),
                ),
                child: Text(
                  order.itemCountOrWeight,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.microSize,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),

          // Row 4: Full-width Status Note Box (2 lines allowed so notes never clip with ...)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 7.0),
            decoration: BoxDecoration(
              color: colors.background.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  order.isStageComplete
                      ? Icons.check_circle_rounded
                      : Icons.sync_rounded,
                  size: 14.0,
                  color: order.isStageComplete
                      ? colors.accentGreen
                      : colors.freshSkyBlue,
                ),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Text(
                    order.statusNote,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: AppTypography.captionSize,
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4.0),
                InkWell(
                  onTap: onAdvanceStage,
                  borderRadius: BorderRadius.circular(6.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 3.0,
                    ),
                    decoration: BoxDecoration(
                      color: colors.harborNavy,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 12.0,
                      color: colors.harborGold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9.0),

          // Row 5: Assigned Staff
          Row(
            children: [
              Container(
                width: 20.0,
                height: 20.0,
                decoration: BoxDecoration(
                  color: colors.freshSkyBlue.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(order.assignedStaff),
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.microSize,
                    fontWeight: FontWeight.w800,
                    color: colors.harborNavy,
                  ),
                ),
              ),
              const SizedBox(width: 6.0),
              Expanded(
                child: Text(
                  'Staff: ${order.assignedStaff}',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: AppTypography.captionSize,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),

          // Row 6: Timestamps (Wrap prevents Due time clipping on narrow columns)
          Wrap(
            spacing: 8.0,
            runSpacing: 2.0,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                'In: ${order.timeReceived}',
                style: textTheme.labelSmall?.copyWith(
                  fontSize: AppTypography.microSize,
                  color: colors.textSecondary,
                ),
              ),
              Text(
                'Due: ${order.dueTime}',
                style: textTheme.labelSmall?.copyWith(
                  fontSize: AppTypography.microSize,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),

          // Row 7: Stage Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(99.0),
            child: LinearProgressIndicator(
              value: order.progress,
              minHeight: 5.5,
              backgroundColor: colors.borderSubtle,
              color: stageColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _stageAccentColor(ProductionStage stage, AppColors colors) {
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

  Color _priorityDotColor(OrderPriority priority) {
    switch (priority) {
      case OrderPriority.urgent:
        return const Color(0xFFD97706);
      case OrderPriority.high:
        return const Color(0xFFEA580C);
      case OrderPriority.standard:
        return const Color(0xFF0284C7);
    }
  }

  String _initials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
