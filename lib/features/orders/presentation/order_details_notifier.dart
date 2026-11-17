import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/core/auth/auth_session.dart';
import 'package:laundry_ridge/core/errors/app_failure.dart';
import 'package:laundry_ridge/core/utilities/client_ref.dart';
import 'package:laundry_ridge/core/widgets/garment_line_icon.dart';
import 'package:laundry_ridge/features/orders/data/orders_repository.dart';
import 'package:laundry_ridge/features/orders/domain/order_addon.dart';
import 'package:laundry_ridge/features/orders/domain/order_detail.dart';
import 'package:laundry_ridge/features/orders/domain/order_item.dart';
import 'package:laundry_ridge/features/orders/domain/order_payment.dart';
import 'package:laundry_ridge/features/orders/presentation/order_details_state.dart';

class OrderDetailsNotifier extends Notifier<OrderDetailsUiState> {
  bool _disposed = false;
  bool _paymentInFlight = false;
  bool _orderCreateInFlight = false;

  /// Reused until the POS order is confirmed, so a retry after a dropped
  /// response returns the same order instead of creating a second one.
  String? _pendingOrderClientRef;

  /// Item edits are saved one after another so a slow request cannot
  /// overwrite a newer one.
  Future<void> _itemSaveChain = Future<void>.value();

  static String _failureMessage(Object error) =>
      error is AppFailure ? error.message : error.toString();

  void _saveItems(OrderDetail order) {
    final repository = ref.read(ordersRepositoryProvider);
    _itemSaveChain = _itemSaveChain.then((_) async {
      try {
        await repository.replaceOrderItems(order.orderId, order.items);
      } on Object catch (error) {
        if (_disposed) return;
        state = state.copyWith(
          actionFeedbackMessage:
              'Could not save items for ${order.orderId}: ${_failureMessage(error)}. Reloading the order.',
        );
        await loadOrderDetails(order.orderId);
      }
    });
  }

  @override
  OrderDetailsUiState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    // Rebuilt (and data cleared) whenever the signed-in worker changes, so
    // data loads after sign-in and nothing lingers after sign-out. Before
    // sign-in the database refuses every read, so don't ask.
    final signedInId = ref.watch(_signedInWorkerId);
    if (signedInId.isNotEmpty) {
      Future.microtask(() => loadOrderDetails('#ORD-0006'));
    }
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
      OrderDetail? order;
      if (allOrders.isNotEmpty) {
        order = allOrders.firstWhere(
          (item) => item.orderId == orderId,
          orElse: () => allOrders.first,
        );
      } else {
        try {
          order = await repository.fetchOrderDetail(orderId);
        } catch (_) {
          order = null;
        }
      }
      if (_disposed) return;
      state = state.copyWith(
        status: OrderDetailsUiStatus.success,
        orders: allOrders,
        order: order,
        currentStatus: order?.status ?? OrderProcessStatus.processing,
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

  Future<void> updateOrderStatus(OrderProcessStatus newStatus) async {
    final currentOrder = state.order;
    if (currentOrder == null) {
      state = state.copyWith(currentStatus: newStatus);
      return;
    }

    try {
      await ref
          .read(ordersRepositoryProvider)
          .updateOrderStatus(currentOrder.orderId, newStatus);
    } on Object catch (error) {
      if (_disposed) return;
      state = state.copyWith(
        actionFeedbackMessage: 'Status not changed: ${_failureMessage(error)}',
      );
      return;
    }
    if (_disposed) return;

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

  /// POS intake: changes only the new-order draft, never an existing order.
  void incrementPosGarment(GarmentType garment) {
    final updated = Map<GarmentType, int>.from(state.catalogQuantities);
    updated[garment] = (updated[garment] ?? 0) + 1;
    state = state.copyWith(catalogQuantities: updated);
  }

  /// POS intake: changes only the new-order draft, never an existing order.
  void decrementPosGarment(GarmentType garment) {
    final updated = Map<GarmentType, int>.from(state.catalogQuantities);
    final next = (updated[garment] ?? 0) - 1;
    if (next <= 0) {
      updated.remove(garment);
    } else {
      updated[garment] = next;
    }
    state = state.copyWith(catalogQuantities: updated);
  }

  /// Order page: adds a garment to the order that is open and saves it.
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

    _saveItems(updatedOrder);
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

    _saveItems(updatedOrder);
  }

  /// Records a payment once the server accepts it. Returns null on success or
  /// the reason it was rejected (over the balance, reused reference, no access).
  Future<String?> recordPayment({
    required double amount,
    required String method,
    String? reference,
  }) async {
    final currentOrder = state.order;
    if (currentOrder == null) return 'Open an order first.';
    if (_paymentInFlight) return 'A payment is already being saved.';
    if (amount <= 0) return 'Enter an amount greater than zero.';
    if (amount > currentOrder.balanceDue + 0.005) {
      return 'KES ${amount.toStringAsFixed(2)} is more than the KES ${currentOrder.balanceDue.clamp(0, double.infinity).toStringAsFixed(2)} balance due.';
    }

    final trimmedReference = reference?.trim().toUpperCase();
    final newPayment = OrderPayment(
      amount: amount,
      date: _todayLabel(),
      method: '[$method]',
      reference: (trimmedReference?.isEmpty ?? true) ? null : trimmedReference,
    );

    _paymentInFlight = true;
    try {
      await ref
          .read(ordersRepositoryProvider)
          .recordPayment(
            currentOrder.orderId,
            newPayment,
            clientRef: newClientRef(),
          );
    } on Object catch (error) {
      final message = _failureMessage(error);
      if (!_disposed) {
        state = state.copyWith(
          actionFeedbackMessage: 'Payment not recorded: $message',
        );
      }
      return message;
    } finally {
      _paymentInFlight = false;
    }
    if (_disposed) return null;

    final latest = state.order?.orderId == currentOrder.orderId
        ? state.order!
        : currentOrder;
    final updatedPayments = [...latest.payments, newPayment];
    final paid = updatedPayments.fold<double>(0, (sum, p) => sum + p.amount);
    final updatedOrder = latest.copyWith(
      payments: updatedPayments,
      paymentStatusLabel: paid + 0.005 >= latest.totalAmount
          ? 'Paid'
          : 'Partial',
    );

    state = state.copyWith(
      order: updatedOrder,
      orders: [
        for (final item in state.orders)
          if (item.orderId == updatedOrder.orderId) updatedOrder else item,
      ],
      actionFeedbackMessage:
          'Payment of KES ${amount.toStringAsFixed(2)} recorded.',
    );
    return null;
  }

  static String _todayLabel([DateTime? date]) {
    final now = date ?? DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
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
    _pendingOrderClientRef = null;
    state = state.copyWith(catalogQuantities: const {});
  }

  /// Creates the POS order on the server and returns its order number, or
  /// null if it was rejected (the reason is in actionFeedbackMessage).
  Future<String?> createNewPosOrder({
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
  }) async {
    if (_orderCreateInFlight) return null;

    final entries = state.catalogQuantities.entries
        .where((entry) => entry.value > 0)
        .toList();
    if (entries.isEmpty) {
      state = state.copyWith(
        actionFeedbackMessage:
            'Add at least one garment before creating an order.',
      );
      return null;
    }

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

    final now = DateTime.now();
    final initialPayment = switch (paymentStatusLabel) {
      'Paid' => OrderPayment(
        amount: grandTotal,
        date: _todayLabel(now),
        method: '[$paymentMethod]',
      ),
      'Partial' => OrderPayment(
        amount: (grandTotal * 0.5).roundToDouble(),
        date: _todayLabel(now),
        method: '[$paymentMethod]',
      ),
      _ => null,
    };

    final operator = ref.read(authSessionNotifierProvider).currentWorker;
    final draft = OrderDetail(
      orderId: '',
      storeName: 'HARBOR RIDGE',
      storeCode: '+254 142 188767',
      storeEmail: operator.email,
      storeAddress: 'Getathuru Road • Directly opposite NG-CDF Kabete Plaza',
      taxIdentifier: 'TAX: KRA-PIN-P05123984A',
      orderDate: _todayLabel(now),
      deliveryDate: _todayLabel(now.add(const Duration(days: 2))),
      status: OrderProcessStatus.processing,
      customerName: customerName.trim().isEmpty
          ? 'Walk-in Customer'
          : customerName.trim(),
      customerPhone: customerPhone.trim(),
      assignedStaff: operator.fullName,
      primaryService: primaryService,
      vendorBranch: vendorBranch,
      displayAmount: 'KES ${grandTotal.toStringAsFixed(0)}',
      paymentStatusLabel: initialPayment == null
          ? 'Unpaid'
          : (paymentStatusLabel == 'Paid' ? 'Paid' : 'Partial'),
      processingStageLabel: 'Received',
      deliveryStatusLabel: deliveryMethod,
      deliveryMethod: deliveryMethod,
      assignedRider: assignedRider,
      createdDateLabel: _todayLabel(now),
      items: items,
      addons: addons,
      payments: [?initialPayment],
    );

    _orderCreateInFlight = true;
    final clientRef = _pendingOrderClientRef ??= newClientRef();
    final String newOrderId;
    try {
      newOrderId = await ref
          .read(ordersRepositoryProvider)
          .createOrder(
            draft,
            clientRef: clientRef,
            initialPayment: initialPayment,
          );
    } on Object catch (error) {
      if (!_disposed) {
        state = state.copyWith(
          actionFeedbackMessage: 'Order not created: ${_failureMessage(error)}',
        );
      }
      return null;
    } finally {
      _orderCreateInFlight = false;
    }
    _pendingOrderClientRef = null;
    if (_disposed) return newOrderId;

    final newOrder = draft.copyWith(orderId: newOrderId);
    state = state.copyWith(
      orders: [newOrder, ...state.orders],
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

/// The signed-in worker's id, or '' when signed out.
final _signedInWorkerId = Provider<String>(
  (ref) => ref.watch(
    authSessionNotifierProvider.select(
      (s) => s.isAuthenticated ? s.currentWorker.id : '',
    ),
  ),
);

final orderDetailsNotifierProvider =
    NotifierProvider<OrderDetailsNotifier, OrderDetailsUiState>(
      OrderDetailsNotifier.new,
    );
