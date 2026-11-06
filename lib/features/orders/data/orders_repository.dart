import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/core/supabase/supabase_config.dart';
import 'package:laundry_ridge/core/widgets/garment_line_icon.dart';
import 'package:laundry_ridge/features/orders/data/supabase_orders_repository.dart';
import 'package:laundry_ridge/features/orders/domain/order_addon.dart';
import 'package:laundry_ridge/features/orders/domain/order_detail.dart';
import 'package:laundry_ridge/features/orders/domain/order_item.dart';
import 'package:laundry_ridge/features/orders/domain/order_payment.dart';

abstract class OrdersRepository {
  Future<List<OrderDetail>> fetchOrders();
  Future<OrderDetail> fetchOrderDetail(String orderId);
  Future<void> updateOrderStatus(String orderId, OrderProcessStatus status);
  Future<void> createOrder(OrderDetail order);
}

class MockOrdersRepository implements OrdersRepository {
  static const List<OrderDetail> _orders = [
    OrderDetail(
      orderId: 'LG-2026-00125',
      storeName: 'HARBORRIDGE LAUNDRY',
      storeCode: '123456',
      storeEmail: 'store@store.com',
      storeAddress: 'Nairobi, Kenya - 00100',
      taxIdentifier: 'TAX: KRA-PIN-A01',
      orderDate: '05/11/2026',
      deliveryDate: '06/11/2026',
      status: OrderProcessStatus.washing,
      customerName: 'John Kamau',
      customerPhone: '+254 712 345 678',
      assignedStaff: 'Clara M.',
      primaryService: 'Wash & Fold',
      vendorBranch: 'LaundryGo Nairobi',
      displayAmount: 'KES 1,500',
      paymentStatusLabel: 'Paid',
      processingStageLabel: 'Washing',
      deliveryStatusLabel: 'Pickup assigned',
      deliveryMethod: 'Pickup assigned',
      assignedRider: 'Peter Njoroge',
      createdDateLabel: '05 Nov 2026',
      items: [
        OrderItem(
          index: 1,
          serviceName: 'Shirt',
          serviceType: '[Wash & Fold]',
          rate: 45.00,
          quantity: 4,
          icon: Icons.checkroom_rounded,
          garmentType: GarmentType.shirt,
        ),
        OrderItem(
          index: 2,
          serviceName: 'Jeans',
          serviceType: '[Wash & Fold]',
          rate: 60.00,
          quantity: 3,
          icon: Icons.accessibility_new_rounded,
          garmentType: GarmentType.jeans,
        ),
        OrderItem(
          index: 3,
          serviceName: 'Pullover Hoodie',
          serviceType: '[Wash & Fold]',
          rate: 38.00,
          quantity: 2,
          icon: Icons.wash_rounded,
          garmentType: GarmentType.hoodie,
        ),
      ],
      addons: [OrderAddon(name: 'Fabric Softener', amount: 15.00)],
      payments: [
        OrderPayment(amount: 451.00, date: '05/11/2026', method: '[M-PESA]'),
      ],
    ),
    OrderDetail(
      orderId: '#ORD-0006',
      storeName: 'HARBORRIDGE LAUNDRY',
      storeCode: '123456',
      storeEmail: 'store@store.com',
      storeAddress: 'address - 691001',
      taxIdentifier: 'TAX: TAX@TAX',
      orderDate: '26/02/2022',
      deliveryDate: '28/02/2022',
      status: OrderProcessStatus.processing,
      customerName: 'Moncy James',
      customerPhone: '+254 722 891 023',
      assignedStaff: 'Clara M.',
      primaryService: 'Wash & Iron',
      vendorBranch: 'Harborridge Kilimani',
      displayAmount: 'KES 3,850',
      paymentStatusLabel: 'Partial',
      processingStageLabel: 'Processing',
      deliveryStatusLabel: 'Doorstep delivery',
      deliveryMethod: 'Doorstep delivery',
      assignedRider: 'David Mwangi',
      createdDateLabel: '05 Nov 2026',
      items: [
        OrderItem(
          index: 1,
          serviceName: 'Baby Cloths',
          serviceType: '[Wet Wash]',
          rate: 10.00,
          quantity: 2,
          icon: Icons.child_care_rounded,
          garmentType: GarmentType.babyClothes,
        ),
        OrderItem(
          index: 2,
          serviceName: 'Womens Top',
          serviceType: '[Wash & Iron]',
          rate: 25.00,
          quantity: 3,
          icon: Icons.checkroom_rounded,
          garmentType: GarmentType.womensTop,
        ),
        OrderItem(
          index: 3,
          serviceName: 'Womens Dress',
          serviceType: '[Dry Cleaning]',
          rate: 100.00,
          quantity: 2,
          icon: Icons.dry_cleaning_rounded,
          garmentType: GarmentType.womensDress,
        ),
        OrderItem(
          index: 4,
          serviceName: 'Jeans',
          serviceType: '[Wash & Iron]',
          rate: 60.00,
          quantity: 5,
          icon: Icons.accessibility_new_rounded,
          garmentType: GarmentType.jeans,
        ),
        OrderItem(
          index: 5,
          serviceName: 'Under Garments',
          serviceType: '[Wash & Fold]',
          rate: 20.00,
          quantity: 6,
          icon: Icons.wash_rounded,
          garmentType: GarmentType.underGarments,
        ),
        OrderItem(
          index: 6,
          serviceName: 'Shirt',
          serviceType: '[Wash & Iron]',
          rate: 45.00,
          quantity: 3,
          icon: Icons.iron_rounded,
          garmentType: GarmentType.shirt,
        ),
      ],
      addons: [
        OrderAddon(name: 'Stain Removal', amount: 30.00),
        OrderAddon(name: 'Extra Fragrance', amount: 10.00),
      ],
      payments: [
        OrderPayment(amount: 350.00, date: '26/02/2022', method: '[CASH]'),
      ],
    ),
    OrderDetail(
      orderId: 'LG-2026-00126',
      storeName: 'HARBORRIDGE LAUNDRY',
      storeCode: '123456',
      storeEmail: 'store@store.com',
      storeAddress: 'Westlands, Nairobi',
      taxIdentifier: 'TAX: KRA-PIN-A01',
      orderDate: '04/11/2026',
      deliveryDate: '05/11/2026',
      status: OrderProcessStatus.cleaning,
      customerName: 'Grace Wanjiku',
      customerPhone: '+254 733 482 190',
      assignedStaff: 'Marcus T.',
      primaryService: 'Dry Cleaning',
      vendorBranch: 'Harborridge Westlands',
      displayAmount: 'KES 2,800',
      paymentStatusLabel: 'Paid',
      processingStageLabel: 'Cleaning',
      deliveryStatusLabel: 'Rider en route',
      deliveryMethod: 'Express rider',
      assignedRider: 'Samuel Otieno',
      createdDateLabel: '04 Nov 2026',
      items: [
        OrderItem(
          index: 1,
          serviceName: 'Tailored Blazer',
          serviceType: '[Dry Cleaning]',
          rate: 85.00,
          quantity: 1,
          icon: Icons.checkroom_rounded,
          garmentType: GarmentType.tanBlazer,
        ),
        OrderItem(
          index: 2,
          serviceName: 'Shirt',
          serviceType: '[Wash & Iron]',
          rate: 45.00,
          quantity: 2,
          icon: Icons.iron_rounded,
          garmentType: GarmentType.shirt,
        ),
        OrderItem(
          index: 3,
          serviceName: 'Tailored Trousers',
          serviceType: '[Wash & Iron]',
          rate: 40.00,
          quantity: 2,
          icon: Icons.checkroom_rounded,
          garmentType: GarmentType.trousers,
        ),
      ],
      addons: [OrderAddon(name: 'Express Turnaround', amount: 25.00)],
      payments: [
        OrderPayment(amount: 280.00, date: '04/11/2026', method: '[CARD]'),
      ],
    ),
    OrderDetail(
      orderId: 'LG-2026-00127',
      storeName: 'HARBORRIDGE LAUNDRY',
      storeCode: '123456',
      storeEmail: 'store@store.com',
      storeAddress: 'Nairobi CBD',
      taxIdentifier: 'TAX: KRA-PIN-A01',
      orderDate: '04/11/2026',
      deliveryDate: '06/11/2026',
      status: OrderProcessStatus.ironing,
      customerName: 'Polly Matthews',
      customerPhone: '+254 711 391 044',
      assignedStaff: 'Devon R.',
      primaryService: 'Dry Cleaning',
      vendorBranch: 'Ridge Eco-Cleaners',
      displayAmount: 'KES 3,200',
      paymentStatusLabel: 'Unpaid',
      processingStageLabel: 'Ironing',
      deliveryStatusLabel: 'Branch drop-off',
      deliveryMethod: 'Branch drop-off',
      assignedRider: 'Kelvin Kiprop',
      createdDateLabel: '04 Nov 2026',
      items: [
        OrderItem(
          index: 1,
          serviceName: 'Biker Jacket',
          serviceType: '[Dry Cleaning]',
          rate: 110.00,
          quantity: 1,
          icon: Icons.dry_cleaning_rounded,
          garmentType: GarmentType.leatherJacket,
        ),
        OrderItem(
          index: 2,
          serviceName: 'Cashmere Scarf',
          serviceType: '[Dry Cleaning]',
          rate: 28.00,
          quantity: 2,
          icon: Icons.checkroom_rounded,
          garmentType: GarmentType.scarfOnHanger,
        ),
        OrderItem(
          index: 3,
          serviceName: 'Winter Gloves',
          serviceType: '[Wet Wash]',
          rate: 15.00,
          quantity: 2,
          icon: Icons.wash_rounded,
          garmentType: GarmentType.winterGloves,
        ),
      ],
      addons: [OrderAddon(name: 'Leather Conditioning', amount: 35.00)],
      payments: [],
    ),
    OrderDetail(
      orderId: 'LG-2026-00128',
      storeName: 'HARBORRIDGE LAUNDRY',
      storeCode: '123456',
      storeEmail: 'store@store.com',
      storeAddress: 'Nairobi, Kenya',
      taxIdentifier: 'TAX: KRA-PIN-A01',
      orderDate: '03/11/2026',
      deliveryDate: '05/11/2026',
      status: OrderProcessStatus.completed,
      customerName: 'David Ochieng',
      customerPhone: '+254 790 619 773',
      assignedStaff: 'Elena K.',
      primaryService: 'Wash & Iron',
      vendorBranch: 'LaundryGo Nairobi',
      displayAmount: 'KES 1,950',
      paymentStatusLabel: 'Paid',
      processingStageLabel: 'Completed',
      deliveryStatusLabel: 'Doorstep delivery',
      deliveryMethod: 'Doorstep delivery',
      assignedRider: 'Peter Njoroge',
      createdDateLabel: '03 Nov 2026',
      items: [
        OrderItem(
          index: 1,
          serviceName: 'Summer Sundress',
          serviceType: '[Wash & Iron]',
          rate: 55.00,
          quantity: 2,
          icon: Icons.checkroom_rounded,
          garmentType: GarmentType.camisoleDress,
        ),
        OrderItem(
          index: 2,
          serviceName: 'Pocket Shirt Dress',
          serviceType: '[Wash & Iron]',
          rate: 65.00,
          quantity: 1,
          icon: Icons.checkroom_rounded,
          garmentType: GarmentType.shirtDress,
        ),
        OrderItem(
          index: 3,
          serviceName: 'Pleated Halter Top',
          serviceType: '[Wash & Iron]',
          rate: 22.00,
          quantity: 3,
          icon: Icons.checkroom_rounded,
          garmentType: GarmentType.halterTop,
        ),
      ],
      addons: [OrderAddon(name: 'Extra Fragrance', amount: 10.00)],
      payments: [
        OrderPayment(amount: 251.00, date: '03/11/2026', method: '[M-PESA]'),
      ],
    ),
    OrderDetail(
      orderId: 'LG-2026-00129',
      storeName: 'HARBORRIDGE LAUNDRY',
      storeCode: '123456',
      storeEmail: 'store@store.com',
      storeAddress: 'Kilimani, Nairobi',
      taxIdentifier: 'TAX: KRA-PIN-A01',
      orderDate: '03/11/2026',
      deliveryDate: '04/11/2026',
      status: OrderProcessStatus.delivered,
      customerName: 'Emma Davis',
      customerPhone: '+254 720 890 331',
      assignedStaff: 'Clara M.',
      primaryService: 'Wet Wash',
      vendorBranch: 'Harborridge Kilimani',
      displayAmount: 'KES 2,140',
      paymentStatusLabel: 'Paid',
      processingStageLabel: 'Delivered',
      deliveryStatusLabel: 'Delivered',
      deliveryMethod: 'Pickup assigned',
      assignedRider: 'David Mwangi',
      createdDateLabel: '03 Nov 2026',
      items: [
        OrderItem(
          index: 1,
          serviceName: 'Suit Jacket',
          serviceType: '[Dry Cleaning]',
          rate: 80.00,
          quantity: 2,
          icon: Icons.dry_cleaning_rounded,
          garmentType: GarmentType.blueSuitJacket,
        ),
        OrderItem(
          index: 2,
          serviceName: 'Silk Bow Tie',
          serviceType: '[Wet Wash]',
          rate: 12.00,
          quantity: 2,
          icon: Icons.checkroom_rounded,
          garmentType: GarmentType.bowTie,
        ),
        OrderItem(
          index: 3,
          serviceName: 'Fedora Hat',
          serviceType: '[Dry Cleaning]',
          rate: 30.00,
          quantity: 1,
          icon: Icons.checkroom_rounded,
          garmentType: GarmentType.fedoraHat,
        ),
      ],
      addons: [],
      payments: [
        OrderPayment(amount: 214.00, date: '03/11/2026', method: '[CARD]'),
      ],
    ),
  ];

  @override
  Future<List<OrderDetail>> fetchOrders() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _orders;
  }

  @override
  Future<OrderDetail> fetchOrderDetail(String orderId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _orders.firstWhere(
      (order) => order.orderId == orderId,
      orElse: () => _orders[1],
    );
  }

  @override
  Future<void> updateOrderStatus(
    String orderId,
    OrderProcessStatus status,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> createOrder(OrderDetail order) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client != null) {
    return SupabaseOrdersRepository(client);
  }
  return MockOrdersRepository();
});
