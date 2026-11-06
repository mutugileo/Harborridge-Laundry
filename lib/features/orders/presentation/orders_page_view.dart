import 'package:flutter/material.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_spacing.dart';
import 'package:laundry_ridge/core/widgets/app_empty_state.dart';
import 'package:laundry_ridge/core/widgets/garment_catalog_grid.dart';
import 'package:laundry_ridge/core/widgets/garment_line_icon.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';
import 'package:laundry_ridge/features/orders/domain/order_detail.dart';
import 'package:laundry_ridge/features/orders/presentation/order_details_notifier.dart';
import 'package:laundry_ridge/features/orders/presentation/order_details_state.dart';

class OrdersPageView extends StatelessWidget {
  const OrdersPageView({
    super.key,
    required this.state,
    required this.notifier,
  });

  final OrderDetailsUiState state;
  final OrderDetailsNotifier notifier;

  void _showAddItemsCatalogModal(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return FractionallySizedBox(
          heightFactor: 0.82,
          child: Material(
            color: colors.cardBackground,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(spacing.cardRadius),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: EdgeInsets.all(spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Garments for Order ${state.order?.orderId ?? "LG-2026-00125"}',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Tap any garment illustration to add items or open Order Details',
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InteractivePressScale(
                        onTap: () {
                          Navigator.of(modalContext).pop();
                          notifier.openOrderDetails(
                            state.order?.orderId ?? '#ORD-0006',
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: colors.brandPrimary,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            'Open Order Details',
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: SingleChildScrollView(
                      child: GarmentCatalogGrid(
                        quantities: state.catalogQuantities,
                        onIncrementGarment: notifier.incrementCatalogGarment,
                        onDecrementGarment: notifier.decrementCatalogGarment,
                        onAddCustomItem: () => notifier.notifyCatalogAction(
                          'Custom garment entry ready',
                        ),
                        onScanBarcode: () => notifier.notifyCatalogAction(
                          'Barcode scanner ready for garment tag',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filteredOrders = state.filteredOrders;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14.0),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(26.0, 24.0, 26.0, 18.0),
            child: _buildToolbarAndFilters(context),
          ),
          _buildOrdersTable(context, filteredOrders),
          Padding(
            padding: const EdgeInsets.fromLTRB(26.0, 16.0, 26.0, 22.0),
            child: _buildTableFooter(context, filteredOrders.length),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarAndFilters(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 14.0,
          runSpacing: 12.0,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Laundry Orders',
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Filter by order status, payment, service, vendor, customer, date, delivery, or rider',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.0,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 10.0,
              runSpacing: 8.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 250.0),
                  child: Container(
                    height: 36.0,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: colors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 16.0,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            onChanged: notifier.updateSearchQuery,
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 12.0,
                              color: colors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Search order ID, customer, vendor',
                              hintStyle: textTheme.bodySmall?.copyWith(
                                fontSize: 11.0,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.hasActiveFilters)
                  InteractivePressScale(
                    onTap: notifier.resetAllFilters,
                    child: Container(
                      height: 36.0,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Reset Filters',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                InteractivePressScale(
                  onTap: () => _showAddItemsCatalogModal(context),
                  child: Container(
                    height: 36.0,
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    decoration: BoxDecoration(
                      color: colors.accentGreen,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_circle_outline_rounded,
                          size: 15.0,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          'Add Garments',
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontSize: 11.0,
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
        const SizedBox(height: 16.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            _FilterDropdownPill<OrderProcessStatus?>(
              label: 'Order Status',
              value: state.statusFilter,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Order status: All'),
                ),
                ...OrderProcessStatus.values.map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text('Status: ${status.displayLabel}'),
                  ),
                ),
              ],
              onChanged: notifier.updateStatusFilter,
            ),
            _FilterDropdownPill<String?>(
              label: 'Payment Status',
              value: state.paymentStatusFilter,
              items: const [
                DropdownMenuItem(value: null, child: Text('Payment: All')),
                DropdownMenuItem(value: 'Paid', child: Text('Payment: Paid')),
                DropdownMenuItem(
                  value: 'Partial',
                  child: Text('Payment: Partial'),
                ),
                DropdownMenuItem(
                  value: 'Unpaid',
                  child: Text('Payment: Unpaid'),
                ),
              ],
              onChanged: notifier.updatePaymentStatusFilter,
            ),
            _FilterDropdownPill<String?>(
              label: 'Service Type',
              value: state.serviceTypeFilter,
              items: const [
                DropdownMenuItem(value: null, child: Text('Service: All')),
                DropdownMenuItem(
                  value: 'Wash & Fold',
                  child: Text('Service: Wash & Fold'),
                ),
                DropdownMenuItem(
                  value: 'Wash & Iron',
                  child: Text('Service: Wash & Iron'),
                ),
                DropdownMenuItem(
                  value: 'Dry Cleaning',
                  child: Text('Service: Dry Cleaning'),
                ),
                DropdownMenuItem(
                  value: 'Wet Wash',
                  child: Text('Service: Wet Wash'),
                ),
              ],
              onChanged: notifier.updateServiceTypeFilter,
            ),
            _FilterDropdownPill<String?>(
              label: 'Vendor / Branch',
              value: state.vendorFilter,
              items: [
                const DropdownMenuItem(value: null, child: Text('Vendor: All')),
                for (final v in {
                  'LaundryGo Nairobi',
                  'Harborridge Main',
                  'LaundryGo Westlands',
                  'LaundryGo Kilimani',
                  'Harborridge Kilimani',
                  'Harborridge Westlands',
                  'Ridge Eco-Cleaners',
                  if (state.vendorFilter != null) state.vendorFilter!,
                })
                  DropdownMenuItem(value: v, child: Text('Vendor: $v')),
              ],
              onChanged: notifier.updateVendorFilter,
            ),
            _FilterDropdownPill<String?>(
              label: 'Customer',
              value: state.customerFilter,
              items: const [
                DropdownMenuItem(value: null, child: Text('Customer: All')),
                DropdownMenuItem(
                  value: 'John Kamau',
                  child: Text('Customer: John Kamau'),
                ),
                DropdownMenuItem(
                  value: 'Moncy James',
                  child: Text('Customer: Moncy James'),
                ),
                DropdownMenuItem(
                  value: 'Grace Wanjiku',
                  child: Text('Customer: Grace Wanjiku'),
                ),
                DropdownMenuItem(
                  value: 'Polly Matthews',
                  child: Text('Customer: Polly Matthews'),
                ),
                DropdownMenuItem(
                  value: 'David Ochieng',
                  child: Text('Customer: David Ochieng'),
                ),
                DropdownMenuItem(
                  value: 'Emma Davis',
                  child: Text('Customer: Emma Davis'),
                ),
              ],
              onChanged: notifier.updateCustomerFilter,
            ),
            _FilterDropdownPill<String?>(
              label: 'Date Created',
              value: state.dateCreatedFilter,
              items: const [
                DropdownMenuItem(value: null, child: Text('Date created: All')),
                DropdownMenuItem(
                  value: '05 Nov 2026',
                  child: Text('Created: 05 Nov 2026'),
                ),
                DropdownMenuItem(
                  value: '04 Nov 2026',
                  child: Text('Created: 04 Nov 2026'),
                ),
                DropdownMenuItem(
                  value: '03 Nov 2026',
                  child: Text('Created: 03 Nov 2026'),
                ),
              ],
              onChanged: notifier.updateDateCreatedFilter,
            ),
            _FilterDropdownPill<String?>(
              label: 'Delivery Method',
              value: state.deliveryMethodFilter,
              items: const [
                DropdownMenuItem(
                  value: null,
                  child: Text('Delivery method: All'),
                ),
                DropdownMenuItem(
                  value: 'Pickup assigned',
                  child: Text('Delivery: Pickup assigned'),
                ),
                DropdownMenuItem(
                  value: 'Doorstep delivery',
                  child: Text('Delivery: Doorstep delivery'),
                ),
                DropdownMenuItem(
                  value: 'Branch drop-off',
                  child: Text('Delivery: Branch drop-off'),
                ),
                DropdownMenuItem(
                  value: 'Express rider',
                  child: Text('Delivery: Express rider'),
                ),
              ],
              onChanged: notifier.updateDeliveryMethodFilter,
            ),
            _FilterDropdownPill<String?>(
              label: 'Assigned Rider',
              value: state.assignedRiderFilter,
              items: const [
                DropdownMenuItem(value: null, child: Text('Rider: All')),
                DropdownMenuItem(
                  value: 'Peter Njoroge',
                  child: Text('Rider: Peter Njoroge'),
                ),
                DropdownMenuItem(
                  value: 'David Mwangi',
                  child: Text('Rider: David Mwangi'),
                ),
                DropdownMenuItem(
                  value: 'Samuel Otieno',
                  child: Text('Rider: Samuel Otieno'),
                ),
                DropdownMenuItem(
                  value: 'Kelvin Kiprop',
                  child: Text('Rider: Kelvin Kiprop'),
                ),
              ],
              onChanged: notifier.updateAssignedRiderFilter,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrdersTable(BuildContext context, List<OrderDetail> orders) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    if (orders.isEmpty) {
      return AppEmptyState(
        icon: Icons.receipt_long_rounded,
        title: 'No Orders Found',
        description: 'No orders match your active filter criteria. Intake a new laundry batch or reset filters.',
        actionLabel: 'POS Order Intake',
        actionIcon: Icons.add_shopping_cart_rounded,
        onAction: () => _showAddItemsCatalogModal(context),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 820.0;

        if (isCompact) {
          return Column(
            children: [
              for (var i = 0; i < orders.length; i++)
                _CompactOrderRowCard(
                  order: orders[i],
                  onOpenDetails: () =>
                      notifier.openOrderDetails(orders[i].orderId),
                ),
            ],
          );
        }

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 22.0,
                vertical: 12.0,
              ),
              color: const Color(0xFFECEFF3),
              child: Row(
                children: [
                  Expanded(
                    flex: 22,
                    child: Text(
                      'ORDER NUMBER',
                      style: _headerStyle(textTheme, colors),
                    ),
                  ),
                  Expanded(
                    flex: 18,
                    child: Text(
                      'CUSTOMER',
                      style: _headerStyle(textTheme, colors),
                    ),
                  ),
                  Expanded(
                    flex: 20,
                    child: Text(
                      'SERVICE',
                      style: _headerStyle(textTheme, colors),
                    ),
                  ),
                  Expanded(
                    flex: 22,
                    child: Text(
                      'VENDOR',
                      style: _headerStyle(textTheme, colors),
                    ),
                  ),
                  Expanded(
                    flex: 15,
                    child: Text(
                      'AMOUNT',
                      style: _headerStyle(textTheme, colors),
                    ),
                  ),
                  Expanded(
                    flex: 13,
                    child: Text(
                      'PAYMENT',
                      style: _headerStyle(textTheme, colors),
                    ),
                  ),
                  Expanded(
                    flex: 16,
                    child: Text(
                      'PROCESSING',
                      style: _headerStyle(textTheme, colors),
                    ),
                  ),
                  Expanded(
                    flex: 22,
                    child: Text(
                      'DELIVERY',
                      style: _headerStyle(textTheme, colors),
                    ),
                  ),
                  Expanded(
                    flex: 16,
                    child: Text(
                      'CREATED',
                      style: _headerStyle(textTheme, colors),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            for (var i = 0; i < orders.length; i++)
              _DesktopOrderTableRow(
                order: orders[i],
                isSelected: state.order?.orderId == orders[i].orderId,
                onOpenDetails: () =>
                    notifier.openOrderDetails(orders[i].orderId),
              ),
          ],
        );
      },
    );
  }

  TextStyle? _headerStyle(TextTheme textTheme, AppColors colors) {
    return textTheme.labelSmall?.copyWith(
      fontSize: 10.0,
      color: colors.textSecondary,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.35,
    );
  }

  Widget _buildTableFooter(BuildContext context, int count) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            'Showing $count of ${state.orders.length} orders',
            style: textTheme.bodySmall?.copyWith(
              fontSize: 12.0,
              color: colors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8.0),
        Flexible(
          child: Text(
            'Click any order row to open Order Details',
            style: textTheme.bodySmall?.copyWith(
              fontSize: 12.0,
              color: colors.brandPrimary,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _FilterDropdownPill<T> extends StatelessWidget {
  const _FilterDropdownPill({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final isActive = value != null;

    final constrainedItems = items.map((item) {
      Widget content = item.child;
      if (content is Text) {
        content = Text(
          content.data ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: content.style,
        );
      }
      return DropdownMenuItem<T>(
        key: item.key,
        value: item.value,
        enabled: item.enabled,
        alignment: item.alignment,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 170.0),
          child: content,
        ),
      );
    }).toList();

    return Container(
      height: 32.0,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isActive ? colors.brandPrimary : colors.borderSubtle,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: items.any((item) => item.value == value) ? value : null,
          isDense: true,
          icon: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 15.0,
              color: isActive ? colors.brandPrimary : colors.textSecondary,
            ),
          ),
          style: textTheme.labelSmall?.copyWith(
            fontSize: 11.0,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? colors.brandPrimary : colors.textPrimary,
          ),
          items: constrainedItems,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DesktopOrderTableRow extends StatelessWidget {
  const _DesktopOrderTableRow({
    required this.order,
    required this.isSelected,
    required this.onOpenDetails,
  });

  final OrderDetail order;
  final bool isSelected;
  final VoidCallback onOpenDetails;

  Color _processingColor(OrderProcessStatus status) {
    switch (status) {
      case OrderProcessStatus.washing:
        return const Color(0xFF0284C7);
      case OrderProcessStatus.processing:
        return const Color(0xFF8392A5);
      case OrderProcessStatus.cleaning:
        return const Color(0xFF159CE8);
      case OrderProcessStatus.ironing:
        return const Color(0xFFF5A638);
      case OrderProcessStatus.completed:
        return const Color(0xFF28C76F);
      case OrderProcessStatus.delivered:
        return const Color(0xFF1E293B);
    }
  }

  Color _paymentBadgeColor(String paymentStatus) {
    switch (paymentStatus) {
      case 'Paid':
        return const Color(0xFF10B981);
      case 'Partial':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final paymentColor = _paymentBadgeColor(order.paymentStatusLabel);

    return InkWell(
      onTap: onOpenDetails,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 13.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF8FAFC) : Colors.transparent,
          border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 22,
              child: Text(
                order.orderId,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  color: colors.brandPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 18,
              child: Text(
                order.customerName,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 20,
              child: Row(
                children: [
                  GarmentLineIcon(
                    type: order.items.first.garmentType,
                    size: 26.0,
                  ),
                  const SizedBox(width: 6.0),
                  Expanded(
                    child: Text(
                      order.primaryService,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2B729E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 22,
              child: Text(
                order.vendorBranch,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12.0,
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 15,
              child: Text(
                order.displayAmount,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 13,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: paymentColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    order.paymentStatusLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: paymentColor,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 16,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: _processingColor(order.status),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    order.processingStageLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.deliveryStatusLabel,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Rider: ${order.assignedRider}',
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 10.0,
                      color: colors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 16,
              child: Text(
                order.createdDateLabel,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 11.0,
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactOrderRowCard extends StatelessWidget {
  const _CompactOrderRowCard({
    required this.order,
    required this.onOpenDetails,
  });

  final OrderDetail order;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onOpenDetails,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: Row(
          children: [
            GarmentLineIcon(type: order.items.first.garmentType, size: 36.0),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${order.orderId} · ${order.customerName}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    '${order.primaryService} · ${order.vendorBranch} · ${order.displayAmount}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    '${order.paymentStatusLabel} · ${order.processingStageLabel} · ${order.deliveryStatusLabel} · ${order.createdDateLabel}',
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 11.0,
                      color: colors.brandPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
