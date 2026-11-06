import 'package:flutter/material.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';
import 'package:laundry_ridge/features/orders/domain/order_detail.dart';

class OrderAddonsPaymentsCard extends StatelessWidget {
  const OrderAddonsPaymentsCard({
    super.key,
    required this.order,
    required this.onAddPayment,
    required this.onPrintInvoice,
  });

  final OrderDetail order;
  final VoidCallback onAddPayment;
  final VoidCallback onPrintInvoice;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

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
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Service Addons',
            style: textTheme.titleSmall?.copyWith(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 14.0),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7FA),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < order.addons.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10.0),
                  Text(
                    '${order.addons[i].name}:   KES ${order.addons[i].amount.toStringAsFixed(2)}',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12.0,
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22.0),
          Text(
            'Payments',
            style: textTheme.titleSmall?.copyWith(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 14.0),
          ...order.payments.map((payment) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.radio_button_checked_rounded,
                    size: 16.0,
                    color: Color(0xFF8392A5),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KES ${payment.amount.toStringAsFixed(2)}',
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3.0),
                        Text(
                          '${payment.date}   ${payment.method}',
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 11.0,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 6.0),
          InteractivePressScale(
            onTap: onAddPayment,
            child: Container(
              width: double.infinity,
              height: 38.0,
              decoration: BoxDecoration(
                color: const Color(0xFF3CC48E),
                borderRadius: BorderRadius.circular(6.0),
              ),
              alignment: Alignment.center,
              child: Text(
                'ADD PAYMENT',
                style: textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontSize: 11.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          InteractivePressScale(
            onTap: onPrintInvoice,
            child: Container(
              width: double.infinity,
              height: 38.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF1AC4E),
                borderRadius: BorderRadius.circular(6.0),
              ),
              alignment: Alignment.center,
              child: Text(
                'Print Invoice',
                style: textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontSize: 11.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
