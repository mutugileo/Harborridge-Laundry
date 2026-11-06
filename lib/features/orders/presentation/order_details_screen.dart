import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';
import 'package:laundry_ridge/app/theme/app_spacing.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';
import 'package:laundry_ridge/core/widgets/order_header_bar.dart';
import 'package:laundry_ridge/core/widgets/order_sidebar.dart';
import 'package:laundry_ridge/core/widgets/shared_axis_page_transition.dart';
import 'package:laundry_ridge/features/orders/presentation/order_details_notifier.dart';
import 'package:laundry_ridge/features/orders/presentation/order_details_state.dart';
import 'package:laundry_ridge/features/orders/presentation/orders_page_view.dart';
import 'package:laundry_ridge/features/orders/presentation/widgets/order_addons_payments_card.dart';
import 'package:laundry_ridge/features/orders/presentation/widgets/order_invoice_card.dart';
import 'package:laundry_ridge/features/orders/presentation/widgets/order_skeleton_view.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  const OrderDetailsScreen({super.key, this.isEmbeddedInShell = false});

  final bool isEmbeddedInShell;

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showAddPaymentSheet() {
    final notifier = ref.read(orderDetailsNotifierProvider.notifier);
    final spacing = context.spacing;
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Material(
          color: colors.cardBackground,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(spacing.cardRadius),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Record Payment',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: spacing.sm),
                Text(
                  'Add a confirmed payment transaction to Order #ORD-0006',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                SizedBox(height: spacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: InteractivePressScale(
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          notifier.recordPayment(
                            amount: 150.00,
                            method: 'CASH',
                          );
                        },
                        child: Container(
                          height: 44.0,
                          decoration: BoxDecoration(
                            color: colors.brandPrimary,
                            borderRadius: BorderRadius.circular(
                              spacing.buttonRadius,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Pay KES 150.00 (Cash)',
                            style: textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: spacing.md),
                    Expanded(
                      child: InteractivePressScale(
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          notifier.recordPayment(
                            amount: 350.00,
                            method: 'M-PESA',
                          );
                        },
                        child: Container(
                          height: 44.0,
                          decoration: BoxDecoration(
                            color: colors.accentGreen,
                            borderRadius: BorderRadius.circular(
                              spacing.buttonRadius,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Pay KES 350.00 (M-Pesa)',
                            style: textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing.md),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderDetailsNotifierProvider);
    final notifier = ref.read(orderDetailsNotifierProvider.notifier);
    final colors = context.colors;
    final motion = context.motion;

    ref.listen<OrderDetailsUiState>(orderDetailsNotifierProvider, (
      previous,
      next,
    ) {
      if (next.actionFeedbackMessage != null &&
          next.actionFeedbackMessage != previous?.actionFeedbackMessage) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.actionFeedbackMessage!),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        notifier.clearFeedbackMessage();
      }
    });

    if (widget.isEmbeddedInShell) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SharedAxisPageTransition.verticalSubflow(
            isDrillingIn: !state.isShowingOrdersList,
            child: _buildBodyContent(
              context: context,
              state: state,
              notifier: notifier,
              constraints: constraints,
            ),
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900.0;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: colors.background,
          drawer: isDesktop
              ? null
              : Drawer(
                  backgroundColor: colors.cardBackground,
                  child: OrderSidebar(
                    selectedIndex: state.selectedSidebarIndex,
                    isFloating: false,
                    onItemSelected: (index) {
                      notifier.selectSidebarIndex(index);
                      if (index == 1) {
                        notifier.showOrdersList();
                      }
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
                child: ColoredBox(color: colors.headerBanner),
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
                          selectedIndex: state.selectedSidebarIndex,
                          onItemSelected: (index) {
                            notifier.selectSidebarIndex(index);
                            if (index == 1) {
                              notifier.showOrdersList();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 22.0),
                    ],
                    Expanded(
                      child: Column(
                        children: [
                          OrderHeaderBar(
                            title: state.isShowingOrdersList
                                ? 'Orders'
                                : 'Order Details',
                            onToggleDrawer: () {
                              if (isDesktop) {
                                notifier.toggleSidebar();
                              } else {
                                _scaffoldKey.currentState?.openDrawer();
                              }
                            },
                            onBackPressed: () {
                              if (!state.isShowingOrdersList) {
                                notifier.showOrdersList();
                              } else {
                                notifier.openOrderDetails('#ORD-0006');
                              }
                            },
                          ),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: motion.mediumDuration,
                              switchInCurve: motion.standardCurve,
                              switchOutCurve: motion.standardCurve,
                              layoutBuilder: (currentChild, previousChildren) {
                                return Stack(
                                  alignment: Alignment.topCenter,
                                  children: <Widget>[
                                    ...previousChildren,
                                    ?currentChild,
                                  ],
                                );
                              },
                              child: _buildBodyContent(
                                context: context,
                                state: state,
                                notifier: notifier,
                                constraints: constraints,
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
    );
  }

  Widget _buildBodyContent({
    required BuildContext context,
    required OrderDetailsUiState state,
    required OrderDetailsNotifier notifier,
    required BoxConstraints constraints,
  }) {
    switch (state.status) {
      case OrderDetailsUiStatus.loading:
        return const SingleChildScrollView(
          key: ValueKey('order_loading_view'),
          child: OrderSkeletonView(),
        );

      case OrderDetailsUiStatus.error:
        final colors = context.colors;
        final spacing = context.spacing;
        final textTheme = Theme.of(context).textTheme;

        return Center(
          key: const ValueKey('order_error_view'),
          child: Padding(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 48.0,
                  color: colors.statusError,
                ),
                SizedBox(height: spacing.md),
                Text('Failed to load order', style: textTheme.titleMedium),
                SizedBox(height: spacing.xs),
                Text(
                  state.errorMessage ??
                      'The requested order could not be retrieved.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.lg),
                InteractivePressScale(
                  onTap: () => notifier.loadOrderDetails('#ORD-0006'),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.lg,
                      vertical: spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: colors.brandPrimary,
                      borderRadius: BorderRadius.circular(spacing.buttonRadius),
                    ),
                    child: Text(
                      'Retry',
                      style: textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case OrderDetailsUiStatus.success:
        if (state.isShowingOrdersList) {
          return Align(
            key: const ValueKey('orders_list_page_view'),
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: OrdersPageView(state: state, notifier: notifier),
            ),
          );
        }

        final order = state.order;
        if (order == null) return const SizedBox.shrink();

        final isMultiColumn = constraints.maxWidth >= 680.0;

        return Align(
          key: ValueKey('order_detail_view_${order.orderId}'),
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: isMultiColumn
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 73,
                        child: OrderInvoiceCard(
                          order: order,
                          currentStatus: state.currentStatus,
                          onStatusChanged: notifier.updateOrderStatus,
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      Expanded(
                        flex: 27,
                        child: OrderAddonsPaymentsCard(
                          order: order,
                          onAddPayment: _showAddPaymentSheet,
                          onPrintInvoice: notifier.triggerPrintInvoice,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      OrderInvoiceCard(
                        order: order,
                        currentStatus: state.currentStatus,
                        onStatusChanged: notifier.updateOrderStatus,
                      ),
                      const SizedBox(height: 20.0),
                      OrderAddonsPaymentsCard(
                        order: order,
                        onAddPayment: _showAddPaymentSheet,
                        onPrintInvoice: notifier.triggerPrintInvoice,
                      ),
                    ],
                  ),
          ),
        );
    }
  }
}
