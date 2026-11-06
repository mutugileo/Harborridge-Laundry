import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/features/dashboard/domain/dashboard_models.dart';
import 'package:laundry_ridge/features/dashboard/presentation/dashboard_state.dart';

class DashboardNotifier extends Notifier<DashboardUiState> {
  @override
  DashboardUiState build() {
    return const DashboardUiState(
      selectedDateFilter: 'Last 30 days',
      selectedStatsFilter: 'Weekly',
      selectedRevenueFilter: 'Today',
      selectedCustomerIndex: 2,
      activeOrdersCount: 15,
      totalOrdersCount: 4145,
      kpiMetrics: [
        DashboardKpiMetric(
          title: 'Total Revenue',
          value: 'KES 485,740',
          changeBadge: '32%',
          isPositive: true,
          accentColor: Color(0xFF2DA1E7),
          icon: Icons.monetization_on_outlined,
          sparklineHeights: [0.95, 0.55, 0.80, 0.42, 0.35, 0.62],
        ),
        DashboardKpiMetric(
          title: 'Total Orders',
          value: '2,152',
          changeBadge: '12%',
          isPositive: true,
          accentColor: Color(0xFFDCA842),
          icon: Icons.inventory_2_outlined,
          sparklineHeights: [0.92, 0.52, 0.78, 0.40, 0.32, 0.58],
        ),
        DashboardKpiMetric(
          title: 'Total Products',
          value: '459',
          changeBadge: '-21%',
          isPositive: false,
          accentColor: Color(0xFF1FBF75),
          icon: Icons.workspace_premium_outlined,
          sparklineHeights: [0.94, 0.54, 0.82, 0.44, 0.36, 0.60],
        ),
      ],
      topCustomers: [
        DashboardTopCustomer(
          name: 'John Kamau',
          totalSpent: 'KES 48,500',
          ordersCountLabel: '12+ Orders',
          growthBadge: '9%',
          initials: 'JK',
          avatarBackground: Color(0xFF1E3A8A),
          avatarAccent: Color(0xFF93C5FD),
        ),
        DashboardTopCustomer(
          name: 'Moncy James',
          totalSpent: 'KES 74,200',
          ordersCountLabel: '19+ Orders',
          growthBadge: '18%',
          initials: 'MJ',
          avatarBackground: Color(0xFF0F766E),
          avatarAccent: Color(0xFF5EEAD4),
        ),
        DashboardTopCustomer(
          name: 'Anastasia Yesenenko',
          totalSpent: 'KES 38,900',
          ordersCountLabel: '15+ Orders',
          growthBadge: '12%',
          initials: 'AY',
          avatarBackground: Color(0xFFDCA842),
          avatarAccent: Color(0xFF152042),
        ),
        DashboardTopCustomer(
          name: 'Polly Matthews',
          totalSpent: 'KES 41,600',
          ordersCountLabel: '16+ Orders',
          growthBadge: '14%',
          initials: 'PM',
          avatarBackground: Color(0xFF0284C7),
          avatarAccent: Color(0xFFE0F2FE),
        ),
        DashboardTopCustomer(
          name: 'Grace Wanjiku',
          totalSpent: 'KES 62,400',
          ordersCountLabel: '21+ Orders',
          growthBadge: '22%',
          initials: 'GW',
          avatarBackground: Color(0xFF334155),
          avatarAccent: Color(0xFFF8FAFC),
        ),
      ],
      weeklyStatistics: [
        OrderStatisticDayPoint(
          dayLabel: 'Mon',
          completedRatio: 0.68,
          pendingRatio: 0.62,
        ),
        OrderStatisticDayPoint(
          dayLabel: 'Tue',
          completedRatio: 0.52,
          pendingRatio: 0.48,
        ),
        OrderStatisticDayPoint(
          dayLabel: 'Wed',
          completedRatio: 0.86,
          pendingRatio: 0.80,
        ),
        OrderStatisticDayPoint(
          dayLabel: 'Thu',
          completedRatio: 0.50,
          pendingRatio: 0.45,
        ),
        OrderStatisticDayPoint(
          dayLabel: 'Fri',
          completedRatio: 0.51,
          pendingRatio: 0.46,
        ),
        OrderStatisticDayPoint(
          dayLabel: 'Sat',
          completedRatio: 0.50,
          pendingRatio: 0.44,
        ),
      ],
      realtimeRevenueNormalized: [
        0.38,
        0.41,
        0.36,
        0.43,
        0.39,
        0.42,
        0.38,
        0.46,
        0.45,
        0.52,
        0.50,
        0.64,
        0.53,
        0.58,
        0.72,
        0.75,
        0.92,
        0.81,
        0.84,
        0.71,
        0.73,
        0.65,
        0.66,
        0.56,
        0.58,
        0.51,
        0.46,
        0.59,
        0.52,
        0.55,
        0.45,
      ],
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
