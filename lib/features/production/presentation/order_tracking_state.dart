import 'package:laundry_ridge/features/production/domain/production_order_card.dart';

enum OrderTrackingStatus { loading, success, error }

class OrderTrackingState {
  const OrderTrackingState({
    required this.status,
    required this.orders,
    required this.activeWorkflowTab,
    required this.selectedPriorityFilter,
    required this.searchQuery,
    this.draggedOrderNumber,
    this.errorMessage,
  });

  final OrderTrackingStatus status;
  final List<ProductionOrderCard> orders;
  final BoardWorkflowTab activeWorkflowTab;
  final OrderPriority? selectedPriorityFilter;
  final String searchQuery;
  final String? draggedOrderNumber;
  final String? errorMessage;

  factory OrderTrackingState.initial() {
    return const OrderTrackingState(
      status: OrderTrackingStatus.loading,
      orders: [],
      activeWorkflowTab: BoardWorkflowTab.clean,
      selectedPriorityFilter: null,
      searchQuery: '',
    );
  }

  List<ProductionOrderCard> ordersForStage(ProductionStage stage) {
    return orders.where((order) {
      if (order.stage != stage) return false;
      if (selectedPriorityFilter != null &&
          order.priority != selectedPriorityFilter) {
        return false;
      }
      if (searchQuery.trim().isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesNumber = order.orderNumber.toLowerCase().contains(query);
        final matchesCustomer = order.customerName.toLowerCase().contains(
          query,
        );
        final matchesStaff = order.assignedStaff.toLowerCase().contains(query);
        final matchesService = order.serviceType.toLowerCase().contains(query);
        if (!matchesNumber &&
            !matchesCustomer &&
            !matchesStaff &&
            !matchesService) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  OrderTrackingState copyWith({
    OrderTrackingStatus? status,
    List<ProductionOrderCard>? orders,
    BoardWorkflowTab? activeWorkflowTab,
    OrderPriority? selectedPriorityFilter,
    bool clearPriorityFilter = false,
    String? searchQuery,
    String? draggedOrderNumber,
    bool clearDraggedOrder = false,
    String? errorMessage,
  }) {
    return OrderTrackingState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      activeWorkflowTab: activeWorkflowTab ?? this.activeWorkflowTab,
      selectedPriorityFilter: clearPriorityFilter
          ? null
          : (selectedPriorityFilter ?? this.selectedPriorityFilter),
      searchQuery: searchQuery ?? this.searchQuery,
      draggedOrderNumber: clearDraggedOrder
          ? null
          : (draggedOrderNumber ?? this.draggedOrderNumber),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
