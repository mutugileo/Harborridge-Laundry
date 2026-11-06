import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/app/responsive/responsive_breakpoints.dart';
import 'package:laundry_ridge/app/router/admin_nav_tab.dart';
import 'package:laundry_ridge/app/router/admin_shell_notifier.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/core/auth/auth_portal_screen.dart';
import 'package:laundry_ridge/core/auth/auth_session.dart';
import 'package:laundry_ridge/core/auth/change_pin_dialog.dart';
import 'package:laundry_ridge/core/widgets/order_header_bar.dart';
import 'package:laundry_ridge/core/widgets/order_sidebar.dart';
import 'package:laundry_ridge/core/widgets/shared_axis_page_transition.dart';
import 'package:laundry_ridge/features/customers/presentation/customers_view.dart';
import 'package:laundry_ridge/features/dashboard/domain/dashboard_models.dart';
import 'package:laundry_ridge/features/dashboard/presentation/admin_dashboard_view.dart';
import 'package:laundry_ridge/features/dispatch/presentation/dispatch_view.dart';
import 'package:laundry_ridge/features/inventory/presentation/inventory_view.dart';
import 'package:laundry_ridge/features/orders/presentation/order_details_notifier.dart';
import 'package:laundry_ridge/features/orders/presentation/order_details_screen.dart';
import 'package:laundry_ridge/features/payments/presentation/payments_view.dart';
import 'package:laundry_ridge/features/production/presentation/order_tracking_board_view.dart';
import 'package:laundry_ridge/features/production/presentation/order_tracking_notifier.dart';
import 'package:laundry_ridge/features/reports/presentation/reports_view.dart';
import 'package:laundry_ridge/features/services/presentation/admin_services_catalog_view.dart';
import 'package:laundry_ridge/features/settings/presentation/settings_view.dart';
import 'package:laundry_ridge/features/settlements/presentation/settlements_view.dart';
import 'package:laundry_ridge/features/staff/presentation/staff_view.dart';
import 'package:laundry_ridge/features/vendors/presentation/vendors_view.dart';

class AdminShellScreen extends ConsumerStatefulWidget {
  const AdminShellScreen({super.key});

  @override
  ConsumerState<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends ConsumerState<AdminShellScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _headerTitleForTab(AdminNavTab tab, {required bool isOrdersList}) {
    switch (tab) {
      case AdminNavTab.orders:
        return isOrdersList ? 'Orders' : 'Order Details';
      case AdminNavTab.orderStatus:
        return 'Order Tracking';
      case AdminNavTab.services:
        return 'POS / New Order Intake';
      case AdminNavTab.dashboard:
      case AdminNavTab.dispatch:
      case AdminNavTab.customers:
      case AdminNavTab.vendors:
      case AdminNavTab.payments:
      case AdminNavTab.settlements:
      case AdminNavTab.inventory:
      case AdminNavTab.staff:
      case AdminNavTab.reports:
      case AdminNavTab.settings:
        return tab.title;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authSessionNotifierProvider);
    final authNotifier = ref.read(authSessionNotifierProvider.notifier);
    final shellState = ref.watch(adminShellNotifierProvider);
    final shellNotifier = ref.read(adminShellNotifierProvider.notifier);
    final ordersState = ref.watch(orderDetailsNotifierProvider);
    final ordersNotifier = ref.read(orderDetailsNotifierProvider.notifier);
    final colors = context.colors;

    return SharedAxisPageTransition.portal(
      child: !authState.isAuthenticated
          ? const AuthPortalScreen(key: ValueKey('auth_portal_screen'))
          : LayoutBuilder(
              key: const ValueKey('authenticated_admin_shell'),
              builder: (context, constraints) {
                final isDesktop = ResponsiveBreakpoints.isDesktop(
                  constraints.maxWidth,
                );

                return Scaffold(
                  key: _scaffoldKey,
                  backgroundColor: colors.background,
                  drawer: isDesktop
                      ? null
                      : Drawer(
                          backgroundColor: colors.cardBackground,
                          child: OrderSidebar(
                            selectedIndex: shellState.currentTab.index,
                            exceptedModules:
                                authState.currentWorker.exceptedModules,
                            onChangePinTap: () {
                              Navigator.of(context).pop();
                              showChangeWorkerPinDialog(context);
                            },
                            onLogoutTap: authNotifier.signOutToPortal,
                            isFloating: false,
                            onItemSelected: (index) {
                              final selectedTab = AdminNavTab.values[index];
                              if (selectedTab == AdminNavTab.orders) {
                                ordersNotifier.showOrdersList();
                              }
                              shellNotifier.switchTab(selectedTab);
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                  body: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 245.0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colors.harborNavy,
                                const Color(0xFF193569),
                                const Color(0xFF124E8C),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const CustomPaint(
                            painter: _HarborridgeBannerBubblesPainter(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          isDesktop ? 20.0 : 12.0,
                          0.0,
                          isDesktop ? 20.0 : 12.0,
                          16.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isDesktop) ...[
                              Padding(
                                padding: const EdgeInsets.only(top: 38.0),
                                child: OrderSidebar(
                                  selectedIndex: shellState.currentTab.index,
                                  exceptedModules:
                                      authState.currentWorker.exceptedModules,
                                  onChangePinTap: () =>
                                      showChangeWorkerPinDialog(context),
                                  onLogoutTap: authNotifier.signOutToPortal,
                                  onItemSelected: (index) {
                                    final selectedTab =
                                        AdminNavTab.values[index];
                                    if (selectedTab == AdminNavTab.orders) {
                                      ordersNotifier.showOrdersList();
                                    }
                                    shellNotifier.switchTab(selectedTab);
                                  },
                                ),
                              ),
                              const SizedBox(width: 22.0),
                            ],
                            Expanded(
                              child: Column(
                                children: [
                                  OrderHeaderBar(
                                    title: _headerTitleForTab(
                                      shellState.currentTab,
                                      isOrdersList:
                                          ordersState.isShowingOrdersList,
                                    ),
                                    activeWorkerLabel:
                                        '${authState.currentWorker.fullName} • ${authState.currentWorker.roleTitle}',
                                    onChangePinTap: () =>
                                        showChangeWorkerPinDialog(context),
                                    onSwitchWorkerTap:
                                        authNotifier.signOutToPortal,
                                    onToggleDrawer: () {
                                      if (!isDesktop) {
                                        _scaffoldKey.currentState?.openDrawer();
                                      }
                                    },
                                    onBackPressed: () {
                                      if (shellState.currentTab ==
                                          AdminNavTab.orders) {
                                        if (!ordersState.isShowingOrdersList) {
                                          ordersNotifier.showOrdersList();
                                        } else {
                                          ordersNotifier.openOrderDetails(
                                            '#ORD-0006',
                                          );
                                        }
                                      } else {
                                        ordersNotifier.showOrdersList();
                                        shellNotifier.switchTab(
                                          AdminNavTab.orders,
                                        );
                                      }
                                    },
                                  ),
                                  Expanded(
                                    child: SharedAxisPageTransition.peerFeature(
                                      direction: shellState.transitionDirection,
                                      child: _buildCurrentView(
                                        shellState.currentTab,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildCurrentView(AdminNavTab tab) {
    final ordersState = ref.watch(orderDetailsNotifierProvider);
    final ordersNotifier = ref.read(orderDetailsNotifierProvider.notifier);
    final shellNotifier = ref.read(adminShellNotifierProvider.notifier);

    switch (tab) {
      case AdminNavTab.dashboard:
        return AdminDashboardView(
          key: const ValueKey('admin_dashboard_view'),
          onQuickLinkSelected: (target) {
            switch (target) {
              case DashboardQuickLinkTarget.orders:
                ordersNotifier.showOrdersList();
                shellNotifier.switchTab(AdminNavTab.orders);
              case DashboardQuickLinkTarget.products:
                shellNotifier.switchTab(AdminNavTab.services);
              case DashboardQuickLinkTarget.invoices:
                shellNotifier.switchTab(AdminNavTab.payments);
              case DashboardQuickLinkTarget.customer:
                shellNotifier.switchTab(AdminNavTab.customers);
              case DashboardQuickLinkTarget.drivers:
                shellNotifier.switchTab(AdminNavTab.dispatch);
            }
          },
          onNewOrderRequested: () {
            shellNotifier.switchTab(AdminNavTab.services);
          },
          onRegisterWorkerRequested: () {
            shellNotifier.switchTab(AdminNavTab.staff);
          },
        );
      case AdminNavTab.orders:
        return const OrderDetailsScreen(
          key: ValueKey('admin_order_details_view'),
          isEmbeddedInShell: true,
        );
      case AdminNavTab.orderStatus:
        return OrderTrackingBoardView(
          key: const ValueKey('admin_order_tracking_board_view'),
          onOpenOrderDetails: (orderNumber) {
            ordersNotifier.openOrderDetails(orderNumber);
            shellNotifier.switchTab(AdminNavTab.orders);
          },
          onNewOrderIntake: () {
            shellNotifier.switchTab(AdminNavTab.services);
          },
        );
      case AdminNavTab.dispatch:
        return DispatchView(
          key: const ValueKey('admin_dispatch_view'),
          onOpenOrderDetails: (orderId) {
            ordersNotifier.openOrderDetails(orderId);
            shellNotifier.switchTab(AdminNavTab.orders);
          },
        );
      case AdminNavTab.customers:
        return CustomersView(
          key: const ValueKey('admin_customers_view'),
          onOpenOrderDetails: (orderId) {
            ordersNotifier.openOrderDetails(orderId);
            shellNotifier.switchTab(AdminNavTab.orders);
          },
          onStartPosOrder: () {
            shellNotifier.switchTab(AdminNavTab.services);
          },
        );
      case AdminNavTab.vendors:
        return VendorsView(
          key: const ValueKey('admin_vendors_view'),
          onFilterOrdersByBranch: (branchName) {
            ordersNotifier.resetAllFilters();
            ordersNotifier.updateVendorFilter(branchName);
            ordersNotifier.showOrdersList();
            shellNotifier.switchTab(AdminNavTab.orders);
          },
        );
      case AdminNavTab.services:
        return AdminServicesCatalogView(
          key: const ValueKey('admin_services_view'),
          quantities: ordersState.catalogQuantities,
          onIncrementGarment: ordersNotifier.incrementCatalogGarment,
          onDecrementGarment: ordersNotifier.decrementCatalogGarment,
          onClearGarments: ordersNotifier.clearCatalogQuantities,
          onAddCustomItem: () => ordersNotifier.notifyCatalogAction(
            'Custom garment entry ready for #ORD-0006',
          ),
          onScanBarcode: () => ordersNotifier.notifyCatalogAction(
            'Barcode scanner ready for garment tag',
          ),
          onSubmitNewOrder: (submission) {
            final totalItems = ordersState.catalogQuantities.values.fold<int>(
              0,
              (sum, qty) => sum + qty,
            );
            final newOrderId = ordersNotifier.createNewPosOrder(
              customerName: submission.customerName,
              customerPhone: submission.customerPhone,
              primaryService: submission.primaryService,
              vendorBranch: submission.vendorBranch,
              deliveryMethod: submission.deliveryMethod,
              assignedRider: submission.assignedRider,
              paymentStatusLabel: submission.paymentStatusLabel,
              paymentMethod: submission.paymentMethod,
              includeStainRemoval: submission.includeStainRemoval,
              includeExtraFragrance: submission.includeExtraFragrance,
            );
            ref
                .read(orderTrackingNotifierProvider.notifier)
                .addProductionOrderFromPos(
                  orderNumber: newOrderId,
                  customerName: submission.customerName,
                  serviceType: submission.primaryService,
                  itemCount: totalItems > 0 ? totalItems : 4,
                  assignedStaff: ref
                      .read(authSessionNotifierProvider)
                      .currentWorker
                      .fullName,
                );
            shellNotifier.switchTab(AdminNavTab.orders);
          },
        );
      case AdminNavTab.payments:
        return PaymentsView(
          key: const ValueKey('admin_payments_view'),
          onOpenOrderDetails: (orderId) {
            ordersNotifier.openOrderDetails(orderId);
            shellNotifier.switchTab(AdminNavTab.orders);
          },
        );
      case AdminNavTab.settlements:
        return SettlementsView(
          key: const ValueKey('admin_settlements_view'),
          onFilterOrdersByBranch: (branchName) {
            ordersNotifier.resetAllFilters();
            ordersNotifier.updateVendorFilter(branchName);
            ordersNotifier.showOrdersList();
            shellNotifier.switchTab(AdminNavTab.orders);
          },
        );
      case AdminNavTab.inventory:
        return InventoryView(
          key: const ValueKey('admin_inventory_view'),
          onOpenOrderDetails: (orderId) {
            ordersNotifier.openOrderDetails(orderId);
            shellNotifier.switchTab(AdminNavTab.orders);
          },
        );
      case AdminNavTab.staff:
        return StaffView(
          key: const ValueKey('admin_staff_view'),
          onOpenLoginPortal: () {
            ref.read(authSessionNotifierProvider.notifier).signOutToPortal();
          },
        );
      case AdminNavTab.reports:
        return ReportsView(
          key: const ValueKey('admin_reports_view'),
          onFilterOrdersByBranch: (branchName) {
            ordersNotifier.resetAllFilters();
            ordersNotifier.updateVendorFilter(branchName);
            ordersNotifier.showOrdersList();
            shellNotifier.switchTab(AdminNavTab.orders);
          },
        );
      case AdminNavTab.settings:
        return SettingsView(
          key: const ValueKey('admin_settings_view'),
          onSignOutRequested: () {
            ref.read(authSessionNotifierProvider.notifier).signOutToPortal();
          },
        );
    }
  }
}

class _HarborridgeBannerBubblesPainter extends CustomPainter {
  const _HarborridgeBannerBubblesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final ringPaint = Paint()
      ..color = const Color(0x282DA1E7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final fillPaint = Paint()
      ..color = const Color(0x0F2DA1E7)
      ..style = PaintingStyle.fill;

    final bubbles = <(Offset, double)>[
      (Offset(size.width * 0.88, size.height * 0.26), 28.0),
      (Offset(size.width * 0.93, size.height * 0.56), 19.0),
      (Offset(size.width * 0.82, size.height * 0.62), 23.0),
      (Offset(size.width * 0.75, size.height * 0.30), 15.0),
      (Offset(size.width * 0.64, size.height * 0.48), 21.0),
      (Offset(size.width * 0.34, size.height * 0.36), 18.0),
      (Offset(size.width * 0.27, size.height * 0.64), 12.0),
    ];

    for (final (center, radius) in bubbles) {
      canvas.drawCircle(center, radius, fillPaint);
      canvas.drawCircle(center, radius, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
