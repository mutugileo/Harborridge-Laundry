import 'package:flutter/material.dart';

enum DashboardQuickLinkTarget { orders, products, invoices, customer, drivers }

class DashboardKpiMetric {
  const DashboardKpiMetric({
    required this.title,
    required this.value,
    required this.changeBadge,
    required this.isPositive,
    required this.accentColor,
    required this.icon,
    required this.sparklineHeights,
  });

  final String title;
  final String value;
  final String changeBadge;
  final bool isPositive;
  final Color accentColor;
  final IconData icon;
  final List<double> sparklineHeights;
}

class DashboardTopCustomer {
  const DashboardTopCustomer({
    required this.name,
    required this.totalSpent,
    required this.ordersCountLabel,
    required this.growthBadge,
    required this.initials,
    required this.avatarBackground,
    required this.avatarAccent,
  });

  final String name;
  final String totalSpent;
  final String ordersCountLabel;
  final String growthBadge;
  final String initials;
  final Color avatarBackground;
  final Color avatarAccent;
}

class OrderStatisticDayPoint {
  const OrderStatisticDayPoint({
    required this.dayLabel,
    required this.completedRatio,
    required this.pendingRatio,
  });

  final String dayLabel;
  final double completedRatio;
  final double pendingRatio;
}
