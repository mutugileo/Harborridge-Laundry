import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/features/dashboard/domain/dashboard_models.dart';
import 'package:laundry_ridge/features/dashboard/presentation/dashboard_state.dart';
import 'package:laundry_ridge/features/orders/domain/order_detail.dart';
import 'package:laundry_ridge/features/orders/presentation/order_details_notifier.dart';

class DashboardNotifier extends Notifier<DashboardUiState> {
  @override
  DashboardUiState build() {
    final ordersState = ref.watch(orderDetailsNotifierProvider);
    final orders = ordersState.orders;

    final activeOrders = orders
        .where((o) => o.status != OrderProcessStatus.delivered)
        .length;
    final totalOrders = orders.length;
    final totalRevenue = orders
        .fold<double>(0.0, (sum, o) => sum + o.paidAmount)
        .round();

    final customerSpending = <String, double>{};
    final customerOrderCounts = <String, int>{};
    for (final order in orders) {
      customerSpending[order.customerName] =
          (customerSpending[order.customerName] ?? 0.0) + order.paidAmount;
      customerOrderCounts[order.customerName] =
          (customerOrderCounts[order.customerName] ?? 0) + 1;
    }

    final sortedCustomers = customerSpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCustomers = sortedCustomers.take(5).map((entry) {
      final name = entry.key;
      final spent = entry.value.round();
      final count = customerOrderCounts[name] ?? 1;
      final initials = name
          .split(' ')
          .map((p) => p.isNotEmpty ? p[0] : '')
          .take(2)
          .join();
      return DashboardTopCustomer(
        name: name,
        totalSpent: 'KES $spent',
        ordersCountLabel: '$count Orders',
        growthBadge: '100%',
        initials: initials.isEmpty ? 'C' : initials,
        avatarBackground: const Color(0xFF1E3A8A),
        avatarAccent: const Color(0xFF93C5FD),
      );
    }).toList();

    return DashboardUiState(
      selectedDateFilter: 'Last 30 days',
      selectedStatsFilter: 'Weekly',
      selectedRevenueFilter: 'Today',
      selectedCustomerIndex: 0,
      activeOrdersCount: activeOrders,
      totalOrdersCount: totalOrders,
      kpiMetrics: [
        DashboardKpiMetric(
          title: 'Total Revenue',
          value: 'KES $totalRevenue',
          changeBadge: totalRevenue > 0 ? '+100%' : '0%',
          isPositive: totalRevenue > 0,
          accentColor: const Color(0xFF2DA1E7),
          icon: Icons.monetization_on_outlined,
          sparklineHeights: totalRevenue > 0
              ? const [0.2, 0.4, 0.6, 0.8, 1.0, 0.9]
              : const [0.1, 0.1, 0.1, 0.1, 0.1, 0.1],
        ),
        DashboardKpiMetric(
          title: 'Total Orders',
          value: '$totalOrders',
          changeBadge: totalOrders > 0 ? '+$totalOrders' : '0',
          isPositive: totalOrders > 0,
          accentColor: const Color(0xFFDCA842),
          icon: Icons.inventory_2_outlined,
          sparklineHeights: totalOrders > 0
              ? const [0.3, 0.5, 0.7, 0.8, 0.9, 1.0]
              : const [0.1, 0.1, 0.1, 0.1, 0.1, 0.1],
        ),
        DashboardKpiMetric(
          title: 'Active Wash Queue',
          value: '$activeOrders',
          changeBadge: activeOrders > 0 ? 'Live' : 'Clear',
          isPositive: true,
          accentColor: const Color(0xFF1FBF75),
          icon: Icons.workspace_premium_outlined,
          sparklineHeights: activeOrders > 0
              ? const [0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
              : const [0.1, 0.1, 0.1, 0.1, 0.1, 0.1],
        ),
      ],
      topCustomers: topCustomers,
      weeklyStatistics: const [
        OrderStatisticDayPoint(
          dayLabel: 'Mon',
          completedRatio: 0.0,
          pendingRatio: 0.0,
        ),
        OrderStatisticDayPoint(
          dayLabel: 'Tue',
          completedRatio: 0.0,
          pendingRatio: 0.0,
        ),
        OrderStatisticDayPoint(
          dayLabel: 'Wed',
          completedRatio: 0.0,
          pendingRatio: 0.0,
        ),
        OrderStatisticDayPoint(
          dayLabel: 'Thu',
          completedRatio: 0.0,
          pendingRatio: 0.0,
        ),
        OrderStatisticDayPoint(
          dayLabel: 'Fri',
          completedRatio: 0.0,
          pendingRatio: 0.0,
        ),
        OrderStatisticDayPoint(
          dayLabel: 'Sat',
          completedRatio: 0.0,
          pendingRatio: 0.0,
        ),
      ],
      realtimeRevenueNormalized: const [0.1, 0.1, 0.1, 0.1, 0.1],
    );
  }

  void selectDateFilter(String filter) {
    state = state.copyWith(selectedDateFilter: filter, clearFeedback: true);
  }

  void selectStatsFilter(String filter) {
    state = state.copyWith(selectedStatsFilter: filter, clearFeedback: true);
  }

  void selectRevenueFilter(String filter) {
    state = state.copyWith(selectedRevenueFilter: filter, clearFeedback: true);
  }

  void selectTopCustomer(int index) {
    state = state.copyWith(selectedCustomerIndex: index, clearFeedback: true);
  }

  void triggerDashboardAction(String message) {
    state = state.copyWith(feedbackMessage: message);
  }
}

final dashboardNotifierProvider =
    NotifierProvider<DashboardNotifier, DashboardUiState>(
      DashboardNotifier.new,
    );
