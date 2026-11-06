import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/features/production/domain/production_order_card.dart';

abstract class OrderTrackingRepository {
  Future<List<ProductionOrderCard>> fetchProductionOrders();
}

class InMemoryOrderTrackingRepository implements OrderTrackingRepository {
  @override
  Future<List<ProductionOrderCard>> fetchProductionOrders() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return const [
      ProductionOrderCard(
        orderNumber: '#592',
        customerName: 'Liam O\'Connor',
        itemCountOrWeight: '14 items • 11.2 lbs',
        serviceType: 'Wash & Fold',
        priority: OrderPriority.urgent,
        stationNumber: '#1',
        timeReceived: '10:15 AM',
        dueTime: '12/06 04:00 PM',
        assignedStaff: 'Sarah Kim',
        stage: ProductionStage.toDo,
        progress: 0.15,
        statusNote: 'Sorted & tagged for intake',
      ),
      ProductionOrderCard(
        orderNumber: '#ORD-0006',
        customerName: 'Moncy James',
        itemCountOrWeight: '21 items • 16.5 lbs',
        serviceType: 'Wash & Iron',
        priority: OrderPriority.high,
        stationNumber: '#2',
        timeReceived: '09:05 AM',
        dueTime: '12/06 06:00 PM',
        assignedStaff: 'Marcus Vance',
        stage: ProductionStage.toDo,
        progress: 0.25,
        statusNote: 'Stain pre-treatment queued',
      ),
      ProductionOrderCard(
        orderNumber: '#561',
        customerName: 'Polly Matthews',
        itemCountOrWeight: '16 items • 12.8 lbs',
        serviceType: 'Wet Wash',
        priority: OrderPriority.urgent,
        stationNumber: '#3',
        timeReceived: '09:41 AM',
        dueTime: '12/06 02:30 PM',
        assignedStaff: 'Elena Rostova',
        stage: ProductionStage.cleaning,
        progress: 0.95,
        statusNote: 'Cleaning complete',
        isStageComplete: true,
      ),
      ProductionOrderCard(
        orderNumber: '#589',
        customerName: 'Clara Vance',
        itemCountOrWeight: '8 items • 6.4 lbs',
        serviceType: 'Dry Cleaning',
        priority: OrderPriority.standard,
        stationNumber: '#4',
        timeReceived: '10:30 AM',
        dueTime: '12/07 11:00 AM',
        assignedStaff: 'David Chen',
        stage: ProductionStage.cleaning,
        progress: 0.55,
        statusNote: 'Delicate solvent cycle (24m left)',
      ),
      ProductionOrderCard(
        orderNumber: '#548',
        customerName: 'Emma Davis',
        itemCountOrWeight: '19 items • 15.0 lbs',
        serviceType: 'Wash & Fold',
        priority: OrderPriority.high,
        stationNumber: '#3',
        timeReceived: '08:20 AM',
        dueTime: '12/08 12:00 PM',
        assignedStaff: 'Sarah Kim',
        stage: ProductionStage.drying,
        progress: 0.72,
        statusNote: 'Tumble dry medium heat',
      ),
      ProductionOrderCard(
        orderNumber: '#607',
        customerName: 'Hollie Matthews',
        itemCountOrWeight: '12 items • 9.6 lbs',
        serviceType: 'Wash & Iron',
        priority: OrderPriority.urgent,
        stationNumber: '#1',
        timeReceived: '09:15 AM',
        dueTime: '12/06 03:15 PM',
        assignedStaff: 'Marcus Vance',
        stage: ProductionStage.drying,
        progress: 0.60,
        statusNote: 'Humidity sensor cycle',
      ),
      ProductionOrderCard(
        orderNumber: '#608',
        customerName: 'Adam Dunnett',
        itemCountOrWeight: '10 items • 7.8 lbs',
        serviceType: 'Dry Cleaning',
        priority: OrderPriority.standard,
        stationNumber: '#2',
        timeReceived: '08:50 AM',
        dueTime: '12/06 05:00 PM',
        assignedStaff: 'Elena Rostova',
        stage: ProductionStage.drying,
        progress: 0.85,
        statusNote: 'Cool-down phase',
        isStageComplete: true,
      ),
      ProductionOrderCard(
        orderNumber: '#541',
        customerName: 'Noah Patel',
        itemCountOrWeight: '15 items • 11.8 lbs',
        serviceType: 'Wash & Fold',
        priority: OrderPriority.high,
        stationNumber: '#5',
        timeReceived: '07:45 AM',
        dueTime: '12/06 01:30 PM',
        assignedStaff: 'David Chen',
        stage: ProductionStage.fold,
        progress: 0.90,
        statusNote: 'Steam press & packaging',
        isStageComplete: true,
      ),
    ];
  }
}

final orderTrackingRepositoryProvider = Provider<OrderTrackingRepository>((
  ref,
) {
  return InMemoryOrderTrackingRepository();
});
