import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_ridge/features/orders/domain/order_detail.dart';
import 'package:laundry_ridge/features/orders/presentation/order_details_notifier.dart';
import 'package:laundry_ridge/features/orders/presentation/order_details_state.dart';

void main() {
  test(
    'OrderDetailsNotifier loads order details and computes totals',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(orderDetailsNotifierProvider).status,
        OrderDetailsUiStatus.loading,
      );

      await container
          .read(orderDetailsNotifierProvider.notifier)
          .loadOrderDetails('#ORD-0006');

      final state = container.read(orderDetailsNotifierProvider);
      expect(state.status, OrderDetailsUiStatus.success);
      expect(state.orders, isNotEmpty);
      expect(state.orders.first.orderId, 'LG-2026-00125');
      expect(state.orders.first.customerName, 'John Kamau');
      expect(state.orders.first.vendorBranch, 'LaundryGo Nairobi');
      expect(state.orders.first.displayAmount, 'KES 1,500');
      expect(state.orders, isNotEmpty);
      expect(state.orders.first.orderId, 'LG-2026-00125');
      expect(state.orders.first.customerName, 'John Kamau');
      expect(state.orders.first.vendorBranch, 'LaundryGo Nairobi');
      expect(state.orders.first.displayAmount, 'KES 1,500');
      expect(state.order, isNotNull);
      expect(state.order!.orderId, '#ORD-0006');
      expect(state.order!.items.length, 6);
      expect(state.order!.itemsSubTotal, 850.0);
      expect(state.order!.addonsTotal, 40.0);
      expect(state.order!.paidAmount, 350.0);
    },
  );

  test('OrderDetailsNotifier filters order list by status, payment, service, vendor, customer, date, delivery, and rider', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(orderDetailsNotifierProvider.notifier);
    await notifier.loadOrderDetails('#ORD-0006');

    notifier.updateVendorFilter('LaundryGo Nairobi');
    notifier.updatePaymentStatusFilter('Paid');
    notifier.updateServiceTypeFilter('Wash & Fold');
    notifier.updateCustomerFilter('John Kamau');
    notifier.updateDateCreatedFilter('05 Nov 2026');
    notifier.updateDeliveryMethodFilter('Pickup assigned');
    notifier.updateAssignedRiderFilter('Peter Njoroge');

    final filtered = container
        .read(orderDetailsNotifierProvider)
        .filteredOrders;
    expect(filtered.length, 1);
    expect(filtered.single.orderId, 'LG-2026-00125');

    notifier.resetAllFilters();
    expect(
      container.read(orderDetailsNotifierProvider).filteredOrders.length,
      6,
    );
  });

  test('OrderDetailsNotifier filters order list by status, payment, service, vendor, customer, date, delivery, and rider', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(orderDetailsNotifierProvider.notifier);
    await notifier.loadOrderDetails('#ORD-0006');

    notifier.updateVendorFilter('LaundryGo Nairobi');
    notifier.updatePaymentStatusFilter('Paid');
    notifier.updateServiceTypeFilter('Wash & Fold');
    notifier.updateCustomerFilter('John Kamau');
    notifier.updateDateCreatedFilter('05 Nov 2026');
    notifier.updateDeliveryMethodFilter('Pickup assigned');
    notifier.updateAssignedRiderFilter('Peter Njoroge');

    final filtered = container
        .read(orderDetailsNotifierProvider)
        .filteredOrders;
    expect(filtered.length, 1);
    expect(filtered.single.orderId, 'LG-2026-00125');

    notifier.resetAllFilters();
    expect(
      container.read(orderDetailsNotifierProvider).filteredOrders.length,
      6,
    );
  });

  test(
    'OrderDetailsNotifier updates process status and records payment',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(orderDetailsNotifierProvider.notifier)
          .loadOrderDetails('#ORD-0006');

      container
          .read(orderDetailsNotifierProvider.notifier)
          .updateOrderStatus(OrderProcessStatus.cleaning);

      expect(
        container.read(orderDetailsNotifierProvider).currentStatus,
        OrderProcessStatus.cleaning,
      );

      container
          .read(orderDetailsNotifierProvider.notifier)
          .recordPayment(amount: 200.0, method: 'CARD');

      final updatedState = container.read(orderDetailsNotifierProvider);
      expect(updatedState.order!.payments.length, 2);
      expect(updatedState.order!.paidAmount, 550.0);
    },
  );
}
