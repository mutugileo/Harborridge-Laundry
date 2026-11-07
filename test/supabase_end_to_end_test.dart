import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laundry_ridge/core/widgets/garment_line_icon.dart';
import 'package:laundry_ridge/features/orders/domain/order_detail.dart';
import 'package:laundry_ridge/features/orders/presentation/order_details_notifier.dart';
import 'package:laundry_ridge/features/production/domain/production_order_card.dart';
import 'package:laundry_ridge/features/production/presentation/order_tracking_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Supabase and Backend End-to-End Flow Tests', () {
    test(
      'Orders Repository & Notifier: Order Creation, Payment & Status Flow',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(orderDetailsNotifierProvider.notifier);
        await notifier.loadOrderDetails('#ORD-0006');
        await Future<void>.delayed(const Duration(milliseconds: 200));

        final initialOrder = container.read(orderDetailsNotifierProvider).order;
        expect(initialOrder, isNotNull);

        // Record a payment of KES 500
        notifier.recordPayment(amount: 500.0, method: 'M-PESA');
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final updatedOrder = container.read(orderDetailsNotifierProvider).order;
        expect(updatedOrder, isNotNull);
        expect(updatedOrder!.payments.any((p) => p.amount == 500.0), isTrue);
        expect(updatedOrder.paymentStatusLabel, 'Paid');

        // Update Order Status
        notifier.updateOrderStatus(OrderProcessStatus.ironing);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final afterStatusChange = container
            .read(orderDetailsNotifierProvider)
            .order;
        expect(afterStatusChange!.status, OrderProcessStatus.ironing);

        // Increment Catalog Garment Item
        notifier.incrementCatalogGarment(GarmentType.shirt);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final afterItemAdd = container.read(orderDetailsNotifierProvider).order;
        expect(
          afterItemAdd!.items.any((i) => i.garmentType == GarmentType.shirt),
          isTrue,
        );
      },
    );

    test('Production Kanban: Stage Transitions & Staff Reassignment', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(orderTrackingNotifierProvider.notifier);
      await notifier.loadProductionBoard();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final initialState = container.read(orderTrackingNotifierProvider);
      expect(initialState.orders.isNotEmpty, isTrue);

      const targetOrderNumber = '#561';
      const targetStage = ProductionStage.drying;

      notifier.moveOrderToStage(
        orderNumber: targetOrderNumber,
        targetStage: targetStage,
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final dryingOrders = container
          .read(orderTrackingNotifierProvider)
          .ordersForStage(ProductionStage.drying);
      expect(
        dryingOrders.any((o) => o.orderNumber == targetOrderNumber),
        isTrue,
      );

      // Reassign staff
      const newStaff = 'Faith Wanjiku';
      notifier.reassignStaffMember(
        orderNumber: targetOrderNumber,
        staffName: newStaff,
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final stateAfterStaff = container.read(orderTrackingNotifierProvider);
      final orderWithNewStaff = stateAfterStaff.orders.firstWhere(
        (o) => o.orderNumber == targetOrderNumber,
      );
      expect(orderWithNewStaff.assignedStaff, newStaff);
    });
  });
}
