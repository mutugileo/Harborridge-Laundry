import 'package:flutter/material.dart';
import 'package:laundry_ridge/core/errors/app_failure.dart';
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

  static const String _orderSelect =
      '*, order_items(*), order_addons(*), order_payments(*)';

  @override
  Future<List<OrderDetail>> fetchOrders() async {
    final response = await _guard(
      () => _client
          .from('orders')
          .select(_orderSelect)
          .order('created_at', ascending: false),
    );
    return [
      for (final row in response as List)
        _mapToOrderDetail(row as Map<String, dynamic>),
    ];
  }

  @override
  Future<OrderDetail> fetchOrderDetail(String orderId) async {
    final response = await _guard(
      () => _client
          .from('orders')
          .select(_orderSelect)
          .eq('order_id', orderId)
          .maybeSingle(),
    );
    if (response == null) {
      throw AppFailure(message: 'Order $orderId was not found.');
    }
    return _mapToOrderDetail(response);
  }

  @override
  Future<void> updateOrderStatus(
    String orderId,
    OrderProcessStatus status,
  ) async {
    final updated = await _guard(
      () => _client
          .from('orders')
          .update({
            'status': status.name,
            'processing_stage_label': status.displayLabel,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('order_id', orderId)
          .select('order_id'),
    );
    if ((updated as List).isEmpty) {
      throw const AppFailure(
        message: 'Your account cannot change order status.',
        code: 'forbidden',
      );
    }
  }

  @override
  Future<String> createOrder(
    OrderDetail draft, {
    required String clientRef,
    OrderPayment? initialPayment,
  }) async {
    final result = await _guard(
      () => _client.rpc(
        'create_order',
        params: {
          'p_client_ref': clientRef,
          'p_order': {
            'customer_name': draft.customerName,
            'customer_phone': draft.customerPhone,
            'primary_service': draft.primaryService,
            'vendor_branch': draft.vendorBranch,
            'delivery_method': draft.deliveryMethod,
            'assigned_rider': draft.assignedRider,
            'delivery_date': draft.deliveryDate,
          },
          'p_items': [for (final item in draft.items) _itemJson(item)],
          'p_addons': [
            for (final addon in draft.addons)
              {'name': addon.name, 'amount': addon.amount},
          ],
          'p_payment': initialPayment == null
              ? null
              : {
                  'amount': initialPayment.amount,
                  'method': _cleanMethod(initialPayment.method),
                  'reference': initialPayment.reference,
                },
        },
      ),
    );
    return (result as Map<String, dynamic>)['order_id'] as String;
  }

  @override
  Future<void> recordPayment(
    String orderId,
    OrderPayment payment, {
    required String clientRef,
  }) async {
    await _guard(
      () => _client.rpc(
        'record_order_payment',
        params: {
          'p_client_ref': clientRef,
          'p_order_id': orderId,
          'p_amount': payment.amount,
          'p_method': _cleanMethod(payment.method),
          'p_reference': payment.reference,
        },
      ),
    );
  }

  @override
  Future<void> replaceOrderItems(String orderId, List<OrderItem> items) async {
    await _guard(
      () => _client.rpc(
        'replace_order_items',
        params: {
          'p_order_id': orderId,
          'p_items': [for (final item in items) _itemJson(item)],
        },
      ),
    );
  }

  static Map<String, dynamic> _itemJson(OrderItem item) => {
    'service_name': item.serviceName,
    'service_type': item.serviceType,
    'rate': item.rate,
    'quantity': item.quantity,
    'garment_type': item.garmentType.name,
    if (item.imageUrl != null) 'image_url': item.imageUrl,
  };

  static String _cleanMethod(String method) =>
      method.replaceAll('[', '').replaceAll(']', '').trim();

  /// Runs a query and turns database errors into messages staff can act on.
  static Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on PostgrestException catch (error) {
      if (error.code == '42501') {
        throw AppFailure(
          message: error.message.contains('permission denied')
              ? 'Your account does not have access to do that.'
              : error.message,
          code: 'forbidden',
        );
      }
      throw AppFailure(message: error.message, code: error.code);
    }
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
        imageUrl: itemMap['image_url'] as String?,
      );
    }).toList()..sort((a, b) => a.index.compareTo(b.index));

    final rawAddons = row['order_addons'] as List<dynamic>? ?? const [];
    final addons = rawAddons.map((raw) {
      final addonMap = raw as Map<String, dynamic>;
      return OrderAddon(
        name: addonMap['name'] as String? ?? 'Addon',
        amount: (addonMap['amount'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

    final rawPayments = row['order_payments'] as List<dynamic>? ?? const [];
    final payments = rawPayments
        .cast<Map<String, dynamic>>()
        .where((paymentMap) => paymentMap['voided_at'] == null)
        .map(
          (paymentMap) => OrderPayment(
            amount: (paymentMap['amount'] as num?)?.toDouble() ?? 0.0,
            date: paymentMap['payment_date'] as String? ?? '',
            method: paymentMap['method'] as String? ?? '[M-PESA]',
            reference: paymentMap['reference_code'] as String?,
          ),
        )
        .toList();

    return OrderDetail(
      orderId: row['order_id'] as String? ?? '',
      storeName: row['store_name'] as String? ?? 'HARBOR RIDGE LAUNDRY',
      storeCode: row['store_code'] as String? ?? '+254 142 188767',
      storeEmail:
          row['store_email'] as String? ?? 'operations@harborridge.co.ke',
      storeAddress:
          row['store_address'] as String? ??
          'Getathuru Road • Directly opposite NG-CDF Kabete Plaza',
      taxIdentifier:
          row['tax_identifier'] as String? ?? 'TAX: KRA-PIN-P05123984A',
      orderDate: row['order_date'] as String? ?? '',
      deliveryDate: row['delivery_date'] as String? ?? '',
      status: status,
      customerName: row['customer_name'] as String? ?? 'Walk-in Customer',
      customerPhone: row['customer_phone'] as String? ?? '+254 142 188767',
      assignedStaff: row['assigned_staff'] as String? ?? 'Attendant',
      primaryService: row['primary_service'] as String? ?? 'Wash & Fold',
      vendorBranch:
          row['vendor_branch'] as String? ?? 'Harbor Ridge • Getathuru Road',
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
      case GarmentType.dustTrenchBathrobe:
      case GarmentType.bulkIroning:
        return Icons.checkroom_rounded;
      case GarmentType.denimShorts:
      case GarmentType.jeans:
        return Icons.accessibility_new_rounded;
      case GarmentType.babyClothes:
      case GarmentType.babyBlanketSheers:
        return Icons.child_care_rounded;
      case GarmentType.winterGloves:
      case GarmentType.underGarments:
      case GarmentType.hoodie:
      case GarmentType.generalLaundryLoad:
      case GarmentType.curtains:
      case GarmentType.tableclothsTowels:
      case GarmentType.duvetKingQueen:
      case GarmentType.duvetStandard:
      case GarmentType.woollenBlanket:
      case GarmentType.comfortAndVelvet:
      case GarmentType.largeBedCover:
      case GarmentType.smallBedCover:
      case GarmentType.bedsheets:
      case GarmentType.pillowcase:
        return Icons.wash_rounded;
      case GarmentType.leatherJacket:
      case GarmentType.blueSuitJacket:
      case GarmentType.threePieceSuit:
      case GarmentType.kaundaSuit:
      case GarmentType.kitengeSuit:
      case GarmentType.skirtSuit:
      case GarmentType.religiousClothes:
      case GarmentType.graduationGown:
      case GarmentType.traditionalAttire:
      case GarmentType.weddingGown:
        return Icons.dry_cleaning_rounded;
    }
  }
}
