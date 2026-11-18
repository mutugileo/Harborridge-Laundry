import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/app/router/admin_nav_tab.dart';
import 'package:laundry_ridge/app/router/admin_shell_notifier.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';
import 'package:laundry_ridge/app/theme/app_spacing.dart';
import 'package:laundry_ridge/core/widgets/app_empty_state.dart';
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
    final order = ref.read(orderDetailsNotifierProvider).order;
    if (order == null) return;
    final colors = context.colors;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(bottomSheetContext).bottom,
        ),
        child: Material(
          color: colors.cardBackground,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.spacing.cardRadius),
          ),
          clipBehavior: Clip.antiAlias,
          child: _RecordPaymentForm(
            orderId: order.orderId,
            balanceDue: order.balanceDue,
          ),
        ),
      ),
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
              child: OrdersPageView(
                state: state,
                notifier: notifier,
                onStartNewOrder: () {
                  ref
                      .read(orderDetailsNotifierProvider.notifier)
                      .clearCatalogQuantities();
                  ref
                      .read(adminShellNotifierProvider.notifier)
                      .switchTab(AdminNavTab.services);
                },
              ),
            ),
          );
        }

        final order = state.order;
        if (order == null) {
          return Center(
            child: AppEmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'No Order Selected',
              description: 'Select an order from the list or intake a new ticket to inspect breakdown.',
              actionLabel: 'Browse All Orders',
              actionIcon: Icons.list_alt_rounded,
              onAction: notifier.showOrdersList,
            ),
          );
        }

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
                          onPrintReceipt: notifier.triggerPrintReceipt,
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
                        onPrintReceipt: notifier.triggerPrintReceipt,
                      ),
                    ],
                  ),
          ),
        );
    }
  }
}

class _RecordPaymentForm extends ConsumerStatefulWidget {
  const _RecordPaymentForm({required this.orderId, required this.balanceDue});

  final String orderId;
  final double balanceDue;

  @override
  ConsumerState<_RecordPaymentForm> createState() => _RecordPaymentFormState();
}

class _RecordPaymentFormState extends ConsumerState<_RecordPaymentForm> {
  static const List<String> _methods = [
    'M-Pesa',
    'Cash',
    'Card',
    'Bank Transfer',
  ];

  late final TextEditingController _amountController = TextEditingController(
    text: widget.balanceDue > 0 ? widget.balanceDue.toStringAsFixed(2) : '',
  );
  final TextEditingController _referenceController = TextEditingController();
  String _method = _methods.first;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final amount = double.tryParse(
      _amountController.text.trim().replaceAll(',', ''),
    );
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter the amount received.');
      return;
    }
    if (_method == 'M-Pesa' && _referenceController.text.trim().isEmpty) {
      setState(() => _error = 'Enter the M-Pesa confirmation code.');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final failure = await ref
        .read(orderDetailsNotifierProvider.notifier)
        .recordPayment(
          amount: amount,
          method: _method,
          reference: _referenceController.text,
        );
    if (!mounted) return;
    if (failure == null) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _isSubmitting = false;
        _error = failure;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final settled = widget.balanceDue <= 0.005;

    return Padding(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Record Payment',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: spacing.sm),
          Text(
            settled
                ? '${widget.orderId} is fully paid.'
                : 'Balance due on ${widget.orderId}: KES ${widget.balanceDue.toStringAsFixed(2)}',
            style: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: spacing.md),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: [
              for (final method in _methods)
                ChoiceChip(
                  label: Text(method),
                  selected: _method == method,
                  onSelected: settled || _isSubmitting
                      ? null
                      : (_) => setState(() => _method = method),
                ),
            ],
          ),
          SizedBox(height: spacing.md),
          TextField(
            key: const ValueKey('payment_amount_input'),
            controller: _amountController,
            enabled: !settled && !_isSubmitting,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount received (KES)',
            ),
          ),
          SizedBox(height: spacing.sm),
          TextField(
            key: const ValueKey('payment_reference_input'),
            controller: _referenceController,
            enabled: !settled && !_isSubmitting,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: _method == 'M-Pesa'
                  ? 'M-Pesa confirmation code'
                  : 'Reference (optional)',
            ),
          ),
          if (_error != null) ...[
            SizedBox(height: spacing.sm),
            Text(
              _error!,
              style: textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB91C1C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          SizedBox(height: spacing.lg),
          SizedBox(
            width: double.infinity,
            child: InteractivePressScale(
              onTap: settled || _isSubmitting ? null : _submit,
              child: Container(
                key: const ValueKey('payment_submit_button'),
                height: 44.0,
                decoration: BoxDecoration(
                  color: settled || _isSubmitting
                      ? colors.textTertiary
                      : colors.accentGreen,
                  borderRadius: BorderRadius.circular(spacing.buttonRadius),
                ),
                alignment: Alignment.center,
                child: Text(
                  _isSubmitting ? 'Saving…' : 'Record Payment',
                  style: textTheme.labelLarge?.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(height: spacing.md),
        ],
      ),
    );
  }
}
