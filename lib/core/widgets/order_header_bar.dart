import 'package:flutter/material.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';

class OrderHeaderBar extends StatelessWidget {
  const OrderHeaderBar({
    super.key,
    required this.onToggleDrawer,
    required this.onBackPressed,
    this.title = 'Order Details',
    this.activeWorkerLabel,
    this.onChangePinTap,
    this.onSwitchWorkerTap,
  });

  final VoidCallback onToggleDrawer;
  final VoidCallback onBackPressed;
  final String title;
  final String? activeWorkerLabel;
  final VoidCallback? onChangePinTap;
  final VoidCallback? onSwitchWorkerTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 620.0;
        final isVeryCompact = constraints.maxWidth < 420.0;

        return Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 22.0, 0.0, 14.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: onToggleDrawer,
                    borderRadius: BorderRadius.circular(6.0),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.menu_rounded,
                        color: Colors.white,
                        size: 20.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      isVeryCompact
                          ? 'HARBORRIDGE'
                          : 'HARBORRIDGE — LAUNDRY SERVICE —',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.harborGold,
                        fontSize: isVeryCompact ? 12.0 : 13.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: isVeryCompact ? 0.5 : 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  if (onChangePinTap != null) ...[
                    InteractivePressScale(
                      onTap: onChangePinTap,
                      child: Container(
                        key: const ValueKey('header_change_pin_button'),
                        padding: EdgeInsets.symmetric(
                          horizontal: isVeryCompact ? 7.0 : 9.0,
                          vertical: 5.0,
                        ),
                        decoration: BoxDecoration(
                          color: colors.harborGold.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(99.0),
                          border: Border.all(
                            color: colors.harborGold.withValues(alpha: 0.55),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.pin_outlined,
                              size: 13.0,
                              color: colors.harborGold,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              isVeryCompact ? 'PIN' : 'Change PIN',
                              style: textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6.0),
                  ],
                  if (activeWorkerLabel != null) ...[
                    Flexible(
                      child: InteractivePressScale(
                        onTap: onSwitchWorkerTap,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isVeryCompact ? 7.0 : 10.0,
                            vertical: 5.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(99.0),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.28),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                size: 13.0,
                                color: colors.harborGold,
                              ),
                              const SizedBox(width: 4.0),
                              Flexible(
                                child: Text(
                                  activeWorkerLabel!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!isCompact) const SizedBox(width: 10.0),
                  ] else ...[
                    const Icon(Icons.person, color: Colors.white, size: 17.0),
                    if (!isCompact) const SizedBox(width: 14.0),
                  ],
                  if (!isCompact)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'English',
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.textPrimary,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: colors.textSecondary,
                            size: 16.0,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: AnimatedSwitcher(
                        duration: context.motion.shortDuration,
                        switchInCurve: context.motion.emphasizedCurve,
                        switchOutCurve: context.motion.standardCurve,
                        transitionBuilder: (child, animation) {
                          final slide = Tween<Offset>(
                            begin: const Offset(0.0, 0.25),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: slide,
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          title,
                          key: ValueKey('header_title_$title'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  InteractivePressScale(
                    onTap: onBackPressed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_rounded,
                            size: 14.0,
                            color: colors.brandPrimary,
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            'Back',
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.brandPrimary,
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
          ),
        );
      },
    );
  }
}
