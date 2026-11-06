import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/core/widgets/garment_line_icon.dart';
import 'package:laundry_ridge/features/orders/data/orders_repository.dart';
import 'package:laundry_ridge/features/orders/domain/order_addon.dart';
import 'package:laundry_ridge/features/orders/domain/order_detail.dart';
import 'package:laundry_ridge/features/orders/domain/order_item.dart';
import 'package:laundry_ridge/features/orders/domain/order_payment.dart';
import 'package:laundry_ridge/features/orders/presentation/order_details_state.dart';

class OrderDetailsNotifier extends Notifier<OrderDetailsUiState> {
  bool _disposed = false;

  @override
  OrderDetailsUiState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    Future.microtask(() => loadOrderDetails('#ORD-0006'));
    return OrderDetailsUiState.initial();
  }

  Future<void> loadOrderDetails(String orderId) async {
    if (_disposed) return;
    state = state.copyWith(
      status: OrderDetailsUiStatus.loading,
      errorMessage: null,
    );

    try {
      final repository = ref.read(ordersRepositoryProvider);
      final allOrders = await repository.fetchOrders();
      final order = await repository.fetchOrderDetail(orderId);
      if (_disposed) return;
      state = state.copyWith(
        status: OrderDetailsUiStatus.success,
        orders: allOrders,
        order: order,
        currentStatus: order.status,
      );
    } catch (exception) {
      if (_disposed) return;
      state = state.copyWith(
        status: OrderDetailsUiStatus.error,
        errorMessage: exception.toString(),
      );
    }
  }

  void openOrderDetails(String orderId) {
    final matchingOrder = state.orders.firstWhere(
      (item) => item.orderId == orderId,
      orElse: () => state.order ?? state.orders.first,
    );
    state = state.copyWith(
      order: matchingOrder,
      currentStatus: matchingOrder.status,
      isShowingOrdersList: false,
    );
  }

  void showOrdersList() {
    state = state.copyWith(isShowingOrdersList: true);
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateStatusFilter(OrderProcessStatus? status) {
    state = state.copyWith(
      statusFilter: status,
      clearStatusFilter: status == null,
    );
  }

  void updatePaymentStatusFilter(String? value) {
    state = state.copyWith(
      paymentStatusFilter: value,
      clearPaymentStatusFilter: value == null,
    );
  }

  void updateServiceTypeFilter(String? value) {
    state = state.copyWith(
      serviceTypeFilter: value,
      clearServiceTypeFilter: value == null,
    );
  }

  void updateVendorFilter(String? value) {
    state = state.copyWith(
      vendorFilter: value,
      clearVendorFilter: value == null,
    );
  }

  void updateCustomerFilter(String? value) {
    state = state.copyWith(
      customerFilter: value,
      clearCustomerFilter: value == null,
    );
  }

  void updateDateCreatedFilter(String? value) {
    state = state.copyWith(
      dateCreatedFilter: value,
      clearDateCreatedFilter: value == null,
    );
  }

  void updateDeliveryMethodFilter(String? value) {
    state = state.copyWith(
      deliveryMethodFilter: value,
      clearDeliveryMethodFilter: value == null,
    );
  }

  void updateAssignedRiderFilter(String? value) {
    state = state.copyWith(
      assignedRiderFilter: value,
      clearAssignedRiderFilter: value == null,
    );
  }

  void resetAllFilters() {
    state = state.copyWith(
      searchQuery: '',
      clearStatusFilter: true,
      clearPaymentStatusFilter: true,
      clearServiceTypeFilter: true,
      clearVendorFilter: true,
      clearCustomerFilter: true,
      clearDateCreatedFilter: true,
      clearDeliveryMethodFilter: true,
      clearAssignedRiderFilter: true,
    );
  }

  void updateOrderStatus(OrderProcessStatus newStatus) {
    final currentOrder = state.order;
    if (currentOrder == null) {
      state = state.copyWith(currentStatus: newStatus);
      return;
    }

    final updatedOrder = OrderDetail(
      orderId: currentOrder.orderId,
      storeName: currentOrder.storeName,
      storeCode: currentOrder.storeCode,
      storeEmail: currentOrder.storeEmail,
      storeAddress: currentOrder.storeAddress,
      taxIdentifier: currentOrder.taxIdentifier,
      orderDate: currentOrder.orderDate,
      deliveryDate: currentOrder.deliveryDate,
      status: newStatus,
      customerName: currentOrder.customerName,
      customerPhone: currentOrder.customerPhone,
      assignedStaff: currentOrder.assignedStaff,
      primaryService: currentOrder.primaryService,
      vendorBranch: currentOrder.vendorBranch,
      displayAmount: currentOrder.displayAmount,
      paymentStatusLabel: currentOrder.paymentStatusLabel,
      processingStageLabel: newStatus.displayLabel,
      deliveryStatusLabel: currentOrder.deliveryStatusLabel,
      deliveryMethod: currentOrder.deliveryMethod,
      assignedRider: currentOrder.assignedRider,
      createdDateLabel: currentOrder.createdDateLabel,
      items: currentOrder.items,
      addons: currentOrder.addons,
      payments: currentOrder.payments,
    );

    final updatedList = [
      for (final item in state.orders)
        if (item.orderId == updatedOrder.orderId) updatedOrder else item,
    ];

    state = state.copyWith(
      order: updatedOrder,
      orders: updatedList,
      currentStatus: newStatus,
      actionFeedbackMessage:
          'Order status updated to ${newStatus.displayLabel}',
    );
  }

  void selectSidebarIndex(int index) {
    state = state.copyWith(selectedSidebarIndex: index);
  }

  void toggleSidebar() {
    state = state.copyWith(isSidebarCollapsed: !state.isSidebarCollapsed);
  }

  void incrementCatalogGarment(GarmentType garment) {
    final updatedCounts = Map<GarmentType, int>.from(state.catalogQuantities);
    updatedCounts[garment] = (updatedCounts[garment] ?? 0) + 1;

    final currentOrder = state.order;
    if (currentOrder == null) {
      state = state.copyWith(catalogQuantities: updatedCounts);
      return;
    }

    final existingIdx = currentOrder.items.indexWhere(
      (item) => item.garmentType == garment,
    );

    final List<OrderItem> updatedItems;
    if (existingIdx >= 0) {
      updatedItems = [
        for (var i = 0; i < currentOrder.items.length; i++)
          if (i == existingIdx)
            OrderItem(
              index: currentOrder.items[i].index,
              serviceName: currentOrder.items[i].serviceName,
              serviceType: currentOrder.items[i].serviceType,
              rate: currentOrder.items[i].rate,
              quantity: currentOrder.items[i].quantity + 1,
              icon: currentOrder.items[i].icon,
              garmentType: currentOrder.items[i].garmentType,
            )
          else
            currentOrder.items[i],
      ];
    } else {
      updatedItems = [
        ...currentOrder.items,
        OrderItem(
          index: currentOrder.items.length + 1,
          serviceName: garment.displayName,
          serviceType: garment.defaultServiceType,
          rate: garment.defaultRate,
          quantity: 1,
          icon: Icons.checkroom_rounded,
          garmentType: garment,
        ),
      ];
    }

    final updatedOrder = OrderDetail(
      orderId: currentOrder.orderId,
      storeName: currentOrder.storeName,
      storeCode: currentOrder.storeCode,
      storeEmail: currentOrder.storeEmail,
      storeAddress: currentOrder.storeAddress,
      taxIdentifier: currentOrder.taxIdentifier,
      orderDate: currentOrder.orderDate,
      deliveryDate: currentOrder.deliveryDate,
      status: state.currentStatus,
      customerName: currentOrder.customerName,
      customerPhone: currentOrder.customerPhone,
      assignedStaff: currentOrder.assignedStaff,
      primaryService: currentOrder.primaryService,
      vendorBranch: currentOrder.vendorBranch,
      displayAmount: currentOrder.displayAmount,
      paymentStatusLabel: currentOrder.paymentStatusLabel,
      processingStageLabel: currentOrder.processingStageLabel,
      deliveryStatusLabel: currentOrder.deliveryStatusLabel,
      deliveryMethod: currentOrder.deliveryMethod,
      assignedRider: currentOrder.assignedRider,
      createdDateLabel: currentOrder.createdDateLabel,
      items: updatedItems,
      addons: currentOrder.addons,
      payments: currentOrder.payments,
    );

    final updatedList = [
      for (final item in state.orders)
        if (item.orderId == updatedOrder.orderId) updatedOrder else item,
    ];

    state = state.copyWith(
      order: updatedOrder,
      orders: updatedList,
      catalogQuantities: updatedCounts,
      actionFeedbackMessage:
          'Added ${garment.displayName} to ${updatedOrder.orderId}',
    );
  }

  void decrementCatalogGarment(GarmentType garment) {
    final currentCount = state.catalogQuantities[garment] ?? 0;
    if (currentCount <= 0) return;

    final updatedCounts = Map<GarmentType, int>.from(state.catalogQuantities);
    if (currentCount == 1) {
      updatedCounts.remove(garment);
    } else {
      updatedCounts[garment] = currentCount - 1;
    }

    final currentOrder = state.order;
    if (currentOrder == null) {
      state = state.copyWith(catalogQuantities: updatedCounts);
      return;
    }

    final existingIdx = currentOrder.items.indexWhere(
      (item) => item.garmentType == garment,
    );

    List<OrderItem> updatedItems = currentOrder.items;
    if (existingIdx >= 0) {
      final item = currentOrder.items[existingIdx];
      if (item.quantity > 1) {
        updatedItems = [
          for (var i = 0; i < currentOrder.items.length; i++)
            if (i == existingIdx)
              OrderItem(
                index: item.index,
                serviceName: item.serviceName,
                serviceType: item.serviceType,
                rate: item.rate,
                quantity: item.quantity - 1,
                icon: item.icon,
                garmentType: item.garmentType,
              )
            else
              currentOrder.items[i],
        ];
      }
    }

    final updatedOrder = OrderDetail(
      orderId: currentOrder.orderId,
      storeName: currentOrder.storeName,
      storeCode: currentOrder.storeCode,
      storeEmail: currentOrder.storeEmail,
      storeAddress: currentOrder.storeAddress,
      taxIdentifier: currentOrder.taxIdentifier,
      orderDate: currentOrder.orderDate,
      deliveryDate: currentOrder.deliveryDate,
      status: state.currentStatus,
      customerName: currentOrder.customerName,
      customerPhone: currentOrder.customerPhone,
      assignedStaff: currentOrder.assignedStaff,
      primaryService: currentOrder.primaryService,
      vendorBranch: currentOrder.vendorBranch,
      displayAmount: currentOrder.displayAmount,
      paymentStatusLabel: currentOrder.paymentStatusLabel,
      processingStageLabel: currentOrder.processingStageLabel,
      deliveryStatusLabel: currentOrder.deliveryStatusLabel,
      deliveryMethod: currentOrder.deliveryMethod,
      assignedRider: currentOrder.assignedRider,
      createdDateLabel: currentOrder.createdDateLabel,
      items: updatedItems,
      addons: currentOrder.addons,
      payments: currentOrder.payments,
    );

    final updatedList = [
      for (final item in state.orders)
        if (item.orderId == updatedOrder.orderId) updatedOrder else item,
    ];

    state = state.copyWith(
      order: updatedOrder,
      orders: updatedList,
      catalogQuantities: updatedCounts,
      actionFeedbackMessage: 'Updated ${garment.displayName} quantity',
    );
  }

  void recordPayment({required double amount, required String method}) {
    final currentOrder = state.order;
    if (currentOrder == null) return;

    final updatedPayments = [
      ...currentOrder.payments,
      OrderPayment(amount: amount, date: '05/11/2026', method: '[$method]'),
    ];

    final updatedOrder = OrderDetail(
      orderId: currentOrder.orderId,
      storeName: currentOrder.storeName,
      storeCode: currentOrder.storeCode,
      storeEmail: currentOrder.storeEmail,
      storeAddress: currentOrder.storeAddress,
      taxIdentifier: currentOrder.taxIdentifier,
      orderDate: currentOrder.orderDate,
      deliveryDate: currentOrder.deliveryDate,
      status: state.currentStatus,
      customerName: currentOrder.customerName,
      customerPhone: currentOrder.customerPhone,
      assignedStaff: currentOrder.assignedStaff,
      primaryService: currentOrder.primaryService,
      vendorBranch: currentOrder.vendorBranch,
      displayAmount: currentOrder.displayAmount,
      paymentStatusLabel: 'Paid',
      processingStageLabel: currentOrder.processingStageLabel,
      deliveryStatusLabel: currentOrder.deliveryStatusLabel,
      deliveryMethod: currentOrder.deliveryMethod,
      assignedRider: currentOrder.assignedRider,
      createdDateLabel: currentOrder.createdDateLabel,
      items: currentOrder.items,
      addons: currentOrder.addons,
      payments: updatedPayments,
    );

    final updatedList = [
      for (final item in state.orders)
        if (item.orderId == updatedOrder.orderId) updatedOrder else item,
    ];

    state = state.copyWith(
      order: updatedOrder,
      orders: updatedList,
      actionFeedbackMessage:
          'Payment of KES ${amount.toStringAsFixed(2)} recorded.',
    );
  }

  void triggerPrintInvoice() {
    state = state.copyWith(
      actionFeedbackMessage: 'Invoice ready for print: ${state.order?.orderId}',
    );
  }

  void notifyCatalogAction(String message) {
    state = state.copyWith(actionFeedbackMessage: message);
  }

  void clearCatalogQuantities() {
    state = state.copyWith(catalogQuantities: const {});
  }

  String createNewPosOrder({
    required String customerName,
    required String customerPhone,
    required String primaryService,
    required String vendorBranch,
    required String deliveryMethod,
    required String assignedRider,
    required String paymentStatusLabel,
    required String paymentMethod,
    required bool includeStainRemoval,
    required bool includeExtraFragrance,
  }) {
    final entries = state.catalogQuantities.entries
        .where((entry) => entry.value > 0)
        .toList();

    final items = <OrderItem>[
      for (var i = 0; i < entries.length; i++)
        OrderItem(
          index: i + 1,
          serviceName: entries[i].key.displayName,
          serviceType: '[$primaryService]',
          rate: entries[i].key.defaultRate,
          quantity: entries[i].value,
          icon: Icons.checkroom_rounded,
          garmentType: entries[i].key,
        ),
    ];

    final addons = <OrderAddon>[
      if (includeStainRemoval)
        const OrderAddon(name: 'Stain Removal', amount: 30.0),
      if (includeExtraFragrance)
        const OrderAddon(name: 'Extra Fragrance', amount: 10.0),
    ];

    final subTotal = items.fold<double>(0.0, (sum, item) => sum + item.total);
    final addonTotal = addons.fold<double>(
      0.0,
      (sum, addon) => sum + addon.amount,
    );
    final grandTotal = subTotal + addonTotal;

    final nextSequence = 125 + state.orders.length;
    final newOrderId = 'LG-2026-00$nextSequence';

    final payments = <OrderPayment>[
      if (paymentStatusLabel == 'Paid')
        OrderPayment(
          amount: grandTotal,
          date: '05/11/2026',
          method: '[$paymentMethod]',
        )
      else if (paymentStatusLabel == 'Partial')
        OrderPayment(
          amount: (grandTotal * 0.5).roundToDouble(),
          date: '05/11/2026',
          method: '[$paymentMethod]',
        ),
    ];

    final newOrder = OrderDetail(
      orderId: newOrderId,
      storeName: 'HARBORRIDGE LAUNDRY',
      storeCode: 'HR-2026',
      storeEmail: 'orders@harborridgelaundry.com',
      storeAddress: vendorBranch,
      taxIdentifier: 'TAX: KRA-PIN-P051',
      orderDate: '05/11/2026',
      deliveryDate: '07/11/2026',
      status: OrderProcessStatus.processing,
      customerName: customerName.trim().isEmpty
          ? 'Walk-in Customer'
          : customerName.trim(),
      customerPhone: customerPhone.trim().isEmpty
          ? '+254 700 000 000'
          : customerPhone.trim(),
      assignedStaff: 'Elena Rostova',
      primaryService: primaryService,
      vendorBranch: vendorBranch,
      displayAmount: 'KES ${grandTotal.toStringAsFixed(0)}',
      paymentStatusLabel: paymentStatusLabel,
      processingStageLabel: 'Received',
      deliveryStatusLabel: deliveryMethod,
      deliveryMethod: deliveryMethod,
      assignedRider: assignedRider,
      createdDateLabel: '05 Nov 2026',
      items: items,
      addons: addons,
      payments: payments,
    );

    final updatedOrders = [newOrder, ...state.orders];
    state = state.copyWith(
      orders: updatedOrders,
      order: newOrder,
      currentStatus: newOrder.status,
      isShowingOrdersList: false,
      actionFeedbackMessage:
          'Created order $newOrderId for ${newOrder.customerName}',
    );
    return newOrderId;
  }

  void clearFeedbackMessage() {
    state = state.copyWith(actionFeedbackMessage: null);
  }
}

final orderDetailsNotifierProvider =
    NotifierProvider<OrderDetailsNotifier, OrderDetailsUiState>(
      OrderDetailsNotifier.new,
    );
