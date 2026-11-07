import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/features/production/data/order_tracking_repository.dart';
import 'package:laundry_ridge/features/production/domain/production_order_card.dart';
import 'package:laundry_ridge/features/production/presentation/order_tracking_state.dart';

class OrderTrackingNotifier extends Notifier<OrderTrackingState> {
  bool _disposed = false;

  @override
  OrderTrackingState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    Future.microtask(loadProductionBoard);
    return OrderTrackingState.initial();
  }

  Future<void> loadProductionBoard() async {
    if (_disposed) return;
    state = state.copyWith(
      status: OrderTrackingStatus.loading,
      errorMessage: null,
    );

    try {
      final repository = ref.read(orderTrackingRepositoryProvider);
      final orders = await repository.fetchProductionOrders();
      if (_disposed) return;
      state = state.copyWith(
        status: OrderTrackingStatus.success,
        orders: orders,
      );
    } catch (exception) {
      if (_disposed) return;
      state = state.copyWith(
        status: OrderTrackingStatus.error,
        errorMessage: exception.toString(),
      );
    }
  }

  void moveOrderToStage({
    required String orderNumber,
    required ProductionStage targetStage,
  }) {
    final updatedOrders = state.orders.map((order) {
      if (order.orderNumber != orderNumber) return order;
      return order.copyWith(
        stage: targetStage,
        progress: _defaultProgressForStage(targetStage),
        statusNote: _defaultStatusNoteForStage(targetStage),
        isStageComplete: targetStage == ProductionStage.fold,
      );
    }).toList();

    state = state.copyWith(orders: updatedOrders, clearDraggedOrder: true);
    ref
        .read(orderTrackingRepositoryProvider)
        .updateOrderStage(orderNumber, targetStage);
    ref.read(orderTrackingRepositoryProvider).updateOrderStage(orderNumber, targetStage);
  }

  void advanceOrderToNextStage(String orderNumber) {
    final index = state.orders.indexWhere((o) => o.orderNumber == orderNumber);
    if (index == -1) return;

    final currentOrder = state.orders[index];
    final currentStageIndex = currentOrder.stage.index;
    final nextStageIndex =
        (currentStageIndex + 1) % ProductionStage.values.length;
    final nextStage = ProductionStage.values[nextStageIndex];

    moveOrderToStage(orderNumber: orderNumber, targetStage: nextStage);
  }

  void reassignStaffMember({
    required String orderNumber,
    required String staffName,
  }) {
    final updatedOrders = state.orders.map((order) {
      if (order.orderNumber != orderNumber) return order;
      return order.copyWith(assignedStaff: staffName);
    }).toList();

    state = state.copyWith(orders: updatedOrders);
    ref
        .read(orderTrackingRepositoryProvider)
        .reassignStaff(orderNumber, staffName);
    ref.read(orderTrackingRepositoryProvider).reassignStaff(orderNumber, staffName);
  }

  void selectWorkflowTab(BoardWorkflowTab tab) {
    state = state.copyWith(activeWorkflowTab: tab);
  }

  void filterByPriority(OrderPriority? priority) {
    if (priority == null) {
      state = state.copyWith(clearPriorityFilter: true);
    } else {
      state = state.copyWith(selectedPriorityFilter: priority);
    }
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setDraggedOrder(String? orderNumber) {
    if (orderNumber == null) {
      state = state.copyWith(clearDraggedOrder: true);
    } else {
      state = state.copyWith(draggedOrderNumber: orderNumber);
    }
  }

  void addProductionOrderFromPos({
    required String orderNumber,
    required String customerName,
    required String serviceType,
    required int itemCount,
    required String assignedStaff,
  }) {
    final weight = (itemCount * 0.8).toStringAsFixed(1);
    final newCard = ProductionOrderCard(
      orderNumber: orderNumber,
      customerName: customerName,
      priority: OrderPriority.high,
      stationNumber: '#${state.orders.length + 1}',
      serviceType: serviceType,
      itemCountOrWeight: '$itemCount items • $weight lbs',
      statusNote: 'Sorted & tagged from POS intake',
      isStageComplete: false,
      assignedStaff: assignedStaff,
      timeReceived: 'Just now',
      dueTime: '07/11 04:00 PM',
      progress: 0.25,
      stage: ProductionStage.toDo,
    );
    state = state.copyWith(orders: [newCard, ...state.orders]);
  }

  double _defaultProgressForStage(ProductionStage stage) {
    switch (stage) {
      case ProductionStage.toDo:
        return 0.20;
      case ProductionStage.cleaning:
        return 0.55;
      case ProductionStage.drying:
        return 0.75;
      case ProductionStage.fold:
        return 0.95;
    }
  }

  String _defaultStatusNoteForStage(ProductionStage stage) {
    switch (stage) {
      case ProductionStage.toDo:
        return 'Queued for washing intake';
      case ProductionStage.cleaning:
        return 'Active wash cycle in progress';
      case ProductionStage.drying:
        return 'Tumble dry cycle active';
      case ProductionStage.fold:
        return 'Folding & quality inspection';
    }
  }
}

final orderTrackingNotifierProvider =
    NotifierProvider<OrderTrackingNotifier, OrderTrackingState>(
      OrderTrackingNotifier.new,
    );
