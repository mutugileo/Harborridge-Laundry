import 'package:flutter/material.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_typography.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.badgeColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 28.0),
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final Color? badgeColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final effectiveBadgeColor = badgeColor ?? colors.freshSkyBlue;

    return Center(
      child: Padding(
        padding: padding,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 76.0,
                height: 76.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: effectiveBadgeColor.withValues(alpha: 0.08),
                  border: Border.all(
                    color: effectiveBadgeColor.withValues(alpha: 0.18),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 52.0,
                  height: 52.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: effectiveBadgeColor.withValues(alpha: 0.14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 26.0, color: effectiveBadgeColor),
                ),
              ),
              const SizedBox(height: 18.0),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                description,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: AppTypography.captionSize,
                  color: colors.textSecondary,
                  height: 1.45,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 20.0),
                Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  alignment: WrapAlignment.center,
                  children: [
                    InteractivePressScale(
                      onTap: onAction,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 9.0,
                        ),
                        decoration: BoxDecoration(
                          color: colors.freshSkyBlue,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: colors.freshSkyBlue.withValues(
                                alpha: 0.28,
                              ),
                              blurRadius: 12.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              actionIcon ?? Icons.add_rounded,
                              size: 15.0,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6.0),
                            Flexible(
                              child: Text(
                                actionLabel!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontSize: AppTypography.captionSize,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (secondaryActionLabel != null &&
                        onSecondaryAction != null)
                      InteractivePressScale(
                        onTap: onSecondaryAction,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 9.0,
                          ),
                          decoration: BoxDecoration(
                            color: colors.cardBackground,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: colors.borderSubtle),
                          ),
                          child: Text(
                            secondaryActionLabel!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.textPrimary,
                              fontSize: AppTypography.captionSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
