import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_ridge/features/production/domain/production_order_card.dart';
import 'package:laundry_ridge/features/production/presentation/order_tracking_notifier.dart';
import 'package:laundry_ridge/features/production/presentation/order_tracking_state.dart';

void main() {
  test(
    'OrderTrackingNotifier loads production cards with all required fields',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(orderTrackingNotifierProvider).status,
        OrderTrackingStatus.loading,
      );

      await container
          .read(orderTrackingNotifierProvider.notifier)
          .loadProductionBoard();

      final state = container.read(orderTrackingNotifierProvider);
      expect(state.status, OrderTrackingStatus.success);
      expect(state.orders, isNotEmpty);

      for (final order in state.orders) {
        expect(order.orderNumber.isNotEmpty, isTrue);
        expect(order.customerName.isNotEmpty, isTrue);
        expect(order.itemCountOrWeight.isNotEmpty, isTrue);
        expect(order.serviceType.isNotEmpty, isTrue);
        expect(order.timeReceived.isNotEmpty, isTrue);
        expect(order.dueTime.isNotEmpty, isTrue);
        expect(order.assignedStaff.isNotEmpty, isTrue);
      }
    },
  );

  test(
    'OrderTrackingNotifier moves order across Kanban stages and filters',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(orderTrackingNotifierProvider.notifier)
          .loadProductionBoard();

      container
          .read(orderTrackingNotifierProvider.notifier)
          .moveOrderToStage(
            orderNumber: '#561',
            targetStage: ProductionStage.drying,
          );

      final dryingOrders = container
          .read(orderTrackingNotifierProvider)
          .ordersForStage(ProductionStage.drying);
      expect(dryingOrders.any((o) => o.orderNumber == '#561'), isTrue);

      container
          .read(orderTrackingNotifierProvider.notifier)
          .filterByPriority(OrderPriority.urgent);

      final filteredDrying = container
          .read(orderTrackingNotifierProvider)
          .ordersForStage(ProductionStage.drying);
      expect(
        filteredDrying.every((o) => o.priority == OrderPriority.urgent),
        isTrue,
      );
    },
  );
}
