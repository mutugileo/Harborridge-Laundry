import 'dart:typed_data';

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
    this.imageUrl,
    this.imageBytes,
    this.weightKg,
  });

  final int index;
  final String serviceName;
  final String serviceType;
  final double rate;
  final int quantity;
  final IconData icon;
  final GarmentType garmentType;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final double? weightKg;

  double get total =>
      weightKg != null && weightKg! > 0 ? rate * weightKg! : rate * quantity;

  OrderItem copyWith({
    int? index,
    String? serviceName,
    String? serviceType,
    double? rate,
    int? quantity,
    IconData? icon,
    GarmentType? garmentType,
    String? imageUrl,
    Uint8List? imageBytes,
    double? weightKg,
  }) {
    return OrderItem(
      index: index ?? this.index,
      serviceName: serviceName ?? this.serviceName,
      serviceType: serviceType ?? this.serviceType,
      rate: rate ?? this.rate,
      quantity: quantity ?? this.quantity,
      icon: icon ?? this.icon,
      garmentType: garmentType ?? this.garmentType,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBytes: imageBytes ?? this.imageBytes,
      weightKg: weightKg ?? this.weightKg,
    );
  }
}
