import 'package:flutter/material.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/core/widgets/garment_line_icon.dart';
import 'package:laundry_ridge/features/orders/domain/order_detail.dart';

class OrderInvoiceCard extends StatelessWidget {
  const OrderInvoiceCard({
    super.key,
    required this.order,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  final OrderDetail order;
  final OrderProcessStatus currentStatus;
  final ValueChanged<OrderProcessStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
            padding: const EdgeInsets.fromLTRB(26.0, 26.0, 26.0, 20.0),
            child: _buildHeaderSection(context),
          ),
          _buildTableSection(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(26.0, 18.0, 26.0, 24.0),
            child: _buildFooterSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 380.0;

        final storeInfo = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.storeName,
              style: textTheme.titleMedium?.copyWith(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              order.storeCode,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12.0,
                color: colors.textSecondary,
                height: 1.45,
              ),
            ),
            Text(
              order.storeEmail,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12.0,
                color: colors.textSecondary,
                height: 1.45,
              ),
            ),
            Text(
              order.storeAddress,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12.0,
                color: colors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14.0),
            Text(
              order.taxIdentifier,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12.0,
                color: colors.textSecondary,
              ),
            ),
          ],
        );

        final orderMeta = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ORDER ID:  ',
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 13.0,
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  order.orderId,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Order Date:   ',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.0,
                    color: colors.textSecondary,
                  ),
                ),
                Text(
                  order.orderDate,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Delivery Date:   ',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.0,
                    color: colors.textSecondary,
                  ),
                ),
                Text(
                  order.deliveryDate,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Order\nStatus:',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.0,
                    color: colors.textSecondary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(width: 24.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 5.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8392A5),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<OrderProcessStatus>(
                      value: currentStatus,
                      isDense: true,
                      dropdownColor: const Color(0xFF8392A5),
                      icon: const Padding(
                        padding: EdgeInsets.only(left: 4.0),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 15.0,
                        ),
                      ),
                      items: OrderProcessStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(
                            status.name[0].toUpperCase() +
                                status.name.substring(1),
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (newStatus) {
                        if (newStatus != null) onStatusChanged(newStatus);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [storeInfo, const SizedBox(height: 16.0), orderMeta],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(child: storeInfo),
            const SizedBox(width: 16.0),
            orderMeta,
          ],
        );
      },
    );
  }

  Widget _buildTableSection(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 12.0),
          color: const Color(0xFFECEFF3),
          child: Row(
            children: [
              SizedBox(
                width: 36.0,
                child: Text(
                  '#',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10.0,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  'SERVICE NAME',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10.0,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'IMAGES',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10.0,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'RATE',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10.0,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'QTY',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10.0,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'TOTAL',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10.0,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        ...order.items.map((item) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 26.0,
              vertical: 11.0,
            ),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 36.0,
                  child: Text(
                    '${item.index}',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12.0,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Row(
                    children: [
                      GarmentLineIcon(type: item.garmentType, size: 38.0),
                      const SizedBox(width: 14.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.serviceName,
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1.0),
                            Text(
                              item.serviceType,
                              style: textTheme.labelSmall?.copyWith(
                                fontSize: 11.0,
                                color: const Color(0xFF2B729E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Expanded(flex: 2, child: SizedBox.shrink()),
                Expanded(
                  flex: 2,
                  child: Text(
                    'KES ${item.rate.toStringAsFixed(2)}',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12.0,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${item.quantity}',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12.0,
                      color: colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'KES ${item.total.toStringAsFixed(2)}',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12.0,
                      color: colors.textSecondary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice To:',
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              order.customerName,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 13.0,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 250.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Details:',
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Sub Total:',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12.0,
                          color: colors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'KES ${order.itemsSubTotal.toStringAsFixed(2)}',
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.0,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
