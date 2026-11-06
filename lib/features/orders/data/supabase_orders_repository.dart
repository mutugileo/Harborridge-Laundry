import 'package:flutter/material.dart';
import 'package:laundry_ridge/core/widgets/garment_line_icon.dart';
import 'package:laundry_ridge/features/orders/data/orders_repository.dart';
import 'package:laundry_ridge/features/orders/domain/order_addon.dart';
import 'package:laundry_ridge/features/orders/domain/order_detail.dart';
import 'package:laundry_ridge/features/orders/domain/order_item.dart';
import 'package:laundry_ridge/features/orders/domain/order_payment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseOrdersRepository implements OrdersRepository {
  SupabaseOrdersRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<OrderDetail>> fetchOrders() async {
    try {
      final response = await _client
          .from('orders')
          .select('*, order_items(*), order_addons(*), order_payments(*)')
          .order('created_at', ascending: false);

      final list = (response as List)
          .map((row) => _mapToOrderDetail(row as Map<String, dynamic>))
          .toList();
      return list;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<OrderDetail> fetchOrderDetail(String orderId) async {
    try {
      final response = await _client
          .from('orders')
          .select('*, order_items(*), order_addons(*), order_payments(*)')
          .eq('order_id', orderId)
          .maybeSingle();

      if (response != null) {
        return _mapToOrderDetail(response);
      }
    } catch (_) {}

    throw StateError('Order not found in database: $orderId');
  }

  @override
  Future<void> updateOrderStatus(
    String orderId,
    OrderProcessStatus status,
  ) async {
    try {
      await _client
          .from('orders')
          .update({
            'status': status.name,
            'processing_stage_label': status.displayLabel,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('order_id', orderId);
    } catch (_) {}
  }

  @override
  Future<void> createOrder(OrderDetail order) async {
    try {
      await _client.from('orders').insert({
        'order_id': order.orderId,
        'store_name': order.storeName,
        'store_code': order.storeCode,
        'store_email': order.storeEmail,
        'store_address': order.storeAddress,
        'tax_identifier': order.taxIdentifier,
        'order_date': order.orderDate,
        'delivery_date': order.deliveryDate,
        'status': order.status.name,
        'customer_name': order.customerName,
        'customer_phone': order.customerPhone,
        'assigned_staff': order.assignedStaff,
        'primary_service': order.primaryService,
        'vendor_branch': order.vendorBranch,
        'display_amount': order.displayAmount,
        'payment_status_label': order.paymentStatusLabel,
        'processing_stage_label': order.processingStageLabel,
        'delivery_status_label': order.deliveryStatusLabel,
        'delivery_method': order.deliveryMethod,
        'assigned_rider': order.assignedRider,
        'created_date_label': order.createdDateLabel,
      });

      if (order.items.isNotEmpty) {
        await _client
            .from('order_items')
            .insert(
              order.items
                  .map(
                    (item) => {
                      'order_id': order.orderId,
                      'item_index': item.index,
                      'service_name': item.serviceName,
                      'service_type': item.serviceType,
                      'rate': item.rate,
                      'quantity': item.quantity,
                      'garment_type': item.garmentType.name,
                    },
                  )
                  .toList(),
            );
      }

      if (order.addons.isNotEmpty) {
        await _client
            .from('order_addons')
            .insert(
              order.addons
                  .map(
                    (addon) => {
                      'order_id': order.orderId,
                      'name': addon.name,
                      'amount': addon.amount,
                    },
                  )
                  .toList(),
            );
      }

      if (order.payments.isNotEmpty) {
        await _client
            .from('order_payments')
            .insert(
              order.payments
                  .map(
                    (payment) => {
                      'order_id': order.orderId,
                      'amount': payment.amount,
                      'payment_date': payment.date,
                      'method': payment.method,
                    },
                  )
                  .toList(),
            );
      }
    } catch (_) {}
  }

  OrderDetail _mapToOrderDetail(Map<String, dynamic> row) {
    final statusStr = row['status'] as String? ?? 'washing';
    final status = OrderProcessStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => OrderProcessStatus.washing,
    );

    final rawItems = row['order_items'] as List<dynamic>? ?? const [];
    final items = rawItems.map((raw) {
      final itemMap = raw as Map<String, dynamic>;
      final garmentTypeName = itemMap['garment_type'] as String? ?? 'shirt';
      final garmentType = GarmentType.values.firstWhere(
        (g) => g.name == garmentTypeName,
        orElse: () => GarmentType.shirt,
      );
      return OrderItem(
        index: (itemMap['item_index'] as num?)?.toInt() ?? 1,
        serviceName: itemMap['service_name'] as String? ?? 'Laundry Item',
        serviceType: itemMap['service_type'] as String? ?? '[Wash & Fold]',
        rate: (itemMap['rate'] as num?)?.toDouble() ?? 0.0,
        quantity: (itemMap['quantity'] as num?)?.toInt() ?? 1,
        icon: _iconForGarment(garmentType),
        garmentType: garmentType,
      );
    }).toList();

    final rawAddons = row['order_addons'] as List<dynamic>? ?? const [];
    final addons = rawAddons.map((raw) {
      final addonMap = raw as Map<String, dynamic>;
      return OrderAddon(
        name: addonMap['name'] as String? ?? 'Addon',
        amount: (addonMap['amount'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

    final rawPayments = row['order_payments'] as List<dynamic>? ?? const [];
    final payments = rawPayments.map((raw) {
      final paymentMap = raw as Map<String, dynamic>;
      return OrderPayment(
        amount: (paymentMap['amount'] as num?)?.toDouble() ?? 0.0,
        date: paymentMap['payment_date'] as String? ?? '',
        method: paymentMap['method'] as String? ?? '[M-PESA]',
      );
    }).toList();

    return OrderDetail(
      orderId: row['order_id'] as String? ?? '',
      storeName: row['store_name'] as String? ?? 'HARBORRIDGE LAUNDRY',
      storeCode: row['store_code'] as String? ?? '123456',
      storeEmail: row['store_email'] as String? ?? 'store@store.com',
      storeAddress: row['store_address'] as String? ?? 'Nairobi, Kenya',
      taxIdentifier: row['tax_identifier'] as String? ?? 'TAX: KRA-PIN',
      orderDate: row['order_date'] as String? ?? '',
      deliveryDate: row['delivery_date'] as String? ?? '',
      status: status,
      customerName: row['customer_name'] as String? ?? 'Walk-in Customer',
      customerPhone: row['customer_phone'] as String? ?? '',
      assignedStaff: row['assigned_staff'] as String? ?? 'Attendant',
      primaryService: row['primary_service'] as String? ?? 'Wash & Fold',
      vendorBranch: row['vendor_branch'] as String? ?? 'LaundryGo Nairobi',
      displayAmount: row['display_amount'] as String? ?? 'KES 0',
      paymentStatusLabel: row['payment_status_label'] as String? ?? 'Unpaid',
      processingStageLabel:
          row['processing_stage_label'] as String? ?? status.displayLabel,
      deliveryStatusLabel: row['delivery_status_label'] as String? ?? 'Pending',
      deliveryMethod: row['delivery_method'] as String? ?? 'Pickup',
      assignedRider: row['assigned_rider'] as String? ?? 'Unassigned',
      createdDateLabel: row['created_date_label'] as String? ?? '',
      items: items,
      addons: addons,
      payments: payments,
    );
  }

  static IconData _iconForGarment(GarmentType type) {
    switch (type) {
      case GarmentType.halterTop:
      case GarmentType.tanBlazer:
      case GarmentType.womensTop:
      case GarmentType.womensDress:
      case GarmentType.trousers:
      case GarmentType.scarfOnHanger:
      case GarmentType.shirtDress:
      case GarmentType.camisoleDress:
      case GarmentType.stripedTee:
      case GarmentType.shirt:
      case GarmentType.denimJacket:
      case GarmentType.wrapSkirt:
      case GarmentType.fedoraHat:
      case GarmentType.bowTie:
        return Icons.checkroom_rounded;
      case GarmentType.denimShorts:
      case GarmentType.jeans:
        return Icons.accessibility_new_rounded;
      case GarmentType.babyClothes:
        return Icons.child_care_rounded;
      case GarmentType.winterGloves:
      case GarmentType.underGarments:
      case GarmentType.hoodie:
        return Icons.wash_rounded;
      case GarmentType.leatherJacket:
      case GarmentType.blueSuitJacket:
        return Icons.dry_cleaning_rounded;
    }
  }
}
