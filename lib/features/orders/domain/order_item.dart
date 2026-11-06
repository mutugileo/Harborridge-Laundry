import 'package:flutter/widgets.dart';
import 'package:laundry_ridge/core/widgets/garment_line_icon.dart';

class OrderItem {
  const OrderItem({
    required this.index,
    required this.serviceName,
    required this.serviceType,
    required this.rate,
    required this.quantity,
    required this.icon,
    required this.garmentType,
  });

  final int index;
  final String serviceName;
  final String serviceType;
  final double rate;
  final int quantity;
  final IconData icon;
  final GarmentType garmentType;

  double get total => rate * quantity;
}
