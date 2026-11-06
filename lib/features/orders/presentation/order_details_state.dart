import 'package:laundry_ridge/core/widgets/garment_line_icon.dart';
import 'package:laundry_ridge/features/orders/domain/order_detail.dart';

enum OrderDetailsUiStatus { loading, success, error }

class OrderDetailsUiState {
  const OrderDetailsUiState({
    required this.status,
    required this.selectedSidebarIndex,
    required this.orders,
    required this.order,
    required this.currentStatus,
    required this.isSidebarCollapsed,
    required this.isShowingOrdersList,
    required this.searchQuery,
    required this.statusFilter,
    required this.paymentStatusFilter,
    required this.serviceTypeFilter,
    required this.vendorFilter,
    required this.customerFilter,
    required this.dateCreatedFilter,
    required this.deliveryMethodFilter,
    required this.assignedRiderFilter,
    required this.catalogQuantities,
    this.errorMessage,
    this.actionFeedbackMessage,
  });

  final OrderDetailsUiStatus status;
  final int selectedSidebarIndex;
  final List<OrderDetail> orders;
  final OrderDetail? order;
  final OrderProcessStatus currentStatus;
  final bool isSidebarCollapsed;
  final bool isShowingOrdersList;
  final String searchQuery;
  final OrderProcessStatus? statusFilter;
  final String? paymentStatusFilter;
  final String? serviceTypeFilter;
  final String? vendorFilter;
  final String? customerFilter;
  final String? dateCreatedFilter;
  final String? deliveryMethodFilter;
  final String? assignedRiderFilter;
  final Map<GarmentType, int> catalogQuantities;
  final String? errorMessage;
  final String? actionFeedbackMessage;

  bool get hasActiveFilters =>
      searchQuery.trim().isNotEmpty ||
      statusFilter != null ||
      paymentStatusFilter != null ||
      serviceTypeFilter != null ||
      vendorFilter != null ||
      customerFilter != null ||
      dateCreatedFilter != null ||
      deliveryMethodFilter != null ||
      assignedRiderFilter != null;

  List<OrderDetail> get filteredOrders {
    final query = searchQuery.trim().toLowerCase();
    return orders.where((item) {
      if (statusFilter != null && item.status != statusFilter) {
        return false;
      }
      if (paymentStatusFilter != null &&
          item.paymentStatusLabel != paymentStatusFilter) {
        return false;
      }
      if (serviceTypeFilter != null &&
          item.primaryService != serviceTypeFilter) {
        return false;
      }
      if (vendorFilter != null && item.vendorBranch != vendorFilter) {
        return false;
      }
      if (customerFilter != null && item.customerName != customerFilter) {
        return false;
      }
      if (dateCreatedFilter != null &&
          item.createdDateLabel != dateCreatedFilter) {
        return false;
      }
      if (deliveryMethodFilter != null &&
          item.deliveryMethod != deliveryMethodFilter) {
        return false;
      }
      if (assignedRiderFilter != null &&
          item.assignedRider != assignedRiderFilter) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return item.orderId.toLowerCase().contains(query) ||
          item.customerName.toLowerCase().contains(query) ||
          item.vendorBranch.toLowerCase().contains(query) ||
          item.primaryService.toLowerCase().contains(query) ||
          item.assignedRider.toLowerCase().contains(query);
    }).toList();
  }

  factory OrderDetailsUiState.initial() {
    return const OrderDetailsUiState(
      status: OrderDetailsUiStatus.loading,
      selectedSidebarIndex: 1,
      orders: [],
      order: null,
      currentStatus: OrderProcessStatus.processing,
      isSidebarCollapsed: false,
      isShowingOrdersList: true,
      searchQuery: '',
      statusFilter: null,
      paymentStatusFilter: null,
      serviceTypeFilter: null,
      vendorFilter: null,
      customerFilter: null,
      dateCreatedFilter: null,
      deliveryMethodFilter: null,
      assignedRiderFilter: null,
      catalogQuantities: {GarmentType.tanBlazer: 1, GarmentType.shirt: 2},
      errorMessage: null,
      actionFeedbackMessage: null,
    );
  }

  OrderDetailsUiState copyWith({
    OrderDetailsUiStatus? status,
    int? selectedSidebarIndex,
    List<OrderDetail>? orders,
    OrderDetail? order,
    OrderProcessStatus? currentStatus,
    bool? isSidebarCollapsed,
    bool? isShowingOrdersList,
    String? searchQuery,
    OrderProcessStatus? statusFilter,
    bool clearStatusFilter = false,
    String? paymentStatusFilter,
    bool clearPaymentStatusFilter = false,
    String? serviceTypeFilter,
    bool clearServiceTypeFilter = false,
    String? vendorFilter,
    bool clearVendorFilter = false,
    String? customerFilter,
    bool clearCustomerFilter = false,
    String? dateCreatedFilter,
    bool clearDateCreatedFilter = false,
    String? deliveryMethodFilter,
    bool clearDeliveryMethodFilter = false,
    String? assignedRiderFilter,
    bool clearAssignedRiderFilter = false,
    Map<GarmentType, int>? catalogQuantities,
    String? errorMessage,
    String? actionFeedbackMessage,
  }) {
    return OrderDetailsUiState(
      status: status ?? this.status,
      selectedSidebarIndex: selectedSidebarIndex ?? this.selectedSidebarIndex,
      orders: orders ?? this.orders,
      order: order ?? this.order,
      currentStatus: currentStatus ?? this.currentStatus,
      isSidebarCollapsed: isSidebarCollapsed ?? this.isSidebarCollapsed,
      isShowingOrdersList: isShowingOrdersList ?? this.isShowingOrdersList,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: clearStatusFilter
          ? null
          : (statusFilter ?? this.statusFilter),
      paymentStatusFilter: clearPaymentStatusFilter
          ? null
          : (paymentStatusFilter ?? this.paymentStatusFilter),
      serviceTypeFilter: clearServiceTypeFilter
          ? null
          : (serviceTypeFilter ?? this.serviceTypeFilter),
      vendorFilter: clearVendorFilter
          ? null
          : (vendorFilter ?? this.vendorFilter),
      customerFilter: clearCustomerFilter
          ? null
          : (customerFilter ?? this.customerFilter),
      dateCreatedFilter: clearDateCreatedFilter
          ? null
          : (dateCreatedFilter ?? this.dateCreatedFilter),
      deliveryMethodFilter: clearDeliveryMethodFilter
          ? null
          : (deliveryMethodFilter ?? this.deliveryMethodFilter),
      assignedRiderFilter: clearAssignedRiderFilter
          ? null
          : (assignedRiderFilter ?? this.assignedRiderFilter),
      catalogQuantities: catalogQuantities ?? this.catalogQuantities,
      errorMessage: errorMessage ?? this.errorMessage,
      actionFeedbackMessage: actionFeedbackMessage,
    );
  }
}
