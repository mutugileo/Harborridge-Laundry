import 'package:flutter/widgets.dart';

enum ServiceCategory { all, washAndFold, dryCleaning, ironing, bedding }

class LaundryService {
  const LaundryService({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.estimatedTurnaroundHours,
    required this.unitPrice,
    required this.unitLabel,
    required this.icon,
  });

  final String id;
  final String title;
  final String description;
  final ServiceCategory category;
  final int estimatedTurnaroundHours;
  final double unitPrice;
  final String unitLabel;
  final IconData icon;
}
