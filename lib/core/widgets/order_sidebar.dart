import 'package:flutter/material.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_spacing.dart';
import 'package:laundry_ridge/core/permissions/role_permission.dart';
import 'package:laundry_ridge/core/widgets/harborridge_logo.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';

class SidebarItemData {
  const SidebarItemData({
    required this.moduleKey,
    required this.title,
    required this.icon,
    required this.iconColor,
    this.hasSubmenu = false,
  });

  final AppModuleKey moduleKey;
  final String title;
  final IconData icon;
  final Color iconColor;
  final bool hasSubmenu;
}

class OrderSidebar extends StatelessWidget {
  const OrderSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.exceptedModules = const {},
    this.onChangePinTap,
    this.onLogoutTap,
    this.isFloating = true,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final Set<AppModuleKey> exceptedModules;
  final VoidCallback? onChangePinTap;
  final VoidCallback? onLogoutTap;
  final bool isFloating;

  static const List<SidebarItemData> navItems = [
    SidebarItemData(
      moduleKey: AppModuleKey.dashboard,
      title: 'Dashboard',
      icon: Icons.storefront_outlined,
      iconColor: Color(0xFF2DA1E7),
    ),
    SidebarItemData(
      moduleKey: AppModuleKey.orders,
      title: 'Orders',
      icon: Icons.shopping_basket_outlined,
      iconColor: Color(0xFF2DA1E7),
    ),
    SidebarItemData(
      moduleKey: AppModuleKey.orderStatus,
      title: 'Order Status Screen',
      icon: Icons.format_list_bulleted_rounded,
      iconColor: Color(0xFFDCA842),
    ),
    SidebarItemData(
      moduleKey: AppModuleKey.dispatch,
      title: 'Dispatch',
      icon: Icons.local_shipping_outlined,
      iconColor: Color(0xFF124E8C),
    ),
    SidebarItemData(
      moduleKey: AppModuleKey.customers,
      title: 'Customers',
      icon: Icons.person_rounded,
      iconColor: Color(0xFF2DA1E7),
    ),
    SidebarItemData(
      moduleKey: AppModuleKey.vendors,
      title: 'Vendors',
      icon: Icons.handshake_outlined,
      iconColor: Color(0xFF152042),
    ),
    SidebarItemData(
      moduleKey: AppModuleKey.services,
      title: 'Services',
      icon: Icons.local_offer_rounded,
      iconColor: Color(0xFF2DA1E7),
      hasSubmenu: true,
    ),
    SidebarItemData(
      moduleKey: AppModuleKey.payments,
      title: 'Payments',
      icon: Icons.payments_outlined,
      iconColor: Color(0xFF1FBF75),
    ),
    SidebarItemData(
      moduleKey: AppModuleKey.settlements,
      title: 'Settlements',
      icon: Icons.account_balance_wallet_outlined,
      iconColor: Color(0xFFDCA842),
      hasSubmenu: true,
    ),
    SidebarItemData(
      moduleKey: AppModuleKey.inventory,
      title: 'Inventory',
      icon: Icons.inventory_2_outlined,
      iconColor: Color(0xFF124E8C),
    ),
    SidebarItemData(
      moduleKey: AppModuleKey.staff,
      title: 'Staff',
      icon: Icons.badge_outlined,
      iconColor: Color(0xFF2DA1E7),
    ),
    SidebarItemData(
      moduleKey: AppModuleKey.reports,
      title: 'Reports',
      icon: Icons.bar_chart_rounded,
      iconColor: Color(0xFFDCA842),
      hasSubmenu: true,
    ),
    SidebarItemData(
      moduleKey: AppModuleKey.settings,
      title: 'Settings',
      icon: Icons.settings_rounded,
      iconColor: Color(0xFF152042),
      hasSubmenu: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final textTheme = Theme.of(context).textTheme;

    final visibleIndices = <int>[
      for (var i = 0; i < navItems.length; i++)
        if (!exceptedModules.contains(navItems[i].moduleKey)) i,
    ];

    return Container(
      width: 220.0,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: isFloating
            ? BorderRadius.circular(14.0)
            : BorderRadius.only(
                topRight: Radius.circular(spacing.cardRadius),
                bottomRight: Radius.circular(spacing.cardRadius),
              ),
        boxShadow: isFloating
            ? const [
                BoxShadow(
                  color: Color(0x140F172A),
                  blurRadius: 24.0,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20.0, 22.0, 16.0, 16.0),
            child: HarborridgeLogo(isCompact: true),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 4.0,
              ),
              itemCount: visibleIndices.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4.0),
              itemBuilder: (context, visibleIdx) {
                final originalIndex = visibleIndices[visibleIdx];
                final item = navItems[originalIndex];
                final isSelected = originalIndex == selectedIndex;

                return InteractivePressScale(
                  onTap: () => onItemSelected(originalIndex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 11.0,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.brandPrimary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          size: 16.0,
                          color: isSelected ? Colors.white : item.iconColor,
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            item.title,
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 12.0,
                              color: isSelected
                                  ? Colors.white
                                  : colors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.hasSubmenu)
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16.0,
                            color: isSelected
                                ? Colors.white
                                : colors.textTertiary,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (onChangePinTap != null || onLogoutTap != null) ...[
            Divider(color: colors.borderSubtle, height: 1.0),
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onChangePinTap != null) ...[
                    InteractivePressScale(
                      onTap: onChangePinTap,
                      child: Container(
                        key: const ValueKey('sidebar_change_pin_button'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 9.0,
                        ),
                        decoration: BoxDecoration(
                          color: colors.freshSkyBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.pin_outlined,
                              size: 16.0,
                              color: colors.harborNavy,
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Text(
                                'Change PIN',
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w700,
                                  color: colors.harborNavy,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (onLogoutTap != null) const SizedBox(height: 6.0),
                  ],
                  if (onLogoutTap != null)
                    InteractivePressScale(
                      onTap: onLogoutTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.power_settings_new_rounded,
                              size: 16.0,
                              color: colors.textSecondary,
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Text(
                                'Logout',
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
