import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_ridge/core/widgets/garment_line_icon.dart';
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
      expect(state.orders.first.vendorBranch, 'Harborridge Main');
      expect(state.orders.first.displayAmount, 'KES 1,500');
      expect(state.orders, isNotEmpty);
      expect(state.orders.first.orderId, 'LG-2026-00125');
      expect(state.orders.first.customerName, 'John Kamau');
      expect(state.orders.first.vendorBranch, 'Harborridge Main');
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

    notifier.updateVendorFilter('Harborridge Main');
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

    notifier.updateVendorFilter('Harborridge Main');
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

      final notifier = container.read(orderDetailsNotifierProvider.notifier);
      await notifier.updateOrderStatus(OrderProcessStatus.cleaning);

      expect(
        container.read(orderDetailsNotifierProvider).currentStatus,
        OrderProcessStatus.cleaning,
      );

      // #ORD-0006: KES 890 total, KES 350 already paid, KES 540 due.
      final failure = await notifier.recordPayment(
        amount: 200.0,
        method: 'CARD',
      );
      expect(failure, isNull);

      final updatedState = container.read(orderDetailsNotifierProvider);
      expect(updatedState.order!.payments.length, 2);
      expect(updatedState.order!.paidAmount, 550.0);
      expect(updatedState.order!.paymentStatusLabel, 'Partial');
    },
  );

  test('rejects a payment larger than the balance due', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(orderDetailsNotifierProvider.notifier);
    await notifier.loadOrderDetails('#ORD-0006');

    final failure = await notifier.recordPayment(
      amount: 350.0 * 5,
      method: 'M-Pesa',
    );

    expect(failure, contains('more than'));
    expect(
      container.read(orderDetailsNotifierProvider).order!.payments.length,
      1,
    );
  });

  test('ignores a second tap while a payment is being saved', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(orderDetailsNotifierProvider.notifier);
    await notifier.loadOrderDetails('#ORD-0006');

    final first = notifier.recordPayment(amount: 100.0, method: 'Cash');
    final second = await notifier.recordPayment(amount: 100.0, method: 'Cash');
    expect(second, contains('already being saved'));
    expect(await first, isNull);

    expect(
      container.read(orderDetailsNotifierProvider).order!.payments.length,
      2,
    );
  });

  test('paying the full balance marks the order Paid', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(orderDetailsNotifierProvider.notifier);
    await notifier.loadOrderDetails('#ORD-0006');
    final due = container.read(orderDetailsNotifierProvider).order!.balanceDue;

    expect(await notifier.recordPayment(amount: due, method: 'M-Pesa'), isNull);
    expect(
      container.read(orderDetailsNotifierProvider).order!.paymentStatusLabel,
      'Paid',
    );
  });

  test('POS garment taps change only the draft, not the open order', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(orderDetailsNotifierProvider.notifier);
    await notifier.loadOrderDetails('#ORD-0006');
    final before = container.read(orderDetailsNotifierProvider).order!;
    final draftShirts =
        container
            .read(orderDetailsNotifierProvider)
            .catalogQuantities[GarmentType.shirt] ??
        0;

    notifier.incrementPosGarment(GarmentType.shirt);
    notifier.incrementPosGarment(GarmentType.shirt);
    notifier.decrementPosGarment(GarmentType.shirt);

    final state = container.read(orderDetailsNotifierProvider);
    expect(state.catalogQuantities[GarmentType.shirt], draftShirts + 1);
    expect(state.order!.items.length, before.items.length);
    expect(state.order!.totalAmount, before.totalAmount);
  });
}
