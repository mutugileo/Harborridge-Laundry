import 'package:laundry_ridge/features/orders/domain/order_addon.dart';
import 'package:laundry_ridge/features/orders/domain/order_item.dart';
import 'package:laundry_ridge/features/orders/domain/order_payment.dart';

enum OrderProcessStatus {
  washing,
  processing,
  cleaning,
  ironing,
  completed,
  delivered,
}

extension OrderProcessStatusLabel on OrderProcessStatus {
  String get displayLabel {
    switch (this) {
      case OrderProcessStatus.washing:
        return 'Washing';
      case OrderProcessStatus.processing:
        return 'Processing';
      case OrderProcessStatus.cleaning:
        return 'Cleaning';
      case OrderProcessStatus.ironing:
        return 'Ironing';
      case OrderProcessStatus.completed:
        return 'Completed';
      case OrderProcessStatus.delivered:
        return 'Delivered';
    }
  }
}

class OrderDetail {
  const OrderDetail({
    required this.orderId,
    required this.storeName,
    required this.storeCode,
    required this.storeEmail,
    required this.storeAddress,
    required this.taxIdentifier,
    required this.orderDate,
    required this.deliveryDate,
    required this.status,
    required this.customerName,
    required this.items,
    required this.addons,
    required this.payments,
    this.customerPhone = '+254 712 345 678',
    this.assignedStaff = 'Clara M.',
    this.primaryService = 'Wash & Fold',
    this.vendorBranch = 'LaundryGo Nairobi',
    this.displayAmount = 'KES 1,500',
    this.paymentStatusLabel = 'Paid',
    this.processingStageLabel = 'Washing',
    this.deliveryStatusLabel = 'Pickup assigned',
    this.deliveryMethod = 'Pickup assigned',
    this.assignedRider = 'Peter Njoroge',
    this.createdDateLabel = '05 Nov 2026',
  });

  final String orderId;
  final String storeName;
  final String storeCode;
  final String storeEmail;
  final String storeAddress;
  final String taxIdentifier;
  final String orderDate;
  final String deliveryDate;
  final OrderProcessStatus status;
  final String customerName;
  final String customerPhone;
  final String assignedStaff;
  final String primaryService;
  final String vendorBranch;
  final String displayAmount;
  final String paymentStatusLabel;
  final String processingStageLabel;
  final String deliveryStatusLabel;
  final String deliveryMethod;
  final String assignedRider;
  final String createdDateLabel;
  final List<OrderItem> items;
  final List<OrderAddon> addons;
  final List<OrderPayment> payments;

  int get totalPieces =>
      items.fold(0, (previous, item) => previous + item.quantity);

  double get itemsSubTotal =>
      items.fold(0.0, (previous, item) => previous + item.total);

  double get addonsTotal =>
      addons.fold(0.0, (previous, addon) => previous + addon.amount);

  double get totalAmount => itemsSubTotal + addonsTotal;

  double get paidAmount =>
      payments.fold(0.0, (previous, payment) => previous + payment.amount);

  double get balanceDue => totalAmount - paidAmount;
}
